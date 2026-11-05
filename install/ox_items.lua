--[[
    cr-thief items.
    'money' (cash) is ox_inventory's default cash item and is used as loot by several street jobs.

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
['crowbar'] = {
    label = 'Crowbar',
    weight = 1800,
    stack = false,
    close = true,
    description = 'The universal key.',
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

['car_battery'] = {
    label = 'Car Battery',
    weight = 15000,
    stack = true,
},
['pipe_bundle'] = {
    label = 'Bundle of Pipe',
    weight = 20000,
    stack = true,
},
['power_drill'] = { label = 'Power Drill', weight = 1800, stack = true, description = 'Still has the site\'s name written on it.' },
['nail_gun']    = { label = 'Nail Gun',    weight = 2500, stack = true },

-- Street / shop loot -----------------------------------------------------------
['stolen_phone']    = { label = 'Stolen Phone',    weight = 200,  stack = true, description = 'Locked. Still worth something.' },
['stolen_gps']      = { label = 'Stolen GPS',      weight = 400,  stack = true },
['stolen_laptop']   = { label = 'Stolen Laptop',   weight = 2000, stack = true },
['stolen_watch']    = { label = 'Stolen Watch',    weight = 100,  stack = true },
['sunglasses']      = { label = 'Sunglasses',      weight = 100,  stack = true },
['stolen_giftcard'] = { label = 'Gift Card',       weight = 10,   stack = false, description = 'Balance unknown. Allegedly.' },
['stolen_mail']     = { label = 'Stolen Mail',     weight = 50,   stack = true },
['stolen_goods']    = { label = 'Shoplifted Goods', weight = 300, stack = true },
['stolen_liquor']   = { label = 'Bottle of Liquor', weight = 800, stack = true },
['stolen_cigs']     = { label = 'Carton of Cigarettes', weight = 300, stack = true },

-- Common materials (most servers already have these) ------------------------
['metalscrap'] = { label = 'Metal Scrap', weight = 100, stack = true },
['copper']     = { label = 'Copper',      weight = 100, stack = true },
['aluminum']   = { label = 'Aluminium',   weight = 100, stack = true },
['steel']      = { label = 'Steel',       weight = 100, stack = true },
['iron']       = { label = 'Iron',        weight = 100, stack = true },
['plastic']    = { label = 'Plastic',     weight = 100, stack = true },
['rubber']     = { label = 'Rubber',      weight = 100, stack = true },
['glass']      = { label = 'Glass',       weight = 100, stack = true },
