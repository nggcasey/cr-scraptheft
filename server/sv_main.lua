local Config = require 'config.sh_config'

local scrappedObjects = {}
local lastScrapTimes = {}

local function ClearExpiredScraps(now)

    if Config.ScrapResetTime == nil then
        warn('Config.ScrapResetTime is missing. Defaulting to 30 minutes. You can set the reset time in shared > config.lua ')
        Config.ScrapResetTime = 30
    end

    local resetTime = (Config.ScrapResetTime or 30) * 60 -- minutes -> seconds
    local removed = 0

    for i = #scrappedObjects, 1, -1 do
        if (now - scrappedObjects[i].timestamp) >= resetTime then
            table.remove(scrappedObjects, i)
            removed = removed + 1
        end
    end

    if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
        print(('[cr-scraptheft] Cleared %d expired scrapped objects. Remaining: %d'):format(removed, #scrappedObjects))
    end
end

local function ClearExpiredCooldowns(now)
    local expired = 0

    for src, lastTime in pairs(lastScrapTimes) do
        if (now - lastTime) > (Config.ScrapTime * 2) then
            -- If their last scrap was a long time ago (e.g., double the normal scrap time), clear it
            lastScrapTimes[src] = nil
            expired = expired + 1
        end
    end

    if expired > 0 and GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
        print(('[cr-scraptheft] Cleared %d expired cooldown entries.'):format(expired))
    end
end

local function RewardPlayer(src, model)
    local rewardsConfig = Config.ScrapObjects[model]
    if not rewardsConfig then
        warn(('Player %s tried to receive scrap reward for unknown model %s.'):format(src, tostring(model)))
        return
    end

    -- Determine how many different reward types to give
    local numRewards = math.random(rewardsConfig.minRewards, rewardsConfig.maxRewards)

    -- Shuffle reward entries so they get random ones
    local shuffledRewards = {}
    for _, reward in ipairs(rewardsConfig.rewards) do
        table.insert(shuffledRewards, reward)
    end
    -- Simple shuffle
    for i = #shuffledRewards, 2, -1 do
        local j = math.random(i)
        shuffledRewards[i], shuffledRewards[j] = shuffledRewards[j], shuffledRewards[i]
    end

    -- Give the selected number of random rewards
    for i = 1, numRewards do
        local reward = shuffledRewards[i]
        if reward then
            local item = reward.item
            local amount = math.random(reward.min, reward.max)
            exports.ox_inventory:AddItem(src, item, amount)

            if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
                print(('[cr-scraptheft] Gave %dx %s to player %s.'):format(amount, item, src))
            end
        end
    end

    -- Optional: Notify the player
    if Config.NotifySystem == 1 then --ox notify
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Success',
            description = 'You stole some scraps - Watch out for the cops!',
            type = 'success',
        })
    elseif Config.NotifySystem == 2 then --okokNotify
        TriggerClientEvent('okokNotify:Alert', src, 'Success', 'You stole some scraps - Watch out for the cops!', 5.0, 'success', false)
    else
        warn(('Unable to notify player - Please check Config.NotifySystem'))
    end
end

CreateThread(function()
    while true do
        local now = os.time()
        ClearExpiredScraps(now)
        ClearExpiredCooldowns(now)
        Wait(60000) -- Check every 60 seconds
    end
end)

AddEventHandler('playerDropped', function()
    lastScrapTimes[source] = nil
end)


lib.callback.register('cr-scraptheft:checkIfScrapped', function(source, data)
    -- Validate required data
    if not data or not data.coords or not data.resource or not data.entity then
        warn(('Invalid data received from %s'):format(source))
        return false
    end

    -- Ensure callback is triggered only by the correct resource
    if data.resource ~= 'cr-scraptheft' then
        error(('Unauthorized resource (%s) attempted to call checkIfScrapped (source %s)'):format(data.resource, source))
        return false
    end

    -- Check if the object has already been scrapped
    for _, entry in pairs(scrappedObjects) do
        if entry.model == data.model then
            local distance = #(entry.coords - data.coords)
            if distance <= Config.ScrapRadius then
                if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
                    print(('Scrap blocked: already scrapped within radius (Distance: %.2f)'):format(distance))
                end
                return false
            end
        end
    end

    return true
end)

RegisterNetEvent('cr-scraptheft:server:requestreward', function(data)
    local src = source
    local ped = GetPlayerPed(src)

    --Validate basic data
    if not data or not data.model or not data.coords then
        warn(('Possible Exploits: Player ID: %s sent invalid scrap reward request'):format(src))
        return
    end

    --Validate model
    if not Config.ScrapObjects[data.model] then
        warn(('Possible Exploits: Player ID: %s tried to scrap invalid object model %s'):format(src, tostring(data.model)))
        return
    end

    --Validate player proximity to object
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - data.coords)

    if distance > (Config.TargetDistance * 10) then --Allow 10x radius to avoid slight issues: TODO - Rework logic
        warn(('Possible Exploits: Player ID: %s tried to scrap from too far away (%.2f meters).'):format(src, distance))
        return
    end

    --Required Item Check
    local hasItem = exports.ox_inventory:Search(source, 'count', Config.RequiredItem) > 0

    if not hasItem then
        warn(('Possible Exploits: Player ID %s tried to scrap without required item (%s).'):format(source, Config.RequiredItem))
        return
    end

    --Cooldown check
    local now = os.time()
    if lastScrapTimes[src] and (now - lastScrapTimes[src]) < Config.ScrapTime then
        warn(('Possible Exploits: Player %s is trying to scrap faster than allowed (%d seconds cooldown).'):format(src, Config.ScrapTime))
        return
    end

    lastScrapTimes[src] = now

    RewardPlayer(src, data.model)

    -- Insert the new scrapped object
    table.insert(scrappedObjects, {
        model = data.model,
        coords = data.coords,
        timestamp = os.time()
    })

    if GetConvar('cr-scraptheft_debugMode', 'false') == 'true' then
        print(('[cr-scraptheft] Scrap added (Total scrapped objects: %d)'):format(#scrappedObjects))
    end
end)
