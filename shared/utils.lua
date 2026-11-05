local config = require 'config.shared'
local profiles = {}
for _, file in ipairs(require 'config.jobs') do
    for id, job in pairs(require('config.jobs.' .. file)) do
        if profiles[id] then error(('cr-thief: duplicate job id "%s" in config/jobs/%s.lua'):format(id, file)) end
        profiles[id] = job
    end
end
local buyers = require 'config.buyers'
local people = require 'config.people'
local dispatch = require 'config.dispatch'

local Shared = {}

Shared.resource = GetCurrentResourceName()
Shared.config = config
Shared.profiles = profiles
Shared.buyers = buyers
Shared.people = people
Shared.dispatch = dispatch

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

function Shared.pick(list)
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
end

---Pick a key from { key = weight } or an entry from a list of { weight = n }.
function Shared.weighted(tbl)
    local total = 0
    for _, v in pairs(tbl) do total += type(v) == 'table' and (v.weight or 1) or v end
    local roll = math.random() * total
    for k, v in pairs(tbl) do
        roll -= type(v) == 'table' and (v.weight or 1) or v
        if roll <= 0 then return k, v end
    end
end

---Roll a { min, max } range (integers stay integers); anything else is returned as-is.
function Shared.roll(v)
    if type(v) == 'table' and #v == 2 and type(v[1]) == 'number' and type(v[2]) == 'number' then
        if math.type(v[1]) == 'integer' and math.type(v[2]) == 'integer' then return math.random(v[1], v[2]) end
        return v[1] + math.random() * (v[2] - v[1])
    end
    return v
end

---Fill {placeholders}. Unknown ones are left as-is.
function Shared.fill(str, vars)
    if not str then return '' end
    return (str:gsub('{(%w+)}', function(k)
        local v = vars[k]
        if v == nil then return '{' .. k .. '}' end
        return tostring(v)
    end))
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
