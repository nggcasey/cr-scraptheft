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

local alertTimeOut = false --Not used anywhere else
function Utils.AlertCops(coords)
    if alertTimeOut then
        if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
            print("Alerts suppressed due to cooldown")
        end
        return
    end

    --Alert Cops
    local chance = Config.CopsChance
    local randomNumber = math.random()
    local pos = GetEntityCoords(PlayerPedId())

    if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
        print(string.format("Settings: Random Number: %s | Config.CopsChance: %s", tostring(randomNumber), tostring(chance)))
        if randomNumber <= chance then
            print("Random number less than chance - Police WILL be alerted")
        else
            print("Random number greater than chance - Police will NOT be alerted")
        end
    end

    if randomNumber <= chance then

        if Config.Dispatch == 'ps-dispatch' then
            exports["ps-dispatch"]:CustomAlert({
                message = 'Scrap Material Theft',
                code = '484',
                coords = coords,
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
        alertTimeOut = true
        if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
            print("Start alert timeout for "..Config.AlertCooldown..' milliseconds')
        end

        SetTimeout(Config.AlertCooldown, function()
            alertTimeOut = false
            if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
                print('Alert timeout finished')
            end
        end)

    end
end


