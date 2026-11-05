--[[
    Vehicle targets (catalytic converters, wheels) and the synced aftermath:
      scrap:cat    -> the exhaust note changes to something loud and rough for everyone nearby
      scrap:wheels -> missing wheels stay missing for everyone, car left sitting on blocks
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Theft = require 'client.modules.theft'

local config = Shared.config
local vcfg = config.Vehicles

-- motorcycles, cycles, boats, helicopters, planes, emergency, trains
local BLOCKED_CLASSES = { [8] = true, [13] = true, [14] = true, [15] = true, [16] = true, [18] = true, [21] = true }

local function strippable(veh)
    if not DoesEntityExist(veh) or not NetworkGetEntityIsNetworked(veh) then return false end
    if BLOCKED_CLASSES[GetVehicleClass(veh)] then return false end
    local model = GetEntityModel(veh)
    if vcfg.blacklistHashes[model] then return false end
    if not IsVehicleSeatFree(veh, -1) or GetEntitySpeed(veh) > 1.0 then return false end
    return true
end

local function nearestWheel(veh, point)
    local best, bestDist
    for idx in pairs(Theft.WHEEL_BONES) do
        local pos = Theft.wheelPosition(veh, idx)
        if pos then
            local d = #(pos - point)
            if not bestDist or d < bestDist then best, bestDist = idx, d end
        end
    end
    return best, bestDist
end

local function wheelGone(veh, idx)
    local wheels = Entity(veh).state['scrap:wheels']
    return wheels and wheels[tostring(idx)] or false
end

for id, profile in pairs(Shared.profiles) do
    if profile.kind == 'vehicle' then
        local option = {
            name = 'cr-scraptheft:' .. id,
            icon = profile.target.icon,
            label = profile.target.label,
            distance = profile.target.distance or 2.0,
        }

        if profile.part == 'cat' then
            option.canInteract = function(entity)
                if Theft.busy or not strippable(entity) then return false end
                if vcfg.electricHashes[GetEntityModel(entity)] then return false end
                if Entity(entity).state['scrap:cat'] then return false end
                return U.hasAnyTool(profile)
            end
            option.onSelect = function(data)
                Theft.run(Theft.vehicleContext(profile, data.entity))
            end
        else
            option.bones = { 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }
            option.canInteract = function(entity, _, coords)
                if Theft.busy or not strippable(entity) then return false end
                local idx, dist = nearestWheel(entity, coords)
                if not idx or dist > 1.2 or wheelGone(entity, idx) then return false end
                return U.hasAnyTool(profile)
            end
            option.onSelect = function(data)
                local idx = nearestWheel(data.entity, data.coords)
                if idx then Theft.run(Theft.vehicleContext(profile, data.entity, idx)) end
            end
        end

        exports.ox_target:addGlobalVehicle({ option })
    end
end

---------------------------------------------------------------------------
-- Synced aftermath
---------------------------------------------------------------------------
local function entityFromBag(bagName)
    local ok, entity = pcall(lib.waitFor, function()
        local ent = GetEntityFromStateBagName(bagName)
        return ent ~= 0 and ent or nil
    end, nil, 3000)
    return ok and entity or nil
end

AddStateBagChangeHandler('scrap:wheels', '', function(bagName, _, value)
    if not value then return end
    local veh = entityFromBag(bagName)
    if not veh then return end
    for key in pairs(value) do
        BreakOffVehicleWheel(veh, tonumber(key), false, true, true, false)
    end
end)

AddStateBagChangeHandler('scrap:cat', '', function(bagName, _, value)
    if not value or not vcfg.noCatAudio then return end
    local veh = entityFromBag(bagName)
    if veh then ForceUseAudioGameObject(veh, vcfg.noCatAudio) end
end)
