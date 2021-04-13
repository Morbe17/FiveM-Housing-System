# Resmurf-Housing-System

This is a housing system in which the player is teleported to an interior and set to a different dimmension; allowing the posibilities of re-using interiors.

https://streamable.com/d9vznw

List of built in commands:
`/createProperty 1 3 10000`
`/setfee`
`/sellto`
`/sellproperty`
`/unbuginterior`


The `unbuginterior` command will be removed later on, just incase someone gets bugged, it'll unbug them. You might want to disable this before putting it into your server.

## INSTALLATION:

Import the properties.sql file into your ESX Database; after that just plaste the rest of the files in a folder called `properties` (If you use other name, the resource wont work.) and ensure it. 

## REQUIRES:

Resources: `bob74_ipl` and 'base_events' These should be default FiveM resources if you've installed your server recently, anyways, make sure you have them on!

### Exported functions:

```
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
    'doesPropertyHasItem'```
