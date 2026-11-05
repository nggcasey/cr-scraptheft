--[[
    The stage runner. A job is a list of stages; each stage keeps its animation looping,
    holds the right tool, throws sparks, may interrupt with skill checks or hazards,
    and is confirmed by the server before the next one starts.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Heat = require 'client.modules.heat'
local Loot = require 'client.modules.loot'
local Carry = require 'client.modules.carry'

local config = Shared.config
local Theft = { busy = false }

local WHEEL_BONES = { [0] = 'wheel_lf', [1] = 'wheel_rf', [2] = 'wheel_lr', [3] = 'wheel_rr' }
Theft.WHEEL_BONES = WHEEL_BONES

local SHOCK_FX = { asset = 'core', name = 'ent_brk_sparking_wires', on = 'ped', scale = 0.6 }

---------------------------------------------------------------------------
-- Contexts
---------------------------------------------------------------------------
function Theft.propContext(profile, entity)
    local coords = GetEntityCoords(entity)
    return {
        profile = profile,
        entity = entity,
        focus = coords,
        request = { model = GetEntityModel(entity), coords = coords, heading = GetEntityHeading(entity) },
    }
end

function Theft.wheelPosition(veh, wheel)
    local bone = GetEntityBoneIndexByName(veh, WHEEL_BONES[wheel])
    if bone == -1 then return end
    return GetWorldPositionOfEntityBone(veh, bone)
end

function Theft.vehicleContext(profile, veh, wheel)
    local name = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local label = GetLabelText(name)
    if label == 'NULL' then label = name end

    return {
        profile = profile,
        entity = veh,
        vehicle = veh,
        wheel = wheel,
        focus = wheel and Theft.wheelPosition(veh, wheel) or GetEntityCoords(veh),
        request = { netId = VehToNet(veh), wheel = wheel, label = label },
    }
end

---------------------------------------------------------------------------
-- Positioning: walk into a believable working spot
---------------------------------------------------------------------------
local function position(ctx)
    local ped = cache.ped
    local profile = ctx.profile
    local pcoords = GetEntityCoords(ped)

    if profile.kind == 'prop' then
        local flat = vec3(pcoords.x - ctx.focus.x, pcoords.y - ctx.focus.y, 0.0)
        local len = #flat
        local dir = len > 0.01 and flat / len or vec3(0.0, -1.0, 0.0)
        if len > 1.3 then
            local stand = ctx.focus + dir * 1.0
            U.walkTo(vec3(stand.x, stand.y, pcoords.z), GetHeadingFromVector_2d(-dir.x, -dir.y))
        else
            TaskTurnPedToFaceCoord(ped, ctx.focus.x, ctx.focus.y, ctx.focus.z, 800)
            Wait(800)
        end
        ctx.dropAt = ctx.focus + dir * 0.7 + vec3(0.0, 0.0, 0.6)
        return
    end

    local veh = ctx.vehicle
    local h = GetEntityHeading(veh)
    local min, max = GetModelDimensions(GetEntityModel(veh))

    if profile.part == 'cat' then
        local side = GetOffsetFromEntityGivenWorldCoords(veh, pcoords.x, pcoords.y, pcoords.z).x >= 0 and 1 or -1
        local stand = GetOffsetFromEntityInWorldCoords(veh, side * (max.x + 0.15), 0.0, 0.0)
        -- Face away from the car: the mechanic clip lies back, sliding the upper body underneath.
        U.walkTo(stand, side == 1 and h - 90.0 or h + 90.0)
        ctx.dropAt = GetOffsetFromEntityInWorldCoords(veh, side * (max.x + 0.25), 0.9, min.z + 0.5)
    else
        local l = GetOffsetFromEntityGivenWorldCoords(veh, ctx.focus.x, ctx.focus.y, ctx.focus.z)
        local side = l.x >= 0 and 1 or -1
        local stand = GetOffsetFromEntityInWorldCoords(veh, l.x + side * 0.8, l.y, 0.0)
        U.walkTo(stand, side == 1 and h + 90.0 or h - 90.0)
        ctx.dropAt = GetOffsetFromEntityInWorldCoords(veh, l.x + side * 1.2, l.y + 0.6, l.z + 0.3)
        ctx.wheelLocal, ctx.side = l, side
    end
end

---------------------------------------------------------------------------
-- World props created during a job
---------------------------------------------------------------------------
local function wheelGround(ctx, inset)
    local l = ctx.wheelLocal
    return GetOffsetFromEntityInWorldCoords(ctx.vehicle, l.x - ctx.side * (inset or 0.0), l.y, l.z - 0.2)
end

local function registerDebris(ctx, obj, netId, temporary)
    if not netId then return end
    if lib.callback.await('cr-scraptheft:registerDebris', false, ctx.token, netId, temporary) then
        if not temporary then U.release(obj) end
    end
end

local function placeProp(ctx, def)
    local pos = def.at == 'wheel' and ctx.wheelLocal and wheelGround(ctx, 0.35) or ctx.dropAt
    local heading = GetEntityHeading(ctx.vehicle or cache.ped)
    local obj, netId = U.spawnProp(def.model, pos, { heading = heading, ground = true, freeze = true })
    ctx.temp[#ctx.temp + 1] = obj
    registerDebris(ctx, obj, netId, true)
end

local function spawnDebris(ctx, def)
    if def.at == 'wheel' and ctx.wheelLocal then
        local obj, netId = U.spawnProp(def.model, wheelGround(ctx, 0.05), {
            heading = GetEntityHeading(ctx.vehicle), ground = true, freeze = def.freeze,
        })
        return registerDebris(ctx, obj, netId, false)
    end

    local pos
    if ctx.vehicle and def.offset then
        pos = GetOffsetFromEntityInWorldCoords(ctx.vehicle, def.offset.x, def.offset.y, def.offset.z)
    else
        pos = ctx.dropAt + vec3(math.random(-30, 30) / 100, math.random(-30, 30) / 100, 0.1)
    end
    local obj, netId = U.spawnProp(def.model, pos, {
        heading = math.random(0, 359) + 0.0,
        freeze = def.freeze,
        impulse = vec3(math.random(-10, 10) / 10, math.random(-10, 10) / 10, 1.0),
    })
    registerDebris(ctx, obj, netId, false)
end

local function removeWheel(ctx)
    if U.requestControl(ctx.vehicle, 1500) then
        BreakOffVehicleWheel(ctx.vehicle, ctx.wheel, false, true, true, false)
    end
end

---------------------------------------------------------------------------
-- Hazards
---------------------------------------------------------------------------
local function shock(ctx, hazard)
    local ped = cache.ped
    U.ptfxBurst(SHOCK_FX, ctx, 900)
    PlayPedAmbientSpeechNative(ped, 'GENERIC_SHOCKED_HIGH', 'SPEECH_PARAMS_FORCE_SHOUTED')
    SetPedToRagdoll(ped, 2500, 2500, 0, false, false, false)
    ApplyDamageToPed(ped, hazard.damage or 20, false)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.35)
    SetTimecycleModifier('Dont_tazeme_bro')
    SetTimeout(3000, ClearTimecycleModifier)
    U.notify(locale('shocked'), 'error')
end

---@return boolean interrupted
local function rollHazard(ctx, stage, steps)
    local hazard = stage.hazard
    if not hazard or math.random() >= hazard.chance / steps then return false end

    if hazard.protect and U.hasItem(hazard.protect) then
        if not ctx.protectedNotice then
            ctx.protectedNotice = true
            U.notify(locale('protected'), 'success')
        end
        return false
    end

    if hazard.type == 'shock' then shock(ctx, hazard) end
    return true
end

---------------------------------------------------------------------------
-- Stage
---------------------------------------------------------------------------
local function setAnim(ctx, anim)
    local ped = cache.ped
    if ctx.anim ~= anim then
        U.anim.stop(ped, ctx.anim)
        ctx.anim = anim
        U.anim.play(ped, anim)
    elseif not U.anim.playing(ped, anim) then
        U.anim.play(ped, anim)
    end
end

local function runStage(ctx, stage)
    local ped = cache.ped
    local tool = stage.tool and config.Tools[stage.tool]
    if tool and not U.hasTool(stage.tool) then return false, 'missing_tool', tool.label end

    if stage.place and not ctx.placed then
        ctx.placed = true
        placeProp(ctx, stage.place)
    end

    setAnim(ctx, stage.anim)
    if stage.anim and stage.anim.scenario then Wait(1200) end -- let the scenario settle in

    local handDef = stage.prop or (tool and tool.prop)
    local held = handDef and not (stage.anim and stage.anim.scenario) and U.attachProp(ped, handDef) or nil
    local fx = stage.ptfx and U.ptfxStart(stage.ptfx, ctx, held)

    local steps = stage.steps or 1
    local stepTime = stage.duration * ctx.speed / steps
    local attempts, step = 0, 1
    local ok, reason = true, nil

    while step <= steps do
        local label = (steps > 1 and stage.stepLabel) and stage.stepLabel:format(step, steps) or stage.label
        if not U.progress(label, stepTime) then
            ok, reason = false, 'cancel'
            break
        end

        if rollHazard(ctx, stage, steps) then
            ok, reason = false, 'hazard'
            break
        end

        if stage.skill then
            setAnim(ctx, stage.anim)
            if lib.skillCheck(stage.skill.difficulty, stage.skill.inputs) then
                step += 1
            else
                attempts += 1
                PlaySoundFrontend(-1, 'Drill_Pin_Break', 'DLC_HEIST_FLEECA_SOUNDSET', true)
                U.notify(locale('skill_fail'), 'error', 2500)
                Heat.noise(ctx, stage.noise)
                if attempts >= (stage.skill.attempts or 3) then
                    ok, reason = false, 'skill'
                    break
                end
            end
        else
            step += 1
        end
    end

    U.ptfxStop(fx)
    U.delete(held)

    if ok then Heat.noise(ctx, stage.noise) end
    return ok, reason, reason == 'missing_tool' and tool and tool.label or nil
end

---------------------------------------------------------------------------
-- Job lifecycle
---------------------------------------------------------------------------
local function cleanup(ctx)
    ctx.active = false
    U.anim.stop(cache.ped, ctx.anim)
    for _, obj in ipairs(ctx.temp or {}) do U.delete(obj) end
    Theft.busy = false
end

function Theft.abort(ctx, serverEnded)
    cleanup(ctx)
    if not serverEnded and ctx.token then
        lib.callback.await('cr-scraptheft:cancel', false, ctx.token)
    end
end

function Theft.run(ctx)
    if Theft.busy or Carry.isCarrying() then return end
    Theft.busy = true

    local profile = ctx.profile
    local ok, token, speed = lib.callback.await('cr-scraptheft:begin', false, profile.id, ctx.request)
    if not ok then
        Theft.busy = false
        return U.fail(token, speed)
    end

    ctx.token, ctx.speed, ctx.active, ctx.temp = token, speed or 1.0, true, {}
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    position(ctx)

    if profile.alarm and ctx.vehicle and GetVehicleDoorLockStatus(ctx.vehicle) >= 2 and math.random() < profile.alarm then
        if U.requestControl(ctx.vehicle, 1000) then
            SetVehicleAlarm(ctx.vehicle, true)
            StartVehicleAlarm(ctx.vehicle)
        end
        ctx.alarm = true
        U.notify(locale('alarm'), 'warning')
    end

    Heat.watch(ctx)

    local result
    for index, stage in ipairs(profile.stages) do
        local done, reason, extra
        repeat
            done, reason, extra = runStage(ctx, stage)
            if not done and reason == 'hazard' then
                ctx.anim = nil
                Wait(3500)
                if IsEntityDead(cache.ped) or #(GetEntityCoords(cache.ped) - ctx.focus) > 5.0 then break end
                position(ctx)
            end
        until done or reason ~= 'hazard'

        if not done then
            Theft.abort(ctx)
            if reason == 'cancel' then return U.notify(locale('cancelled')) end
            return U.fail(reason, extra)
        end

        local accepted, res, extra2 = lib.callback.await('cr-scraptheft:stage', false, ctx.token, index)
        if not accepted then
            Theft.abort(ctx, true)
            return U.fail(res, extra2)
        end

        if stage.debris then spawnDebris(ctx, stage.debris) end
        if stage.effect == 'removeWheel' and ctx.vehicle then removeWheel(ctx) end
        if type(res) == 'table' then result = res end
    end

    cleanup(ctx)
    ShakeGameplayCam('HAND_SHAKE', 0.15)
    SetTimeout(600, function() StopGameplayCamShaking(false) end)

    if result and result.loot then
        Loot.scatter(result.loot, ctx.dropAt)
        U.notify(locale('job_done', profile.label), 'success')
    end
end

return Theft
