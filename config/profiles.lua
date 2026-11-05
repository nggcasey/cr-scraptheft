--[[
    cr-scraptheft :: theft profiles

    kind
        'prop'    - a world object (target by model)
        'vehicle' - part = 'cat' (catalytic converter) or 'wheel'

    stages (run in order; every stage is confirmed by the server)
        label      progress text
        duration   ms (scaled by rep speed)
        tool       tool id from config/shared.lua Tools (nil = bare hands)
        anim       { dict, clip, flag } or { scenario }   (loops for the whole stage)
        prop       override the hand prop of the tool
        steps      split the stage into N chunks; with `skill` set, a skill check runs between chunks
        stepLabel  label for each chunk, %d/%d = step/total
        skill      { difficulty = {...}, inputs = {...}, attempts = 3 } - failing makes noise and repeats the chunk
        noise      0-1 chance this stage gets reported (before night/alarm modifiers). Witnesses are separate.
        ptfx       { asset, name, on = 'target' | 'tool' | 'ped', offset, scale }
        hazard     { type = 'shock', chance, damage, protect = item }  - interrupt the stage and hurt the player
        place      { model, at = 'wheel' }  - prop placed at the start and removed when the job ends (car jack)
        debris     { model, offset | at = 'wheel', freeze }  - stays in the world until the spot resets
        effect     'removeWheel'

    loot
        item, label, count = {min, max}, chance (0-1)
        value      {min, max}  -> stored as metadata.value (scaled by vehicle tier), buyers pay that
        carry      true = heavy, must be carried and loaded into a vehicle
        model      prop dropped in the world. 'source' = the object being stolen (it disappears from the world)
        attach     carry attachment override { bone, pos, rot }
    Loot without a `model` is grouped into one `bundle` drop (a bag of bits).

    hide / swap
        hide = true      the world object vanishes once stolen (until respawn)
        swap = { [model] = replacementModel } shows a damaged version until respawn
]]

local A = {
    repair   = { dict = 'mini@repair', clip = 'fixing_a_player', flag = 1 },
    weld     = { scenario = 'WORLD_HUMAN_WELDING' },
    rummage  = { dict = 'amb@prop_human_bum_bin@base', clip = 'base', flag = 1 },
    hotwire  = { dict = 'anim@gangops@facility@servers@', clip = 'hotwire', flag = 1 },
    mechanic = { dict = 'amb@world_human_vehicle_mechanic@male@base', clip = 'base', flag = 1 },
    crouch   = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
    kneel    = { dict = 'amb@medic@standing@tendtodead@base', clip = 'base', flag = 1 },
}

local SPARKS = { asset = 'scr_reconstructionaccident', name = 'scr_sparking_generator', scale = 0.8 }
local WIRE_SPARKS = { asset = 'core', name = 'ent_brk_sparking_wires', scale = 1.0 }

return {
    ---------------------------------------------------------------------------
    ac_unit = {
        kind = 'prop',
        label = 'A/C unit',
        models = {
            'prop_aircon_l_01', 'prop_aircon_l_02', 'prop_aircon_l_03', 'prop_aircon_l_03_dam', 'prop_aircon_l_04',
            'prop_aircon_m_01', 'prop_aircon_m_02', 'prop_aircon_m_03', 'prop_aircon_m_04', 'prop_aircon_m_05', 'prop_aircon_m_06',
        },
        target = { label = 'Strip A/C unit', icon = 'fas fa-fan', distance = 1.8 },
        respawn = 30,       -- minutes
        minCops = 0,
        rep = 2,
        alert = { title = 'Copper Theft', code = '10-62' },

        stages = {
            {
                label = 'Unscrewing the service panel',
                duration = 5000, tool = 'screwdriver', anim = A.repair, noise = 0.02,
                debris = { model = 'prop_rub_scrap_06', offset = vec3(0.0, -0.7, 0.5) },
            },
            {
                label = 'Cutting the refrigerant lines',
                duration = 9000, tool = 'cutter', anim = A.weld, noise = 0.12,
                steps = 2, skill = { difficulty = { 'easy', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = SPARKS.asset, name = SPARKS.name, scale = 0.6, on = 'target', offset = vec3(0.0, -0.3, 0.4) },
            },
            {
                label = 'Wrenching out the condenser coil',
                duration = 4500, anim = A.rummage, noise = 0.04,
                skill = { difficulty = { 'medium' }, inputs = { 'e' } },
            },
        },

        loot = {
            { item = 'copper_coil', label = 'Condenser coil', count = { 1, 1 }, carry = true, model = 'prop_compressor_03' },
            { item = 'copper', count = { 2, 5 }, chance = 0.85 },
            { item = 'aluminum', count = { 1, 3 }, chance = 0.6 },
            { item = 'metalscrap', count = { 2, 6 } },
            { item = 'plastic', count = { 1, 3 }, chance = 0.4 },
        },
        bundle = { model = 'prop_cs_rub_binbag_01', label = 'Bag of scrap' },
        swap = { prop_aircon_l_03 = 'prop_aircon_l_03_dam' },
    },

    ---------------------------------------------------------------------------
    electrical_box = {
        kind = 'prop',
        label = 'Electrical cabinet',
        models = {
            'prop_elecbox_01a', 'prop_elecbox_02a', 'prop_elecbox_03a', 'prop_elecbox_04a', 'prop_elecbox_05a',
            'prop_elecbox_08', 'prop_elecbox_09', 'prop_elecbox_10',
        },
        target = { label = 'Rip copper wiring', icon = 'fas fa-bolt', distance = 1.6 },
        respawn = 25,
        minCops = 0,
        rep = 2,
        alert = { title = 'Utility Tampering', code = '10-62' },

        stages = {
            {
                label = 'Prying the cabinet door',
                duration = 4000, tool = 'screwdriver', anim = A.repair, noise = 0.04,
            },
            {
                label = 'Cutting live cables',
                duration = 8000, tool = 'boltcutters', anim = A.hotwire, noise = 0.05,
                steps = 3, stepLabel = 'Cutting cable %d/%d', skill = { difficulty = { 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = WIRE_SPARKS.asset, name = WIRE_SPARKS.name, scale = 0.7, on = 'target', offset = vec3(0.0, -0.2, 0.8) },
                hazard = { type = 'shock', chance = 0.25, damage = 25, protect = 'insulated_gloves' },
            },
            {
                label = 'Yanking the wiring loom',
                duration = 3500, anim = A.rummage, noise = 0.02,
            },
        },

        loot = {
            { item = 'copper_wire', count = { 2, 4 } },
            { item = 'copper', count = { 1, 3 }, chance = 0.6 },
            { item = 'plastic', count = { 1, 2 }, chance = 0.5 },
        },
        bundle = { model = 'prop_cs_rub_binbag_01', label = 'Bag of wiring' },
    },

    ---------------------------------------------------------------------------
    generator = {
        kind = 'prop',
        label = 'Site generator',
        models = { 'prop_generator_03b', 'prop_generator_04' },
        target = { label = 'Steal generator', icon = 'fas fa-car-battery', distance = 1.8 },
        respawn = 45,
        minCops = 1,
        rep = 4,
        alert = { title = 'Plant Theft', code = '10-62' },

        stages = {
            {
                label = 'Disconnecting the leads',
                duration = 4000, tool = 'boltcutters', anim = A.kneel, noise = 0.03,
            },
            {
                label = 'Cutting the security chain',
                duration = 7000, tool = 'cutter', anim = A.weld, noise = 0.2,
                skill = { difficulty = { 'easy', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = SPARKS.asset, name = SPARKS.name, scale = 0.6, on = 'target', offset = vec3(0.0, 0.0, 0.3) },
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
    catalytic = {
        kind = 'vehicle',
        part = 'cat',
        label = 'Catalytic converter',
        target = { label = 'Cut catalytic converter', icon = 'fas fa-screwdriver-wrench', distance = 2.5 },
        minCops = 0,
        rep = 4,
        alarm = 0.6,        -- chance a LOCKED car's alarm goes off when you slide under it
        alert = { title = 'Catalytic Converter Theft', code = '10-62' },

        stages = {
            {
                label = 'Sliding under the vehicle',
                duration = 2500, anim = A.mechanic, noise = 0.0,
            },
            {
                label = 'Cutting the exhaust pipe',
                duration = 12000, tool = 'cutter', anim = A.mechanic, noise = 0.18,
                steps = 2, skill = { difficulty = { 'easy', 'medium', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = SPARKS.asset, name = SPARKS.name, scale = 0.7, on = 'target', offset = vec3(0.0, 0.0, -0.35) },
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
        kind = 'vehicle',
        part = 'wheel',
        label = 'Wheel',
        target = { label = 'Steal wheel', icon = 'fas fa-circle-dot', distance = 2.0 },
        minCops = 0,
        rep = 2,
        alarm = 0.5,
        alert = { title = 'Vehicle Tampering', code = '10-62' },

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
}
