--[[
    Keeps thieves moving:
      area heat    every job heats its map cell for everyone; hot areas get jumpy, max heat = lockdown
      repetition   the same thief working the same cell over and over earns less rep
      tips         "word on the street": one job type in one district pays bonus rep and loot for a while
]]
local Shared = require 'shared.utils'
local Bridge = require 'server.bridge'
local Rep = require 'server.rep'

local cfg = Shared.config.World
local World = {}

local heat = {}       -- [cell] = points
local personal = {}   -- [identifier] = { { cell, t } }
local tip

local function cellOf(c)
    return ('%d:%d'):format(math.floor(c.x / cfg.cellSize), math.floor(c.y / cfg.cellSize))
end

function World.heat(coords) return heat[cellOf(coords)] or 0 end
function World.locked(coords) return World.heat(coords) >= cfg.maxHeat end
function World.multiplier(coords) return 1.0 + World.heat(coords) * cfg.heatMultiplier end

function World.add(coords, amount)
    local cell = cellOf(coords)
    heat[cell] = math.min(cfg.maxHeat, (heat[cell] or 0) + (amount or 1))
    return heat[cell]
end

CreateThread(function()
    while true do
        Wait(cfg.decay.every * 1000)
        for cell, value in pairs(heat) do
            value -= cfg.decay.amount
            heat[cell] = value > 0 and value or nil
        end
    end
end)

---Record a job for the player and return their rep multiplier for repeating themselves.
---@return number multiplier, boolean repeated
function World.repetition(src, coords)
    local id = Bridge.identifier(src) or tostring(src)
    local now, cell, count, keep = os.time(), cellOf(coords), 0, {}
    for _, e in ipairs(personal[id] or {}) do
        if now - e.t < cfg.personal.window * 60 then
            keep[#keep + 1] = e
            if e.cell == cell then count += 1 end
        end
    end
    keep[#keep + 1] = { cell = cell, t = now }
    personal[id] = keep
    if count >= cfg.personal.repeats then return cfg.personal.xpMultiplier, true end
    return 1.0, false
end

---------------------------------------------------------------------------
-- Word on the street
---------------------------------------------------------------------------
local function rollTip()
    local t = cfg.tips
    local ids = {}
    for id in pairs(Shared.profiles) do ids[#ids + 1] = id end
    table.sort(ids)
    local district = Shared.pick(t.districts)
    local id = Shared.pick(ids)
    if not district or not id then return end

    tip = {
        profile = id,
        label = Shared.profiles[id].label,
        district = district.label,
        coords = district.coords,
        radius = district.radius,
    }
    GlobalState['thief:tip'] = tip

    for _, player in ipairs(GetPlayers()) do
        local src = tonumber(player)
        if Rep.level(src) >= t.announceMinRep then
            TriggerClientEvent('cr-thief:tip', src, tip)
        end
    end
    lib.print.debug(('new tip: %s in %s'):format(tip.label, tip.district))
end

if cfg.tips.enabled then
    CreateThread(function()
        while true do
            rollTip()
            Wait(cfg.tips.every * 60000)
        end
    end)
end

function World.tipApplies(profileId, coords)
    return tip ~= nil and tip.profile == profileId and #(coords - tip.coords) <= tip.radius
end

---------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------
lib.callback.register('cr-thief:status', function(source)
    local idx, level, nextLevel, xp = Rep.level(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    return {
        rep = { index = idx, label = level.label, xp = xp, next = nextLevel and nextLevel.xp, nextLabel = nextLevel and nextLevel.label },
        heat = World.heat(coords),
        maxHeat = cfg.maxHeat,
        tip = tip,
    }
end)

-- A rival thief wants a cut.
lib.callback.register('cr-thief:payOff', function(source, amount)
    local rival = Shared.people.encounters.types.rival
    local max = rival and type(rival.cut) == 'table' and rival.cut[2] or 500
    amount = math.floor(tonumber(amount) or 0)
    if amount < 1 or amount > max then return false end
    return Bridge.removeMoney(source, amount) and true or false
end)

return World
