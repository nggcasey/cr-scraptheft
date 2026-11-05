--[[
    Builds what actually lands on the police side: who's calling and what they say,
    filled in from what's really happening (street, job, your getaway car) and how
    good a witness they are.
]]
local Shared = require 'shared.utils'

local people = Shared.people
local dcfg = Shared.dispatch
local pick, fill = Shared.pick, Shared.fill

local Reports = {}

-- Rough paint index -> colour word. Witnesses aren't paint experts either.
local COLOUR_RANGES = {
    { 0, 2, 'black' }, { 3, 11, 'silver' }, { 12, 13, 'black' }, { 14, 14, 'grey' }, { 15, 26, 'dark grey' },
    { 27, 35, 'red' }, { 36, 38, 'orange' }, { 39, 40, 'red' }, { 41, 41, 'orange' }, { 42, 42, 'yellow' },
    { 43, 48, 'dark red' }, { 49, 60, 'green' }, { 61, 87, 'blue' }, { 88, 89, 'yellow' }, { 90, 91, 'gold' },
    { 92, 92, 'green' }, { 93, 110, 'brown' }, { 111, 113, 'white' }, { 114, 120, 'grey' }, { 121, 134, 'white' },
    { 135, 137, 'pink' }, { 138, 138, 'orange' }, { 139, 140, 'green' }, { 141, 150, 'purple' },
}

local function colourName(index)
    for _, r in ipairs(COLOUR_RANGES) do
        if index >= r[1] and index <= r[2] then return r[3] end
    end
    return 'dark'
end

local function vehicleLabel(veh)
    local name = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local label = GetLabelText(name)
    return label ~= 'NULL' and label or name:lower()
end

function Reports.street(coords)
    local hash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local name = GetStreetNameFromHashKey(hash)
    return name ~= '' and name or 'the area'
end

---@return string text, table? info { label, colour, plate }
local function getaway(ctx)
    local s = dcfg.suspect
    local veh = GetVehiclePedIsIn(cache.ped, true)
    if veh == 0 or not DoesEntityExist(veh) or veh == ctx.vehicle then return '' end
    if #(GetEntityCoords(veh) - ctx.focus) > 60.0 then return '' end

    local primary = GetVehicleColours(veh)
    local info = { label = vehicleLabel(veh), colour = colourName(primary) }
    local text = ('Possible vehicle: %s %s'):format(info.colour, info.label)

    if math.random() < s.plateChance then
        local plate = GetVehicleNumberPlateText(veh):gsub('%s', '')
        info.plate = plate:sub(1, 3)
        text = ('%s, plate starting with %s'):format(text, info.plate)
    end
    return text .. '.', info
end

local function suspect()
    local s = dcfg.suspect
    local male = IsPedMale(cache.ped)
    if math.random() < s.wrongGenderChance then male = not male end
    local gender = male and 'male' or 'female'
    return ('%s%s %s %s'):format(pick(s.certainty) or '', pick(s.builds), gender, pick(s.clothing)), gender
end

---Generate a name from a type's nameFormats.
function Reports.makeName(def, male, street)
    local n = people.names
    if male == nil then male = math.random() < 0.5 end
    local vars = {
        first = pick(male and n.male or n.female),
        last = pick(n.last),
        nick = pick(n.nicknames),
        house = math.random(2, 48),
        street = street or 'the street',
    }
    return fill(pick(def.nameFormats) or '{first} {last}', vars), vars.first
end

---Every placeholder for a job (and optionally the persona involved).
function Reports.vars(ctx, persona)
    local n = people.names
    local item = ctx.profile.label:lower()
    local street = ctx.street or Reports.street(ctx.focus)
    ctx.street = street

    local vars = {
        item = item,
        target = ctx.request and ctx.request.label or 'car',
        street = street,
        neighbour = pick(math.random() < 0.5 and n.female or n.male),
    }

    local actions = ctx.profile.alert and ctx.profile.alert.actions
    vars.action = fill(pick(actions) or ('stealing a ' .. item), vars)
    vars.suspect, vars.gender = suspect()
    vars.vehicle, vars.getaway = getaway(ctx)

    if persona then
        vars.name, vars.first, vars.dog = persona.name, persona.first, persona.dog
    end
    return vars
end

---@param kind 'noise'|'witness'|'unseen'|'cop'|'alarm'|'viral'
---@return { caller: string, message: string, gender: string, street: string, getaway?: table }
function Reports.build(ctx, kind, persona)
    local vars = Reports.vars(ctx, persona)
    local caller, template

    if kind == 'witness' or kind == 'unseen' then
        caller = persona.name
        template = pick(persona.t and persona.t.report or persona.report)
    elseif kind == 'cop' then
        caller, template = pick(dcfg.cop.callers), pick(dcfg.cop.templates)
    elseif kind == 'alarm' then
        caller, template = pick(dcfg.alarm.callers), pick(dcfg.alarm.templates)
    elseif kind == 'viral' then
        vars.caption = persona and persona.caption or pick(dcfg.viral.captions)
        caller, template = pick(dcfg.viral.callers), pick(dcfg.viral.templates)
    end

    if not template then -- noise complaint (or a witness type with no lines of its own)
        if math.random() < (dcfg.classicChance or 0) then
            caller, template = caller or pick(dcfg.classicCallers), pick(dcfg.classicMessages)
        else
            caller, template = caller or pick(dcfg.noise.callers), pick(dcfg.noise.templates)
        end
    end

    -- Tidy: no dangling spaces from an empty {vehicle}; capitalise sentence starts.
    local message = fill(template, vars):gsub('%s+$', ''):gsub('%s%s+', ' ')
    message = message:gsub('^(%l)', string.upper):gsub('([%.!%?]%s+)(%l)', function(p, c) return p .. c:upper() end)

    return {
        caller = caller,
        message = message,
        gender = vars.gender,
        street = vars.street,
        getaway = vars.getaway,
    }
end

return Reports
