local Config = require 'config.sh_config'

Utils = {}

    ----------------------------------------------
    --        Notification System
    ----------------------------------------------
function Utils.Notify(text, type, duration)
    if not text or text == "" then return end

    local notifySystem = Config.NotifySystem

    if notifySystem == 1 then --ox notify
        lib.notify({
            description = text,
            duration = duration or 5000,
            type = type or 'inform'
        })
    elseif notifySystem == 2 then --okokNotify
        exports['okokNotify']:Alert(
            "",
            text,
            duration or 5000,
            type or 'info',
            true
        )
    else
        print(('^1[ERROR]^0 Invalid NotifySystem configured: %s'):format(notifySystem))
    end
end

function Utils.AlertCops(coords)
    --Alert Cops
    local chance = Config.CopsChance
    local randomNumber = math.random()
    local pos = GetEntityCoords(PlayerPedId())

    if randomNumber <= chance then

        if Config.Dispatch == 'ps-dispatch' then
            exports["ps-dispatch"]:CustomAlert({
                message = 'Scrap Material Theft',
                code = '484',
                name = tostring('%s - %s'):format(Config.DispatchCaller[math.random(1,#Config.DispatchCaller)], Config.DispatchMsg[math.random(1,#Config.DispatchMsg)]) or 'Thieves stealing',
            })
        elseif Config.Dispatch =='cd_dispatch' then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = {'police', },
                coords = data.coords,
                title = 'Scrap Material Theft',
                message = tostring('%s - %s'):format(Config.DispatchCaller[math.random(1,#Config.DispatchCaller)], Config.DispatchMsg[math.random(1,#Config.DispatchMsg)]) or 'Thieves stealing',
                flash = 0,
                unique_id = data.unique_id,
                sound = 1,
                blip = {
                    sprite = 431,
                    scale = 1.2,
                    colour = 3,
                    flashes = false,
                    text = 'Scrap Material Theft',
                    time = 5,
                    radius = 10,
                }
            })
        end

    end
end


