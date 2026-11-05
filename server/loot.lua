--[[
    Physical loot: every reward is a networked prop in the world first.
    The client spawns it (so it can fall with physics and fall back to a safe model),
    then registers the net id here. Only registered props can be picked up.
]]
local Shared = require 'shared.utils'

local config = Shared.config
local fallbackHash = joaat(config.FallbackProp)

local Loot = {}

local entities = {}  -- [netId] = entry (registered loot lying in the world)
local pending = {}   -- [src] = { [id] = entry } (waiting for the client to spawn the prop)
local carrying = {}  -- [src] = entry
local debris = {}    -- [netId] = { entity, expires }
local nextId = 0

local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end

local function waitForEntity(netId)
    for _ = 1, 30 do
        local ent = NetworkGetEntityFromNetworkId(netId)
        if ent ~= 0 and DoesEntityExist(ent) then return ent end
        Wait(50)
    end
end

local function near(src, coords, dist)
    return #(GetEntityCoords(GetPlayerPed(src)) - coords) <= dist
end

local function canCarryAll(src, items)
    for _, it in ipairs(items) do
        if not exports.ox_inventory:CanCarryItem(src, it.item, it.count, it.metadata) then return false end
    end
    return true
end

local function giveAll(inv, items)
    local given = 0
    for _, it in ipairs(items) do
        if exports.ox_inventory:AddItem(inv, it.item, it.count, it.metadata) then given += 1 end
    end
    return given
end

local function setCarry(src, entry)
    carrying[src] = entry
    Player(src).state:set('scrap:carry', entry and {
        label = entry.label,
        model = entry.modelHash,
        attach = entry.attach,
    } or nil, true)
end

local function track(obj, entry)
    local netId = NetworkGetNetworkIdFromEntity(obj)
    SetEntityOrphanMode(obj, 2)
    entry.entity = obj
    entry.expires = os.time() + config.Loot.lifetime * 60
    entities[netId] = entry
    Entity(obj).state:set('scrap:loot', { label = entry.label, carry = entry.carry or false }, true)
    return netId
end

---Queue a loot entry for the client to spawn.
---entry = { items = { {item, count, metadata} }, label, model, carry, attach }
---@return integer id
function Loot.queue(src, entry)
    nextId += 1
    local id = nextId
    entry.modelHash = Shared.hash(entry.model or config.FallbackProp)
    pending[src] = pending[src] or {}
    pending[src][id] = entry

    -- If the client never spawns it (crash, lag), don't let the player lose the goods.
    SetTimeout(20000, function()
        local list = pending[src]
        if not list or not list[id] then return end
        list[id] = nil
        if GetPlayerPing(src) > 0 then
            giveAll(src, entry.items)
            lib.print.warn(('loot %d for %s was never spawned, given directly'):format(id, src))
        end
    end)

    return id
end

function Loot.trackDebris(obj, minutes)
    SetEntityOrphanMode(obj, 2)
    debris[NetworkGetNetworkIdFromEntity(obj)] = { entity = obj, expires = os.time() + minutes * 60 }
end

function Loot.isCarrying(src) return carrying[src] ~= nil end

lib.callback.register('cr-scraptheft:registerLoot', function(source, id, netId)
    local list = pending[source]
    local entry = list and list[id]
    if not entry or type(netId) ~= 'number' then return false end

    local obj = waitForEntity(netId)
    if not obj then return false end

    local model = GetEntityModel(obj)
    if (model ~= entry.modelHash and model ~= fallbackHash) or not near(source, GetEntityCoords(obj), 12.0) then
        lib.print.warn(('%s registered an invalid loot entity (model %s)'):format(source, model))
        return false
    end

    list[id] = nil
    entry.modelHash = model
    track(obj, entry)
    return true
end)

lib.callback.register('cr-scraptheft:pickup', function(source, netId)
    local entry = entities[netId]
    if not entry or not DoesEntityExist(entry.entity) then return false end
    if carrying[source] then return false, 'already_carrying' end
    if not near(source, GetEntityCoords(entry.entity), 3.5) then return false end

    if entry.carry then
        entities[netId] = nil
        DeleteEntity(entry.entity)
        setCarry(source, entry)
        return true, 'carry'
    end

    if not canCarryAll(source, entry.items) then return false, 'too_heavy' end
    entities[netId] = nil
    DeleteEntity(entry.entity)
    giveAll(source, entry.items)
    return true
end)

lib.callback.register('cr-scraptheft:drop', function(source)
    local entry = carrying[source]
    if not entry then return end
    setCarry(source, nil)
    return { id = Loot.queue(source, entry), model = entry.modelHash }
end)

lib.callback.register('cr-scraptheft:stow', function(source, vehNet)
    local entry = carrying[source]
    if not entry then return false end

    local veh = NetworkGetEntityFromNetworkId(vehNet)
    if veh == 0 or not DoesEntityExist(veh) or GetEntityType(veh) ~= 2 then return false end
    if not near(source, GetEntityCoords(veh), 7.0) then return false end

    local inv = 'trunk' .. trim(GetVehicleNumberPlateText(veh))
    for _, it in ipairs(entry.items) do
        if not exports.ox_inventory:CanCarryItem(inv, it.item, it.count, it.metadata) then
            return false, 'no_room'
        end
    end

    if giveAll(inv, entry.items) == 0 then return false, 'no_room' end
    setCarry(source, nil)
    return true
end)

AddEventHandler('playerDropped', function()
    local src = source
    pending[src] = nil

    local entry = carrying[src]
    carrying[src] = nil
    if not entry then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    if #coords < 1.0 then return end
    local obj = CreateObjectNoOffset(entry.modelHash, coords.x, coords.y, coords.z - 0.9, true, true, false)
    if pcall(lib.waitFor, function() return DoesEntityExist(obj) or nil end, nil, 2000) then
        track(obj, entry)
    end
end)

-- Cleanup of abandoned loot and expired debris
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for netId, entry in pairs(entities) do
            if now >= entry.expires or not DoesEntityExist(entry.entity) then
                if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
                entities[netId] = nil
            end
        end
        for netId, d in pairs(debris) do
            if now >= d.expires or not DoesEntityExist(d.entity) then
                if DoesEntityExist(d.entity) then DeleteEntity(d.entity) end
                debris[netId] = nil
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= Shared.resource then return end
    for _, entry in pairs(entities) do
        if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    end
    for _, d in pairs(debris) do
        if DoesEntityExist(d.entity) then DeleteEntity(d.entity) end
    end
    for src, entry in pairs(carrying) do
        giveAll(src, entry.items)
        Player(src).state:set('scrap:carry', nil, true)
    end
end)

Loot.giveAll = giveAll
Loot.waitForEntity = waitForEntity
return Loot
