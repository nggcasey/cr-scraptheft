--[[
    cr-thief :: the locals

    Everything about the people around you while you work:

      encounters  someone actually turns up (at most one per job). Each visit generates a persona:
                  a name, a personality type, and traits rolled from the ranges below, so no two
                  visits play out the same.
      bystanders  passing peds who see you react (stare, mutter, film, hurry off). They never call.
      offscreen   voices and sounds from the street with nobody in sight: a window slams, a dog
                  barks. These nudge the chance of a noise report.

    Any number written as { min, max } is rolled for each visit.

    Placeholders usable in lines:
      {name} {first}       the persona          {item}     what you're stealing ("a/c unit")
      {neighbour}          a random first name  {target}   the car you're working on
      {street}             current street
]]

return {
    names = {
        female = {
            'Karen', 'Brenda', 'Sharon', 'Deborah', 'Linda', 'Susan', 'Janine', 'Tracy', 'Margaret', 'Doris',
            'Pam', 'Gail', 'Kylie', 'Beverly', 'Carol', 'Denise', 'Mildred', 'Ethel', 'Gladys', 'Peggy',
            'Betty', 'Mei', 'Priya', 'Rosa', 'Fatima', 'Agnes', 'Yvonne', 'Cheryl', 'Wendy', 'Noreen',
        },
        male = {
            'Gary', 'Dennis', 'Frank', 'Kevin', 'Darren', 'Shane', 'Barry', 'Trevor', 'Wayne', 'Clive',
            'Nigel', 'Bruce', 'Mohammed', 'Yusuf', 'Ming', 'Raj', 'Vinnie', 'Dale', 'Craig', 'Terry',
            'Rodney', 'Keith', 'Malcolm', 'Stavros', 'Desmond', 'Luis', 'Hamish', 'Reggie', 'Lenny', 'Doug',
        },
        last = {
            'Smith', 'Nguyen', 'Kowalski', 'Patel', "O'Brien", 'Murphy', 'Thompson', 'Rossi', 'Singh', 'Wong',
            'Jenkins', 'Baxter', 'McAllister', 'Papadopoulos', 'Kim', 'Garcia', 'Henderson', 'Fitzgerald',
            'Okafor', 'Novak', 'Lindqvist', 'Haddad', 'Pemberton', 'Doyle',
        },
        nicknames = {
            'Shifty', 'Two-Bob', 'Sparky', 'Dodgy Dave', 'Copper Col', 'Big Tone', 'Rusty', 'Gazza',
            'Knuckles', 'The Magpie', 'Spanner', 'Wheelie Bin', 'Half-Price', 'Mouse',
        },
    },

    ---------------------------------------------------------------------------
    -- Encounters
    ---------------------------------------------------------------------------
    encounters = {
        enabled = true,
        chance = 0.35,               -- per job
        nightMultiplier = 0.6,       -- fewer people about at night
        delay = { 3000, 12000 },     -- ms after starting before the roll
        spawnDistance = { 22.0, 35.0 },
        copsSeeYou = true,           -- an ambient cop with line of sight reports it instantly

        types = {
            -------------------------------------------------------------------
            karen = {
                label = 'Nosy neighbour',
                icon = 'mobile-screen',
                weight = 4,
                behaviour = 'nag',
                models = { 'a_f_m_bevhills_01', 'a_f_m_bevhills_02', 'a_f_y_hipster_02', 'a_f_m_tourist_01' },
                nameFormats = { '{first} from No. {house}', '{first} {last}', 'Neighbourhood Watch {first}' },
                nagTime = { 10000, 22000 },        -- patience before she calls
                lineEvery = { 3500, 6500 },
                giveUpDistance = 30.0,
                lines = {
                    'Excuse me! EXCUSE ME! I am filming this!',
                    "That is NOT your {item}. That's {neighbour}'s!",
                    'Do you even live here? I know everyone on {street}.',
                    "I'm calling the police. And the HOA.",
                    "Don't you DARE walk away while I'm talking to you!",
                    'This is going straight on the neighbourhood group.',
                    "I want to speak to whoever's in charge of you.",
                    'My husband is a lawyer. Well. He was.',
                    'I have your face in 4K, sweetie.',
                    "Is this what you do all day? Get a job!",
                },
                leaveLines = { 'Hmph. And STAY gone.', "That's right, keep walking!", "I'll be watching you." },
                callLines = { "That's it, I'm calling the police!", "Hello, police? Yes, it's {name}. AGAIN." },
                report = {
                    "There's a {suspect} stealing {neighbour}'s {item} on {street}! I have VIDEO.",
                    'This is {name}. Someone is {action} on {street}. I have asked them to stop TWICE.',
                    "I'd like to report a crime AND a complaint about your response times. {action}, {street}.",
                },
            },

            -------------------------------------------------------------------
            angry = {
                label = 'Angry local',
                icon = 'hand-fist',
                weight = 2,
                behaviour = 'confront',
                models = { 'a_m_m_hillbilly_01', 'a_m_y_musclbeac_01', 'a_m_m_salton_02', 'a_m_m_farmer_01' },
                nameFormats = { '{first} {last}', '{first}' },
                weapons = { 'WEAPON_UNARMED', 'WEAPON_BAT', 'WEAPON_UNARMED', 'WEAPON_GOLFCLUB' },
                warnTime = { 2500, 5000 },
                backOffChance = { 0.3, 0.8 },     -- chance he backs down when you aim a gun at him
                callChance = { 0.1, 0.4 },        -- chance he rings the cops after
                companion = { chance = 0.3, models = { 'a_c_rottweiler' }, attack = true },
                lines = {
                    'Oi! Put that down, mate!',
                    'You picked the wrong street, sunshine.',
                    "I'll sort you out myself, no need for the cops.",
                    "Right. That's it. Come here.",
                    "That's {neighbour}'s! She's eighty-four, you grub!",
                },
                backOffLines = { 'Woah, woah! Alright, alright...', "Easy! I didn't see nothing!", "Not worth it. NOT worth it." },
                walkAwayLines = { 'Yeah, keep walking!', "And don't come back!" },
                report = {
                    'Bloke here {action}, I had a go at him. {suspect}. {street}.',
                    "It's {name}. Tried to stop some grub {action} on {street}. Send someone before I do something.",
                },
            },

            -------------------------------------------------------------------
            timid = {
                label = 'Timid passer-by',
                icon = 'phone',
                weight = 4,
                behaviour = 'caller',
                useNearby = true,
                approach = false,
                models = { 'a_m_y_hipster_01', 'a_f_y_tourist_01', 'a_m_y_business_01', 'a_f_y_business_01' },
                callTime = { 6000, 12000 },
                scareChance = { 0.7, 1.0 },
                scenario = 'WORLD_HUMAN_STAND_MOBILE',
                lines = {
                    "H-hello, police? I think someone's stealing...",
                    "I-I'm not looking! I'm not looking!",
                    "*whispering* there's someone {action}...",
                    'Sorry, sorry, wrong number. *keeps dialling*',
                },
                report = {
                    "Um, hi, sorry to bother you, I think someone's {action}? On {street}? Sorry.",
                    "*whispering* there's a {suspect} {action} near {street}. please hurry.",
                    "I don't want to get involved but someone is {action} on {street}.",
                },
            },

            -------------------------------------------------------------------
            security = {
                label = 'Security guard',
                icon = 'shield-halved',
                weight = 1,
                behaviour = 'caller',
                approach = true,
                keepDistance = { 6.0, 10.0 },
                models = { 's_m_m_security_01' },
                nameFormats = { 'Guard {last}', 'Officer {first} (Securicorp)' },
                weapon = 'WEAPON_FLASHLIGHT',
                callTime = { 4000, 6000 },
                scareChance = { 0.15, 0.5 },
                anim = { dict = 'random@arrests', clip = 'generic_radio_chatter', flag = 49 },
                lines = {
                    'Hey! You! Stay right there!',
                    "Control, I've got someone tampering on site.",
                    "I've been doing this for twenty years, pal. Don't try me.",
                },
                report = {
                    'Site security. Suspect {action} on {street}. {suspect}. I am observing.',
                    '{name} here, patrol unit. Active theft, {street}. Requesting police.',
                },
            },

            -------------------------------------------------------------------
            grandpa = {
                label = 'Grumpy pensioner',
                icon = 'person-cane',
                weight = 2,
                behaviour = 'caller',
                useNearby = false,
                approach = false,
                models = { 'a_m_o_genstreet_01', 'a_m_o_soucent_01', 'a_f_o_genstreet_01', 'a_f_o_soucent_01' },
                nameFormats = { 'Mr {last}', 'Mrs {last}', 'Old {first}' },
                callTime = { 12000, 20000 },      -- still finding his glasses
                scareChance = { 0.3, 0.6 },
                scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
                heckle = true,                    -- keeps shouting while he dials
                lines = {
                    'Back in my day we stole things QUIETLY!',
                    "I fought in a war for this street!",
                    "I'm ringing the constabulary! Where are my glasses...",
                    'Young people today! No respect for property!',
                    "{neighbour}! {neighbour}, come look at this hooligan!",
                    "I can see you! I've got cataracts, not blindness!",
                },
                report = {
                    "Hello? HELLO? Is this the police? There's a hooligan {action} on {street}! What? SPEAK UP!",
                    "It's {name} from {street}. Some lout's {action}. In MY day they'd get the cane.",
                },
            },

            -------------------------------------------------------------------
            dogwalker = {
                label = 'Dog walker',
                icon = 'dog',
                weight = 2,
                behaviour = 'caller',
                approach = true,
                keepDistance = { 9.0, 13.0 },
                models = { 'a_m_y_runner_01', 'a_f_y_fitness_01', 'a_f_y_runner_01', 'a_m_m_tourist_01' },
                callTime = { 7000, 11000 },
                scareChance = { 0.6, 0.9 },
                scenario = 'WORLD_HUMAN_STAND_MOBILE',
                companion = {
                    chance = 1.0,
                    models = { 'a_c_retriever', 'a_c_shepherd', 'a_c_husky', 'a_c_westy', 'a_c_pug', 'a_c_poodle' },
                    bark = true,                  -- runs up and barks at you
                },
                lines = {
                    "{dog}! {dog}, NO! Come here!",
                    "Sorry, he doesn't usually... actually, what ARE you doing?",
                    "{dog} doesn't like you. {dog} is a very good judge of character.",
                },
                report = {
                    'Out walking my dog and someone is {action} on {street}. {dog} is going nuts.',
                    "Hi, it's {name}. There's a {suspect} {action} on {street}. My dog found them, honestly.",
                },
                dogNames = { 'Biscuit', 'Max', 'Bella', 'Chopper', 'Princess', 'Rex', 'Lola', 'Tank', 'Muffin', 'Kevin' },
            },

            -------------------------------------------------------------------
            drunk = {
                label = 'Drunk',
                icon = 'beer-mug-empty',
                weight = 2,
                behaviour = 'drunk',
                models = { 'a_m_m_tramp_01', 'a_m_o_tramp_01', 'a_m_m_trampbeac_01', 'a_m_y_beachvesp_01' },
                nameFormats = { '{nick}', '{first}' },
                hangAround = { 10000, 20000 },
                loudChance = 0.4,                 -- gets loud enough to draw a noise report
                passOutChance = 0.25,
                lines = {
                    "Oi... oi mate... *hic* ...you need a hand?",
                    "Is that... is that copper? I LOVE copper.",
                    "I'm not gonna tell no one. *hic* I'm gonna tell EVERYONE.",
                    "You're my best mate, you are.",
                    "*sings badly*",
                    "Can I have a go? Go on. Go on. Go on.",
                    "HEY EVERYONE! THIS BLOKE'S NICKING STUFF! ...wait, was that a secret?",
                },
                report = {
                    "*hic* yeah g'day... me mate's {action} on {street}... no I'M not drunk, YOU'RE drunk.",
                },
            },

            -------------------------------------------------------------------
            filmer = {
                label = 'Teen with a phone',
                icon = 'video',
                weight = 2,
                behaviour = 'filmer',
                models = { 'a_m_y_skater_01', 'a_f_y_hipster_01', 'a_m_y_hipster_02', 'a_m_y_skater_02' },
                nameFormats = { '@{first}{house}', '@{nick}_official', '@{last}{house}x' },
                filmTime = { 6000, 10000 },
                postDelay = { 30000, 90000 },     -- ms until the clip blows up and someone reports it
                lines = {
                    "Yo, chat, look at this guy!",
                    "Bro is NOT subtle 💀",
                    "Say hi to my 40 followers!",
                    "This is going on my story.",
                    "Can you do that again but slower? Lighting's bad.",
                },
            },

            -------------------------------------------------------------------
            -- Never rolled at random (weight 0): used when a shop guard catches you.
            clerk = {
                label = 'Shop clerk',
                icon = 'cash-register',
                weight = 0,
                behaviour = 'caller',
                approach = false,
                models = { 'mp_m_shopkeep_01' },
                callTime = { 2500, 4500 },
                scareChance = { 0.4, 0.8 },
                scenario = 'WORLD_HUMAN_STAND_MOBILE',
                lines = {
                    'HEY! Put that back!',
                    "I saw that! I'm calling the cops!",
                    "Not again! That's the third one today!",
                    "You think I don't have cameras? Smile!",
                },
                report = {
                    'Shoplifter at the store on {street}. {suspect}. Just walked out with stuff.',
                    "It's {name} from the store on {street}. Someone's {action}. I've got it on camera.",
                },
            },

            -------------------------------------------------------------------
            rival = {
                label = 'Rival thief',
                icon = 'handshake-angle',
                weight = 1,
                behaviour = 'rival',
                models = { 'a_m_m_hillbilly_02', 'a_m_y_methhead_01', 'a_m_m_salton_01', 'a_m_m_rurmeth_01' },
                nameFormats = { '{nick}', '{nick} {last}' },
                cut = { 50, 200 },                -- $ he wants
                outcomes = { snitch = 2, fight = 2, leave = 1 }, -- weighted, if you refuse
                lines = {
                    "Oi. This is MY patch.",
                    "You're working {street}? Nobody works {street} without paying {name}.",
                    "Nice {item}. Be a shame if the cops heard about it.",
                },
                payLines = { "Pleasure doing business.", "Smart. Real smart.", "See you next time, partner." },
                snitchLines = { "Your funeral, mate. *pulls out phone*", "Hope you like orange." },
                fightLines = { "Wrong answer.", "Right, I'll take it then." },
                leaveLines = { "Pfft. Not worth my time.", "You'll regret that. Eventually. Probably." },
                report = {
                    "Anonymous tip. Some amateur's {action} on {street}. {suspect}. You didn't hear it from me.",
                },
            },
        },
    },

    ---------------------------------------------------------------------------
    -- Bystanders: life going on around you. They react but never call the cops.
    ---------------------------------------------------------------------------
    bystanders = {
        enabled = true,
        radius = 18.0,
        chance = 0.5,          -- chance a ped who sees you reacts at all
        reactions = { stare = 3, hurry = 3, mutter = 2, film = 1 },
        lines = {
            "...is he allowed to do that?",
            "Not my problem. Not my problem.",
            "Huh. Didn't know that came off.",
            "Every week, I swear.",
            "Should I... nah.",
            "Ooh, is that copper?",
        },
    },

    ---------------------------------------------------------------------------
    -- Off-screen: the street reacting with nobody in sight.
    -- chance is per noisy stage; reportBonus is added to that stage's noise report chance.
    ---------------------------------------------------------------------------
    offscreen = {
        enabled = true,
        chance = 0.2,
        events = {
            { text = '*A window slides open* "Some of us have WORK in the morning!"', reportBonus = 0.08, time = 'night' },
            { text = '"WHAT IS THAT NOISE?!" (from inside somewhere)', reportBonus = 0.05 },
            { text = '*A dog starts barking a few yards over*', reportBonus = 0.03 },
            { text = '*A porch light flicks on across the street*', reportBonus = 0.06, time = 'night' },
            { text = '*A curtain twitches in an upstairs window*', reportBonus = 0.05 },
            { text = '"Mum, someone\'s outside!" "Get away from the window!"', reportBonus = 0.07 },
            { text = '*A car slows down... then keeps going*', reportBonus = 0.02 },
            { text = '"Oi! Some of us are trying to watch the footy!"', reportBonus = 0.04, time = 'day' },
            { text = '*Someone upstairs turns their music up. Rude, but helpful.*', reportBonus = -0.05 },
            { text = '*Sirens, a few streets away... heading somewhere else. Probably.*', reportBonus = 0.0 },
        },
    },
}
