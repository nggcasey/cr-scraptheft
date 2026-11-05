--[[
    cr-thief :: buyers

    items: [item] = base price per unit, or 'value' to pay the item's metadata.value (catalytic converters, wheels).
    Prices are then scaled by the live market and the seller's rep.

    hours: { open = 21, close = 5 } in game time (wraps past midnight), or false for always open.
    locations: a list; one is picked at random and re-rolled every `rotate` real minutes.
    minRep: rep level index (config/shared.lua Rep.levels) needed before they'll deal with you.
    tipsOff: this buyer can point players with enough rep to another buyer (sets a waypoint).

    The coordinates below are starting points; stand where you want the ped and use your own.
    The ped is snapped to the ground on spawn, so z only needs to be close.
]]

return {
    scrapyard = {
        label = 'Joshua Road Salvage',
        ped = 's_m_y_dockwork_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        locations = { vec4(2397.42, 3089.44, 48.15, 239.0) },
        hours = false,
        payout = 'clean',
        minRep = 1,
        blip = { sprite = 365, colour = 47, scale = 0.8 },
        tipsOff = 'fence',
        items = {
            copper_coil = 320,
            portable_generator = 650,
            copper_wire = 38,
            copper = 22,
            aluminum = 14,
            steel = 10,
            iron = 8,
            metalscrap = 6,
            rubber = 3,
            plastic = 2,
            glass = 2,
        },
    },

    fence = {
        label = 'Parts Fence',
        ped = 'g_m_y_lost_01',
        scenario = 'WORLD_HUMAN_SMOKING',
        locations = {
            vec4(1240.1, -3168.2, 5.5, 270.0),   -- Elysian Island containers
            vec4(1740.0, 3290.0, 41.1, 195.0),   -- Sandy Shores airfield hangars
            vec4(-582.0, 5326.0, 70.2, 340.0),   -- Paleto sawmill
        },
        rotate = 60,
        hours = { open = 21, close = 5 },
        payout = 'clean',
        minRep = 2,
        items = {
            catalytic_converter = 'value',
            stolen_wheel = 'value',
            copper_coil = 360,
            portable_generator = 700,
        },
    },
}
