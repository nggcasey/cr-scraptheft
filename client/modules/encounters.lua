--[[
    The locals. Characters who turn up while you work, each with a generated persona
    (name, type, traits rolled from config/people.lua), plus bystanders who just react.

    Behaviours
      nag       walks up, films you, whinges; calls if you stick around (Karen)
      confront  marches over, warns you, then fights (angry local, sometimes with a dog)
      caller    keeps their distance and phones / radios it in (timid, security, grandpa, dog walker)
      drunk     stumbles over, slurs, might get loud, might pass out
      filmer    films you for socials; the clip blows up later and gets reported
      rival     another thief who wants a cut: pay, or he snitches / swings / storms off

    hooks = { report = fun(kind, persona), noise = fun(chance), night = boolean, heatMult = number }
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Reports = require 'client.modules.reports'

local people = Shared.people
local cfg = people.encounters
local pick, roll = Shared.pick, Shared.roll

local Encounters = {}
local spawned = {}

local BARK = {
    a_c_retriever = 'WORLD_DOG_BARKING_RETRIEVER',
    a_c_shepherd = 'WORLD_DOG_BARKING_SHEPHERD',
    a_c_husky = 'WORLD_DOG_BARKING_SHEPHERD',
    a_c_rottweiler = 'WORLD_DOG_BARKING_ROTTWEILER',
    a_c_westy = 'WORLD_DOG_BARKING_SMALL',
    a_c_pug = 'WORLD_DOG_BARKING_SMALL',
    a_c_poodle = 'WORLD_DOG_BARKING_SMALL',
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function gone(ped) return not ped or not DoesEntityExist(ped) or IsEntityDead(ped) end
local function dist(ped) return #(GetEntityCoords(ped) - GetEntityCoords(cache.ped)) end

local function threatened(ped)
    return IsPlayerFreeAimingAtEntity(cache.playerId, ped) or IsPlayerTargettingEntity(cache.playerId, ped)
end

local function loadPedModel(models)
    local list = {}
    for _, m in ipairs(models or {}) do list[#list + 1] = m end
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
    list[#list + 1] = 'a_m_y_hipster_01'
    for _, m in ipairs(list) do
        local hash = joaat(m)
        if IsModelInCdimage(hash) and IsModelAPed(hash) then
            lib.requestModel(hash, 5000)
            return hash, m
        end
    end
end

local function release(ped)
    if not ped or not DoesEntityExist(ped) then return end
    spawned[ped] = nil
    SetPedKeepTask(ped, true)
    SetPedAsNoLongerNeeded(ped)
end

---------------------------------------------------------------------------
-- Personas
---------------------------------------------------------------------------
local Persona = {}
Persona.__index = Persona

---Read a trait, rolling { min, max } ranges once per persona.
function Persona:get(key)
    if self.traits[key] == nil then self.traits[key] = roll(self.t[key]) end
    return self.traits[key]
end

function Persona:say(list, speech, kind)
    if speech and not gone(self.ped) then
        PlayPedAmbientSpeechNative(self.ped, speech, 'SPEECH_PARAMS_FORCE_SHOUTED')
    end
    local text = Shared.fill(pick(list), self.vars)
    if text == '' then return end
    if text:sub(1, 1) ~= '*' then text = ('"%s"'):format(text) end
    U.speech(('%s · %s'):format(self.name, self.t.label), text, self.t.icon, kind or 'warning')
end

local function newPersona(id, t, ped, ctx)
    local male = IsPedMale(ped)
    local name, first = Reports.makeName(t, male, ctx.street)
    local p = setmetatable({
        id = id, t = t, ped = ped, name = name, first = first, male = male,
        dog = pick(t.dogNames), traits = {},
    }, Persona)
    p.vars = Reports.vars(ctx, p)
    return p
end

---------------------------------------------------------------------------
-- Companions (dogs)
---------------------------------------------------------------------------
local function heel(p)
    if gone(p.dogPed) then return end
    ClearPedTasks(p.dogPed)
    TaskFollowToOffsetOfEntity(p.dogPed, p.ped, 0.6, -1.0, 0.0, 1.5, -1, 1.0, true)
end

local function spawnCompanion(p)
    local c = p.t.companion
    if not c or math.random() >= (c.chance or 1.0) then return end
    local hash, model = loadPedModel(c.models)
    if not hash or not model:find('^a_c_') then return end

    local pos = GetOffsetFromEntityInWorldCoords(p.ped, 0.8, -0.8, 0.0)
    local dog = CreatePed(28, hash, pos.x, pos.y, pos.z, GetEntityHeading(p.ped), true, true)
    SetModelAsNoLongerNeeded(hash)
    spawned[dog] = true
    SetBlockingOfNonTemporaryEvents(dog, true)
    p.dogPed, p.dogModel = dog, model
    heel(p)
end

local function bark(p)
    local dog = p.dogPed
    if gone(dog) or not p.t.companion.bark then return end
    CreateThread(function()
        TaskGoToEntity(dog, cache.ped, -1, 2.5, 3.0, 1073741824, 0)
        local untilTime = GetGameTimer() + 8000
        while GetGameTimer() < untilTime and not gone(dog) and dist(dog) > 3.5 do Wait(250) end
        if gone(dog) then return end
        local scenario = BARK[p.dogModel]
        if scenario then TaskStartScenarioInPlace(dog, scenario, 0, true) else TaskTurnPedToFaceEntity(dog, cache.ped, -1) end
    end)
end

local function sic(p)
    if not gone(p.dogPed) and p.t.companion.attack then TaskCombatPed(p.dogPed, cache.ped, 0, 16) end
end

---------------------------------------------------------------------------
-- Movement
---------------------------------------------------------------------------
---@return boolean arrived (false = threatened on the way, or gone)
local function approach(p, stopAt, run)
    local ped = p.ped
    TaskGoToEntity(ped, cache.ped, -1, stopAt, run and 2.5 or 1.3, 1073741824, 0)
    local untilTime = GetGameTimer() + 25000
    while GetGameTimer() < untilTime and not gone(ped) and dist(ped) > stopAt + 1.0 do
        if threatened(ped) then return false end
        Wait(250)
    end
    return not gone(ped)
end

local function flee(ped, range)
    if gone(ped) then return end
    ClearPedTasks(ped)
    TaskSmartFleePed(ped, cache.ped, range or 100.0, -1, false, false)
end

---------------------------------------------------------------------------
-- Behaviours
---------------------------------------------------------------------------
local behaviours = {}

function behaviours.nag(p, ctx, hooks)
    local ped = p.ped
    if not approach(p, 2.5, false) then
        p:say(p.t.callLines, 'GENERIC_FRIGHTENED_HIGH', 'error')
        flee(ped)
        return hooks.report('witness', p)
    end

    TaskTurnPedToFaceEntity(ped, cache.ped, 1000)
    Wait(1000)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MOBILE_FILM_SHOCKING', 0, true)
    p:say(p.t.lines, 'GENERIC_INSULT_HIGH')

    local deadline = GetGameTimer() + p:get('nagTime')
    local nextLine = GetGameTimer() + p:get('lineEvery')
    local shoved = false

    while not gone(ped) do
        local now = GetGameTimer()

        if threatened(ped) or shoved then
            p:say(p.t.callLines, 'GENERIC_FRIGHTENED_HIGH', 'error')
            flee(ped)
            return hooks.report('witness', p)
        end
        if IsPedRagdoll(ped) then shoved = true end

        if not ctx.active and #(GetEntityCoords(cache.ped) - ctx.focus) > p:get('giveUpDistance') then
            p:say(p.t.leaveLines, 'GENERIC_CURSE_HIGH', 'inform')
            ClearPedTasks(ped)
            return
        end

        if now > deadline then
            p:say(p.t.callLines, 'GENERIC_INSULT_HIGH', 'error')
            ClearPedTasks(ped)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
            Wait(3000)
            hooks.report('witness', p)
            Wait(6000)
            ClearPedTasks(ped)
            return
        end

        if now > nextLine then
            nextLine = now + roll(p.t.lineEvery)
            p:say(p.t.lines, pick({ 'GENERIC_INSULT_HIGH', 'GENERIC_CURSE_HIGH', 'GENERIC_SHOCKED_HIGH' }))
        end
        Wait(200)
    end
end

function behaviours.confront(p, ctx, hooks)
    local ped, me = p.ped, cache.ped
    local willCall = math.random() < p:get('callChance')

    local function backOff()
        p:say(p.t.backOffLines, 'GENERIC_FRIGHTENED_HIGH', 'success')
        ClearPedTasks(ped)
        TaskHandsUp(ped, 2500, me, -1, false)
        heel(p)
        Wait(2500)
        flee(ped)
        if willCall then hooks.report('witness', p) end
    end

    if not approach(p, 2.0, true) and math.random() < p:get('backOffChance') then return backOff() end
    if gone(ped) then return end

    TaskTurnPedToFaceEntity(ped, me, p:get('warnTime'))
    p:say(p.t.lines, 'GENERIC_INSULT_HIGH')
    bark(p)

    local warnUntil = GetGameTimer() + p:get('warnTime')
    while GetGameTimer() < warnUntil and not gone(ped) do
        if threatened(ped) then
            if math.random() < p:get('backOffChance') then return backOff() end
            break -- calls your bluff
        end
        if not ctx.active and dist(ped) > 15.0 then
            p:say(p.t.walkAwayLines, 'GENERIC_CURSE_HIGH', 'inform')
            ClearPedTasks(ped)
            heel(p)
            return
        end
        Wait(200)
    end
    if gone(ped) then return end

    local weapon = joaat(pick(p.t.weapons) or 'WEAPON_UNARMED')
    if weapon ~= `WEAPON_UNARMED` then GiveWeaponToPed(ped, weapon, 1, false, true) end
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    TaskCombatPed(ped, me, 0, 16)
    sic(p)
    p:say(p.t.lines, 'GENERIC_WAR_CRY', 'error')

    if lib.progressActive() then lib.cancelProgress() end

    local untilTime = GetGameTimer() + 45000
    while GetGameTimer() < untilTime and not gone(ped) and not IsEntityDead(me) and dist(ped) < 40.0 do
        Wait(500)
    end

    if not gone(ped) then
        ClearPedTasks(ped)
        heel(p)
        TaskWanderStandard(ped, 10.0, 10)
        if willCall then hooks.report('witness', p) end
    end
end

function behaviours.caller(p, ctx, hooks)
    local ped, me, t = p.ped, cache.ped, p.t
    if t.weapon then
        GiveWeaponToPed(ped, joaat(t.weapon), 1, false, true)
        SetCurrentPedWeapon(ped, joaat(t.weapon), true)
    end

    if t.approach and not approach(p, p:get('keepDistance') or 8.0, false) then
        if math.random() < p:get('scareChance') then return flee(ped) end
    end
    if gone(ped) then return end

    ClearPedTasks(ped)
    TaskTurnPedToFaceEntity(ped, me, 1000)
    bark(p)
    Wait(1000)
    p:say(t.lines, t.approach and 'GENERIC_INSULT_HIGH' or nil)

    if t.anim then U.anim.play(ped, t.anim) else TaskStartScenarioInPlace(ped, t.scenario or 'WORLD_HUMAN_STAND_MOBILE', 0, true) end

    local deadline = GetGameTimer() + p:get('callTime')
    local nextHeckle = GetGameTimer() + 4000
    while GetGameTimer() < deadline do
        if gone(ped) or IsPedRagdoll(ped) then return end -- silenced
        if threatened(ped) then
            if math.random() < p:get('scareChance') then
                PlayPedAmbientSpeechNative(ped, 'GENERIC_FRIGHTENED_HIGH', 'SPEECH_PARAMS_FORCE_SHOUTED')
                flee(ped, 150.0)
                heel(p)
                U.notify(locale('witness_scared'), 'success')
                return
            end
            deadline = GetGameTimer() -- not scared: finishes the call right now
        end
        if t.heckle and GetGameTimer() > nextHeckle then
            nextHeckle = GetGameTimer() + math.random(4000, 7000)
            p:say(t.lines, 'GENERIC_INSULT_MED')
        end
        Wait(100)
    end

    ClearPedTasks(ped)
    heel(p)
    TaskSmartFleePed(ped, me, 80.0, -1, false, false)
    U.notify(locale('witness_called'), 'error')
    hooks.report('witness', p)
end

function behaviours.drunk(p, ctx, hooks)
    local ped = p.ped
    local clipset = 'move_m@drunk@verydrunk'
    lib.requestAnimSet(clipset)
    SetPedMovementClipset(ped, clipset, 1.0)
    SetPedIsDrunk(ped, true)

    if not approach(p, 2.0, false) then
        p:say({ 'Woah! Woah! S\'alright! I\'m goin\'!' }, 'GENERIC_FRIGHTENED_HIGH', 'inform')
        return flee(ped, 40.0)
    end

    p:say(p.t.lines, 'GENERIC_HI', 'inform')
    local untilTime = GetGameTimer() + p:get('hangAround')
    local loudDone = false

    while GetGameTimer() < untilTime and not gone(ped) do
        if threatened(ped) then
            p:say({ "Alright alright... *hic* ...I didn't see nothin'. Never do." }, 'GENERIC_FRIGHTENED_HIGH', 'inform')
            return flee(ped, 40.0)
        end
        TaskTurnPedToFaceEntity(ped, cache.ped, 2000)
        Wait(math.random(3500, 6000))
        if gone(ped) then return end
        p:say(p.t.lines, pick({ 'GENERIC_HI', 'GENERIC_CURSE_MED', 'GENERIC_THANKS' }), 'inform')

        if not loudDone and math.random() < p:get('loudChance') / 3 then
            loudDone = true
            p:say({ "*starts shouting about you to the whole street*" }, 'GENERIC_INSULT_HIGH', 'error')
            hooks.report('noise')
        end
    end

    if gone(ped) then return end
    if math.random() < p:get('passOutChance') then
        U.speech(nil, ('*%s passes out on the footpath*'):format(p.name), 'bed')
        SetPedToRagdoll(ped, 60000, 60000, 0, false, false, false)
    else
        TaskWanderStandard(ped, 10.0, 10)
    end
end

function behaviours.filmer(p, ctx, hooks)
    local ped = p.ped
    local scared = false
    if not approach(p, math.random(6, 10) + 0.0, false) then scared = true end

    if not scared then
        TaskTurnPedToFaceEntity(ped, cache.ped, 800)
        Wait(800)
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MOBILE_FILM_SHOCKING', 0, true)
        p:say(p.t.lines, nil, 'warning')

        local untilTime = GetGameTimer() + p:get('filmTime')
        while GetGameTimer() < untilTime do
            if gone(ped) or IsPedRagdoll(ped) then
                U.speech(nil, locale('phone_dropped'), 'mobile-screen', 'success')
                return
            end
            if threatened(ped) then scared = true break end
            Wait(150)
        end
    end

    if gone(ped) then return end
    p.caption = scared and 'he literally pulled a gun on me 😭' or nil
    p:say(scared and { 'NAH NAH NAH I\'M OUT 😭' } or { 'Thanks for the content! 😂' }, 'GENERIC_FRIGHTENED_HIGH')
    flee(ped, 80.0)

    SetTimeout(p:get('postDelay'), function()
        U.speech(nil, locale('went_viral'), 'arrow-trend-up', 'error')
        hooks.report('viral', p)
    end)
end

function behaviours.rival(p, ctx, hooks)
    local ped = p.ped
    if not approach(p, 2.0, false) then return flee(ped, 40.0) end

    TaskTurnPedToFaceEntity(ped, cache.ped, -1)
    p:say(p.t.lines, 'GENERIC_HI')
    local cut = p:get('cut')

    local choice = lib.alertDialog({
        header = ('%s wants a cut'):format(p.name),
        content = Shared.fill(pick(p.t.lines), p.vars) .. ('\n\n**He wants $%d to keep quiet.**'):format(cut),
        centered = true,
        cancel = true,
        labels = { confirm = ('Pay $%d'):format(cut), cancel = 'Tell him to get lost' },
    })

    if gone(ped) then return end
    if choice == 'confirm' then
        if lib.callback.await('cr-thief:payOff', false, cut) then
            p:say(p.t.payLines, 'GENERIC_THANKS', 'success')
            ClearPedTasks(ped)
            TaskWanderStandard(ped, 10.0, 10)
            return
        end
        p:say({ "No cash? Then we've got a problem." }, 'GENERIC_INSULT_HIGH')
    end

    local outcome = Shared.weighted(p.t.outcomes)
    if outcome == 'snitch' then
        p:say(p.t.snitchLines, 'GENERIC_INSULT_HIGH', 'error')
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
        Wait(4000)
        if gone(ped) or IsPedRagdoll(ped) then return end
        hooks.report('witness', p)
        ClearPedTasks(ped)
        TaskWanderStandard(ped, 10.0, 10)
    elseif outcome == 'fight' then
        p:say(p.t.fightLines, 'GENERIC_WAR_CRY', 'error')
        SetPedCombatAttributes(ped, 46, true)
        TaskCombatPed(ped, cache.ped, 0, 16)
        if lib.progressActive() then lib.cancelProgress() end
        local untilTime = GetGameTimer() + 30000
        while GetGameTimer() < untilTime and not gone(ped) and not IsEntityDead(cache.ped) and dist(ped) < 40.0 do Wait(500) end
    else
        p:say(p.t.leaveLines, 'GENERIC_CURSE_HIGH', 'inform')
        ClearPedTasks(ped)
        TaskWanderStandard(ped, 10.0, 10)
    end
end

---------------------------------------------------------------------------
-- Spawning / recruiting
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
        local d = roll(cfg.spawnDistance)
        local found, pos = GetSafeCoordForPed(origin.x + math.cos(angle) * d, origin.y + math.sin(angle) * d, origin.z, true, 16)
        if found then
            local hash = loadPedModel(t.models)
            if not hash then return end
            local ped = CreatePed(4, hash, pos.x, pos.y, pos.z, math.random(0, 359) + 0.0, true, true)
            SetModelAsNoLongerNeeded(hash)
            spawned[ped] = true
            return ped
        end
    end
end

local function adopt(ped)
    U.requestControl(ped, 800)
    SetEntityAsMissionEntity(ped, true, true)
    spawned[ped] = true
end

---Run a behaviour on a ped.
local function run(id, t, ped, ctx, hooks)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)

    local p = newPersona(id, t, ped, ctx)
    spawnCompanion(p)
    lib.print.debug(('encounter: %s "%s"'):format(id, p.name))

    local ok, err = pcall(behaviours[t.behaviour], p, ctx, hooks)
    if not ok then lib.print.error(err) end

    release(p.dogPed)
    release(ped)
end

---A specific ped reacts (a pickpocket victim who noticed, a shop clerk).
---@param weights table<string, number> encounter type ids -> weight
function Encounters.react(ped, ctx, hooks, weights)
    local id = Shared.weighted(weights)
    local t = id and cfg.types[id]
    if not t or gone(ped) then return end
    adopt(ped)
    CreateThread(function() run(id, t, ped, ctx, hooks) end)
end

---------------------------------------------------------------------------
-- Bystanders: life going on. They react, they never call.
---------------------------------------------------------------------------
local reactions = {}

function reactions.stare(ped)
    TaskTurnPedToFaceEntity(ped, cache.ped, -1)
    Wait(math.random(3000, 6000))
end

function reactions.hurry(ped)
    local away = GetEntityCoords(ped) - GetEntityCoords(cache.ped)
    local len = #away
    if len < 0.1 then return end
    local target = GetEntityCoords(ped) + away / len * 25.0
    TaskGoStraightToCoord(ped, target.x, target.y, target.z, 2.0, 10000, 0.0, 0.5)
    Wait(6000)
end

function reactions.mutter(ped)
    TaskTurnPedToFaceEntity(ped, cache.ped, 2000)
    PlayPedAmbientSpeechNative(ped, 'GENERIC_SHOCKED_MED', 'SPEECH_PARAMS_FORCE')
    U.speech(locale('passer_by'), ('"%s"'):format(pick(people.bystanders.lines)), 'person-walking')
    Wait(2500)
end

function reactions.film(ped)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MOBILE_FILM_SHOCKING', 0, true)
    Wait(math.random(4000, 7000))
end

local function watchBystanders(ctx)
    local b = people.bystanders
    if not b or not b.enabled then return end
    local seen = {}
    CreateThread(function()
        while ctx.active do
            local me = cache.ped
            for _, ped in ipairs(GetGamePool('CPed')) do
                if not seen[ped] and ped ~= me and not IsPedAPlayer(ped) and IsPedHuman(ped) and not IsEntityDead(ped)
                    and not IsPedInAnyVehicle(ped, false) and not IsEntityAMissionEntity(ped)
                    and #(GetEntityCoords(ped) - ctx.focus) < b.radius and HasEntityClearLosToEntityInFront(ped, me) then
                    seen[ped] = true
                    if math.random() < b.chance and U.requestControl(ped, 300) then
                        local reaction = Shared.weighted(b.reactions)
                        CreateThread(function()
                            ClearPedTasks(ped)
                            reactions[reaction](ped)
                            if DoesEntityExist(ped) and not IsEntityDead(ped) then
                                ClearPedTasks(ped)
                                TaskWanderStandard(ped, 10.0, 10)
                            end
                        end)
                    end
                end
            end
            Wait(2000)
        end
    end)
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

function Encounters.start(ctx, hooks)
    watchBystanders(ctx)
    if not cfg.enabled then return end

    if cfg.copsSeeYou then
        CreateThread(function()
            while ctx.active do
                if copSees(ctx) then
                    U.notify(locale('witness_cop'), 'error')
                    return hooks.report('cop')
                end
                Wait(2000)
            end
        end)
    end

    CreateThread(function()
        Wait(roll(cfg.delay))
        if not ctx.active then return end

        local chance = cfg.chance * (hooks.night and cfg.nightMultiplier or 1.0) * (hooks.heatMult or 1.0)
        if math.random() >= chance then return end

        local id, t = Shared.weighted(cfg.types)
        if not t then return end

        local ped = t.useNearby and findOnlooker(ctx.focus)
        if ped then adopt(ped) else ped = spawnPed(t, ctx.focus) end
        if not ped then return end

        if t.behaviour ~= 'caller' or t.approach then U.notify(locale('witness_spotted'), 'warning') end
        run(id, t, ped, ctx, hooks)
    end)
end

AddEventHandler('onResourceStop', function(name)
    if name ~= Shared.resource then return end
    for ped in pairs(spawned) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)

return Encounters
