local QBCore = exports['qb-core']:GetCoreObject()

--====================================================================================
------------------------------------------
--                EVENTS            --
------------------------------------------
--====================================================================================

RegisterNetEvent('am-scraptheft:steal',function(scrapObj, entity, securityToken)
    local pos = GetEntityCoords(PlayerId())
    local clientToken = securityToken
    local hasItem = exports['qb-inventory']:HasItem(Config.ItemNeeded, 1)

    if hasItem then
        QBCore.Functions.TriggerCallback('am-scraptheft:GetCops', function(copCount)

            if copCount >= Config.MinCops then

                --Alert Cops
                if Config.Dispatch == 'ps-dispatch' then
                    local chance = Config.CopsChance
                    local randomNumber = math.random()

                    if randomNumber <= chance then
                        exports["ps-dispatch"]:CustomAlert({
                            coords = {
                                x = pos.x,
                                y = pos.y,
                                z = pos.z
                            },
                            message = "Scrap Material Theft",
                            dispatchCode = "000",
                            priority = 2,
                            description = "Scrap Material Theft",
                            recipientList = 'police',
                            gender = true,
                            name = 'Caller: '..Config.DispatchCaller[math.random(1,#Config.DispatchCaller)]..' - '..Config.DispatchMsg[math.random(1,#Config.DispatchMsg)],
                            radius = 0,
                            sprite = 60,
                            color = 3,
                            scale = 1.0,
                            length = 3,
                        })
                    end
                end

                --Progress Bar
                QBCore.Functions.Progressbar('stealingscraps', 'Stealing Scraps', Config.ScrapTime, false, true,
                    {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    },
                    {
                        task = 'WORLD_HUMAN_WELDING',
                    },
                    {}, {}, function()
                        -- This code runs if the progress bar completes successfully

                        TriggerServerEvent('am-scraptheft:removescrap', entity)
                        TriggerServerEvent('am-scraptheft:reward', scrapObj, clientToken)

                        ClearPedTasks(PlayerPedId())

                    end, function()
                        -- This code runs if the progress bar gets cancelled
                        ClearPedTasks(PlayerPedId())
                end)

            else
                QBCore.Functions.Notify('Not enough cops online', 'error', 5000)
            end

        end)

    else
        QBCore.Functions.Notify('You need a '..Config.ItemNeeded..' to do this ', 'error', 5000)
    end

end)

--====================================================================================
------------------------------------------
--                Threads             --
------------------------------------------
--====================================================================================

--Target Exports: Get all the objects from the config and add them to qb-target
CreateThread(function()
    for i=1, #Config.ScrapObjects do
        local scrapObj = Config.ScrapObjects[i]
        exports['qb-target']:AddTargetModel(scrapObj.name, {
            options = {
                {
                    type = 'client',
                    icon = 'fa fa-print',
                    label = 'Steal Scraps',
                    --item = Config.RequiredItem, - TODO:
                    action = function(entity)
                        TriggerServerEvent('am-scraptheft:checkifscrapped', scrapObj,entity)

                    end
                },
            },
            distance = 1.5,
        })
    end
end)

--