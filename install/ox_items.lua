--[[
    Paste into ox_inventory/data/items.lua (skip any you already have, e.g. metalscrap, copper).
    Item images: copy images/*.png into ox_inventory/web/images (missing images show a placeholder).

    Tools are non-stackable so each one tracks its own durability.
]]

-- Tools ---------------------------------------------------------------------
['angle_grinder'] = {
    label = 'Angle Grinder',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Cordless. Loud. Throws sparks everywhere.',
},
['oxycutter'] = {
    label = 'Oxy Cutter',
    weight = 3000,
    stack = false,
    close = true,
    description = 'Careful, this gets hot. Good for cutting metal.',
    client = { image = 'oxycutter.png' },
},
['screwdriverset'] = {
    label = 'Screwdriver Set',
    weight = 400,
    stack = false,
    close = true,
},
['bolt_cutters'] = {
    label = 'Bolt Cutters',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Chains, padlocks, cables. Not fussy.',
},
['lug_wrench'] = {
    label = 'Lug Wrench',
    weight = 1200,
    stack = false,
    close = true,
},
['car_jack'] = {
    label = 'Car Jack',
    weight = 6000,
    stack = false,
    close = true,
},
['insulated_gloves'] = {
    label = 'Insulated Gloves',
    weight = 300,
    stack = false,
    close = true,
    description = 'Rated to 1000V. Probably.',
},

-- Loot ----------------------------------------------------------------------
['copper_coil'] = {
    label = 'Condenser Coil',
    weight = 12000,
    stack = true,
    description = 'Ripped out of an A/C unit. Full of copper.',
},
['copper_wire'] = {
    label = 'Copper Wire',
    weight = 800,
    stack = true,
},
['portable_generator'] = {
    label = 'Generator',
    weight = 35000,
    stack = true,
    description = 'Property of someone\'s construction site.',
},
['catalytic_converter'] = {
    label = 'Catalytic Converter',
    weight = 5000,
    stack = false,
    description = 'Platinum, palladium, rhodium. And a freshly cut pipe.',
},
['stolen_wheel'] = {
    label = 'Wheel',
    weight = 11000,
    stack = false,
},

-- Common materials (most servers already have these) ------------------------
['metalscrap'] = { label = 'Metal Scrap', weight = 100, stack = true },
['copper']     = { label = 'Copper',      weight = 100, stack = true },
['aluminum']   = { label = 'Aluminium',   weight = 100, stack = true },
['steel']      = { label = 'Steel',       weight = 100, stack = true },
['iron']       = { label = 'Iron',        weight = 100, stack = true },
['plastic']    = { label = 'Plastic',     weight = 100, stack = true },
['rubber']     = { label = 'Rubber',      weight = 100, stack = true },
['glass']      = { label = 'Glass',       weight = 100, stack = true },
