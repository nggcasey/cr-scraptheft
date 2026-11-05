--[[
    cr-thief :: what gets reported to police

    A report is built from:
      caller   who's on the phone
      message  a template with placeholders, filled from what's actually happening
    Witnesses (config/people.lua) use their own `report` lines. Everything else uses the pools below.

    Placeholders
      {action}   what you're doing (per job, in config/jobs/*.lua -> alert.actions)
      {item}     the job label ("a/c unit")      {target}  the car being stripped
      {street}   street name                     {suspect} a (not always accurate) description
      {vehicle}  your getaway car, if one's parked nearby ("blue Sultan, plate starting 4AB...")
      {neighbour} random first name              {name}    the caller
]]

return {
    -- Original callers & messages, still in rotation for noise complaints.
    classicCallers = {
        'John', 'James', 'Betty', 'Karen', 'Mr Singh', 'Dennis', 'Frank', 'Peggy',
        'Mildred', 'Ethel', 'Gladys', 'Kevin', 'Mohammed', 'Yusuf', 'Ming', 'Mrs Wong',
    },
    classicMessages = {
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
        'Someone across the road is stealing, I tried to stop them but they told me to piss off',
    },
    classicChance = 0.35,   -- share of noise complaints that use the classic lines

    -- Someone heard it, nobody saw it.
    noise = {
        callers = {
            'Anonymous', 'Resident, Unit 4B', 'Night-shift nurse next door', 'Concerned citizen',
            'Building manager', "Someone's nan", 'Local business owner', 'Uber driver passing by',
        },
        templates = {
            "Grinding noise for the last ten minutes near {street}. At THIS hour?",
            "Sounds like someone's cutting metal on {street}. Sparks over the fence.",
            'Loud banging and clanging behind the buildings on {street}.',
            "Can't see anything but it sounds like someone's {action}. {street}.",
            "There's power tools going near {street} and nobody's doing renos round here.",
            "Something's going on at {street}. Lot of clanging. Could be nothing. Probably not nothing.",
        },
    },

    -- Named people who call it in WITHOUT ever showing up: the apartment across the road,
    -- the bloke next door peering through the blinds. Nobody is spawned; you may get a hint, or nothing.
    -- Rolled once per job, independent of noise reports and encounters.
    unseen = {
        chance = 0.25,          -- per job (night multiplier from Heat.night applies)
        delay = { 8000, 25000 },-- ms after starting; the call goes out at this point
        hintChance = 0.5,       -- chance the player gets a subtle clue that someone's watching
        callers = {
            {
                weight = 4, gender = 'female',
                nameFormats = { '{first} {last}, apartment across the road', '{first} in 3C', 'Mrs {last} (upstairs)' },
                hints = { '*A curtain twitches in an upstairs window*', '*Blinds snap shut across the road*' },
                report = {
                    "I can see someone {action} from my window on {street}. {suspect}. I'm not going down there.",
                    "It's {name}. There's a {suspect} {action} outside. Third time this month!",
                    "Someone's {action} right under my balcony on {street}. I've got the binoculars on them.",
                },
            },
            {
                weight = 3, gender = 'male',
                nameFormats = { '{first} next door', '{first} {last}', 'Neighbourhood Watch Coordinator {first}' },
                hints = { '*A porch light flicks on across the street*', '*Someone is silhouetted in a window*' },
                report = {
                    'G\'day, {name} here. Some {suspect} is {action} on {street}. I\'ve written down the time.',
                    "Neighbourhood Watch. Suspicious activity, {street}: {action}. {vehicle}",
                    "Watching a {suspect} {action} on {street} right now. Want me to go have a word? ...Fine.",
                },
            },
            {
                weight = 2, gender = 'any',
                nameFormats = { 'Night-shift worker, {street}', 'Gamer, apartment 12', 'Insomniac on {street}' },
                hints = { '*A TV glow flickers off in a window above you*' },
                time = 'night',
                report = {
                    "Can't sleep and now there's someone {action} outside. {street}. Unbelievable.",
                    "Was mid-game and heard a grinder. Looked out, someone's {action} on {street}.",
                },
            },
            {
                weight = 2, gender = 'any',
                nameFormats = { 'Barista at the cafe on {street}', 'Shop owner, {street}', 'Delivery driver' },
                hints = { '*Someone across the street quickly looks away*' },
                time = 'day',
                report = {
                    "Hi, I can see someone {action} from the shop on {street}. {suspect}.",
                    "Out on a delivery, someone's {action} on {street}. {vehicle} Not stopping, got six more drops.",
                },
            },
        },
    },

    -- Car alarm went off and the monitoring company called it in.
    alarm = {
        chance = 0.5,           -- chance a triggered alarm is reported by the alarm company
        callers = { 'SecurCorp Monitoring', 'Bullseye Alarm Co.', 'Vigil Auto-Watch', 'Tracker Plus' },
        templates = {
            'Vehicle alarm triggered: {target} on {street}. Owner not answering.',
            'Tilt sensor activated on a {target}, {street}. Possible parts theft.',
            'Alarm and GPS movement alert, {target} at {street}. Please attend.',
        },
    },

    -- An NPC cop saw you.
    cop = {
        callers = { 'Off-duty officer', 'Patrol unit (unassigned)', 'Traffic unit' },
        templates = {
            'Observed suspect {action} on {street}. {suspect}.',
            'Witnessed active theft, {street}. Suspect {suspect}. {vehicle}',
        },
    },

    -- A teen's video went viral.
    viral = {
        callers = { 'LifeInvader tip line', 'Weazel News tip desk', '@LSNewsDesk', 'Bleeter trending' },
        templates = {
            'Video trending online shows someone {action} on {street}. Caption: "{caption}" (posted by {name})',
            'Viewers flagging footage of a {suspect} {action} near {street}. Posted by {name}.',
        },
        captions = {
            'bro thinks hes invisible 💀', 'not even hiding it lmao', 'LS is a different breed fr',
            'the audacity', 'he waved at me??', 'this is why we cant have nice things',
        },
    },

    -- Witnesses describing the suspect. Not always accurately.
    suspect = {
        certainty = { '', '', '', 'possibly ', 'definitely ' },
        builds = { 'skinny', 'big', 'short', 'tall', 'scruffy-looking', 'shifty-looking', 'sweaty', 'very confident' },
        clothing = {
            'in a hoodie', 'in a hi-vis vest', 'in a tracksuit', 'in a beanie', 'in work overalls',
            'in a cap', 'in dark clothes', 'in thongs and a singlet', 'in a nice jacket, weirdly',
        },
        wrongGenderChance = 0.1,
        plateChance = 0.4,      -- chance they caught part of the getaway car's plate
    },
}
