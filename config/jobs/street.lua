--[[ cr-thief :: petty street crime. Field reference: config/jobs/README.md
     These props are everywhere on the map: the idea is to keep moving, not camp one corner. ]]
local A = require 'config.jobs.anims'
local FX = A.fx

return {
    ---------------------------------------------------------------------------
    pickpocket = {
        category = 'street',
        kind = 'ped',
        label = 'Pedestrian',
        target = { label = 'Pickpocket', icon = 'fas fa-hand-holding', distance = 1.3 },
        rep = 1,
        heat = 1,
        directLoot = true,
        behind = true,              -- you have to be behind them
        -- When they notice (failed skill check, or a random notice roll), they become one of
        -- these encounter types from config/people.lua.
        notice = { chance = 0.12, reactions = { timid = 3, angry = 2, karen = 2 } },
        alert = { title = 'Pickpocket', code = '10-62', actions = {
            'going through people\'s pockets', 'lifting wallets', 'pickpocketing people',
        } },

        stages = {
            {
                label = 'Lifting their wallet',
                duration = 2500, anim = A.pickpocket, noise = 0.0,
                skill = { difficulty = { 'medium' }, inputs = { 'e' }, attempts = 1 },
            },
        },

        loot = {
            { item = 'money', count = { 5, 60 } },
            { item = 'stolen_phone', count = { 1, 1 }, chance = 0.2 },
            { item = 'stolen_watch', count = { 1, 1 }, chance = 0.07 },
            { item = 'stolen_giftcard', count = { 1, 1 }, chance = 0.05, value = { 20, 100 } },
        },
    },

    ---------------------------------------------------------------------------
    vending = {
        category = 'street',
        kind = 'prop',
        label = 'Vending machine',
        models = { 'prop_vend_snak_01', 'prop_vend_soda_01', 'prop_vend_soda_02', 'prop_vend_coffe_01', 'prop_vend_water_01' },
        target = { label = 'Jimmy the cash box', icon = 'fas fa-coins', distance = 1.5 },
        respawn = 40,
        rep = 1,
        heat = 2,
        directLoot = true,
        alert = { title = 'Vandalism / Theft', code = '10-62', actions = {
            'prying open a vending machine', 'smashing up a vending machine', 'breaking into the drinks machine',
        } },

        stages = {
            {
                label = 'Prying the front panel',
                duration = 5000, tool = 'crowbar', anim = A.repair, noise = 0.15,
                skill = { difficulty = { 'easy', 'medium' }, inputs = { 'w', 'a', 's', 'd' } },
            },
            {
                label = 'Scooping the coin box',
                duration = 3000, anim = A.rummage, noise = 0.02,
            },
        },

        loot = {
            { item = 'money', count = { 15, 70 } },
            { item = 'stolen_goods', label = 'Snacks', count = { 1, 3 }, chance = 0.5 },
        },
    },

    ---------------------------------------------------------------------------
    parking_meter = {
        category = 'street',
        kind = 'prop',
        label = 'Parking meter',
        models = { 'prop_parknmeter_01', 'prop_parknmeter_02' },
        target = { label = 'Crack the meter', icon = 'fas fa-square-parking', distance = 1.3 },
        respawn = 30,
        rep = 1,
        heat = 1,
        directLoot = true,
        alert = { title = 'Vandalism', code = '10-62', actions = { 'smashing open a parking meter', 'robbing a parking meter' } },

        stages = {
            {
                label = 'Levering the coin door',
                duration = 4000, tool = 'crowbar', anim = A.repair, noise = 0.12,
                skill = { difficulty = { 'easy' }, inputs = { 'e' } },
            },
        },

        loot = { { item = 'money', count = { 3, 25 } } },
    },

    ---------------------------------------------------------------------------
    payphone = {
        category = 'street',
        kind = 'prop',
        label = 'Payphone',
        models = {
            'prop_phonebox_01a', 'prop_phonebox_01b', 'prop_phonebox_01c',
            'prop_phonebox_02', 'prop_phonebox_03', 'prop_phonebox_04',
        },
        target = { label = 'Rob the payphone', icon = 'fas fa-phone-volume', distance = 1.3 },
        respawn = 35,
        rep = 1,
        heat = 1,
        directLoot = true,
        alert = { title = 'Vandalism', code = '10-62', actions = { 'pulling apart a payphone', 'robbing the coin box out of a phone booth' } },

        stages = {
            {
                label = 'Unscrewing the coin box',
                duration = 4500, tool = 'screwdriver', anim = A.repair, noise = 0.04,
            },
            {
                label = 'Ripping out the handset cable',
                duration = 2000, anim = A.hotwire, noise = 0.05,
            },
        },

        loot = {
            { item = 'money', count = { 5, 30 } },
            { item = 'copper_wire', count = { 1, 1 }, chance = 0.4 },
        },
    },

    ---------------------------------------------------------------------------
    newsbox = {
        category = 'street',
        kind = 'prop',
        label = 'Newspaper box',
        models = { 'prop_news_disp_01a', 'prop_news_disp_02a', 'prop_news_disp_02c', 'prop_news_disp_03a', 'prop_news_disp_05a', 'prop_news_disp_06a' },
        target = { label = 'Shake down the news box', icon = 'fas fa-newspaper', distance = 1.3 },
        respawn = 25,
        rep = 1,
        heat = 1,
        directLoot = true,
        alert = { title = 'Vandalism', code = '10-62', actions = { 'kicking a newspaper box', 'shaking coins out of a news stand' } },

        stages = {
            {
                label = 'Jiggling the coin slot',
                duration = 3500, anim = A.repair, noise = 0.06,
                skill = { difficulty = { 'easy' }, inputs = { 'e' } },
            },
        },

        loot = { { item = 'money', count = { 1, 12 } } },
    },

    ---------------------------------------------------------------------------
    mailbox = {
        category = 'street',
        kind = 'prop',
        label = 'Mailbox',
        models = { 'prop_postbox_01a' },
        target = { label = 'Fish out the mail', icon = 'fas fa-envelope-open-text', distance = 1.3 },
        respawn = 40,
        rep = 1,
        heat = 1,
        directLoot = true,
        alert = { title = 'Mail Theft', code = '10-62', actions = { 'fishing mail out of a postbox', 'stealing mail', 'prying open a postbox' } },

        stages = {
            {
                label = 'Prying the slot',
                duration = 4000, tool = 'crowbar', anim = A.repair, noise = 0.07,
            },
            {
                label = 'Sorting through the envelopes',
                duration = 3500, anim = A.rummage, noise = 0.0,
            },
        },

        loot = {
            { item = 'stolen_mail', count = { 1, 4 } },
            { item = 'stolen_giftcard', count = { 1, 1 }, chance = 0.12, value = { 20, 100 } },
        },
    },
}
