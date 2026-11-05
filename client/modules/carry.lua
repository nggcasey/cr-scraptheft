--[[
    Carrying heavy loot. The server owns the state (player statebag 'thief:carry');
    this module just makes it look and feel heavy:
      - box-carry animation, no sprinting, jumping, weapons, cover or entering vehicles
      - slower walk
      - drop it with the keybind, or lose it if you're knocked over or die
      - target any vehicle to load it into the trunk
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Loot = require 'client.modules.loot'

local cfg = Shared.config.Carry
local Carry = {}
local active, dropping

local BLOCKED = { 21, 22, 23, 24, 25, 37, 44, 45, 140, 141, 142, 257, 263, 264 }

local keybind

local function stop()
    if not active then return end
    local ped = cache.ped
    U.delete(active.prop)
    StopAnimTask(ped, cfg.anim.dict, cfg.anim.clip, 2.0)
    active = nil
    lib.hideTextUI()
end

function Carry.drop()
    if not active or dropping then return end
    dropping = true

    local ped = cache.ped
    local alive = not IsEntityDead(ped) and not IsPedRagdoll(ped)
    if alive then U.anim.once(ped, 'random@domestic', 'pickup_low', 900) end

    local entry = lib.callback.await('cr-thief:drop', false)
    if entry then
        stop()
        local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.6, alive and -0.4 or 0.2)
        Loot.spawn(entry, pos, { heading = GetEntityHeading(ped) })
    end
    dropping = false
end

local function start(data)
    stop()
    local ped = cache.ped
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

    local attach = data.attach or cfg.attach
    local prop = U.attachProp(ped, { model = data.model, bone = attach.bone, pos = attach.pos, rot = attach.rot })
    local session = { prop = prop, data = data }
    active = session

    lib.showTextUI(locale('carry_hint', data.label, keybind and keybind:getCurrentKey() or cfg.dropKey), { icon = 'fas fa-dolly' })

    CreateThread(function()
        local nextAnimCheck = 0
        while active == session do
            ped = cache.ped
            for i = 1, #BLOCKED do DisableControlAction(0, BLOCKED[i], true) end
            SetPedMoveRateOverride(ped, cfg.moveRate)

            local now = GetGameTimer()
            if now > nextAnimCheck then
                nextAnimCheck = now + 400
                if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, true) then
                    CreateThread(Carry.drop)
                elseif not IsEntityPlayingAnim(ped, cfg.anim.dict, cfg.anim.clip, 3) and not dropping then
                    U.anim.play(ped, cfg.anim)
                end
            end
            Wait(0)
        end
    end)
end

function Carry.isCarrying() return active ~= nil end

keybind = lib.addKeybind({
    name = 'cr_thief_drop',
    description = locale('keybind_drop'),
    defaultKey = cfg.dropKey,
    onPressed = function()
        if active then Carry.drop() end
    end,
})

AddStateBagChangeHandler('thief:carry', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value then start(value) else stop() end
end)

CreateThread(function()
    local current = LocalPlayer.state['thief:carry']
    if current then start(current) end
end)

---------------------------------------------------------------------------
-- Load into a vehicle
---------------------------------------------------------------------------
exports.ox_target:addGlobalVehicle({
    {
        name = 'cr-thief:stow',
        icon = 'fas fa-box-open',
        label = locale('target_stow'),
        distance = 3.0,
        canInteract = function() return active ~= nil and not dropping end,
        onSelect = function(data)
            local veh, ped = data.entity, cache.ped
            dropping = true -- pause the carry loop's animation upkeep
            local hasControl = NetworkHasControlOfEntity(veh)
            if hasControl then SetVehicleDoorOpen(veh, 5, false, false) end

            TaskTurnPedToFaceEntity(ped, veh, 600)
            Wait(600)
            U.anim.once(ped, 'anim@heists@narcotics@trash', 'throw_b', 1200, 48)

            local ok, reason = lib.callback.await('cr-thief:stow', false, NetworkGetNetworkIdFromEntity(veh))
            if hasControl then SetTimeout(800, function() SetVehicleDoorShut(veh, 5, false) end) end
            dropping = false
            if not ok then return U.fail(reason) end
            U.notify(locale('stowed'), 'success')
        end,
    },
})

AddEventHandler('onResourceStop', function(name)
    if name == Shared.resource then stop() end
end)

return Carry
