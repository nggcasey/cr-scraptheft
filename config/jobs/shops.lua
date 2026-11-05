--[[ cr-thief :: shoplifting. Field reference: config/jobs/README.md

     guard: peds of these models are watching the shop floor. Each stage they can see you,
     they may catch you; they then react as one of the listed encounter types (config/people.lua).
     Add your shop script's clerk models to the list. Shelf models vary by MLO; add your own. ]]
local A = require 'config.jobs.anims'

local CLERKS = { 'mp_m_shopkeep_01', 's_m_m_linecook', 's_f_y_shop_low', 's_f_y_shop_mid', 's_m_y_shop_mask' }

return {
    ---------------------------------------------------------------------------
    shoplift = {
        category = 'shop',
        kind = 'prop',
        label = 'Shop shelf',
        models = {
            'v_ret_247shelves01', 'v_ret_247shelves02', 'v_ret_247shelves03', 'v_ret_247shelves04', 'v_ret_247shelves05',
            'v_ret_ml_liqshelfa', 'v_ret_ml_liqshelfb', 'v_ret_ml_liqshelfc', 'v_ret_gc_shelf01', 'v_ret_gc_shelf02',
        },
        target = { label = 'Pocket something', icon = 'fas fa-basket-shopping', distance = 1.6 },
        respawn = 15,
        rep = 1,
        heat = 2,
        directLoot = true,
        guard = { models = CLERKS, radius = 14.0, chance = 0.35, reactions = { clerk = 1 } },
        alert = { title = 'Shoplifting', code = '10-62', actions = {
            'stuffing things down their jacket', 'shoplifting', 'walking out without paying',
        } },

        stages = {
            {
                label = 'Browsing casually...',
                duration = 3500, anim = { scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' }, noise = 0.0,
            },
            {
                label = 'Slipping it into your jacket',
                duration = 1800, anim = A.shopMid, noise = 0.0,
                skill = { difficulty = { 'easy', 'medium' }, inputs = { 'e' }, attempts = 1 },
            },
        },

        loot = {
            { item = 'stolen_goods', label = 'Shoplifted goods', count = { 1, 3 } },
            { item = 'stolen_liquor', count = { 1, 1 }, chance = 0.3 },
            { item = 'stolen_cigs', count = { 1, 2 }, chance = 0.3 },
        },
    },
}
