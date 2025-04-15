local modelNames = {}

for modelName in pairs(Config.ScrapObjects) do
    table.insert(modelNames, modelName)
end

exports.ox_target:addModel(modelNames, {
    distance = 2,
    icon = 'fas fa-tools',
    label = 'Steal scraps',
    --items = Config.RequiredItem,
    onSelect = function(data)

        local model = GetEntityModel(data.entity)
        data.model = model
        data.coords = GetEntityCoords(data.entity, false)


        lib.callback('cr-scraptheft:checkIfScrapped', false, function(success)
            if success then
                print('success')
            else
                print('scrapped already')
            end
        end, data)
    end
})



-- local entity = data.entity
-- local coords = GetEntityCoords(entity)
-- local model = GetEntityModel(entity)
-- local modelName = GetEntityArchetypeName(entity) or 'unknown'

-- print(coords, model, modelName)

-- lib.callback('cr-scrapyard:tryScrap', false, function(success)
--     if success then
--         -- Proceed with reward logic here
--         lib.notify({ type = 'success', description = 'Success!' })
--     else
--         lib.notify({ type = 'error', description = 'This has already been scrapped!' })
--     end
-- end, model, coords)