local QBCore = exports['qb-core']:GetCoreObject()
local scrappedObj = {123456789}
local securityToken = math.random(1,99999999)

--====================================================================================
------------------------------------------
--                CALLBACKS            --
------------------------------------------
--====================================================================================

QBCore.Functions.CreateCallback('am-scraptheft:GetCops', function(source, cb)
	local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			amount = amount + 1
		end
	end
	cb(amount)
end)

--====================================================================================
------------------------------------------
--                EVENTS            --
------------------------------------------
--====================================================================================


RegisterNetEvent('am-scraptheft:removescrap', function(entity)
	table.insert(scrappedObj, entity)
end)

RegisterNetEvent('am-scraptheft:checkifscrapped', function(scrapObj, entity)
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
		TriggerClientEvent('am-scraptheft:steal', src, scrapObj, entity, securityToken)
	end

end)


RegisterNetEvent('am-scraptheft:reward', function(scrapObj, clientToken)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if clientToken == securityToken then
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

			Player.Functions.AddItem(rewardItem.item, rewardItemAmount)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem.item])
		end
	else
		print('WARNING - ID: '..src..' just attempted to receive a reward without a valid security token, possible lua injector')
	end



end)