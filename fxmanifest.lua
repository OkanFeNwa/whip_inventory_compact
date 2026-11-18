fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'whip_inventory_compact'
version '1.2.0'
description 'Localized skin for the stock whip inventory (no renderer replaced)'
author 'whip_inventory_compact contributors'
-- Add `repository 'https://github.com/<you>/whip_inventory_compact'` before publishing.

dependency 'whip_core'

-- The satellite helper is included, never copied. It re-runs Whip.register after
-- every whip_core (re)start, which is when the theme registry is empty again.
-- config.lua + shared/locale.lua give the skin the same IT/EN/ES/FR/DE switch
-- used by whip_clothingwheel.
shared_scripts {
    '@whip_core/lib/satellite.lua',
    'config.lua',
    'shared/locale.lua',
}

client_script 'client.lua'
server_script 'server.lua'

files {
    'theme.css',
    'locales/active.css',
}
