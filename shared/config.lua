Config = {}

Config.MinCops = 0 --Minimum cops on duty
Config.CopsChance = 0.2 --Chance of cops being called, ranges from 0.0 to 1.0
Config.Dispatch = 'ps-dispatch' --Choose 'ps-dispatch' or 'cd_dispatch'
--TODO: Config.Framework - For now, only supporting qbx cos I can't be assed doing anything else - Casey

Config.ScrapTime = 30000 --Time in miliseconds to steal scraps
Config.ItemNeeded = 'oxycutter'
Config.ScrapRadius = 0.5 --Dont touch unless you know what your doing


Config.DispatchCaller = {
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
}

Config.DispatchMsg = {
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
}

Config.ScrapObjects = {
    ['prop_aircon_l_01'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_l_02'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_l_03'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_l_03_dam'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_l_04'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_01'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_02'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_03'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_04'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_05'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
    ['prop_aircon_m_06'] = {
        minRewards = 2,
        maxRewards = 3,
        rewards = {
            { item = 'plastic', min = 1, max = 2 },
            { item = 'metalscrap', min = 3, max = 6 },
            { item = 'rubber', min = 1, max = 2 },
            { item = 'copperwire', min = 3, max = 6 },
        },
    },
}



-- Config.ScrapObjects = {
--     {
--         ['name'] = 'prop_aircon_l_01', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_l_02', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_l_03', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_l_03_dam', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_l_04', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_01', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_02', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_03', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_04', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_05', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
--     {
--         ['name'] = 'prop_aircon_m_06', -- Prop Model Name
--         ['minRewards'] = 2, --Minimum amount of different rewards
--         ['maxRewards'] = 3, --Max amount of different rewards
--         ['rewards'] = {
--             {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'metalscrap', ['min'] = 3, ['max'] = 6},
--             {['item'] = 'rubber', ['min'] = 1, ['max'] = 2},
--             {['item'] = 'copperwire', ['min'] = 3, ['max'] = 6},
--         },
--     },
-- }