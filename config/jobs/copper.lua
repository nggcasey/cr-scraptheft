--[[ cr-thief :: copper jobs. Field reference: config/jobs/README.md ]]
local A = require 'config.jobs.anims'
local FX = A.fx

return {
    ---------------------------------------------------------------------------
    ac_unit = {
        category = 'copper',
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
        alert = { title = 'Copper Theft', code = '10-62', actions = { 'pulling apart an air conditioner', 'cutting the pipes off an a/c unit', 'stripping the copper out of an aircon', 'dismantling someone\'s air conditioning' } },

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
                ptfx = { asset = FX.sparks.asset, name = FX.sparks.name, scale = 0.6, on = 'target', offset = vec3(0.0, -0.3, 0.4) },
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
        category = 'copper',
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
        alert = { title = 'Utility Tampering', code = '10-62', actions = { 'ripping wires out of an electrical box', 'cutting cables out of a power cabinet', 'messing with the electrical box', 'pulling copper wire out of the mains' } },

        stages = {
            {
                label = 'Prying the cabinet door',
                duration = 4000, tool = 'screwdriver', anim = A.repair, noise = 0.04,
            },
            {
                label = 'Cutting live cables',
                duration = 8000, tool = 'boltcutters', anim = A.hotwire, noise = 0.05,
                steps = 3, stepLabel = 'Cutting cable %d/%d', skill = { difficulty = { 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
                ptfx = { asset = FX.wire.asset, name = FX.wire.name, scale = 0.7, on = 'target', offset = vec3(0.0, -0.2, 0.8) },
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
}
