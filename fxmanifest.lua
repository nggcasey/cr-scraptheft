fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'cr-thief'
author 'Casey Reed'
description 'Be a thief: copper, cats, wheels, car break-ins, pickpocketing, shoplifting, construction sites and petty street crime, with a living neighbourhood that notices.'
version '3.0.0'
repository 'https://github.com/nggcasey/cr-scraptheft'

ox_lib 'locale'

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'config/*.lua',
    'config/jobs/*.lua',
    'shared/*.lua',
    'client/modules/*.lua',
    'locales/*.json',
}

dependencies {
    '/onesync',
    'ox_lib',
    'ox_target',
    'ox_inventory',
}
