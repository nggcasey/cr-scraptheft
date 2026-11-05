--[[
    Encounters: the odd person who turns up while you're working.
    Behaviours (configured in config/shared.lua -> Heat.encounters.types):

      nag       Karen. Walks up, films you, whinges. Calls the cops if you're still around when
                she runs out of patience. Threaten or shove her and she calls immediately.
      confront  Angry local. Marches over, warns you, then fights (and interrupts the job).
                Aim a gun at him and he may back down.
      caller    Keeps their distance and phones / radios it in. Aim at them and they may run.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'

local cfg = Shared.config.Heat.encounters
local Encounters = {}
local spawned = {}

local function pick(list) return list[math.random(#list)] end

local function weightedType()
    local total = 0
    for _, t in pairs(cfg.types) do total += (t.weight or 1) end
    local roll = math.random() * total
    for id, t in pairs(cfg.types) do
        roll -= (t.weight or 1)
        if roll <= 0 then return id, t end
    end
end

local function say(ped, t, line, speech)
    if speech then PlayPedAmbientSpeechNative(ped, speech, 'SPEECH_PARAMS_FORCE_SHOUTED') end
    if line then
        lib.notify({ title = t.label, description = ('"%s"'):format(line), icon = 'comment', type = 'warning', duration = 4500 })
    end
end

local function threatened(ped)
    return IsPlayerFreeAimingAtEntity(cache.playerId, ped) or IsPlayerTargettingEntity(cache.playerId, ped)
end

local function gone(ped)
    return not DoesEntityExist(ped) or IsEntityDead(ped)
end

local function dist(ped)
    return #(GetEntityCoords(ped) - GetEntityCoords(cache.ped))
end

local function release(ped)
    if not DoesEntityExist(ped) then return end
    spawned[ped] = nil
    SetPedKeepTask(ped, true)
    SetPedAsNoLongerNeeded(ped)
end

---------------------------------------------------------------------------
-- Finding / spawning someone
---------------------------------------------------------------------------
local function findOnlooker(origin)
    local me = cache.ped
    for _, p in ipairs(GetGamePool('CPed')) do
        if p ~= me and not IsPedAPlayer(p) and IsPedHuman(p) and not IsEntityDead(p)
            and not IsPedInAnyVehicle(p, false) and not IsEntityAMissionEntity(p)
            and #(GetEntityCoords(p) - origin) < 30.0 and HasEntityClearLosToEntityInFront(p, me) then
            return p
        end
    end
end

local function spawnPed(t, origin)
    for _ = 1, 8 do
        local angle = math.random() * math.pi * 2
        local d = cfg.spawnDistance[1] + math.random() * (cfg.spawnDistance[2] - cfg.spawnDistance[1])
        local found, pos = GetSafeCoordForPed(origin.x + math.cos(angle) * d, origin.y + math.sin(angle) * d, origin.z, true, 16)
        if found then
            local hash = U.loadModel(pick(t.models))
            local ped = CreatePed(4, hash, pos.x, pos.y, pos.z, math.random(0, 359) + 0.0, true, true)
            SetModelAsNoLongerNeeded(hash)
            spawned[ped] = true
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, false)
            return ped
        end
    end
end

local function approach(ped, stopAt, run)
    TaskGoToEntity(ped, cache.ped, -1, stopAt, run and 2.5 or 1.3, 1073741824, 0)
    local untilTime = GetGameTimer() + 25000
    while GetGameTimer() < untilTime and not gone(ped) and dist(ped) > stopAt + 1.0 do
        if threatened(ped) then return false end
        Wait(250)
    end
    return not gone(ped)
end

---------------------------------------------------------------------------
-- Behaviours
---------------------------------------------------------------------------
local behaviours = {}

function behaviours.nag(ped, t, ctx, report)
    if not approach(ped, 2.5, false) then
        -- threatened on the way over: screams, runs, calls
        say(ped, t, t.callLine, 'GENERIC_FRIGHTENED_HIGH')
        TaskSmartFleePed(ped, cache.ped, 100.0, -1, false, false)
        return report(true)
    end

    TaskTurnPedToFaceEntity(ped, cache.ped, 1000)
    Wait(1000)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MOBILE_FILM_SHOCKING', 0, true)
    say(ped, t, pick(t.lines), 'GENERIC_INSULT_HIGH')

    local deadline = GetGameTimer() + t.nagTime
    local nextLine = GetGameTimer() + 4000
    local wasRagdoll = false

    while not gone(ped) do
        local now = GetGameTimer()

        if threatened(ped) or wasRagdoll then
            say(ped, t, t.callLine, 'GENERIC_FRIGHTENED_HIGH')
            ClearPedTasks(ped)
            TaskSmartFleePed(ped, cache.ped, 100.0, -1, false, false)
            return report(true)
        end
        if IsPedRagdoll(ped) then wasRagdoll = true end

        if not ctx.active and #(GetEntityCoords(cache.ped) - ctx.focus) > t.giveUpDistance then
            say(ped, t, t.leaveLine, 'GENERIC_CURSE_HIGH')
            ClearPedTasks(ped)
            return
        end

        if now > deadline then
            say(ped, t, t.callLine, 'GENERIC_INSULT_HIGH')
            ClearPedTasks(ped)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
            Wait(3000)
            report(true)
            Wait(6000)
            ClearPedTasks(ped)
            return
        end

        if now > nextLine then
            nextLine = now + math.random(4000, 6500)
            say(ped, t, pick(t.lines), pick({ 'GENERIC_INSULT_HIGH', 'GENERIC_CURSE_HIGH', 'GENERIC_SHOCKED_HIGH' }))
        end

        Wait(200)
    end
end

function behaviours.confront(ped, t, ctx, report)
    local me = cache.ped
    local willCall = math.random() < (t.callChance or 0)

    local function backOff()
        say(ped, t, t.backOffLine, 'GENERIC_FRIGHTENED_HIGH')
        ClearPedTasks(ped)
        TaskHandsUp(ped, 2500, me, -1, false)
        Wait(2500)
        TaskSmartFleePed(ped, me, 100.0, -1, false, false)
        if willCall then report(true) end
    end

    if not approach(ped, 2.0, true) then
        if math.random() < t.backOffChance then return backOff() end
    end
    if gone(ped) then return end

    TaskTurnPedToFaceEntity(ped, me, t.warnTime)
    say(ped, t, pick(t.lines), 'GENERIC_INSULT_HIGH')

    local warnUntil = GetGameTimer() + t.warnTime
    while GetGameTimer() < warnUntil and not gone(ped) do
        if threatened(ped) then
            if math.random() < t.backOffChance then return backOff() end
            break -- calls your bluff
        end
        if not ctx.active and dist(ped) > 15.0 then
            say(ped, t, 'Yeah, keep walking!', 'GENERIC_CURSE_HIGH')
            ClearPedTasks(ped)
            return
        end
        Wait(200)
    end
    if gone(ped) then return end

    -- Fight
    local weapon = joaat(pick(t.weapons or { 'WEAPON_UNARMED' }))
    if weapon ~= `WEAPON_UNARMED` then GiveWeaponToPed(ped, weapon, 1, false, true) end
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    TaskCombatPed(ped, me, 0, 16)
    say(ped, t, pick(t.lines), 'GENERIC_WAR_CRY')

    if lib.progressActive() then lib.cancelProgress() end

    local untilTime = GetGameTimer() + 45000
    while GetGameTimer() < untilTime and not gone(ped) and not IsEntityDead(me) and dist(ped) < 40.0 do
        Wait(500)
    end

    if not gone(ped) then
        ClearPedTasks(ped)
        TaskWanderStandard(ped, 10.0, 10)
        if willCall then report(true) end
    end
end

function behaviours.caller(ped, t, ctx, report)
    local me = cache.ped
    if t.weapon then
        GiveWeaponToPed(ped, joaat(t.weapon), 1, false, true)
        SetCurrentPedWeapon(ped, joaat(t.weapon), true)
    end

    if t.approach and not approach(ped, t.keepDistance or 8.0, false) then
        if math.random() < t.scareChance then
            TaskSmartFleePed(ped, me, 100.0, -1, false, false)
            return
        end
    end
    if gone(ped) then return end

    ClearPedTasks(ped)
    TaskTurnPedToFaceEntity(ped, me, 1000)
    Wait(1000)
    say(ped, t, pick(t.lines), t.approach and 'GENERIC_INSULT_HIGH' or nil)

    if t.anim then
        U.anim.play(ped, t.anim)
    else
        TaskStartScenarioInPlace(ped, t.scenario or 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    end

    local deadline = GetGameTimer() + t.callTime
    while GetGameTimer() < deadline do
        if gone(ped) or IsPedRagdoll(ped) then return end -- silenced
        if threatened(ped) then
            if math.random() < t.scareChance then
                ClearPedTasks(ped)
                PlayPedAmbientSpeechNative(ped, 'GENERIC_FRIGHTENED_HIGH', 'SPEECH_PARAMS_FORCE_SHOUTED')
                TaskSmartFleePed(ped, me, 150.0, -1, false, false)
                U.notify(locale('witness_scared'), 'success')
                return
            end
            deadline = GetGameTimer() -- not scared: finishes the call right now
        end
        Wait(100)
    end

    ClearPedTasks(ped)
    TaskSmartFleePed(ped, me, 80.0, -1, false, false)
    U.notify(locale('witness_called'), 'error')
    report(true)
end

---------------------------------------------------------------------------
-- Entry
---------------------------------------------------------------------------
local COP_TYPES = { [6] = true, [27] = true }

local function copSees(ctx)
    local me = cache.ped
    for _, p in ipairs(GetGamePool('CPed')) do
        if COP_TYPES[GetPedType(p)] and not IsPedAPlayer(p) and not IsEntityDead(p)
            and #(GetEntityCoords(p) - ctx.focus) < 40.0 and HasEntityClearLosToEntityInFront(p, me) then
            return true
        end
    end
end

---@param report fun(witnessed: boolean)
function Encounters.start(ctx, isNight, report)
    if not cfg.enabled then return end

    if cfg.copsSeeYou then
        CreateThread(function()
            while ctx.active do
                if copSees(ctx) then
                    U.notify(locale('witness_cop'), 'error')
                    return report(true)
                end
                Wait(2000)
            end
        end)
    end

    CreateThread(function()
        Wait(math.random(cfg.delay[1], cfg.delay[2]))
        if not ctx.active then return end

        local chance = cfg.chance * (isNight and cfg.nightMultiplier or 1.0)
        if math.random() >= chance then return end

        local id, t = weightedType()
        if not t then return end

        local ped = t.useNearby and findOnlooker(ctx.focus)
        if ped then
            U.requestControl(ped, 800)
            SetEntityAsMissionEntity(ped, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            spawned[ped] = true
        else
            ped = spawnPed(t, ctx.focus)
        end
        if not ped then return end

        lib.print.debug(('encounter: %s'):format(id))
        if t.behaviour ~= 'caller' or t.approach then U.notify(locale('witness_spotted'), 'warning') end

        local ok, err = pcall(behaviours[t.behaviour], ped, t, ctx, report)
        if not ok then lib.print.error(err) end
        release(ped)
    end)
end

AddEventHandler('onResourceStop', function(name)
    if name ~= Shared.resource then return end
    for ped in pairs(spawned) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)

return Encounters
