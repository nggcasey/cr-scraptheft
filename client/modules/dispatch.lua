local Shared = require 'shared.utils'
local config = Shared.config

local Dispatch = {}

---@param profile table
---@param coords vector3
---@param report { caller: string, message: string, gender: string, street: string, getaway?: table }
function Dispatch.send(profile, coords, report)
    local alert = profile.alert or {}
    local title = alert.title or 'Theft in progress'
    local line = ('%s - %s'):format(report.caller, report.message)
    local car = report.getaway

    lib.print.debug(('dispatch [%s] %s'):format(title, line))

    if config.Dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:CustomAlert({
            message = title,
            code = alert.code or '10-62',
            icon = 'fas fa-screwdriver-wrench',
            priority = 2,
            coords = coords,
            name = line,
            gender = report.gender,
            street = report.street,
            vehicle = car and car.label or nil,
            color = car and car.colour or nil,
            plate = car and car.plate or nil,
            jobs = { 'leo' },
            alert = { radius = 0, sprite = 431, color = 1, scale = 1.0, length = 3, flash = false },
        })
    elseif config.Dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = { 'police' },
            coords = coords,
            title = title,
            message = line,
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, scale = 1.2, colour = 3, flashes = false,
                text = title, time = 5, radius = 10,
            },
        })
    elseif config.Dispatch == 'custom' then
        -- Hook your own dispatch here. `report` has caller, message, gender, street, getaway.
        -- TriggerServerEvent('my-dispatch:alert', { title = title, message = line, coords = coords })
    end
end

return Dispatch
