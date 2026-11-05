--[[
    Loot in the world: spawned by the client (so it tumbles with physics), registered with the
    server, picked up through ox_target. Heavy loot puts the player in carry mode.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'

local config = Shared.config
local Loot = {}

---@param entry { id: integer, model: integer }
---@param coords vector3
---@param opts? { heading?: number, impulse?: vector3 }
function Loot.spawn(entry, coords, opts)
    opts = opts or {}
    local obj, netId = U.spawnProp(entry.model, coords, { network = true, heading = opts.heading, impulse = opts.impulse })
    if not netId then
        U.delete(obj)
        return
    end
    if not lib.callback.await('cr-thief:registerLoot', false, entry.id, netId) then
        U.delete(obj)
        return
    end
    U.release(obj)
    return obj
end

---Drop a list of loot entries around a point, each with a little tumble.
function Loot.scatter(entries, origin, opts)
    opts = opts or {}
    for _, entry in ipairs(entries or {}) do
        local jitter = vec3(math.random(-30, 30) / 100, math.random(-30, 30) / 100, 0.0)
        local impulse = opts.impulse or vec3(math.random(-10, 10) / 10, math.random(-10, 10) / 10, 0.5)
        Loot.spawn(entry, origin + jitter, { heading = math.random(0, 359) + 0.0, impulse = impulse })
        Wait(120)
    end
end

---Every model that loot can appear as (ox_target needs the list up front).
local function lootModels()
    local set = { [config.FallbackProp] = true }
    for _, profile in pairs(Shared.profiles) do
        if profile.bundle then set[profile.bundle.model] = true end
        for _, l in ipairs(profile.loot) do
            if l.model == 'source' then
                for _, m in ipairs(profile.models or {}) do set[m] = true end
            elseif l.model then
                set[l.model] = true
            end
        end
    end
    local list = {}
    for m in pairs(set) do list[#list + 1] = m end
    return list
end

local function lootState(entity)
    if not NetworkGetEntityIsNetworked(entity) then return end
    return Entity(entity).state['thief:loot']
end

exports.ox_target:addModel(lootModels(), {
    {
        name = 'cr-thief:pickup',
        icon = 'fas fa-hand',
        label = locale('target_pickup'),
        distance = 2.0,
        canInteract = function(entity)
            return lootState(entity) ~= nil and not LocalPlayer.state['thief:carry']
        end,
        onSelect = function(data)
            local entity = data.entity
            local state = lootState(entity)
            if not state then return end

            local ped = cache.ped
            TaskTurnPedToFaceEntity(ped, entity, 600)
            Wait(600)
            U.anim.once(ped, 'random@domestic', 'pickup_low', 1100)

            local ok, reason = lib.callback.await('cr-thief:pickup', false, NetworkGetNetworkIdFromEntity(entity))
            if not ok then return U.fail(reason) end
            if reason ~= 'carry' then U.notify(locale('picked_up', state.label), 'success') end
        end,
    },
})

return Loot
