local Shared = require 'shared.utils'
local config = Shared.config

local Dispatch = {}

local function pick(list) return list[math.random(#list)] end

---@param profile table
---@param coords vector3
---@param witnessed boolean true when a witness phoned it in (vs. a noise report)
function Dispatch.send(profile, coords, witnessed)
    local heat = config.Heat
    local alert = profile.alert or {}
    local title = alert.title or 'Theft in progress'
    local caller = ('%s - %s'):format(pick(heat.callers), pick(heat.messages))
    if not witnessed then caller = ('%s (%s)'):format(caller, locale('dispatch_noise')) end

    lib.print.debug(('dispatch: %s @ %s'):format(title, coords))

    if config.Dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:CustomAlert({
            message = title,
            code = alert.code or '10-62',
            icon = 'fas fa-screwdriver-wrench',
            priority = 2,
            coords = coords,
            name = caller,
            jobs = { 'leo' },
            alert = { radius = 0, sprite = 431, color = 1, scale = 1.0, length = 3, flash = false },
        })
    elseif config.Dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = { 'police' },
            coords = coords,
            title = title,
            message = caller,
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, scale = 1.2, colour = 3, flashes = false,
                text = title, time = 5, radius = 10,
            },
        })
    elseif config.Dispatch == 'custom' then
        -- Hook your own dispatch here.
        -- TriggerServerEvent('my-dispatch:alert', { title = title, message = caller, coords = coords })
    end
end

return Dispatch
