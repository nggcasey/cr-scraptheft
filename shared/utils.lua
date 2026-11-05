local config = require 'config.shared'
local profiles = require 'config.profiles'
local buyers = require 'config.buyers'

local Shared = {}

Shared.resource = GetCurrentResourceName()
Shared.config = config
Shared.profiles = profiles
Shared.buyers = buyers

function Shared.hash(model)
    return type(model) == 'number' and model or joaat(model)
end

local function hashSet(list)
    local set = {}
    for i = 1, #(list or {}) do set[joaat(list[i])] = list[i] end
    return set
end

-- Precompute lookups once per runtime.
for id, profile in pairs(profiles) do
    profile.id = id
    profile.modelHashes = hashSet(profile.models)
    if profile.swap then
        local swap = {}
        for from, to in pairs(profile.swap) do swap[joaat(from)] = joaat(to) end
        profile.swapHashes = swap
    end
end

for id, buyer in pairs(buyers) do buyer.id = id end

config.Vehicles.electricHashes = hashSet(config.Vehicles.electric)
config.Vehicles.blacklistHashes = hashSet(config.Vehicles.blacklist)
config.Vehicles.tierByHash = {}
for _, tier in ipairs(config.Vehicles.tiers or {}) do
    for _, model in ipairs(tier.models) do
        config.Vehicles.tierByHash[joaat(model)] = tier.multiplier
    end
end

---Stable id for a static world object (identical on every client and the server).
function Shared.spotId(model, coords)
    return ('%d:%.1f:%.1f:%.1f'):format(model, coords.x, coords.y, coords.z)
end

---@return integer index, table level, table? nextLevel
function Shared.repLevel(xp)
    local levels = config.Rep.levels
    local idx = 1
    for i = 1, #levels do
        if xp >= levels[i].xp then idx = i end
    end
    return idx, levels[idx], levels[idx + 1]
end

function Shared.inHours(hours, hour)
    if not hours then return true end
    if hours.open <= hours.close then
        return hour >= hours.open and hour < hours.close
    end
    return hour >= hours.open or hour < hours.close
end

---Every tool id a profile uses (for "do I have anything for this job" checks).
function Shared.profileTools(profile)
    if profile.toolList then return profile.toolList end
    local seen, list = {}, {}
    for _, stage in ipairs(profile.stages) do
        if stage.tool and not seen[stage.tool] then
            seen[stage.tool] = true
            list[#list + 1] = stage.tool
        end
    end
    profile.toolList = list
    return list
end

return Shared
