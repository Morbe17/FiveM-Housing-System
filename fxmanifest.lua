fx_version 'cerulean'
games { 'gta5' }

author 'Resmurf'
description 'Hosing system'
version '1.0.0'

shared_script{
    'config.lua',
    'translations.lua',
    'properties.lua'
}

client_scripts {
    'client/main.lua',
    'client/cl_functions.lua',
    'client/loader.lua',
    'client/nui.lua',
    'client/storage.lua'
}

server_script {
    "@mysql-async/lib/MySQL.lua",
    'server/main.lua',
    'server/sv_functions.lua',
    'server/storage.lua',
}

ui_page "html/index.html"

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/jquery-3.5.1-'
}

server_exports{
    'displayError',
    'displayMessage',
    'getRandomizer',
    'propertiesGetPlayerJob',
    'propertiesRemovePlayerMoney',
    'propertiesAddPlayerMoney',
    'propertiesAddPlayerMoneyAmount',
    'propertiesGetPlayerNameFromServerId',
    'getPlayerIdentifier',
    'getPropertyOwner',
    'getPropertyType',
    'getPlayerBankMoney',
    'getPlayerMoney',
    'removePlayerMoney',
    'setPropertyFee',
    'setPropertyForSale',
    'setPropertyOwner',
    'setPropertyName',
    'setPropertyMaxCapacity',
    'getPropertyMaxCapacity',
    'savePlayerInteriorStatus',
    'isDbPlayerIstanced',
    'togglePropertyLock',
    'isPropertyLocked',
    'storeItem',
    'removeItem',
    'doesPropertyHasItem'
}