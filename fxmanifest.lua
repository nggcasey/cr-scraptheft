fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'cr-scraptheft'
author 'Casey Reed'
description 'Immersive scrap & parts theft: strip A/C units, rip copper, cut catalytic converters, jack wheels and fence the goods.'
version '3.0.0'
repository 'https://github.com/nggcasey/cr-scraptheft'

ox_lib 'locale'

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'config/*.lua',
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
