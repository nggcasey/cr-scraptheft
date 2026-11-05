local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Theft = require 'client.modules.theft'
local Spots = require 'client.modules.spots'

require 'client.modules.carry'
require 'client.modules.loot'
require 'client.modules.vehicles'
if Shared.config.EnableBuyers then require 'client.modules.buyers' end

---------------------------------------------------------------------------
-- World-object jobs (A/C units, vending machines, shelves, tool chests, ...)
---------------------------------------------------------------------------
for id, profile in pairs(Shared.profiles) do
    if profile.kind == 'prop' then
        exports.ox_target:addModel(profile.models, {
            {
                name = 'cr-thief:' .. id,
                icon = profile.target.icon,
                label = profile.target.label,
                distance = profile.target.distance or 2.0,
                canInteract = function(entity)
                    -- map props are never networked; networked copies are loot / someone else's props
                    if Theft.busy or NetworkGetEntityIsNetworked(entity) then return false end
                    if Spots.isStripped(entity) then return false end
                    return U.hasAnyTool(profile)
                end,
                onSelect = function(data)
                    Theft.run(Theft.propContext(profile, data.entity))
                end,
            },
        })
    end
end

---------------------------------------------------------------------------
-- Pedestrian jobs (pickpocketing)
---------------------------------------------------------------------------
local COP_TYPES = { [6] = true, [27] = true }

local function isBehind(ped)
    local fwd = GetEntityForwardVector(ped)
    local to = GetEntityCoords(cache.ped) - GetEntityCoords(ped)
    local len = #to
    if len < 0.01 then return false end
    return (fwd.x * to.x + fwd.y * to.y) / len < -0.3
end

local pedOptions = {}
for id, profile in pairs(Shared.profiles) do
    if profile.kind == 'ped' then
        pedOptions[#pedOptions + 1] = {
            name = 'cr-thief:' .. id,
            icon = profile.target.icon,
            label = profile.target.label,
            distance = profile.target.distance or 1.3,
            canInteract = function(entity)
                if Theft.busy or IsPedAPlayer(entity) or not IsPedHuman(entity) or IsEntityDead(entity) then return false end
                if IsPedInAnyVehicle(entity, false) or IsEntityAMissionEntity(entity) or COP_TYPES[GetPedType(entity)] then return false end
                if not NetworkGetEntityIsNetworked(entity) or Entity(entity).state['thief:robbed'] then return false end
                if profile.behind and not isBehind(entity) then return false end
                return U.hasAnyTool(profile)
            end,
            onSelect = function(data)
                Theft.run(Theft.pedContext(profile, data.entity))
            end,
        }
    end
end
if #pedOptions > 0 then exports.ox_target:addGlobalPed(pedOptions) end

---------------------------------------------------------------------------
-- /thief: rep, local heat, word on the street
---------------------------------------------------------------------------
local function heatColour(heat, max)
    if heat >= max then return 'red' end
    if heat >= max - 3 then return 'orange' end
    if heat >= max / 3 then return 'yellow' end
    return 'green'
end

RegisterCommand('thief', function()
    local status = lib.callback.await('cr-thief:status', false)
    if not status then return end
    local rep, tip = status.rep, status.tip

    local options = {
        {
            title = locale('rep_title', rep.label),
            description = rep.next and locale('rep_progress', rep.xp, rep.next, rep.nextLabel) or locale('rep_max', rep.xp),
            icon = 'star', iconColor = '#facc15',
            progress = rep.next and math.floor(rep.xp / rep.next * 100) or 100,
            colorScheme = 'yellow',
            readOnly = true,
        },
        {
            title = locale('status_heat'),
            description = locale('status_heat_desc_' .. heatColour(status.heat, status.maxHeat)),
            icon = 'temperature-half',
            progress = math.floor(status.heat / status.maxHeat * 100),
            colorScheme = heatColour(status.heat, status.maxHeat),
            readOnly = true,
        },
    }

    if tip then
        options[#options + 1] = {
            title = locale('status_tip'),
            description = locale('tip_text', tip.label, tip.district),
            icon = 'comment-dots',
            onSelect = function()
                SetNewWaypoint(tip.coords.x, tip.coords.y)
                U.notify(locale('tip_marked', tip.district))
            end,
        }
    end

    lib.registerContext({ id = 'cr-thief:status', title = locale('status_title'), options = options })
    lib.showContext('cr-thief:status')
end, false)
TriggerEvent('chat:addSuggestion', '/thief', locale('cmd_thief'))

RegisterNetEvent('cr-thief:tip', function(tip)
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    U.speech(locale('tip_sender'), locale('tip_text', tip.label, tip.district), 'comment-sms', 'inform')
end)
