--[[
    Heat: how the cops find out. Several independent channels per job:
      noise    someone heard it (no NPC needed). Rolled every noisy stage, nudged by off-screen events.
      unseen   a named person calls from their window across the road. Nobody spawns; maybe a hint.
      alarm    the car's alarm company calls it in.
      witness  an encounter NPC calls (see encounters.lua).
      cop      an ambient cop saw you.
      viral    a teen's video blew up.
    Area heat (from the server) scales all of it: hit the same neighbourhood too often and it gets jumpy.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Dispatch = require 'client.modules.dispatch'
local Reports = require 'client.modules.reports'
local Encounters = require 'client.modules.encounters'

local cfg = Shared.config.Heat
local people, dcfg = Shared.people, Shared.dispatch
local Heat = {}
local lastAlert = -math.huge

function Heat.isNight()
    return Shared.inHours({ open = cfg.night.from, close = cfg.night.to }, GetClockHours())
end

local function timeOk(t)
    if not t then return true end
    return (t == 'night') == Heat.isNight()
end

local function filterTime(list)
    local out = {}
    for _, e in ipairs(list or {}) do
        if timeOk(e.time) then out[#out + 1] = e end
    end
    return out
end

---@param kind? 'noise'|'witness'|'unseen'|'cop'|'alarm'|'viral'
function Heat.report(ctx, kind, persona)
    kind = kind or 'noise'
    if kind == 'noise' and ctx.reported then return end -- one noise complaint per job is plenty
    ctx.reported = true
    if GetGameTimer() - lastAlert < cfg.cooldown * 1000 then return end
    lastAlert = GetGameTimer()
    Dispatch.send(ctx.profile, ctx.focus, Reports.build(ctx, kind, persona))
end

---The street reacting with nobody in sight. Returns a bonus to this stage's report chance.
local function offscreen()
    local o = people.offscreen
    if not o or not o.enabled or math.random() >= o.chance then return 0 end
    local e = Shared.pick(filterTime(o.events))
    if not e then return 0 end
    U.speech(nil, e.text, 'ear-listen')
    return e.reportBonus or 0
end

---Roll a noise report for a stage.
function Heat.noise(ctx, chance)
    chance = chance or 0
    if chance <= 0 then return end
    chance += offscreen()
    if ctx.reported then return end

    chance *= (Heat.isNight() and cfg.night.multiplier or 1.0) * (ctx.heatMult or 1.0)
    if ctx.alarm then chance += cfg.alarmBonus end
    if math.random() < chance then Heat.report(ctx, 'noise') end
end

---A car alarm went off; maybe the monitoring company rings it in.
function Heat.alarm(ctx)
    if math.random() >= (dcfg.alarm.chance or 0) then return end
    SetTimeout(math.random(5000, 15000), function() Heat.report(ctx, 'alarm') end)
end

local function unseenCaller(ctx)
    local u = dcfg.unseen
    if not u then return end
    local chance = u.chance * (Heat.isNight() and cfg.night.multiplier or 1.0) * (ctx.heatMult or 1.0)
    if math.random() >= chance then return end

    CreateThread(function()
        Wait(Shared.roll(u.delay))
        if not ctx.active then return end

        local _, def = Shared.weighted(filterTime(u.callers))
        if not def then return end
        local male = def.gender == 'male' or (def.gender ~= 'female' and math.random() < 0.5)
        local name = Reports.makeName(def, male, ctx.street or Reports.street(ctx.focus))

        if math.random() < u.hintChance and def.hints then
            U.speech(nil, Shared.pick(def.hints), 'eye')
            Wait(math.random(2000, 4000))
        end
        Heat.report(ctx, 'unseen', { name = name, report = def.report })
    end)
end

---Everything that watches a job while it runs.
function Heat.watch(ctx)
    unseenCaller(ctx)
    Encounters.start(ctx, {
        night = Heat.isNight(),
        heatMult = ctx.heatMult,
        report = function(kind, persona) Heat.report(ctx, kind, persona) end,
    })
end

---Hooks for a one-off reaction (pickpocket victim, shop clerk).
function Heat.hooks(ctx)
    return {
        night = Heat.isNight(),
        heatMult = ctx.heatMult,
        report = function(kind, persona) Heat.report(ctx, kind, persona) end,
    }
end

return Heat
