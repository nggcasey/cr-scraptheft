
    # Job reference

    file / index
        Jobs live in config/jobs/<category>.lua; config/jobs.lua lists which files load.
        Job ids must be unique across all files.

    top-level fields
        category   free text grouping ('copper', 'street', ...)
        kind       'prop'    - a world object (target by model)
                   'vehicle' - part = 'cat' | 'wheel' | 'glovebox' (car break-in) | 'battery' | any custom part
                               (custom parts are one-per-vehicle and stored as statebag 'thief:<part>')
                   'ped'     - an ambient pedestrian (pickpocketing)
        rep        XP for finishing (scaled by repetition / tips)
        heat       area heat added for everyone when finished (default 1)
        respawn    minutes before a world object can be hit again (prop jobs)
        minCops    police on duty required
        alarm      chance a LOCKED vehicle's alarm goes off (vehicle jobs)
        directLoot true = loot goes straight into the inventory (falls back to a drop if full)
        behind     ped jobs: must approach from behind
        notice     ped jobs: { chance, reactions = { [encounterType] = weight } }, victim notices after
                   a failed skill check (always) or afterwards (chance)
        guard      { models, radius, chance, reactions } watching peds (shop clerks) who can catch you
        alert      { title, code, actions = { ... } } dispatch title and what witnesses say you're doing
        target     { label, icon, distance, bones? }

    stages (run in order; every stage is confirmed by the server)
        label      progress text
        duration   ms (scaled by rep speed)
        tool       tool id from config/shared.lua Tools (nil = bare hands)
        anim       { dict, clip, flag } or { scenario }   (loops for the whole stage)
        prop       override the hand prop of the tool
        steps      split the stage into N chunks; with `skill` set, a skill check runs between chunks
        stepLabel  label for each chunk, %d/%d = step/total
        skill      { difficulty = {...}, inputs = {...}, attempts = 3 } - failing makes noise and repeats the chunk
        noise      0-1 chance this stage gets reported (before night/alarm modifiers). Witnesses are separate.
        ptfx       { asset, name, on = 'target' | 'tool' | 'ped', offset, scale }
        hazard     { type = 'shock', chance, damage, protect = item }  - interrupt the stage and hurt the player
        place      { model, at = 'wheel' }  - prop placed at the start and removed when the job ends (car jack)
        debris     { model, offset | at = 'wheel', freeze }  - stays in the world until the spot resets
        effect     'removeWheel' | 'smashWindow' | 'openHood'

    loot
        item, label, count = {min, max}, chance (0-1)
        value      {min, max}  -> stored as metadata.value (scaled by vehicle tier), buyers pay that
        carry      true = heavy, must be carried and loaded into a vehicle
        model      prop dropped in the world. 'source' = the object being stolen (it disappears from the world)
        (with tips active, counts are multiplied by World.tips.lootMultiplier)
        attach     carry attachment override { bone, pos, rot }
    Loot without a `model` is grouped into one `bundle` drop (a bag of bits).

    hide / swap
        hide = true      the world object vanishes once stolen (until respawn)
        swap = { [model] = replacementModel } shows a damaged version until respawn
