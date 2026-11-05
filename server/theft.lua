--[[
    Server-authoritative theft sessions.
    begin -> stage 1..n (each timed + tool-checked) -> finish (loot rolled here, never on the client)
]]
local Shared = require 'shared.utils'
local Bridge = require 'server.bridge'
local Rep = require 'server.rep'
local Loot = require 'server.loot'
local World = require 'server.world'

local config = Shared.config
local profiles = Shared.profiles
local sec = config.Security
local fallbackHash = joaat(config.FallbackProp)

local sessions = {}    -- [src] = active session
local recent = {}      -- [src] = just-finished session (debris can still be registered for a few seconds)
local locks = {}       -- [targetKey] = src
local lastFinish = {}
local stripped = {}    -- [spotId] = stripped world object

local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end
local function playerCoords(src) return GetEntityCoords(GetPlayerPed(src)) end

---------------------------------------------------------------------------
-- Stripped world objects (synced to clients through GlobalState)
---------------------------------------------------------------------------
local function publishSpots()
    local out = {}
    for id, s in pairs(stripped) do
        out[id] = { model = s.model, coords = s.coords, heading = s.heading, swap = s.swap, hide = s.hide }
    end
    GlobalState['thief:spots'] = out
end
publishSpots()

CreateThread(function()
    while true do
        Wait(30000)
        local now, changed = os.time(), false
        for id, s in pairs(stripped) do
            if now >= s.expires then
                stripped[id] = nil
                changed = true
            end
        end
        if changed then publishSpots() end
    end
end)

---------------------------------------------------------------------------
-- Tools
---------------------------------------------------------------------------
local function findTool(src, toolId)
    local tool = config.Tools[toolId]
    if not tool then return { free = true } end

    local best
    for _, name in ipairs(tool.items) do
        local slots = exports.ox_inventory:Search(src, 'slots', name)
        for _, slot in pairs(slots or {}) do
            local durability = (slot.metadata and slot.metadata.durability) or 100
            if durability > 0 and (not best or durability > best.durability) then
                best = { name = name, slot = slot.slot, durability = durability }
            end
        end
    end
    return best
end

local function useTool(src, toolId)
    local tool = config.Tools[toolId]
    if not tool then return true end

    local best = findTool(src, toolId)
    if not best then return false end

    if (tool.wear or 0) > 0 then
        local left = best.durability - tool.wear
        if left <= 0 then
            exports.ox_inventory:RemoveItem(src, best.name, 1, nil, best.slot)
            Bridge.notify(src, locale('tool_broke', tool.label), 'error')
        else
            exports.ox_inventory:SetDurability(src, best.slot, left)
        end
    end
    return true
end

---------------------------------------------------------------------------
-- Loot
---------------------------------------------------------------------------
local function itemLabel(item)
    local data = exports.ox_inventory:Items(item)
    return data and data.label or item
end

local function rollLoot(profile, ctx)
    local entries, bundle = {}, {}

    local function add(l, item)
        if l.model then
            entries[#entries + 1] = {
                items = { item },
                label = l.label or itemLabel(l.item),
                model = l.model == 'source' and ctx.sourceModel or l.model,
                carry = l.carry,
                attach = l.attach,
            }
        else
            bundle[#bundle + 1] = item
        end
    end

    for _, l in ipairs(profile.loot) do
        if math.random() <= (l.chance or 1.0) then
            local count = math.max(1, math.floor(math.random(l.count[1], l.count[2]) * (ctx.lootMult or 1.0) + 0.5))
            if l.value then
                -- Valued parts are unique pieces: one prop / one inventory item each.
                for _ = 1, count do
                    add(l, {
                        item = l.item,
                        count = 1,
                        metadata = {
                            value = math.floor(math.random(l.value[1], l.value[2]) * ctx.mult),
                            description = ctx.description,
                        },
                    })
                end
            else
                add(l, { item = l.item, count = count })
            end
        end
    end

    if #bundle > 0 then
        entries[#entries + 1] = {
            items = bundle,
            label = profile.bundle and profile.bundle.label or profile.label,
            model = profile.bundle and profile.bundle.model,
        }
    end

    return entries
end

---------------------------------------------------------------------------
-- Sessions
---------------------------------------------------------------------------
local function endSession(src)
    local s = sessions[src]
    if not s then return end
    if s.key then locks[s.key] = nil end
    sessions[src] = nil
end

local function targetCoords(s)
    if s.coords then return s.coords end
    local ent = s.vehicle or s.ped
    return ent and DoesEntityExist(ent) and GetEntityCoords(ent) or nil
end

local function finish(src, s)
    local profile = s.profile
    local where = targetCoords(s) or playerCoords(src)
    local tipped = World.tipApplies(profile.id, where)
    local ctx = { mult = 1.0, lootMult = tipped and config.World.tips.lootMultiplier or 1.0 }

    if profile.kind == 'prop' then
        stripped[s.key] = {
            model = s.model,
            coords = s.coords,
            heading = s.heading,
            swap = profile.swapHashes and profile.swapHashes[s.model],
            hide = profile.hide,
            expires = os.time() + (profile.respawn or 30) * 60,
        }
        publishSpots()
        ctx.sourceModel = s.model
    elseif profile.kind == 'ped' then
        if DoesEntityExist(s.ped) then Entity(s.ped).state:set('thief:robbed', true, true) end
    else
        local state = Entity(s.vehicle).state
        if profile.part == 'wheel' then
            local wheels = state['thief:wheels'] or {}
            wheels[tostring(s.wheel)] = true
            state:set('thief:wheels', wheels, true)
        elseif profile.part == 'glovebox' then
            state:set('thief:glovebox', s.window or 0, true)
        else
            state:set('thief:' .. profile.part, true, true)
        end
        ctx.mult = config.Vehicles.tierByHash[s.vehModel] or 1.0
        ctx.description = locale('loot_vehicle_desc', s.vehLabel or 'vehicle', s.plate)
    end

    local queued, pocketed = {}, {}
    for _, entry in ipairs(rollLoot(profile, ctx)) do
        local direct = profile.directLoot and not entry.carry
        if direct and Loot.canCarryAll(src, entry.items) then
            Loot.giveAll(src, entry.items)
            for _, it in ipairs(entry.items) do
                pocketed[#pocketed + 1] = ('%dx %s'):format(it.count, itemLabel(it.item))
            end
        else
            local id = Loot.queue(src, entry)
            queued[#queued + 1] = { id = id, model = entry.modelHash, carry = entry.carry or false }
        end
    end

    -- Rep: less for working the same patch, more for following the tip.
    local repeatMult, repeated = World.repetition(src, where)
    local amount = (profile.rep or 1) * repeatMult * (tipped and config.World.tips.repMultiplier or 1.0)
    local xp = Rep.add(src, math.max(0, math.floor(amount + 0.5)))
    local areaHeat = World.add(where, profile.heat or 1)

    lastFinish[src] = os.time()
    endSession(src)
    recent[src] = { token = s.token, profile = profile, expires = os.time() + 30 }

    lib.print.debug(('%s finished %s (%d drops, %d pocketed, area heat %d)'):format(src, profile.id, #queued, #pocketed, areaHeat))
    return {
        loot = queued,
        pocketed = pocketed,
        xp = xp,
        repeated = repeated,
        tipped = tipped,
        areaHeat = areaHeat,
        maxHeat = config.World.maxHeat,
    }
end

lib.callback.register('cr-thief:begin', function(source, profileId, target)
    local profile = profiles[profileId]
    if not profile or type(target) ~= 'table' then return false end

    local current = sessions[source]
    if current then
        if os.time() - current.started < 300 then return false, 'busy' end
        endSession(source)
    end

    if Loot.isCarrying(source) then return false, 'hands_full' end
    if lastFinish[source] and os.time() - lastFinish[source] < sec.minGap then return false, 'slow_down' end
    if (profile.minCops or 0) > 0 and Bridge.policeCount() < profile.minCops then return false, 'no_cops' end

    for _, toolId in ipairs(Shared.profileTools(profile)) do
        if not findTool(source, toolId) then return false, 'missing_tool', config.Tools[toolId].label end
    end

    local pcoords = playerCoords(source)
    local s = {
        profile = profile,
        stage = 0,
        started = os.time(),
        stageStart = GetGameTimer(),
        token = math.random(1, 2147483647),
    }

    if profile.kind == 'prop' then
        local model, coords = tonumber(target.model), target.coords
        if not model or not profile.modelHashes[model] or type(coords) ~= 'vector3' then return false end
        if #(pcoords - coords) > sec.maxDistance then return false, 'too_far' end

        s.key = Shared.spotId(model, coords)
        if stripped[s.key] then return false, 'already_stripped' end
        s.model, s.coords, s.heading = model, coords, tonumber(target.heading) or 0.0
    elseif profile.kind == 'ped' then
        local netId = tonumber(target.netId) or 0
        local ped = NetworkGetEntityFromNetworkId(netId)
        if ped == 0 or not DoesEntityExist(ped) or GetEntityType(ped) ~= 1 or IsPedAPlayer(ped) then return false end
        if #(pcoords - GetEntityCoords(ped)) > 3.5 then return false, 'too_far' end
        if Entity(ped).state['thief:robbed'] then return false, 'already_stripped' end
        s.key, s.ped = ('ped:%d'):format(netId), ped
    else
        local netId = tonumber(target.netId) or 0
        local veh = NetworkGetEntityFromNetworkId(netId)
        if veh == 0 or not DoesEntityExist(veh) or GetEntityType(veh) ~= 2 then return false end
        if GetVehicleType(veh) ~= 'automobile' then return false, 'bad_vehicle' end

        local model = GetEntityModel(veh)
        if config.Vehicles.blacklistHashes[model] then return false, 'bad_vehicle' end
        if GetPedInVehicleSeat(veh, -1) ~= 0 then return false, 'occupied' end
        if #(pcoords - GetEntityCoords(veh)) > sec.maxDistance then return false, 'too_far' end

        local state = Entity(veh).state
        if profile.part == 'cat' then
            if config.Vehicles.electricHashes[model] then return false, 'no_cat' end
            if state['thief:cat'] then return false, 'already_stripped' end
            s.key = ('cat:%d'):format(netId)
        elseif profile.part == 'wheel' then
            local wheel = tonumber(target.wheel)
            if not wheel or wheel < 0 or wheel > 3 then return false end
            if (state['thief:wheels'] or {})[tostring(wheel)] then return false, 'already_stripped' end
            s.key = ('wheel:%d:%d'):format(netId, wheel)
            s.wheel = wheel
        else
            local key = 'thief:' .. profile.part
            if state[key] ~= nil then return false, 'already_stripped' end
            s.key = ('%s:%d'):format(profile.part, netId)
            s.window = math.floor(tonumber(target.window) or 0) == 1 and 1 or 0
        end

        local plate = trim(GetVehicleNumberPlateText(veh))
        if Bridge.isOwnedPlate(plate) then return false, 'owned_vehicle' end

        s.vehicle, s.netId, s.plate, s.vehModel = veh, netId, plate, model
        s.vehLabel = type(target.label) == 'string' and target.label:sub(1, 32) or nil
    end

    if locks[s.key] then return false, 'in_use' end

    local where = targetCoords(s) or pcoords
    if World.locked(where) then return false, 'area_locked' end

    locks[s.key] = source

    local _, level = Rep.level(source)
    s.speed = level.speed
    sessions[source] = s

    return true, s.token, {
        speed = s.speed,
        heatMult = World.multiplier(where),
        tipped = World.tipApplies(profile.id, where),
    }
end)

lib.callback.register('cr-thief:stage', function(source, token, index)
    local s = sessions[source]
    if not s or s.token ~= token or index ~= s.stage + 1 then return false end

    local stage = s.profile.stages[index]
    if not stage then return false end

    local now = GetGameTimer()
    local minTime = stage.duration * s.speed * sec.timingTolerance
    if now - s.stageStart < minTime then
        lib.print.warn(('%s completed stage %d of %s too fast (%dms < %dms)'):format(source, index, s.profile.id, now - s.stageStart, minTime))
        endSession(source)
        return false, 'too_fast'
    end

    local where = targetCoords(s)
    if not where or #(playerCoords(source) - where) > sec.maxDistance then
        endSession(source)
        return false, 'too_far'
    end

    if s.vehicle and GetPedInVehicleSeat(s.vehicle, -1) ~= 0 then
        endSession(source)
        return false, 'occupied'
    end

    if stage.tool and not useTool(source, stage.tool) then
        endSession(source)
        return false, 'missing_tool', config.Tools[stage.tool].label
    end

    s.stage = index
    s.stageStart = now

    if index < #s.profile.stages then return true end
    return true, finish(source, s)
end)

lib.callback.register('cr-thief:cancel', function(source, token)
    local s = sessions[source]
    if s and s.token == token then endSession(source) end
    return true
end)

---Debris (dropped panels, cinder blocks) and temporary props (car jack) spawned by the client.
lib.callback.register('cr-thief:registerDebris', function(source, token, netId, temporary)
    local s = sessions[source]
    if not s or s.token ~= token then
        s = recent[source]
        if not s or s.token ~= token or os.time() > s.expires then return false end
    end

    local obj = Loot.waitForEntity(netId)
    if not obj then return false end

    local model = GetEntityModel(obj)
    local allowed = model == fallbackHash
    for _, stage in ipairs(s.profile.stages) do
        if (stage.debris and Shared.hash(stage.debris.model) == model)
            or (stage.place and Shared.hash(stage.place.model) == model) then
            allowed = true
        end
    end

    if not allowed or #(playerCoords(source) - GetEntityCoords(obj)) > 15.0 then
        DeleteEntity(obj)
        return false
    end

    Loot.trackDebris(obj, temporary and 5 or (s.profile.respawn or 30))
    return true
end)

AddEventHandler('playerDropped', function()
    endSession(source)
    recent[source] = nil
    lastFinish[source] = nil
end)
