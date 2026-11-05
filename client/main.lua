local Shared = require 'shared.utils'
local U = require 'client.modules.util'
local Theft = require 'client.modules.theft'
local Spots = require 'client.modules.spots'

require 'client.modules.carry'
require 'client.modules.loot'
require 'client.modules.vehicles'
if Shared.config.EnableBuyers then require 'client.modules.buyers' end

-- World-object jobs (A/C units, electrical cabinets, generators, ...)
for id, profile in pairs(Shared.profiles) do
    if profile.kind == 'prop' then
        exports.ox_target:addModel(profile.models, {
            {
                name = 'cr-scraptheft:' .. id,
                icon = profile.target.icon,
                label = profile.target.label,
                distance = profile.target.distance or 2.0,
                canInteract = function(entity)
                    -- map props are never networked; networked copies are loot / someone else's props
                    if Theft.busy or NetworkGetEntityIsNetworked(entity) then return false end
                    if Spots.isStripped(entity) then return false end
                    return U.hasAnyTool(profile)
                end,
                onSelect = function(data)
                    Theft.run(Theft.propContext(profile, data.entity))
                end,
            },
        })
    end
end

RegisterCommand('scraprep', function()
    local rep = lib.callback.await('cr-scraptheft:getRep', false)
    if not rep then return end
    local text = rep.next and locale('rep_progress_short', rep.label, rep.xp, rep.next) or locale('rep_max_short', rep.label, rep.xp)
    U.notify(text, 'inform', 6000)
end, false)
TriggerEvent('chat:addSuggestion', '/scraprep', locale('cmd_rep'))
