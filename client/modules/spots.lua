--[[
    Stripped world objects. The server publishes them in GlobalState; every client hides
    the original map prop (or swaps it for a damaged version) until it respawns.
]]
local Shared = require 'shared.utils'
local U = require 'client.modules.util'

local Spots = {}
local applied = {}   -- [spotId] = { data, replacement }
local swaps = {}     -- [entity] = true (local replacement props, never targetable)

local HIDE_RADIUS = 0.6

local function apply(id, s)
    local c = s.coords
    local entry = { data = s }
    if s.hide or s.swap then
        CreateModelHide(c.x, c.y, c.z, HIDE_RADIUS, s.model, true)
    end
    if s.swap and IsModelInCdimage(s.swap) then
        local obj = U.spawnProp(s.swap, c, { network = false, heading = s.heading, freeze = true })
        swaps[obj] = true
        entry.replacement = obj
    end
    applied[id] = entry
end

local function restore(id)
    local entry = applied[id]
    applied[id] = nil
    local s, c = entry.data, entry.data.coords
    if s.hide or s.swap then
        RemoveModelHide(c.x, c.y, c.z, HIDE_RADIUS, s.model, false)
    end
    if entry.replacement then
        swaps[entry.replacement] = nil
        U.delete(entry.replacement)
    end
end

local function sync(spots)
    spots = spots or {}
    for id in pairs(applied) do
        if not spots[id] then restore(id) end
    end
    for id, s in pairs(spots) do
        if not applied[id] then apply(id, s) end
    end
end

function Spots.isStripped(entity)
    if swaps[entity] then return true end
    return applied[Shared.spotId(GetEntityModel(entity), GetEntityCoords(entity))] ~= nil
end

AddStateBagChangeHandler('thief:spots', 'global', function(_, _, value)
    sync(value)
end)

CreateThread(function()
    sync(GlobalState['thief:spots'])
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= Shared.resource then return end
    for id in pairs(applied) do restore(id) end
end)

return Spots
