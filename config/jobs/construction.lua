--[[ cr-thief :: construction site jobs. Field reference: config/jobs/README.md ]]
local A = require 'config.jobs.anims'
local FX = A.fx

return {
    ---------------------------------------------------------------------------
    generator = {
        category = 'construction',
        kind = 'prop',
        label = 'Site generator',
        models = { 'prop_generator_03b', 'prop_generator_04' },
        target = { label = 'Steal generator', icon = 'fas fa-car-battery', distance = 1.8 },
        respawn = 45,
        minCops = 1,
        rep = 4,
        alert = { title = 'Plant Theft', code = '10-62', actions = { 'stealing a generator off the building site', 'cutting the chain on a site generator', 'carting off construction equipment' } },

        stages = {
            {
                label = 'Disconnecting the leads',
                duration = 4000, tool = 'boltcutters', anim = A.kneel, noise = 0.03,
            },
            {
                label = 'Cutting the security chain',
                duration = 7000, tool = 'cutter', anim = A.weld, noise = 0.2,
                skill = { difficulty = { 'easy', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = FX.sparks.asset, name = FX.sparks.name, scale = 0.6, on = 'target', offset = vec3(0.0, 0.0, 0.3) },
            },
            {
                label = 'Heaving it off the stand',
                duration = 3000, anim = A.rummage, noise = 0.02,
                skill = { difficulty = { 'medium', 'medium' }, inputs = { 'e' } },
            },
        },

        loot = {
            { item = 'portable_generator', label = 'Generator', count = { 1, 1 }, carry = true, model = 'source' },
        },
        hide = true,
    },
    ---------------------------------------------------------------------------
    toolchest = {
        category = 'construction',
        kind = 'prop',
        label = 'Tool chest',
        models = { 'prop_toolchest_01', 'prop_toolchest_02', 'prop_toolchest_03', 'prop_toolchest_04', 'prop_toolchest_05' },
        target = { label = 'Break into tool chest', icon = 'fas fa-toolbox', distance = 1.6 },
        respawn = 45,
        rep = 3,
        heat = 2,
        alert = { title = 'Site Theft', code = '10-62', actions = {
            'breaking into a tool chest', 'cleaning out the tradies\' tools', 'raiding a building site',
        } },

        stages = {
            {
                label = 'Prying the lock',
                duration = 5000, tool = 'crowbar', anim = A.repair, noise = 0.12,
                skill = { difficulty = { 'easy', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
            },
            {
                label = 'Picking through the drawers',
                duration = 4500, anim = A.rummage, noise = 0.03,
            },
        },

        -- Steal the tools you need for bigger jobs. Or sell them.
        loot = {
            { item = 'power_drill', count = { 1, 1 }, chance = 0.5 },
            { item = 'nail_gun', count = { 1, 1 }, chance = 0.25 },
            { item = 'screwdriverset', count = { 1, 1 }, chance = 0.3 },
            { item = 'lug_wrench', count = { 1, 1 }, chance = 0.2 },
            { item = 'crowbar', count = { 1, 1 }, chance = 0.15 },
            { item = 'bolt_cutters', count = { 1, 1 }, chance = 0.15 },
            { item = 'angle_grinder', count = { 1, 1 }, chance = 0.1 },
        },
        bundle = { model = 'prop_tool_box_04', label = 'Armful of tools' },
    },

    ---------------------------------------------------------------------------
    cable_drum = {
        category = 'construction',
        kind = 'prop',
        label = 'Cable drum',
        models = { 'prop_cablespool_01a', 'prop_cablespool_01b', 'prop_cablespool_02', 'prop_cablespool_03', 'prop_cablespool_04', 'prop_cablespool_05', 'prop_cablespool_06' },
        target = { label = 'Strip copper cable', icon = 'fas fa-dharmachakra', distance = 2.0 },
        respawn = 40,
        rep = 2,
        heat = 2,
        alert = { title = 'Copper Theft', code = '10-62', actions = { 'unspooling copper cable off a drum', 'stealing cable from the building site' } },

        stages = {
            {
                label = 'Cutting the strapping',
                duration = 3500, tool = 'boltcutters', anim = A.kneel, noise = 0.04,
            },
            {
                label = 'Unspooling the cable',
                duration = 9000, anim = A.rummage, noise = 0.03,
                steps = 3, stepLabel = 'Unspooling (%d/%d)', skill = { difficulty = { 'easy' }, inputs = { 'e' } },
            },
        },

        loot = { { item = 'copper_wire', count = { 4, 8 } } },
        bundle = { model = 'prop_cs_rub_binbag_01', label = 'Coil of copper cable' },
    },

    ---------------------------------------------------------------------------
    pipe_stack = {
        category = 'construction',
        kind = 'prop',
        label = 'Pipe stack',
        models = { 'prop_pipes_01a', 'prop_pipes_01b', 'prop_pipes_02a', 'prop_pipes_02b', 'prop_pipes_03a', 'prop_pipes_03b', 'prop_pipes_05a' },
        target = { label = 'Take some pipe', icon = 'fas fa-grip-lines', distance = 2.2 },
        respawn = 40,
        rep = 2,
        heat = 2,
        alert = { title = 'Site Theft', code = '10-62', actions = { 'carrying pipes off the building site', 'cutting the bands on a pipe stack' } },

        stages = {
            {
                label = 'Cutting the bands',
                duration = 4000, tool = 'boltcutters', anim = A.kneel, noise = 0.05,
            },
            {
                label = 'Sliding a bundle out',
                duration = 3500, anim = A.rummage, noise = 0.06,
                skill = { difficulty = { 'medium' }, inputs = { 'e' } },
            },
        },

        loot = { { item = 'pipe_bundle', label = 'Bundle of pipe', count = { 1, 1 }, carry = true, model = 'prop_pipe_single_01' } },
    },
}
