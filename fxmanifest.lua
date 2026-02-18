fx_version 'cerulean'
game 'gta5'

author 'Out of Character Radio'
description 'Out of Character Radio: in-game custom radio + loading screen with OOC radio'
version '2.1.0'

-- Edit config.json for community name and loading screen (welcome, rules, news).
supersede_radio 'RADIO_23_DLC_XM19_RADIO' { url = 'https://broadcast.drownradio.net/listen/oocradio_public/radio.mp3', volume = 0.3, name = 'Out of Character Radio', logo = 'nui://radio/logo.png' }

files {
	'config.json',
	'index.html',
	'loadscreen.html',
	'loadscreen.css',
	'loadscreen.js',
	'assets/logo.png', 'assets/oocradio_logo.png', 'assets/background.png'  -- required for loadscreen images
}

ui_page 'index.html'

loadscreen 'loadscreen.html'
loadscreen_cursor 'yes'

server_scripts {
	'server.lua'
}

client_scripts {
	'data.js',
	'client.js'
}
