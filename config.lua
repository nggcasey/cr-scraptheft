Config = {}

--Config.MinCops = 3 --Minimum cops on duty, TODO
Config.CopsChance = 1.0 --Chance of cops being called, ranges from 0.0 to 1.0

Config.ScrapTime = 20000 --Time in miliseconds to steal scraps
--Config.Cooldown = 20000 --Time in miliseconds before a player scan steal scraps again, TODO:

--Config.RequiredItem = 'oxycutter'

Config.ScrapObjects = {

    [1] = {
        ['name'] = 'prop_aircon_l_01', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [2] = {
        ['name'] = 'prop_aircon_l_02', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [3] = {
        ['name'] = 'prop_aircon_l_03', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [4] = {
        ['name'] = 'prop_aircon_l_03_dam', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [5] = {
        ['name'] = 'prop_aircon_l_04', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [6] = {
        ['name'] = 'prop_aircon_m_01', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [7] = {
        ['name'] = 'prop_aircon_m_02', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [8] = {
        ['name'] = 'prop_aircon_m_03', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [9] = {
        ['name'] = 'prop_aircon_m_04', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [10] = {
        ['name'] = 'prop_aircon_m_05', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },

    [11] = {
        ['name'] = 'prop_aircon_m_06', -- Prop Model Name
        ['minRewards'] = 1, --Minimum amount of different rewards
        ['maxRewards'] = 3, --Max amount of different rewards
        ['rewards'] = {
            [1] = {['item'] = 'plastic', ['min'] = 1, ['max'] = 2},
            [2] = {['item'] = 'metalscrap', ['min'] = 5, ['max'] = 6},
            [3] = {['item'] = 'copper', ['min'] = 2, ['max'] = 25},
            [4] = {['item'] = 'rubber', ['min'] = 2, ['max'] = 5},

        },
    },
}