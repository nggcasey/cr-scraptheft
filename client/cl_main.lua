local QBCore = exports['qb-core']:GetCoreObject()

--====================================================================================
------------------------------------------
--                EVENTS            --
------------------------------------------
--====================================================================================


RegisterNetEvent('am-scraptheft:steal',function(scrapObj)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local model = GetEntityModel(entity)

    --Alert Cops
    local chance = Config.CopsChance
    local randomNumber = math.random()
    print(randomNumber)

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
            name = 'Concerned Resident: Filthy thieves are stealing copper again, they need to get a bloody job!',
            radius = 0,
            sprite = 60,
            color = 3,
            scale = 1.0,
            length = 3,
        })
    end



    QBCore.Functions.Progressbar('stealingscraps', 'Stealing Scraps', Config.ScrapTime, false, true,
        {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        {
            animDict = nil,
            anim = nil,
            flags = nil,
            task = 'WORLD_HUMAN_WELDING',
        },
        {}, {}, function()
            print('Items successfully stolen')
            ClearPedTasks(ped)
            TriggerServerEvent('am-scraptheft:reward', scrapObj)

            -- This code runs if the progress bar completes successfully

        end, function()
            ClearPedTasks(ped)
            print('Cancelled stealing shit...pussy')
            -- This code runs if the progress bar gets cancelled
    end)

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
						TriggerEvent('am-scraptheft:steal', scrapObj)
                    end
                },
            },
            distance = 1.5,
        })
    end
end)

--