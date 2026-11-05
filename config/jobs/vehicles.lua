--[[ cr-thief :: vehicle jobs. Field reference: config/jobs/README.md ]]
local A = require 'config.jobs.anims'
local FX = A.fx

return {
    ---------------------------------------------------------------------------
    catalytic = {
        category = 'vehicle',
        kind = 'vehicle',
        part = 'cat',
        label = 'Catalytic converter',
        target = { label = 'Cut catalytic converter', icon = 'fas fa-screwdriver-wrench', distance = 2.5 },
        minCops = 0,
        rep = 4,
        alarm = 0.6,        -- chance a LOCKED car's alarm goes off when you slide under it
        alert = { title = 'Catalytic Converter Theft', code = '10-62', actions = { 'lying under a {target} with a grinder', 'cutting the exhaust off a {target}', 'sawing something off the bottom of a {target}' } },

        stages = {
            {
                label = 'Sliding under the vehicle',
                duration = 2500, anim = A.mechanic, noise = 0.0,
            },
            {
                label = 'Cutting the exhaust pipe',
                duration = 12000, tool = 'cutter', anim = A.mechanic, noise = 0.18,
                steps = 2, skill = { difficulty = { 'easy', 'medium', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = FX.sparks.asset, name = FX.sparks.name, scale = 0.7, on = 'target', offset = vec3(0.0, 0.0, -0.35) },
            },
            {
                label = 'Working the converter loose',
                duration = 4000, anim = A.mechanic, noise = 0.03,
                skill = { difficulty = { 'medium' }, inputs = { 'e' } },
            },
        },

        loot = {
            { item = 'catalytic_converter', count = { 1, 1 }, value = { 220, 420 }, model = 'imp_prop_impexp_exhaust_01' },
        },
    },
    ---------------------------------------------------------------------------
    wheel = {
        category = 'vehicle',
        kind = 'vehicle',
        part = 'wheel',
        label = 'Wheel',
        target = { label = 'Steal wheel', icon = 'fas fa-circle-dot', distance = 2.0 },
        minCops = 0,
        rep = 2,
        alarm = 0.5,
        alert = { title = 'Vehicle Tampering', code = '10-62', actions = { 'jacking up a {target}', 'taking the wheels off a {target}', 'leaving a {target} on bricks' } },

        stages = {
            {
                label = 'Jacking up the corner',
                duration = 5000, tool = 'jack', anim = A.crouch, noise = 0.03,
                place = { model = 'prop_carjack', at = 'wheel' },
            },
            {
                label = 'Cracking the lug nuts',
                duration = 8000, tool = 'wrench', anim = A.crouch, noise = 0.02,
                steps = 5, stepLabel = 'Lug nut %d/%d', skill = { difficulty = { 'easy' }, inputs = { 'e' } },
            },
            {
                label = 'Pulling the wheel',
                duration = 2500, anim = A.crouch, noise = 0.02,
                effect = 'removeWheel',
                debris = { model = 'prop_conc_blocks01a', at = 'wheel', freeze = true },
            },
        },

        loot = {
            { item = 'stolen_wheel', label = 'Wheel', count = { 1, 1 }, value = { 70, 150 }, carry = true, model = 'prop_wheel_01',
              attach = { bone = 60309, pos = vec3(0.1, 0.25, 0.2), rot = vec3(-145.0, 290.0, 0.0) } },
        },
    },
    ---------------------------------------------------------------------------
    car_breakin = {
        category = 'vehicle',
        kind = 'vehicle',
        part = 'glovebox',
        label = 'Car break-in',
        target = { label = 'Break into car', icon = 'fas fa-car-burst', distance = 1.6 },
        minCops = 0,
        rep = 1,
        heat = 1,
        alarm = 0.7,
        directLoot = true,     -- straight into your pockets
        alert = { title = 'Vehicle Break-in', code = '10-62', actions = {
            'smashing the window of a {target}', 'breaking into a {target}', 'rummaging around inside a {target}',
        } },

        stages = {
            {
                label = 'Smashing the window',
                duration = 1600, anim = A.smash, noise = 0.12,
                effect = 'smashWindow',
            },
            {
                label = 'Rummaging through the glovebox',
                duration = 6000, anim = A.search, noise = 0.0,
                steps = 2, skill = { difficulty = { 'easy' }, inputs = { 'e' } },
            },
        },

        loot = {
            { item = 'money', count = { 5, 80 }, chance = 0.7 },
            { item = 'stolen_phone', count = { 1, 1 }, chance = 0.25 },
            { item = 'stolen_gps', count = { 1, 1 }, chance = 0.2 },
            { item = 'sunglasses', count = { 1, 1 }, chance = 0.25 },
            { item = 'stolen_laptop', count = { 1, 1 }, chance = 0.06 },
        },
    },

    ---------------------------------------------------------------------------
    battery = {
        category = 'vehicle',
        kind = 'vehicle',
        part = 'battery',
        label = 'Car battery',
        target = { label = 'Steal the battery', icon = 'fas fa-car-battery', distance = 2.0 },
        minCops = 0,
        rep = 2,
        heat = 1,
        alarm = 0.5,
        alert = { title = 'Vehicle Tampering', code = '10-62', actions = {
            'under the bonnet of a {target}', 'pulling the battery out of a {target}', 'messing with the engine of a {target}',
        } },

        stages = {
            {
                label = 'Popping the bonnet',
                duration = 3500, tool = 'crowbar', anim = A.repair, noise = 0.08,
                effect = 'openHood',
            },
            {
                label = 'Undoing the terminals',
                duration = 5000, tool = 'wrench', anim = A.hood, noise = 0.02,
                steps = 2, skill = { difficulty = { 'easy' }, inputs = { 'e' } },
                ptfx = { asset = FX.wire.asset, name = FX.wire.name, scale = 0.3, on = 'target', offset = vec3(0.0, 1.4, 0.4) },
            },
            {
                label = 'Lifting it out',
                duration = 2500, anim = A.hood, noise = 0.0,
            },
        },

        loot = {
            { item = 'car_battery', label = 'Car battery', count = { 1, 1 }, carry = true, model = 'prop_car_battery_01' },
        },
    },
}
