-- Property types are [1] Houses, [2] Bussinesses, [3] Government Buildings.
--
activeProperties = {}
local firstRun  = false
local total = 0
randomizer = math.random(1, 10000000000)

RegisterNetEvent("properties:loadProperties") -- Loads all the properties from the database, currently triggers when a new one is created or the resource has started.
AddEventHandler("properties:loadProperties", function(secKey)

  if randomizer == secKey then
    activeProperties = {}
    local properties = MySQL.Sync.fetchAll("SELECT * FROM properties", {})

    if properties == nil then
      properties = {}
      print('^3[Resmurf Properties System]^0 WARNING, No properties table were found or some other error may have ocurred, please make sure to start this script after your mysql-async. You might want to restart the resource.')
    end

    for k, v in pairs(properties) do
      --Citizen.Wait(0)
      activeProperties[tonumber(v.id)] = {
        id = v.id,
        propertyOwner = v.propertyOwner,
        interiorId = v.interiorId,
        name = v.name,
        interiorType = v.interiorType,
        location = json.decode(v.location),
        forSale = v.forSale,
        salePrice = v.salePrice,
        fee = v.fee,
        locked = v.locked,
        previousInt = v.previousInt,
        capacity = v.capacity
      }
      total = total + 1
    end

    if not firstRun then
      print('^5[Resmurf Properties System]^0 Loaded successfully, with a total of ('..total..') properties')
    end

    firstRun = true

    TriggerClientEvent("properties:updateProperties", -1, activeProperties) -- Sends all the properties to all the clients, so they can be streamed ingame.
  end
end)

RegisterNetEvent("properties:CreateNewProperty") -- Gets the new property being created from the command or other means. Creates it into the DB (Properties should only be created by admins)
AddEventHandler("properties:CreateNewProperty", function(type, id, loc, price)

  --if isPlayerAllowedToUseCommand(source) then
  if true then
    local src = source
    local propertyOwner = getPlayerIdentifier(src)
    local interiorType = tonumber(type)
    local interiorId = tonumber(id)
    local x, y, z = table.unpack(loc)
    local location = {x = x, y = y, z = z}
    local forSale = true
    local prevInt = GetPlayerRoutingBucket(src)

    if interiorType == 1 or interiorType == 2 then
      forSale = true
    elseif interiorType == 3 then
      forSale = false
    end

    MySQL.Sync.fetchAll("INSERT INTO properties (interiorType, interiorId, location, forSale, salePrice, previousInt, capacity) VALUES(@interiorType, @interiorId, @location, @forSale, @salePrice, @previousInt, @capacity)",
    {["@interiorType"] = interiorType, ["@interiorId"] = interiorId, ["@location"] = json.encode(location), ["forSale"] = forSale, ["salePrice"] = tonumber(price), ["previousInt"] = prevInt, ["capacity"] = Config.DefaultCapacity},

    function (result)
    end)

    TriggerEvent("properties:loadProperties", randomizer)

  else
    
  end

end)

RegisterNetEvent("properties:buyProperty") -- Sets a property to a player
AddEventHandler("properties:buyProperty", function(propertyId, name)

  local src = source
  local playerMoney = getPlayerBankMoney(src)

  local property = activeProperties[propertyId]

  if not Config.RealStateScript then
    if property.forSale and property.interiorType ~= 3 then
      if playerMoney >= property.salePrice then
        local removeMoney = propertiesRemovePlayerMoney(src, property.salePrice)
        if removeMoney then
          setPropertyOwner(src, propertyId, name)
          displayMessage(src,Lenguage[Config.Leng]['boughtProperty'])
        end
      else
        displayError(src, Lenguage[Config.Leng]['noMoney'])
      end
      TriggerEvent("properties:loadProperties", randomizer)
    else
      displayError(src, Lenguage[Config.Leng]['notForSale'])
    end
  else
    return
  end
end)

RegisterNetEvent("properties:enterProperty")
AddEventHandler("properties:enterProperty", function(propertyId)

  local src = source
  local playerMoney = getPlayerMoney(src)

  local property = activeProperties[propertyId]

  if not property.locked then
    if property.fee >= 0 then
      playerMoney = getPlayerBankMoney(src)
      if playerMoney >= property.fee then
        removePlayerMoney(src, property.fee)
      end
    end
      SetPlayerRoutingBucket(src, propertyId)
        if Config.PMAvoice then
          exports['pma-voice'].updateRoutingBucket(src, propertyId)
        end
      TriggerClientEvent("properties:enterProperty2", src, property)
      savePlayerInteriorStatus(src, propertyId, true)
  else
    displayMessage(src, Lenguage[Config.Leng]['islocked'])
  end

end)

RegisterNetEvent("properties:leaveProperty") 
AddEventHandler("properties:leaveProperty", function()

  local src = source
  local playerPropertyId = GetPlayerRoutingBucket(src)

  local property = activeProperties[playerPropertyId]

  if not property.locked then
    SetPlayerRoutingBucket(src, property.previousInt)
    if Config.PMAvoice then
      exports['pma-voice'].updateRoutingBucket(src, propertyId)
    end

    TriggerClientEvent("properties:leaveProperty2", src, property, true)
    if property.previousInt == 0 then
      savePlayerInteriorStatus(src, playerPropertyId, false)
    else
      savePlayerInteriorStatus(src, playerPropertyId, true)
    end
  else
    displayMessage(src, Lenguage[Config.Leng]['islocked'])
  end

end)

RegisterNetEvent('properties:checkIfInstanced') -- Check if a player is inside an itnerior, if so, sets the dimension to such interior.
AddEventHandler('properties:checkIfInstanced', function()

  local src = source
  local isPlayerInstanced, propertyId = isDbPlayerIstanced(src)

  local property = activeProperties[propertyId]

  if isPlayerInstanced then
    SetPlayerRoutingBucket(src, propertyId)
    if Config.PMAvoice then
      exports['pma-voice'].updateRoutingBucket(src, propertyId)
    end

    TriggerClientEvent("properties:setPlayerInsideInteriorForLeader", src, propertyId)
    savePlayerInteriorStatus(src, propertyId, true)
  end 

end)

RegisterNetEvent('properties:toggleLock') -- Check if a player is inside an itnerior, if so, sets the dimension to such interior.
AddEventHandler('properties:toggleLock', function(propertyId)

  local src = source
  local propertyOwner = getPlayerIdentifier(src)

  if propertyId == nil then
    propertyId = GetPlayerRoutingBucket(src)
  end

    local exist = MySQL.Sync.fetchAll("SELECT propertyOwner FROM properties WHERE id = @id", {["@id"] = tonumber(propertyId)})
    local dbIdentifier = exist[1].propertyOwner

    if propertyOwner == dbIdentifier then
      local isPropertyLocked = isPropertyLocked(propertyId)
      togglePropertyLock(src, propertyId, not isPropertyLocked)
    else
      displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
    end

end)

RegisterNetEvent('properties:setFee') -- Check if a player is inside an itnerior, if so, sets the dimension to such interior.
AddEventHandler('properties:setFee', function(value)
  local src = source

  local type = type(tonumber(value))

    if not type == "number" then
        displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
        return
    end

  local amount = tonumber(math.floor(round(value, 0)))
  local propertyId = GetPlayerRoutingBucket(src)

  if propertyId == 0 or propertyId == nil then
    displayMessage(src, Lenguage[Config.Leng]['insideInterior'])
  else
    if amount then
      if amount >= 0 then
        local propertyType = getPropertyType(propertyId)
        if propertyType == 2 then
          local propertyOwner = getPropertyOwner(propertyId)
          local identifier = getPlayerIdentifier(src)
          if propertyOwner == propertyOwner then
            
            setPropertyFee(propertyId, amount)
            TriggerClientEvent("properties:updateProperty", -1, activeProperties[propertyId])
            displayMessage(src, "Fee Set successfully")

          else
            displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
          end
        else
          displayMessage(src, Lenguage[Config.Leng]['onlyBusiness'])
        end
      else
        displayMessage(src, Lenguage[Config.Leng]['noNegativeFee'])
      end
    else
      displayMessage(src, Lenguage[Config.Leng]['missingTheAmount'])
    end
  end
end)


RegisterNetEvent('properties:sellPropertyToPlayer') -- Check if a player is inside an itnerior, if so, sets the dimension to such interior.
AddEventHandler('properties:sellPropertyToPlayer', function(playerId)
  local src = source

  local type = type(tonumber(playerId))

    if not type == "number" then
        displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
        return
    end

  local targetPlayer = tonumber(math.floor(round(playerId, 0)))

  if not GetPlayerPing(targetPlayer) then
    return
  end

  local propertyId = GetPlayerRoutingBucket(src)

  if propertyId == 0 or propertyId == nil then
    displayMessage(src, Lenguage[Config.Leng]['insideInterior'])
  else
    if targetPlayer then
      local propertyOwner = getPropertyOwner(propertyId)
      local identifier = getPlayerIdentifier(src)
      if propertyOwner == propertyOwner then

        setPropertyOwner(targetPlayer, propertyId, activeProperties[propertyId].name)
        TriggerClientEvent("properties:updateProperty", -1, activeProperties[propertyId])
        displayMessage(src, "You've given the property.")
        displayMessage(targetPlayer, "You were given the property.")

      else
        displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
      end
    else
      displayMessage(src, Lenguage[Config.Leng]['missingTheAmount'])
    end
  end
end)

RegisterNetEvent('properties:sellProperty') -- Check if a player is inside an itnerior, if so, sets the dimension to such interior.
AddEventHandler('properties:sellProperty', function(tbl)
  local src = source

  local propertyId = GetPlayerRoutingBucket(src)
  local property = activeProperties[propertyId]

  if propertyId == 0 or propertyId == nil then
    displayMessage(src, Lenguage[Config.Leng]['insideInterior'])
  else
    local propertyOwner = getPropertyOwner(propertyId)
    local identifier = getPlayerIdentifier(src)
    if propertyOwner == propertyOwner then

      for k,v in pairs(tbl) do
        local playerInterior = GetPlayerRoutingBucket(v)

        if playerInterior == propertyId then
          SetPlayerRoutingBucket(v, property.previousInt)
          if Config.PMAvoice then
            exports['pma-voice'].updateRoutingBucket(src, previousInt)
          end
          TriggerClientEvent("properties:leaveProperty2", v, activeProperties[propertyId], true)
          savePlayerInteriorStatus(v, propertyId, false)
        end
      end
      
      setPropertyForSale(propertyId)
      propertiesAddPlayerMoney(src, propertyId)
      TriggerClientEvent("properties:updateProperty", -1, activeProperties[propertyId])

    else
      displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
    end
  end
end)

AddEventHandler('onResourceStart', function(resourceName)

  local key = Config.LicenseKey
  local version = Config.Version

  local myAddress = "http://127.0.0.1:3001/findKey/"..key.."/"..version

  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  --[[ PerformHttpRequest(myAddress, function (errorCode, resultData, resultHeaders)

    local result = json.decode(resultData)
    --local canRun = result.allowAccess
    --local message = result.message

    local canRun = true
    local message = "HardCoded run"

    if canRun then 
      print(message)
      TriggerEvent("properties:loadProperties", randomizer)
    else
      print(message)
      return 
    end

  end) ]]

  TriggerEvent("properties:loadProperties", randomizer)
end)

RegisterNetEvent('properties:RequestProperties')
AddEventHandler('properties:RequestProperties', function(resourceName)
  local src =  source
  TriggerClientEvent("properties:updateProperties", src, activeProperties)
end)


--[[ RegisterCommand("resetinterior", function(source)

  SetPlayerRoutingBucket(source, 0)
end, true)

RegisterCommand("getBucket", function(source)

  print(GetPlayerRoutingBucket(source))
end, true) ]]


RegisterNetEvent("esx_ambulancejob:setDeathStatus")
AddEventHandler("esx_ambulancejob:setDeathStatus", function(bool)

  local src = source
  if bool == false then
    SetPlayerRoutingBucket(src, 0)
    if Config.PMAvoice then
      exports['pma-voice'].updateRoutingBucket(src, 0)
    end
    savePlayerInteriorStatus(src, 0, false)
    TriggerClientEvent("properties:leaveProperty2", src, "Death", false)
  end
end)

RegisterNetEvent("resetBucket")
AddEventHandler("resetBucket", function()
  local src  = source
  SetPlayerRoutingBucket(src, 0)
  if Config.PMAvoice then
    exports['pma-voice'].updateRoutingBucket(src, 0)
  end
  TriggerClientEvent("properties:leaveProperty2", src, "Death", false)

end)
  else
    local propertyOwner = getPropertyOwner(propertyId)
    local identifier = getPlayerIdentifier(src)
    if propertyOwner == propertyOwner then

      for k,v in pairs(tbl) do
        local playerInterior = GetPlayerRoutingBucket(v)

        if playerInterior == propertyId then
          SetPlayerRoutingBucket(v, property.previousInt)
          TriggerClientEvent("properties:leaveProperty2", v, activeProperties[propertyId], true)
          savePlayerInteriorStatus(v, propertyId, false)
        end
      end
      
      setPropertyForSale(propertyId)
      propertiesAddPlayerMoney(src, propertyId)
      TriggerClientEvent("properties:updateProperty", -1, activeProperties[propertyId])

    else
      displayMessage(src, Lenguage[Config.Leng]['notOwnerOrNoKeys'])
    end
  end
end)

AddEventHandler('onResourceStart', function(resourceName)

  local key = Config.LicenseKey
  local version = Config.Version

  local myAddress = "http://127.0.0.1:3001/findKey/"..key.."/"..version

  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  --[[ PerformHttpRequest(myAddress, function (errorCode, resultData, resultHeaders)

    local result = json.decode(resultData)
    --local canRun = result.allowAccess
    --local message = result.message

    local canRun = true
    local message = "HardCoded run"

    if canRun then 
      print(message)
      TriggerEvent("properties:loadProperties", randomizer)
    else
      print(message)
      return 
    end

  end) ]]

  TriggerEvent("properties:loadProperties", randomizer)
end)

RegisterNetEvent('properties:RequestProperties')
AddEventHandler('properties:RequestProperties', function(resourceName)
  local src =  source
  TriggerClientEvent("properties:updateProperties", src, activeProperties)
end)


--[[ RegisterCommand("resetinterior", function(source)

  SetPlayerRoutingBucket(source, 0)
end, true)

RegisterCommand("getBucket", function(source)

  print(GetPlayerRoutingBucket(source))
end, true) ]]


RegisterNetEvent("esx_ambulancejob:setDeathStatus")
AddEventHandler("esx_ambulancejob:setDeathStatus", function(bool)

  local src = source
  if bool == false then
    SetPlayerRoutingBucket(src, 0)
    savePlayerInteriorStatus(src, 0, false)
    TriggerClientEvent("properties:leaveProperty2", src, "Death", false)
  end
end)

RegisterNetEvent("resetBucket")
AddEventHandler("resetBucket", function()
  local src  = source
  SetPlayerRoutingBucket(src, 0)
  TriggerClientEvent("properties:leaveProperty2", src, "Death", false)

end)
