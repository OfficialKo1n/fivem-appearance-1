fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

author 'snakewiz'
description 'A flexible player customization script for FiveM.'
repository 'https://github.com/pedr0fontoura/fivem-appearance'
version '1.2.2'

client_scripts {
  -- 'game/build/client.js',
  'client/constants.lua',
  'client/main.lua',
  'client/customisation.lua',
  'client/nui.lua',
  'client/shops.lua',
  'client/esx.lua'
}

files {
  'web/build/index.html',
  'web/build/static/js/*.js',
  'locales/*.json',
  'peds.json'
}

ui_page 'web/build/index.html'

provides {
  'skinchanger',
  'esx_skin'
}