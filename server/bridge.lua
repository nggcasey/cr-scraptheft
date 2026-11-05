local config = require 'config.shared'

local Bridge = {}

local fw = config.Framework
if fw == 'auto' then
    if GetResourceState('qbx_core') == 'started' then fw = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then fw = 'qb'
    elseif GetResourceState('es_extended') == 'started' then fw = 'esx'
    else fw = 'standalone' end
end
Bridge.framework = fw

local QB, ESX
if fw == 'qb' then QB = exports['qb-core']:GetCoreObject()
elseif fw == 'esx' then ESX = exports.es_extended:getSharedObject() end

local function getPlayer(src)
    if fw == 'qbx' then return exports.qbx_core:GetPlayer(src) end
    if fw == 'qb' then return QB.Functions.GetPlayer(src) end
    if fw == 'esx' then return ESX.GetPlayerFromId(src) end
end

function Bridge.identifier(src)
    local player = getPlayer(src)
    if fw == 'qbx' or fw == 'qb' then return player and player.PlayerData.citizenid end
    if fw == 'esx' then return player and player.identifier end
    return GetPlayerIdentifierByType(src, 'license')
end

function Bridge.notify(src, text, kind)
    if config.Notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, '', text, 5000, kind or 'info', false)
    else
        TriggerClientEvent('ox_lib:notify', src, { description = text, type = kind or 'inform' })
    end
end

---@param dirty boolean
function Bridge.pay(src, amount, dirty)
    if amount <= 0 then return true end

    if dirty then
        if config.Payout.markedBills then
            return exports.ox_inventory:AddItem(src, 'markedbills', 1, { worth = amount })
        end
        return exports.ox_inventory:AddItem(src, config.Payout.dirtyItem, amount)
    end

    local account = config.Payout.cleanAccount
    local player = getPlayer(src)
    if (fw == 'qbx' or fw == 'qb') and player then
        return player.Functions.AddMoney(account, amount, 'thief-sale')
    elseif fw == 'esx' and player then
        if account == 'cash' or account == 'money' then player.addMoney(amount, 'Thief sale')
        else player.addAccountMoney(account, amount, 'Thief sale') end
        return true
    end
    return exports.ox_inventory:AddItem(src, 'money', amount)
end

function Bridge.removeMoney(src, amount)
    if amount <= 0 then return true end
    local account = config.Payout.cleanAccount
    local player = getPlayer(src)
    if (fw == 'qbx' or fw == 'qb') and player then
        return player.Functions.RemoveMoney(account, amount, 'thief-payoff')
    elseif fw == 'esx' and player then
        if player.getMoney() < amount then return false end
        player.removeMoney(amount, 'Payoff')
        return true
    end
    return exports.ox_inventory:RemoveItem(src, 'money', amount)
end

function Bridge.policeCount()
    if fw == 'qbx' then
        local ok, count = pcall(exports.qbx_core.GetDutyCountType, exports.qbx_core, 'leo')
        if ok and count then return count end
    end

    local count = 0
    for _, id in ipairs(GetPlayers()) do
        local player = getPlayer(tonumber(id))
        if player then
            if fw == 'esx' then
                if config.PoliceJobs[player.job.name] then count += 1 end
            else
                local job = player.PlayerData and player.PlayerData.job
                if job and job.onduty and (job.type == 'leo' or config.PoliceJobs[job.name]) then count += 1 end
            end
        end
    end
    return count
end

local ownedTable = config.Vehicles.ownedTable
if ownedTable == 'auto' then ownedTable = fw == 'esx' and 'owned_vehicles' or 'player_vehicles' end

function Bridge.isOwnedPlate(plate)
    if not config.Vehicles.protectOwned or GetResourceState('oxmysql') ~= 'started' then return false end
    local p = promise.new()
    exports.oxmysql:scalar(('SELECT 1 FROM `%s` WHERE plate = ? LIMIT 1'):format(ownedTable), { plate }, function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p) ~= nil
end

return Bridge
