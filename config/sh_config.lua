    ----------------------------------------------
    --        🛠️ DEBUG MODE
    ----------------------------------------------

    --[[
        Debug Mode Setup:

        Debug mode is controlled by a server convar, not this config file.

        To enable or disable debug messages, type the following command directly into the server console or txAdmin console:

        setr cr-scraptheft_debugMode true    -- Enable debug messages
        setr cr-scraptheft_debugMode false   -- Disable debug messages

        (No resource restart needed.)

        Optionally, you can add the setting to your server.cfg if you want debug mode to persist across restarts.
    ]]

return{

    ----------------------------------------------
    --        🛠️ Setup below
    ----------------------------------------------

    NotifySystem = 1, --1 = ox_lib, 2 = okokNotify
    ScrapResetTime = 10, -- Time (in minutes) after which scrapped objects can be scrapped again
    --MinCops = 0,--Minimum cops on duty TODO: Casey
    CopsChance = 0.2, --Chance of cops being called, ranges from 0.0 to 1.0
    AlertCooldown = 30000, -- Cooldown period in milliseconds
    Dispatch = 'ps-dispatch', --Choose 'ps-dispatch' or 'cd_dispatch'
    --TODO: Framework - For now, only supporting qbx cos I can't be assed doing anything else - Casey

    ScrapTime = 15, -- seconds
    RequiredItem = 'oxycutter', --Only supporting ox_inventory, feel free to submit a PR if you want more.
    ScrapRadius = 0.5, --Dont touch unless you know what your doing

    SkillCheck = {
        -- Skillcheck difficulty settings
        -- You can set 'easy', 'medium', or 'hard' in any order and quantity
        -- More info: https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
        difficulty = { 'easy', 'medium',},

        -- Keys that will be used for the skillcheck minigame
        -- You can set this to any combination of keys
        inputs = { 'W', 'A', 'S', 'D' },
    },

    TargetDistance = 2, --ox_target distance

    ----------------------------------------------
    --        🛠️ Set the scrappable objects
    ----------------------------------------------

    ScrapObjects = {
        [827943275] = { -- prop_aircon_l_01
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 6 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [605277920] = { -- prop_aircon_l_02
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1426534598] = { -- prop_aircon_l_03
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [-1413477803] = { -- prop_aircon_l_03_dam
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1195939145] = { -- prop_aircon_l_04
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1369811908] = { -- prop_aircon_m_01
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1131941737] = { -- prop_aircon_m_02
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1948414141] = { -- prop_aircon_m_03
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [1709954128] = { -- prop_aircon_m_04
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [-1393761711] = { -- prop_aircon_m_05
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
        [-1393761711] = { -- prop_aircon_m_06
            minRewards = 2,
            maxRewards = 3,
            rewards = {
                { item = 'plastic', min = 1, max = 2 },
                { item = 'iron', min = 1, max = 2 },
                { item = 'steel', min = 1, max = 2 },
                { item = 'glass', min = 1, max = 2 },
                { item = 'aluminum', min = 1, max = 2 },
                { item = 'metalscrap', min = 3, max = 6 },
                { item = 'rubber', min = 1, max = 2 },
                { item = 'copper', min = 3, max = 6 },
            },
        },
    },


    ----------------------------------------------
    --        👮 Setup dispatch options
    ----------------------------------------------
    DispatchCaller = {
        'John',
        'James',
        'Betty',
        'Karen',
        'Mr Singh',
        'Dennis',
        'Frank',
        'Peggy',
        'Mildred',
        'Ethel',
        'Gladys',
        'Kevin',
        'Mohammed',
        'Yusuf',
        'Ming',
        'Mrs Wong',
    },

    DispatchMsg = {
        'Help, these bastards are stealing again',
        'Filthy thieves stealing all the metal, tell em to get a bloody job!',
        'Grubby mongrels pinching copper, DO SOMETHING!',
        'These idiots are thieving from my building again!',
        'Someone is trying to steal scrap materials using an oxy-cutter',
        'I am on the neighbourhood watch and saw a person stealing scrap materials',
        'I think I saw someone stealing copper piping',
        'Theres a dodgy looking person cutting bits off the building, maybe for scrap metal?',
        'I think I saw someone doing something they shouldnt be',
        'Theres a thief going around the neighbourhood stealing shit',
        'Im the security guard for the area and someones stealing parts from my building',
        'Kids are stealing and using foul language, please stop them',
        'Someone across the road is stealing, I tried to stop them but they told me to piss off'
    },
}