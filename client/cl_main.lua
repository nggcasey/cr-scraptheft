local Config = require 'config.sh_config'

local modelNames = {} --Table of model names to pass to ox_target

for modelName in pairs(Config.ScrapObjects) do
    table.insert(modelNames, modelName)
end

local function startStealing(data)
    local model = GetEntityModel(data.entity)
    local ped = PlayerPedId()
    data.model = model
    data.coords = GetEntityCoords(data.entity, false)

    TaskTurnPedToFaceEntity(ped, data.entity)

    lib.callback('cr-scraptheft:checkIfScrapped', false, function(success)
        if success then

            --Skill Check
            local skillCheckPass = lib.skillCheck(Config.SkillCheck.difficulty, Config.SkillCheck.inputs)
            if skillCheckPass then

                --Start progress bar
                if lib.progressBar({
                    duration = Config.ScrapTime * 1000,
                    label = 'Stealing Scrap',
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        scenario = 'WORLD_HUMAN_WELDING',
                        duration = Config.ScrapTime * 1000,
                    },
                    disable = {
                        move = true
                    }
                })
                then
                    Utils.Notify("You passed the skill and progress yay")
                    Utils.AlertCops()
                    TriggerServerEvent('cr-scraptheft:server:requestreward', data)

                    ClearPedTasks(PlayerPedId())
                end
            else
                Utils.Notify("You passed failed the skill check boo")
            end

        else
            Utils.Notify("This has already been scrapped")
        end
    end, data)

end


exports.ox_target:addModel(modelNames, {
    distance = Config.TargetDistance,
    icon = 'fas fa-tools',
    label = 'Steal scraps',
    items = Config.RequiredItem,
    onSelect = function(data)
        startStealing(data)
    end
})