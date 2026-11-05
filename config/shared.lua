--[[
    cr-scraptheft :: general settings

    Debug output uses ox_lib's print levels. In the server console / server.cfg:
        setr ox:printlevel:cr-scraptheft debug

    Theft types live in config/profiles.lua, buyers in config/buyers.lua.
]]

return {
    ---------------------------------------------------------------------------
    -- Integrations
    ---------------------------------------------------------------------------
    Framework = 'auto',        -- 'auto' | 'qbx' | 'qb' | 'esx' | 'standalone' (used for money, IDs and police counts)
    Notify = 'ox',             -- 'ox' | 'okok'
    Progress = 'circle',       -- 'circle' | 'bar'
    Dispatch = 'ps-dispatch',  -- 'ps-dispatch' | 'cd_dispatch' | 'custom' (edit client/modules/dispatch.lua) | false
    PoliceJobs = { police = true, sheriff = true },

    -- Optional built-in buyers (config/buyers.lua): a scrapyard + a roaming night fence with a live market.
    -- Leave false if your server sells loot through its own pawn shops / scrap buyers; the resource then
    -- just hands out the items.
    EnableBuyers = false, -- only used by the qb/esx/standalone police counter (qbx uses job type 'leo')

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
    },

    ---------------------------------------------------------------------------
    -- Heat: how the cops find out.
    ---------------------------------------------------------------------------
    Heat = {
        cooldown = 45,                 -- seconds between alerts sent because of the same player
        night = { from = 21, to = 5, multiplier = 0.6 }, -- noise is less likely to be reported at night
        alarmBonus = 0.35,             -- extra report chance per stage while a car alarm is going off

        -- Encounters: sometimes somebody turns up. Not every job, not every NPC in range.
        -- Each job rolls once (after a short random delay). Who shows up is a weighted pick.
        --   behaviour 'nag'      - walks up, films you, whinges. Calls if you don't leave. Threaten/shove her and she calls instantly.
        --   behaviour 'confront' - marches up, warns you, then fights. Interrupts the job. Aim a gun and he may back off.
        --   behaviour 'caller'   - keeps distance and phones/radios it in. Aim at them and they may run.
        -- useNearby = try to recruit an ambient ped who can already see you before spawning one.
        encounters = {
            enabled = true,
            chance = 0.3,               -- per job
            nightMultiplier = 0.6,      -- fewer people about at night
            delay = { 3000, 12000 },    -- ms after starting before the roll
            spawnDistance = { 22.0, 35.0 },
            copsSeeYou = true,          -- an ambient cop with line of sight reports it instantly

            types = {
                karen = {
                    label = 'Nosy neighbour',
                    weight = 4,
                    behaviour = 'nag',
                    useNearby = false,
                    models = { 'a_f_m_bevhills_01', 'a_f_m_bevhills_02', 'a_f_y_hipster_02', 'a_f_m_tourist_01' },
                    nagTime = 15000,    -- ms of filming you before she calls
                    giveUpDistance = 30.0,
                    lines = {
                        'Excuse me! EXCUSE ME! I am filming this!',
                        'That is NOT your air conditioner. I know whose it is.',
                        'Do you even live here? I know everyone on this street.',
                        "I'm calling the police. And the HOA.",
                        "Don't you dare walk away from me while I'm talking to you!",
                        'This is going straight on the neighbourhood group.',
                        "I want to speak to whoever's in charge of you.",
                    },
                    leaveLine = 'Hmph. And STAY gone.',
                    callLine = "That's it, I'm calling the police!",
                },
                angry = {
                    label = 'Angry local',
                    weight = 2,
                    behaviour = 'confront',
                    useNearby = false,
                    models = { 'a_m_m_hillbilly_01', 'a_m_y_musclbeac_01', 'a_m_m_salton_02', 'a_m_m_farmer_01' },
                    weapons = { 'WEAPON_UNARMED', 'WEAPON_BAT', 'WEAPON_UNARMED' }, -- random pick
                    warnTime = 4000,
                    backOffChance = 0.6,  -- chance he backs down when you aim a gun at him
                    callChance = 0.25,    -- chance he also rings the cops afterwards
                    lines = {
                        'Oi! Put that down, mate!',
                        'You picked the wrong street, sunshine.',
                        "I'll sort you out myself, no need for the cops.",
                        "Right. That's it. Come here.",
                    },
                    backOffLine = 'Woah, woah! Alright, alright...',
                },
                dogooder = {
                    label = 'Timid passer-by',
                    weight = 4,
                    behaviour = 'caller',
                    useNearby = true,
                    approach = false,
                    models = { 'a_m_y_hipster_01', 'a_f_y_tourist_01', 'a_m_y_business_01', 'a_f_y_business_01' },
                    callTime = 8000,
                    scareChance = 0.9,
                    scenario = 'WORLD_HUMAN_STAND_MOBILE',
                    lines = { "H-hello, police? I think someone's stealing...", "I-I'm not looking! I'm not looking!" },
                },
                security = {
                    label = 'Security guard',
                    weight = 1,
                    behaviour = 'caller',
                    useNearby = false,
                    approach = true,
                    keepDistance = 8.0,
                    models = { 's_m_m_security_01' },
                    weapon = 'WEAPON_FLASHLIGHT',
                    callTime = 5000,
                    scareChance = 0.35,
                    anim = { dict = 'random@arrests', clip = 'generic_radio_chatter', flag = 49 },
                    lines = { 'Hey! You! Stay right there!', "Control, I've got someone tampering on site." },
                },
            },
        },

        callers = {
            'John', 'James', 'Betty', 'Karen', 'Mr Singh', 'Dennis', 'Frank', 'Peggy',
            'Mildred', 'Ethel', 'Gladys', 'Kevin', 'Mohammed', 'Yusuf', 'Ming', 'Mrs Wong',
        },
        messages = {
            'Help, these bastards are stealing again',
            'Filthy thieves stealing all the metal, tell em to get a bloody job!',
            'Grubby mongrels pinching copper, DO SOMETHING!',
            'These idiots are thieving from my building again!',
            'Someone is cutting something with a grinder, sparks everywhere',
            'I am on the neighbourhood watch and saw a person stealing scrap materials',
            'Theres a dodgy looking person cutting bits off the building, maybe for scrap metal?',
            'I think I saw someone doing something they shouldnt be',
            'Theres a thief going around the neighbourhood stealing shit',
            'Im the security guard for the area and someones stealing parts from my building',
            'Someone is lying under a car that isnt theirs, I can hear a saw',
            'Someone across the road is stealing, I tried to stop them but they told me to piss off',
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
    -- Reputation. Each completed job gives the profile's `rep` value as XP.
    -- speed = work duration multiplier, price = sale price multiplier.
    ---------------------------------------------------------------------------
    Rep = {
        levels = {
            { xp = 0,   label = 'Opportunist', speed = 1.00, price = 1.00 },
            { xp = 40,  label = 'Scrapper',    speed = 0.95, price = 1.03 },
            { xp = 120, label = 'Parts Hound', speed = 0.90, price = 1.06 },
            { xp = 300, label = 'Chop Artist', speed = 0.85, price = 1.10 },
            { xp = 650, label = 'Copper King', speed = 0.80, price = 1.15 },
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
