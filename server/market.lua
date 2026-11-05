local Shared = require 'shared.utils'
local Bridge = require 'server.bridge'
local Rep = require 'server.rep'

local config = Shared.config
local cfg = config.Market
local buyers = Shared.buyers

local supply, drift = {}, {}

local function rollDrift()
    for _, buyer in pairs(buyers) do
        for item in pairs(buyer.items) do
            drift[item] = cfg.drift.min + math.random() * (cfg.drift.max - cfg.drift.min)
        end
    end
end
rollDrift()

CreateThread(function()
    local elapsed = 0
    while true do
        Wait(cfg.recoverEvery * 1000)
        for item, amount in pairs(supply) do
            supply[item] = math.max(0, amount - cfg.recoverAmount)
        end
        elapsed += cfg.recoverEvery
        if elapsed >= cfg.drift.every * 60 then
            elapsed = 0
            rollDrift()
        end
    end
end)

local function multiplier(item)
    local m = (drift[item] or 1.0) * (1 - (supply[item] or 0) * cfg.saturation)
    return math.max(cfg.floor, m)
end

---------------------------------------------------------------------------
-- Fence rotation
---------------------------------------------------------------------------
local active = {}

local function rotate(buyer)
    active[buyer.id] = math.random(#buyer.locations)
    GlobalState[('scrap:buyer:%s'):format(buyer.id)] = active[buyer.id]
end

for _, buyer in pairs(buyers) do
    rotate(buyer)
    if buyer.rotate and #buyer.locations > 1 then
        CreateThread(function()
            while true do
                Wait(buyer.rotate * 60000)
                rotate(buyer)
            end
        end)
    end
end

local function buyerNear(src, buyer)
    local loc = buyer.locations[active[buyer.id]]
    local ped = GetPlayerPed(src)
    return #(GetEntityCoords(ped) - loc.xyz) < 6.0
end

---------------------------------------------------------------------------
-- Valuation
---------------------------------------------------------------------------
local function itemLabel(item)
    local data = exports.ox_inventory:Items(item)
    return data and data.label or item
end

---Sorted slots holding `item` (largest value first so players sell their best pieces first).
local function slotsFor(src, item)
    local slots = exports.ox_inventory:Search(src, 'slots', item) or {}
    table.sort(slots, function(a, b)
        return ((a.metadata and a.metadata.value) or 0) > ((b.metadata and b.metadata.value) or 0)
    end)
    return slots
end

---@return integer total, table removal list of {slot, count}
local function appraise(src, buyer, item, amount, bonus)
    local base = buyer.items[item]
    local mult = multiplier(item) * bonus
    local remaining, total, removal = amount, 0, {}

    for _, slot in ipairs(slotsFor(src, item)) do
        if remaining <= 0 then break end
        local take = math.min(slot.count, remaining)
        local unit = base == 'value' and ((slot.metadata and slot.metadata.value) or 0) or base
        total += unit * take
        removal[#removal + 1] = { slot = slot.slot, count = take }
        remaining -= take
    end

    return math.floor(total * mult), removal, amount - remaining
end

lib.callback.register('cr-scraptheft:market', function(source, buyerId)
    local buyer = buyers[buyerId]
    if not buyer or not buyerNear(source, buyer) then return end

    local idx, level, nextLevel, xp = Rep.level(source)
    local rep = { index = idx, label = level.label, xp = xp, next = nextLevel and nextLevel.xp, nextLabel = nextLevel and nextLevel.label }

    if idx < (buyer.minRep or 1) then
        return { refused = true, rep = rep }
    end

    local list = {}
    for item, base in pairs(buyer.items) do
        local count = exports.ox_inventory:Search(source, 'count', item) or 0
        local mult = multiplier(item)
        local entry = { item = item, label = itemLabel(item), count = count, trend = mult }
        if count > 0 then
            entry.total = appraise(source, buyer, item, count, level.price)
            entry.unit = math.floor(entry.total / count)
        else
            entry.unit = base ~= 'value' and math.floor(base * mult * level.price) or nil
        end
        list[#list + 1] = entry
    end

    table.sort(list, function(a, b)
        if (a.count > 0) ~= (b.count > 0) then return a.count > 0 end
        return a.label < b.label
    end)

    return { items = list, rep = rep }
end)

lib.callback.register('cr-scraptheft:sell', function(source, buyerId, item, amount)
    local buyer = buyers[buyerId]
    amount = math.floor(tonumber(amount) or 0)
    if not buyer or not buyer.items[item] or amount < 1 then return false end
    if not buyerNear(source, buyer) then return false end

    local idx, level = Rep.level(source)
    if idx < (buyer.minRep or 1) then return false end

    local payout, removal, found = appraise(source, buyer, item, amount, level.price)
    if found < amount then return false, 'sell_not_enough' end

    for _, r in ipairs(removal) do
        if not exports.ox_inventory:RemoveItem(source, item, r.count, nil, r.slot) then
            return false
        end
    end

    Bridge.pay(source, payout, buyer.payout == 'dirty')
    supply[item] = (supply[item] or 0) + amount
    lib.print.debug(('%s sold %dx %s to %s for $%d'):format(source, amount, item, buyerId, payout))

    return true, payout
end)

lib.callback.register('cr-scraptheft:tipOff', function(source, buyerId)
    local buyer = buyers[buyerId]
    local target = buyer and buyer.tipsOff and buyers[buyer.tipsOff]
    if not target or not buyerNear(source, buyer) then return end
    if Rep.level(source) < (target.minRep or 1) then return false end
    local loc = target.locations[active[target.id]]
    return { coords = loc.xyz, label = target.label, hours = target.hours }
end)
