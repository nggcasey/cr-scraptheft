-- Shared animations and particle effects for job configs.
return {
    repair    = { dict = 'mini@repair', clip = 'fixing_a_player', flag = 1 },
    weld      = { scenario = 'WORLD_HUMAN_WELDING' },
    rummage   = { dict = 'amb@prop_human_bum_bin@base', clip = 'base', flag = 1 },
    hotwire   = { dict = 'anim@gangops@facility@servers@', clip = 'hotwire', flag = 1 },
    mechanic  = { dict = 'amb@world_human_vehicle_mechanic@male@base', clip = 'base', flag = 1 },
    crouch    = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
    kneel     = { dict = 'amb@medic@standing@tendtodead@base', clip = 'base', flag = 1 },
    pry       = { dict = 'missheistfbi3b_ig7', clip = 'lift_fibagent_loop', flag = 1 },
    smash     = { dict = 'veh@break_in@0h@p_m_one@', clip = 'low_force_entry_ds', flag = 0 },
    search    = { dict = 'anim@gangops@morgue@table@', clip = 'player_search', flag = 1 },
    hood      = { dict = 'mini@repair', clip = 'fixing_a_ped', flag = 1 },
    shopHigh  = { dict = 'anim@am_hold_up@male', clip = 'shoplift_high', flag = 48 },
    shopMid   = { dict = 'anim@am_hold_up@male', clip = 'shoplift_mid', flag = 48 },
    shopLow   = { dict = 'anim@am_hold_up@male', clip = 'shoplift_low', flag = 48 },
    pickpocket = { dict = 'anim@am_hold_up@male', clip = 'shoplift_mid', flag = 49 },
    kick      = { dict = 'melee@unarmed@streamed_core', clip = 'heavy_punch_a', flag = 0 },

    fx = {
        sparks = { asset = 'scr_reconstructionaccident', name = 'scr_sparking_generator' },
        wire   = { asset = 'core', name = 'ent_brk_sparking_wires' },
        glass  = { asset = 'core', name = 'ent_brk_glass_shards' },
    },
}
