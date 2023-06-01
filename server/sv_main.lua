local QBCore = exports['qb-core']:GetCoreObject()

--====================================================================================
------------------------------------------
--                EVENTS            --
------------------------------------------
--====================================================================================

RegisterNetEvent('am-scraptheft:reward', function(scrapObj)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	local minRewards = scrapObj.minRewards
	local maxRewards = scrapObj.maxRewards
    local rewardAmount = math.random(minRewards,maxRewards)

    --Give random reward items
    for i=1, rewardAmount do
		local rewardIndex = math.random(1,#scrapObj.rewards)
		local rewardItem = scrapObj.rewards[rewardIndex]
		local rewardItemMin = rewardItem.min
		local rewardItemMax = rewardItem.max
		local rewardItemAmount = math.random(rewardItemMin, rewardItemMax)

		print('ID: '..src..' got '..rewardItemAmount..' of '..rewardItem.item)
		Player.Functions.AddItem(rewardItem.item, rewardItemAmount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem.item])
	end

end)