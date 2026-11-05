--[[
    Buyers: a scrapyard that takes metal, and a fence who only shows up at night,
    moves around, and won't deal with nobodies. Prices follow a live market.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'

local Buyers = {}

local function inHours(buyer)
    return Shared.inHours(buyer.hours, GetClockHours())
end

local function trendIcon(mult)
    if mult >= 1.05 then return 'arrow-trend-up', '#4ade80' end
    if mult <= 0.9 then return 'arrow-trend-down', '#f87171' end
    return 'minus', '#a1a1aa'
end

---------------------------------------------------------------------------
-- Selling
---------------------------------------------------------------------------
local function handOver(ped)
    local me = cache.ped
    TaskTurnPedToFaceEntity(me, ped, 700)
    Wait(700)

    lib.requestAnimDict('mp_common')
    ClearPedTasks(ped)
    TaskPlayAnim(ped, 'mp_common', 'givetake1_b', 4.0, 4.0, 1500, 0, 0, false, false, false)
    TaskPlayAnim(me, 'mp_common', 'givetake1_a', 4.0, 4.0, 1500, 0, 0, false, false, false)
    RemoveAnimDict('mp_common')
    Wait(1500)
end

local function sell(buyer, ped, entry)
    local amount = entry.count
    if entry.count > 1 then
        local input = lib.inputDialog(locale('sell_how_many', entry.label), {
            { type = 'slider', label = locale('amount'), min = 1, max = entry.count, default = entry.count },
        })
        if not input then return end
        amount = math.floor(input[1])
    end

    handOver(ped)
    local ok, payout = lib.callback.await('cr-scraptheft:sell', false, buyer.id, entry.item, amount)
    if buyer.scenario then TaskStartScenarioInPlace(ped, buyer.scenario, 0, true) end

    if not ok then return U.fail(payout) end
    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', true)
    U.notify(locale('sold', amount, entry.label, payout), 'success')
end

function Buyers.open(buyer, ped)
    local data = lib.callback.await('cr-scraptheft:market', false, buyer.id)
    if not data then return end

    if data.refused then
        PlayPedAmbientSpeechNative(ped, 'GENERIC_NO', 'SPEECH_PARAMS_FORCE_NORMAL')
        return U.notify(locale('buyer_refuse', data.rep.label), 'error')
    end

    local rep = data.rep
    local options = {
        {
            title = locale('rep_title', rep.label),
            description = rep.next and locale('rep_progress', rep.xp, rep.next, rep.nextLabel) or locale('rep_max', rep.xp),
            icon = 'star',
            iconColor = '#facc15',
            progress = rep.next and math.floor(rep.xp / rep.next * 100) or 100,
            colorScheme = 'yellow',
            readOnly = true,
        },
    }

    for _, entry in ipairs(data.items) do
        local icon, color = trendIcon(entry.trend)
        local trend = { label = locale('market'), value = ('%d%%'):format(math.floor(entry.trend * 100 + 0.5)) }
        if entry.count > 0 then
            options[#options + 1] = {
                title = ('%s  ×%d'):format(entry.label, entry.count),
                description = locale('sell_offer', entry.total, entry.unit),
                icon = icon, iconColor = color,
                image = ('nui://ox_inventory/web/images/%s.png'):format(entry.item),
                metadata = { trend },
                onSelect = function() sell(buyer, ped, entry) end,
            }
        else
            options[#options + 1] = {
                title = entry.label,
                description = entry.unit and locale('buying_at', entry.unit) or locale('buying_value'),
                icon = icon, iconColor = color,
                metadata = { trend },
                disabled = true,
            }
        end
    end

    lib.registerContext({ id = 'cr-scraptheft:buyer', title = buyer.label, options = options })
    lib.showContext('cr-scraptheft:buyer')
end

local function tipOff(buyer)
    local info = lib.callback.await('cr-scraptheft:tipOff', false, buyer.id)
    if info == false then return U.notify(locale('tip_refuse'), 'error') end
    if not info then return end
    SetNewWaypoint(info.coords.x, info.coords.y)
    local hours = info.hours and locale('tip_hours', info.hours.open, info.hours.close) or ''
    U.notify(locale('tip_given', info.label, hours), 'inform', 8000)
end

---------------------------------------------------------------------------
-- Peds
---------------------------------------------------------------------------
local function spawnPed(buyer, loc)
    local hash = lib.requestModel(buyer.ped)
    local z = loc.z
    local found, ground = GetGroundZFor_3dCoord(loc.x, loc.y, loc.z + 2.0, false)
    if found then z = ground end

    local ped = CreatePed(4, hash, loc.x, loc.y, z, loc.w, false, true)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    if buyer.scenario then TaskStartScenarioInPlace(ped, buyer.scenario, 0, true) end

    local options = {
        {
            name = 'cr-scraptheft:sell',
            icon = 'fas fa-scale-balanced',
            label = locale('target_sell', buyer.label),
            distance = 2.5,
            onSelect = function() Buyers.open(buyer, ped) end,
        },
    }
    if buyer.tipsOff then
        options[#options + 1] = {
            name = 'cr-scraptheft:tip',
            icon = 'fas fa-comment-dots',
            label = locale('target_tip'),
            distance = 2.5,
            onSelect = function() tipOff(buyer) end,
        }
    end
    exports.ox_target:addLocalEntity(ped, options)
    return ped
end

local function setup(buyer)
    local state = { point = nil, ped = nil }

    local function despawn()
        if state.ped and DoesEntityExist(state.ped) then
            exports.ox_target:removeLocalEntity(state.ped)
            DeleteEntity(state.ped)
        end
        state.ped = nil
    end

    local function place(index)
        state.near = false
        if state.point then state.point:remove() end
        despawn()
        local loc = buyer.locations[index] or buyer.locations[1]

        state.point = lib.points.new({
            coords = loc.xyz,
            distance = 60.0,
            onEnter = function(self)
                state.near = true
                CreateThread(function()
                    while state.near and state.point == self do
                        local open = inHours(buyer)
                        if open and not state.ped then
                            state.ped = spawnPed(buyer, loc)
                        elseif not open and state.ped then
                            despawn()
                        end
                        Wait(10000)
                    end
                end)
            end,
            onExit = function()
                state.near = false
                despawn()
            end,
        })
    end

    place(GlobalState[('scrap:buyer:%s'):format(buyer.id)] or 1)
    AddStateBagChangeHandler(('scrap:buyer:%s'):format(buyer.id), 'global', function(_, _, value)
        place(value or 1)
    end)

    if buyer.blip and #buyer.locations == 1 then
        local loc = buyer.locations[1]
        local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
        SetBlipSprite(blip, buyer.blip.sprite)
        SetBlipColour(blip, buyer.blip.colour or 0)
        SetBlipScale(blip, buyer.blip.scale or 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(buyer.label)
        EndTextCommandSetBlipName(blip)
    end

    AddEventHandler('onResourceStop', function(name)
        if name == Shared.resource then despawn() end
    end)
end

for _, buyer in pairs(Shared.buyers) do setup(buyer) end

return Buyers
