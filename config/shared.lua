--[[
    cr-thief :: general settings

    Debug output uses ox_lib's print levels. In the server console / server.cfg:
        setr ox:printlevel:cr-thief debug

    Jobs live in config/jobs/*.lua, buyers in config/buyers.lua.
]]

return {
    ---------------------------------------------------------------------------
    -- Integrations
    ---------------------------------------------------------------------------
    Framework = 'auto',        -- 'auto' | 'qbx' | 'qb' | 'esx' | 'standalone' (used for money, IDs and police counts)
    Notify = 'ox',             -- 'ox' | 'okok'
    Progress = 'circle',       -- 'circle' | 'bar'
    Dispatch = 'ps-dispatch',  -- 'ps-dispatch' | 'cd_dispatch' | 'custom' (edit client/modules/dispatch.lua) | false
    PoliceJobs = { police = true, sheriff = true }, -- only used by the qb/esx/standalone police counter (qbx uses job type 'leo')

    -- Optional built-in buyers (config/buyers.lua): a scrapyard + a roaming night fence with a live market.
    -- Leave false if your server sells loot through its own pawn shops / buyers; the resource then
    -- just hands out the items.
    EnableBuyers = false,

    -- Any prop model that fails to load falls back to this. Keep it a model you know exists.
    FallbackProp = 'prop_cs_cardbox_01',

    ---------------------------------------------------------------------------
    -- Tools. A stage asks for a tool id; the player needs ANY one of its items.
    -- wear = durability (0-100) removed each time the stage is completed. The item breaks at 0.
    -- prop = what is held in the hand while working (omit when the animation/scenario brings its own).
    ---------------------------------------------------------------------------
    Tools = {
        screwdriver = {
            label = 'Screwdriver',
            items = { 'screwdriverset', 'screwdriver' },
            wear = 1,
            prop = { model = 'prop_tool_screwdvr01', bone = 57005, pos = vec3(0.10, 0.04, -0.02), rot = vec3(-80.0, 0.0, 0.0) },
        },
        cutter = {
            label = 'Angle grinder / oxy cutter',
            items = { 'angle_grinder', 'oxycutter' },
            wear = 5,
        },
        boltcutters = {
            label = 'Bolt cutters',
            items = { 'bolt_cutters' },
            wear = 3,
            prop = { model = 'prop_tool_pliers', bone = 57005, pos = vec3(0.10, 0.03, -0.02), rot = vec3(-90.0, 0.0, 0.0) },
        },
        wrench = {
            label = 'Lug wrench',
            items = { 'lug_wrench' },
            wear = 1,
            prop = { model = 'prop_tool_wrench', bone = 57005, pos = vec3(0.12, 0.04, -0.02), rot = vec3(-90.0, 0.0, 0.0) },
        },
        jack = {
            label = 'Car jack',
            items = { 'car_jack' },
            wear = 2,
        },
        crowbar = {
            label = 'Crowbar',
            items = { 'crowbar' },
            wear = 2,
            prop = { model = 'prop_ing_crowbar', bone = 57005, pos = vec3(0.08, 0.03, -0.03), rot = vec3(-80.0, 0.0, 0.0) },
        },
    },

    ---------------------------------------------------------------------------
    -- Heat: how the cops find out.
    ---------------------------------------------------------------------------
    Heat = {
        cooldown = 45,                 -- seconds between alerts sent because of the same player
        night = { from = 21, to = 5, multiplier = 0.6 }, -- noise is less likely to be reported at night
        alarmBonus = 0.35,             -- extra report chance per stage while a car alarm is going off

        -- Who turns up, who calls, and what they say: config/people.lua and config/dispatch.lua
    },

    ---------------------------------------------------------------------------
    -- The world: keeps thieves moving instead of farming one spot.
    --
    -- Every spot, car and pedestrian is locked for EVERYONE once it's hit (until it respawns).
    -- On top of that the map is split into cells; each job heats its cell for everyone.
    -- Hot areas mean jumpier locals (more reports, more encounters). At max heat the area is
    -- locked down until it cools. Doing the same area over and over also earns you less rep.
    ---------------------------------------------------------------------------
    World = {
        cellSize = 300.0,              -- metres
        maxHeat = 10,                  -- lockdown at this heat
        heatMultiplier = 0.12,         -- +12% report / encounter chance per point of area heat
        decay = { every = 120, amount = 1 }, -- seconds, heat points

        personal = {
            window = 45,               -- minutes remembered
            repeats = 3,               -- jobs in the same cell before rep drops off
            xpMultiplier = 0.35,
        },

        -- Word on the street: one job type in one district pays bonus rep + extra loot for a while.
        -- Pulls thieves to the same part of town, so they run into each other.
        tips = {
            enabled = true,
            every = 30,                -- minutes
            repMultiplier = 2.0,
            lootMultiplier = 1.5,
            announceMinRep = 2,        -- rep level that hears about new tips automatically (others use /thief)
            districts = {
                { label = 'Mirror Park',     coords = vec3(1100.0, -550.0, 57.0),   radius = 400.0 },
                { label = 'Vespucci',        coords = vec3(-1200.0, -1100.0, 4.0),  radius = 450.0 },
                { label = 'Strawberry',      coords = vec3(200.0, -1500.0, 29.0),   radius = 400.0 },
                { label = 'Little Seoul',    coords = vec3(-650.0, -950.0, 22.0),   radius = 400.0 },
                { label = 'Rockford Hills',  coords = vec3(-800.0, -200.0, 37.0),   radius = 450.0 },
                { label = 'Del Perro',       coords = vec3(-1500.0, -500.0, 35.0),  radius = 400.0 },
                { label = 'Downtown',        coords = vec3(200.0, -800.0, 31.0),    radius = 450.0 },
                { label = 'Davis',           coords = vec3(100.0, -1700.0, 29.0),   radius = 400.0 },
                { label = 'Vinewood',        coords = vec3(300.0, 200.0, 104.0),    radius = 450.0 },
                { label = 'El Burro Heights', coords = vec3(1350.0, -1700.0, 55.0), radius = 400.0 },
                { label = 'Elysian Island',  coords = vec3(500.0, -3000.0, 6.0),    radius = 600.0 },
                { label = 'Sandy Shores',    coords = vec3(1850.0, 3700.0, 33.0),   radius = 600.0 },
                { label = 'Grapeseed',       coords = vec3(1700.0, 4800.0, 42.0),   radius = 500.0 },
                { label = 'Paleto Bay',      coords = vec3(-200.0, 6300.0, 31.0),   radius = 600.0 },
            },
        },
    },

    ---------------------------------------------------------------------------
    -- Carrying heavy loot
    ---------------------------------------------------------------------------
    Carry = {
        dropKey = 'X',                 -- default keybind to set the item down (players can rebind in FiveM settings)
        moveRate = 0.85,               -- walk speed while carrying (1.0 = normal)
        anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
        attach = { bone = 60309, pos = vec3(0.025, 0.08, 0.255), rot = vec3(-145.0, 290.0, 0.0) },
    },

    Loot = {
        lifetime = 10,                 -- minutes before loot nobody picked up is cleaned up
    },

    ---------------------------------------------------------------------------
    -- Thief reputation. Each completed job gives the job's `rep` value as XP (reduced if you keep
    -- hitting the same neighbourhood, boosted by the current tip).
    -- speed = work duration multiplier, price = sale price multiplier.
    ---------------------------------------------------------------------------
    Rep = {
        levels = {
            { xp = 0,    label = 'Nobody',             speed = 1.00, price = 1.00 },
            { xp = 40,   label = 'Petty Thief',        speed = 0.96, price = 1.03 },
            { xp = 140,  label = 'Prowler',            speed = 0.92, price = 1.06 },
            { xp = 350,  label = 'Professional',       speed = 0.88, price = 1.10 },
            { xp = 750,  label = "Fixer's Favourite", speed = 0.84, price = 1.13 },
            { xp = 1500, label = 'Ghost',              speed = 0.80, price = 1.16 },
        },
    },

    ---------------------------------------------------------------------------
    -- Market: every unit sold floods the market and lowers the price for everyone.
    -- Prices recover over time and drift a little each "trading day".
    ---------------------------------------------------------------------------
    Market = {
        saturation = 0.015,            -- price drop per unit sold
        floor = 0.45,                  -- never below 45% of base
        recoverEvery = 300,            -- seconds
        recoverAmount = 5,             -- units of saturation removed per tick
        drift = { min = 0.85, max = 1.20, every = 120 }, -- random daily swing, re-rolled every N minutes
    },

    Payout = {
        cleanAccount = 'cash',         -- framework account for clean payouts
        dirtyItem = 'black_money',     -- ox_inventory item for dirty payouts
        markedBills = false,           -- true = pay dirty money as one 'markedbills' item with { worth = amount } metadata
    },

    ---------------------------------------------------------------------------
    -- Vehicles (catalytic converters and wheels)
    ---------------------------------------------------------------------------
    Vehicles = {
        protectOwned = false,          -- true = player-owned vehicles (in the database) can't be stripped. Needs oxmysql.
        ownedTable = 'auto',           -- 'auto' = player_vehicles (qb/qbx) or owned_vehicles (esx)
        blacklist = { 'police', 'police2', 'police3', 'police4', 'sheriff', 'sheriff2', 'ambulance', 'firetruk' },

        -- No catalytic converter on these.
        electric = {
            'voltic', 'voltic2', 'raiden', 'cyclone', 'tezeract', 'neon', 'surge', 'khamelion',
            'imorgon', 'iwagen', 'omnisegt', 'virtue', 'powersurge', 'caddy', 'caddy2', 'caddy3', 'airtug',
        },

        -- Value multipliers (catalytic converters + wheels) by model. Anything unlisted is 1.0.
        -- Hybrids carry the most precious metal, which is exactly why they're the real-life favourite.
        tiers = {
            { multiplier = 2.2, models = { 'dilettante', 'dilettante2', 'asea', 'asea2' } },
            { multiplier = 1.6, models = {
                'adder', 'zentorno', 't20', 'osiris', 'turismor', 'entityxf', 'cheetah', 'infernus', 'vacca',
                'nero', 'nero2', 'xa21', 'tempesta', 'emerus', 'krieger', 'thrax', 'furia', 'italigtb', 'reaper',
            } },
            { multiplier = 1.3, models = { 'mule', 'mule2', 'mule3', 'benson', 'pounder', 'phantom', 'hauler', 'packer', 'rumpo', 'speedo', 'burrito3' } },
        },

        -- With the converter gone the exhaust roars. Set false to disable.
        -- Value is an audio game object (any vehicle model name with a loud engine).
        noCatAudio = 'dominator',
    },

    ---------------------------------------------------------------------------
    -- Anti-exploit
    ---------------------------------------------------------------------------
    Security = {
        timingTolerance = 0.8,         -- a stage must take at least 80% of its configured time
        minGap = 4,                    -- seconds between finishing one job and starting the next
        maxDistance = 6.0,             -- max metres from the target while working
    },
}
