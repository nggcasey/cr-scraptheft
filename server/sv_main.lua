local QBCore = exports['qb-core']:GetCoreObject()
local scrappedObj = {123456789}
local securityToken = math.random(1,99999999)

--====================================================================================
------------------------------------------
--                CALLBACKS            --
------------------------------------------
--====================================================================================

if Config.Framework == 'qb' then
    -- Old qb framework approach
    QBCore.Functions.CreateCallback('cr-scraptheft:GetCops', function(source, cb)
        local amount = 0
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
                amount = amount + 1
            end
        end
        cb(amount)
    end)
	elseif Config.Framework == 'qbx' then
		-- New qbx framework approach
		QBCore.Functions.CreateCallback('cr-scraptheft:GetCops', function(source, cb)
			local copCount = exports.qbx_core:GetDutyCountType('leo')
			cb(copCount)
		end)
	else
		-- Handle default or invalid configuration
		print("Invalid or unspecified framework in Config.Framework.")
end


--====================================================================================
------------------------------------------
--                EVENTS            --
------------------------------------------
--====================================================================================


RegisterNetEvent('cr-scraptheft:removescrap', function(entity)
	table.insert(scrappedObj, entity)
end)

RegisterNetEvent('cr-scraptheft:checkifscrapped', function(scrapObj, entity)
	local src = source
	local isScrapped = false

	--Loop through scrapped object list, if scrapped object found return true and break
	for i=1, #scrappedObj do
		if scrappedObj[i] == entity then
			isScrapped = true
			break
		end
	end

	if isScrapped then
		TriggerClientEvent('QBCore:Notify', src, 'Thieves have stolen all of the valuable materials from this!', 'error', 5000)
	else
		TriggerClientEvent('cr-scraptheft:steal', src, scrapObj, entity, securityToken)
	end

end)


RegisterNetEvent('cr-scraptheft:reward', function(scrapObj, clientToken)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if clientToken == securityToken then
        local minRewards = scrapObj.minRewards
        local maxRewards = scrapObj.maxRewards
        local rewardAmount = math.random(minRewards, maxRewards)

        local rewardsGiven = {} -- Table to hold details of rewards given

        -- Give random reward items
        for i = 1, rewardAmount do
            -- Select a random reward from the rewards table
            local rewardIndex = math.random(1, #scrapObj.rewards)
            local rewardItem = scrapObj.rewards[rewardIndex]  -- Direct indexing from the table
            local rewardItemMin = rewardItem.min
            local rewardItemMax = rewardItem.max
            local rewardItemAmount = math.random(rewardItemMin, rewardItemMax)

            -- Add the item to the player's inventory
            if Config.Framework == 'qb' then
                local canAdd = exports['qb-inventory']:CanAddItem(src, rewardItem.item, rewardItemAmount)
                if canAdd then
                    Player.Functions.AddItem(rewardItem.item, rewardItemAmount)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem.item])

                    -- Add reward details to the log table
                    table.insert(rewardsGiven, string.format("%s x%d", rewardItem.item, rewardItemAmount))
                else
                    TriggerClientEvent('QBCore:Notify', src, 'You cannot carry anymore items', 'error', 5000)
                    return
                end
            end

            if Config.Framework == 'qbx' then
                local canAdd = exports.ox_inventory:CanCarryItem(src, rewardItem.item, rewardItemAmount)
                if canAdd then
                    exports.ox_inventory:AddItem(src, rewardItem.item, rewardItemAmount)

                    -- Add reward details to the log table
                    table.insert(rewardsGiven, string.format("%s x%d", rewardItem.item, rewardItemAmount))
                else
                    exports.qbx_core:Notify(src, 'You cannot carry anymore items', 'error', 5000)
                end

            end

        end

        -- Retrieve player details
        local characterName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        local citizenID = Player.PlayerData.citizenid

        -- Create a message string with all rewards and player details
        local message = string.format("%s (%d) [%s] received the following rewards: %s", characterName, src, citizenID, table.concat(rewardsGiven, ", "))

        -- Trigger the logging event
        TriggerEvent('qb-log:server:CreateLog', 'playerevents', 'Received Scrap Items', 'green', message, false, nil)
    else
        print('WARNING - ID: '..src..' just attempted to receive a reward without a valid token.')
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Scrap Items (cr-scraptheft)', 'red', string.format("%s (%d) [%s] just attempted to recieve a reward without a valid token (POSSIBLE LUA INJECTOR)", characterName, src, citizenID), true, nil)
    end
end)