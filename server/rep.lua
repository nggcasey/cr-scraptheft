local Shared = require 'shared.utils'
local Bridge = require 'server.bridge'

local Rep = {}
local cache = {}

local function key(id) return ('rep:%s'):format(id) end

---@return integer xp, string? identifier
function Rep.get(src)
    local id = Bridge.identifier(src)
    if not id then return 0 end
    if cache[id] == nil then cache[id] = GetResourceKvpInt(key(id)) end
    return cache[id], id
end

function Rep.add(src, amount)
    local xp, id = Rep.get(src)
    if not id or not amount or amount == 0 then return xp end
    local before = Shared.repLevel(xp)
    xp += amount
    cache[id] = xp
    SetResourceKvpInt(key(id), xp)

    local after, level = Shared.repLevel(xp)
    if after > before then
        Bridge.notify(src, locale('rep_level_up', level.label), 'success')
    end
    return xp
end

---@return integer index, table level, table? nextLevel, integer xp
function Rep.level(src)
    local xp = Rep.get(src)
    local idx, level, nextLevel = Shared.repLevel(xp)
    return idx, level, nextLevel, xp
end

lib.callback.register('cr-thief:getRep', function(source)
    local idx, level, nextLevel, xp = Rep.level(source)
    return { xp = xp, index = idx, label = level.label, speed = level.speed, next = nextLevel and nextLevel.xp }
end)

return Rep
