--[[
    Heat: how the cops find out.
      - every stage rolls a noise report (less likely at night, more likely with a car alarm going)
      - encounters: the odd Karen, angry local, timid passer-by or security guard (see encounters.lua)
]]
local Shared = require 'shared.utils'
local Dispatch = require 'client.modules.dispatch'
local Encounters = require 'client.modules.encounters'

local cfg = Shared.config.Heat
local Heat = {}
local lastAlert = -math.huge

local function isNight()
    return Shared.inHours({ open = cfg.night.from, close = cfg.night.to }, GetClockHours())
end

---@param witnessed boolean someone actually called it in (vs. a noise report)
function Heat.report(ctx, witnessed)
    if ctx.reported and not witnessed then return end
    ctx.reported = true
    if GetGameTimer() - lastAlert < cfg.cooldown * 1000 then return end
    lastAlert = GetGameTimer()
    Dispatch.send(ctx.profile, ctx.focus, witnessed)
end

---Roll a noise report for a stage.
function Heat.noise(ctx, chance)
    if ctx.reported then return end
    chance = (chance or 0) * (isNight() and cfg.night.multiplier or 1.0)
    if ctx.alarm then chance += cfg.alarmBonus end
    if chance > 0 and math.random() < chance then Heat.report(ctx, false) end
end

---Start encounter / cop checks for the duration of a job.
function Heat.watch(ctx)
    Encounters.start(ctx, isNight(), function(witnessed) Heat.report(ctx, witnessed) end)
end

return Heat
