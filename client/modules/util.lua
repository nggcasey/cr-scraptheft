local Shared = require 'shared.utils'
local config = Shared.config

local U = { anim = {} }
local spawned = {} -- every entity this resource created on this client, removed on stop

---------------------------------------------------------------------------
-- Feedback
---------------------------------------------------------------------------
function U.notify(text, kind, duration)
    if not text or text == '' then return end
    if config.Notify == 'okok' then
        exports.okokNotify:Alert('', text, duration or 5000, kind == 'inform' and 'info' or (kind or 'info'), false)
    else
        lib.notify({ description = text, type = kind or 'inform', duration = duration })
    end
end

---Turn a server failure reason into a message.
function U.fail(reason, extra)
    local key = 'err_' .. tostring(reason or 'generic')
    local text = locale(key, extra)
    if text == key then text = locale('err_generic') end
    U.notify(text, 'error')
end

function U.progress(label, duration)
    local opts = {
        duration = math.max(250, math.floor(duration)),
        label = label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, sprint = true },
    }
    if config.Progress == 'bar' then return lib.progressBar(opts) end
    return lib.progressCircle(opts)
end

---------------------------------------------------------------------------
-- Tools
---------------------------------------------------------------------------
function U.hasTool(toolId)
    local tool = config.Tools[toolId]
    if not tool then return true end
    for _, item in ipairs(tool.items) do
        if (exports.ox_inventory:GetItemCount(item) or 0) > 0 then return true end
    end
    return false
end

function U.hasAnyTool(profile)
    local tools = Shared.profileTools(profile)
    if #tools == 0 then return true end
    for _, id in ipairs(tools) do
        if U.hasTool(id) then return true end
    end
    return false
end

function U.hasItem(item)
    return (exports.ox_inventory:GetItemCount(item) or 0) > 0
end

---------------------------------------------------------------------------
-- Animation
---------------------------------------------------------------------------
function U.anim.play(ped, a)
    if not a then return end
    if a.scenario then
        TaskStartScenarioInPlace(ped, a.scenario, 0, true)
        return
    end
    lib.requestAnimDict(a.dict)
    TaskPlayAnim(ped, a.dict, a.clip, a.blendIn or 3.0, a.blendOut or 3.0, a.duration or -1, a.flag or 1, 0, false, false, false)
    RemoveAnimDict(a.dict)
end

function U.anim.playing(ped, a)
    if not a then return true end
    if a.scenario then return IsPedUsingScenario(ped, a.scenario) end
    return IsEntityPlayingAnim(ped, a.dict, a.clip, 3)
end

function U.anim.stop(ped, a)
    if not a then return end
    if a.scenario then
        ClearPedTasks(ped)
    else
        StopAnimTask(ped, a.dict, a.clip, 2.0)
    end
end

---Play a one-shot clip and wait for it.
function U.anim.once(ped, dict, clip, ms, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, clip, 4.0, 4.0, ms, flag or 0, 0, false, false, false)
    RemoveAnimDict(dict)
    Wait(ms)
end

---------------------------------------------------------------------------
-- Entities
---------------------------------------------------------------------------
function U.requestControl(entity, timeout)
    if NetworkHasControlOfEntity(entity) then return true end
    NetworkRequestControlOfEntity(entity)
    local untilTime = GetGameTimer() + (timeout or 1000)
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < untilTime do
        Wait(0)
        NetworkRequestControlOfEntity(entity)
    end
    return NetworkHasControlOfEntity(entity)
end

---Load a model, falling back to config.FallbackProp when it doesn't exist in this game build.
function U.loadModel(model)
    local hash = Shared.hash(model or config.FallbackProp)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        lib.print.warn(('model %s does not exist, using %s'):format(tostring(model), config.FallbackProp))
        hash = joaat(config.FallbackProp)
    end
    lib.requestModel(hash, 5000)
    return hash
end

---@param opts? { network?: boolean, heading?: number, ground?: boolean, freeze?: boolean, impulse?: vector3 }
---@return integer entity, integer? netId
function U.spawnProp(model, coords, opts)
    opts = opts or {}
    local hash = U.loadModel(model)
    local network = opts.network ~= false
    local obj = CreateObject(hash, coords.x, coords.y, coords.z, network, true, false)
    SetModelAsNoLongerNeeded(hash)
    spawned[obj] = true

    if opts.heading then SetEntityHeading(obj, opts.heading) end
    if opts.ground then PlaceObjectOnGroundProperly(obj) end
    if opts.freeze then
        FreezeEntityPosition(obj, true)
    else
        ActivatePhysics(obj)
        if opts.impulse then
            ApplyForceToEntity(obj, 1, opts.impulse.x, opts.impulse.y, opts.impulse.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        end
    end

    if not network then return obj end

    local netId
    if pcall(lib.waitFor, function() return NetworkGetEntityIsNetworked(obj) or nil end, nil, 2000) then
        netId = NetworkGetNetworkIdFromEntity(obj)
        SetNetworkIdCanMigrate(netId, true)
    end
    return obj, netId
end

---Attach a prop to a ped bone. def = { model, bone, pos, rot }
function U.attachProp(ped, def, network)
    if not def then return end
    local obj = U.spawnProp(def.model, GetEntityCoords(ped), { network = network ~= false, freeze = false })
    SetEntityCollision(obj, false, false)
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, def.bone or 57005),
        def.pos.x, def.pos.y, def.pos.z, def.rot.x, def.rot.y, def.rot.z,
        true, true, false, true, 1, true)
    return obj
end

function U.delete(entity)
    if not entity or not DoesEntityExist(entity) then return end
    spawned[entity] = nil
    if NetworkGetEntityIsNetworked(entity) then U.requestControl(entity, 500) end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
end

---Forget an entity so resource stop won't delete it (handed over to the server).
function U.release(entity) spawned[entity] = nil end

---------------------------------------------------------------------------
-- Particles
---------------------------------------------------------------------------
---@param def { asset: string, name: string, on?: string, offset?: vector3, scale?: number }
---@param ctx table theft context (entity / vehicle)
function U.ptfxStart(def, ctx, toolProp)
    if not def then return end
    if not lib.requestNamedPtfxAsset(def.asset, 3000) then return end

    local off, scale = def.offset or vec3(0.0, 0.0, 0.0), def.scale or 1.0
    local handle
    UseParticleFxAssetNextCall(def.asset)

    if def.on == 'tool' and toolProp then
        handle = StartNetworkedParticleFxLoopedOnEntity(def.name, toolProp, off.x, off.y, off.z, 0.0, 0.0, 0.0, scale, false, false, false)
    elseif def.on == 'ped' then
        handle = StartNetworkedParticleFxLoopedOnEntityBone(def.name, cache.ped, off.x, off.y, off.z, 0.0, 0.0, 0.0, GetPedBoneIndex(cache.ped, 57005), scale, false, false, false)
    elseif ctx.entity and NetworkGetEntityIsNetworked(ctx.entity) then
        handle = StartNetworkedParticleFxLoopedOnEntity(def.name, ctx.entity, off.x, off.y, off.z, 0.0, 0.0, 0.0, scale, false, false, false)
    else
        -- static world object: resolve the offset into world space
        local pos = ctx.entity and GetOffsetFromEntityInWorldCoords(ctx.entity, off.x, off.y, off.z) or (ctx.focus + off)
        handle = StartParticleFxLoopedAtCoord(def.name, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, scale, false, false, false, false)
    end

    RemoveNamedPtfxAsset(def.asset)
    return handle
end

function U.ptfxStop(handle)
    if handle and handle ~= 0 then StopParticleFxLooped(handle, false) end
end

---Short burst: run a looped effect for `ms`.
function U.ptfxBurst(def, ctx, ms)
    local handle = U.ptfxStart(def, ctx)
    SetTimeout(ms or 800, function() U.ptfxStop(handle) end)
end

---------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------
---Walk (not teleport) into a working position.
function U.walkTo(coords, heading, timeout)
    local ped = cache.ped
    if #(GetEntityCoords(ped).xy - coords.xy) > 0.25 then
        TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, timeout or 4000, heading, 0.1)
        local untilTime = GetGameTimer() + (timeout or 4000)
        while #(GetEntityCoords(ped).xy - coords.xy) > 0.3 and GetGameTimer() < untilTime do Wait(50) end
        ClearPedTasks(ped)
    end
    SetEntityHeading(ped, heading)
    Wait(100)
end

AddEventHandler('onResourceStop', function(name)
    if name ~= Shared.resource then return end
    for entity in pairs(spawned) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
end)

return U
