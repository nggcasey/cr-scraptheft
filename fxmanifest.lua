fx_version 'cerulean'
game 'gta5'

author 'Casey Reed'
description 'Scrap Theft'
version '2.0.0'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'config/*.lua',
    '@ox_lib/init.lua'
}

lua54 'yes'