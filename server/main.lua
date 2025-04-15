local scrappedObjects = {}

lib.callback.register('cr-scraptheft:checkIfScrapped', function(source, data)

    -- -- Validate required data
    -- if not data or not data.coords or not data.resource or not data.entity then
    --     print(('[cr-scraptheft] Invalid data received from %s'):format(source))
    --     return false
    -- end

    -- -- Check if resource is correct
    -- if data.resource ~= 'cr-scraptheft' then
    --     print(('[cr-scraptheft] WARNING: Callback triggered by non-owned resource (%s) from %s'):format(data.resource, source))
    --     return false
    -- end

    -- -- Check if the prop is already scrapped (within radius)
    -- for data, entry in pairs(scrappedObjects) do
    --     print(data.entity)
    -- end


    for _, entry in pairs(scrappedObjects) do
        -- entry is each individual table inside scrappedObjects
        --print("Checking entry with model:", entry.model)

        -- Check if the model matches
        if entry.model == data.model then
            --print("Model matches!")

            -- Check distance between coords using vector math
            local distance = #(entry.coords - data.coords)
            --print("Distance between coords:", distance)

            if distance <= Config.ScrapRadius then
                --print("Object is too close, already scrapped!")
                return true -- exit the function early
            end
        end
    end

    -- If loop finishes without returning true:
    print("No matching scrapped object found.")
    table.insert(scrappedObjects, data)
    --return false


    -- print(data.coords)
    -- print(data.model)

end)