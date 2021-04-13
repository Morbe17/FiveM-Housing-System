ESX = nil
local Tunnel
local Proxy


if Config.Framework == 1 then

elseif Config.Framework == 2 then

  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

elseif Config.Framework == 3 then

  Tunnel = module("vrp", "lib/Tunnel")
  Proxy = module("vrp", "lib/Proxy")
    
  vRP = Proxy.getInterface("vRP")

end



function displayError(source, text)

  if Config.Framework == 1 then -- Standalone

  elseif Config.Framework == 2 then -- ESX

    TriggerClientEvent('esx:showNotification', source, text)

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function displayMessage(source, text)

  if Config.Framework == 1 then -- Standalone

  elseif Config.Framework == 2 then -- ESX
    
    TriggerClientEvent('esx:showNotification', source, text)

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function propertiesRemovePlayerMoney(playerId, amount)

  if Config.Framework == 1 then -- Standalone
    
  elseif Config.Framework == 2 then -- ESX

    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeAccountMoney('bank', amount)
    return true

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function propertiesAddPlayerMoney(playerId, propertyId)

  local amountToGive = activeProperties[propertyId].salePrice * Config.SellPropertyPorcentage -- This is the amount to be given.

  if Config.Framework == 1 then -- Standalone
    
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addAccountMoney('bank', amountToGive)

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function propertiesGetPlayerJob(playerId)

  if Config.Framework == 1 then -- Standalone
    return
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer then
      while not xPlayer do
        Citizen.Wait(10)
        xPlayer = ESX.GetPlayerFromId(playerId)
      end
    end

    local job = xPlayer.getJob()
    return job.name

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function propertiesGetPlayerNameFromServerId(playerId)
  if Config.Framework == 1 then -- Standalone
    
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getName()

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR
end

function propertiesAddPlayerMoneyAmount(playerId, amount)

  if Config.Framework == 1 then -- Standalone
    
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addAccountMoney('bank', amount)

  elseif Config.Framework == 3 then

  end
  return false -- NO identifier was found? ERROR
end

function getPlayerIdentifier(source)
  if Config.Framework == 1 then -- Standalone
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
          return v
        end
    end

  elseif Config.Framework == 2 then -- ESX

    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    return identifier

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR
end

function getRandomizer()
  return randomizer
end

function getPropertyOwner(propertyId)
  if activeProperties[propertyId] then
    return activeProperties[propertyId].propertyOwner
  else 
    return false
  end
end

function getPropertyType(propertyId)
  if activeProperties[propertyId] then
    return activeProperties[propertyId].interiorType
  else 
    return false
  end
end


function getPlayerBankMoney(src)
  local playerId  = src

  if Config.Framework == 1 then -- Standalone
    return 1000000
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
      local bank = xPlayer.getAccount('bank')
      return bank.money
    else
      return false
    end

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR
end

function getPlayerMoney(source)
  if Config.Framework == 1 then -- Standalone
    return 1000000
  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = xPlayer.getMoney()

    return cash

  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR
end

function removePlayerMoney(source, amount)

  if Config.Framework == 1 then -- Standalone
    return true

  elseif Config.Framework == 2 then -- ESX
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeMoney(amount)


  elseif Config.Framework == 3 then

  end

  return false -- NO identifier was found? ERROR

end

function setPropertyFee(propertyId, fee)

  MySQL.Sync.execute("UPDATE properties SET fee=@fee WHERE id = @id", {["@fee"] = fee, ["@id"] = propertyId})  
  activeProperties[propertyId].fee = fee

  return true

end

function setPropertyForSale(propertyId)
  
  MySQL.Sync.execute("UPDATE properties SET propertyOwner=@propertyOwner, forSale=@forSale, name=@name WHERE id = @id", {["@propertyOwner"] = "", ["@id"] = propertyId, ["@forSale"] = true, ["@name"] = name})  
  
  activeProperties[propertyId].propertyOwner = ""
  activeProperties[propertyId].forSale = true
  return true

end

function setPropertyOwner(source, propertyId, name)
  local propertyOwner = getPlayerIdentifier(source)

  MySQL.Sync.execute("UPDATE properties SET propertyOwner=@propertyOwner, forSale=@forSale, name=@name WHERE id = @id", {["@propertyOwner"] = propertyOwner, ["@id"] = propertyId, ["@forSale"] = false, ["@name"] = name})  
  activeProperties[propertyId].propertyOwner = propertyOwner
  activeProperties[propertyId].forSale = false
  
  return true

end

function setPropertyName(propertyId, name)

  MySQL.Sync.execute("UPDATE properties SET name=@name WHERE id = @id", {["@name"] = name, ["@id"] = propertyId})  
  activeProperties[propertyId].name = name

  return true
end

function setPropertyMaxCapacity(propertyId, capacity)

  MySQL.Sync.execute("UPDATE properties SET capacity=@capacity WHERE id = @id", {["@capacity"] = capacity, ["@id"] = propertyId})  
  activeProperties[propertyId].capacity = capacity

  return true
end

function getPropertyMaxCapacity(propertyId)
    if activeProperties[propertyId] then
      return activeProperties[propertyId].capacity
    end
end

function savePlayerInteriorStatus(source, interiorId, bool)

  local id = getPlayerIdentifier(source)
  local exist = MySQL.Sync.fetchAll("SELECT identifier FROM propertiesuserstatus WHERE identifier = @identifier", {["@identifier"] = id})

  if next(exist) == nil then

    MySQL.Async.fetchAll("INSERT INTO propertiesuserstatus (identifier, insideinterior, interiorid) VALUES(@identifier, @insideinterior, @interiorid)",
    {["@identifier"] = id, ["@insideinterior"] = bool, ["@interiorid"] = interiorId}, function (result)

    end)
    
  else

      if bool == false then
        interiorId = 0
      end

    MySQL.Sync.execute("UPDATE propertiesuserstatus SET insideInterior=@insideInterior, interiorId=@interiorId WHERE identifier = @identifier", 
    {["@identifier"] = id, ["@interiorId"] = interiorId, ["@insideInterior"] = bool})  
    
  end
end

function isDbPlayerIstanced(source)

  local identifier = getPlayerIdentifier(source)
  local exist = MySQL.Sync.fetchAll("SELECT insideInterior, interiorId FROM propertiesuserstatus WHERE identifier = @identifier", {["@identifier"] = identifier})

  if next(exist) then
    if exist[1].insideInterior == true then
      local interiorId = exist[1].interiorId
      return true, interiorId
    else 
      return false, false
    end
  end
end

function togglePropertyLock(src, propertyId, bool)

  if activeProperties[propertyId] then
    if bool then

      activeProperties[propertyId].locked = bool
      MySQL.Async.execute("UPDATE properties SET locked=@locked WHERE id = @id", {["@id"] = propertyId, ["@locked"] = bool})  
      displayMessage(src, Lenguage[Config.Leng]['locked'])
      return true

    else

      activeProperties[propertyId].locked = bool
      MySQL.Async.execute("UPDATE properties SET locked=@locked WHERE id = @id", {["@id"] = propertyId, ["@locked"] = bool})  
      displayMessage(src, Lenguage[Config.Leng]['unlocked'])
      return true

    end
  end
end

function isPropertyLocked(propertyId)
  if activeProperties[propertyId] then
    if activeProperties[propertyId].locked then
      return true
    else 
      return false
    end
  end
end

function storeItem(propertyId, itemname, amount)

  if Config.Framework == 1 then

  elseif Config.Framework == 2 then

    local exist = MySQL.Sync.fetchAll("SELECT inventory FROM properties WHERE id = @propertyId", {["@propertyId"] = propertyId})
    local inventory = json.decode(exist[1].inventory)

    local value, index = hasItem1(inventory, itemname)


    if value then

      inventory[index].amount = inventory[index].amount + amount
      MySQL.Sync.execute("UPDATE properties SET inventory=@inventory WHERE id = @id", {["@id"] = propertyId, ["@inventory"] = json.encode(inventory)}) 
      return true
      
    else

      local item = {itemname = itemname, amount = amount}
      table.insert(inventory, item)
      MySQL.Sync.execute("UPDATE properties SET inventory=@inventory WHERE id = @id", {["@id"] = propertyId, ["@inventory"] = json.encode(inventory)}) 
      return true

    end

    return false

  elseif Config.Framework == 3 then

  end

  --MySQL.Async.execute("UPDATE properties SET locked=@locked WHERE id = @id", {["@id"] = propertyId, ["@locked"] = bool})  

end

function removeItem(propertyId, itemname, amount)

  if Config.Framework == 1 then

  elseif Config.Framework == 2 then

    local exist = MySQL.Sync.fetchAll("SELECT inventory FROM properties WHERE id = @propertyId", {["@propertyId"] = propertyId})
    local inventory = json.decode(exist[1].inventory)

    local value, index = hasItem1(inventory, itemname)

    if value then

      local amountToRest = inventory[index].amount - amount

      if amountToRest <= 0 then
        table.remove(inventory, index)
        MySQL.Sync.execute("UPDATE properties SET inventory=@inventory WHERE id = @id", {["@id"] = propertyId, ["@inventory"] = json.encode(inventory)}) 
        return true
      else
        inventory[index].amount = amountToRest
        MySQL.Sync.execute("UPDATE properties SET inventory=@inventory WHERE id = @id", {["@id"] = propertyId, ["@inventory"] = json.encode(inventory)}) 
        return true
      end
      
    else

      print("'^5[Resmurf Properties System]^0: Hacker detected, trying to take non-existing item from property id "..propertyId)
      return false
    end

    return false

  elseif Config.Framework == 3 then

  end

  --MySQL.Async.execute("UPDATE properties SET locked=@locked WHERE id = @id", {["@id"] = propertyId, ["@locked"] = bool})  

end

function doesPropertyHasItem(propertyId, itemname)

  local exist = MySQL.Sync.fetchAll("SELECT inventory FROM properties WHERE id = @propertyId", {["@propertyId"] = propertyId})
  local inventory = json.decode(exist[1].inventory)

  local value, amount = hasItem2(inventory, itemname)

  if value then
    return true, amount
  else
    return false, false
  end
end

function hasItem1(inventory, itemname)

  for k, v in pairs(inventory) do
    if v.itemname == itemname then
      return true, k
    end
  end
  return false, k
end

function hasItem2(inventory, itemname)

  for k, v in pairs(inventory) do
    if v.itemname == itemname then
      return true, v.amount
    end
  end
  return false, k
end

function round(number, decimals)
  local power = 10^decimals
  return math.floor(number * power) / power
end

function isPlayerAllowedToUseCommand(source)

  if IsPlayerAceAllowed(source, "command") then
    return true
  else
    return false
  end
end

function generateIdNotExist(range1, range2, table)
  local exist = true
  local theNumber

  local function generate(table)
      math.randomseed(GetGameTimer())
      local number = math.random(range1, range2)
      Citizen.Wait(1)
      for k, v in pairs(table) do
          if v.id then
              if v.id == number then
                  exist = true
              end
          end 
      end

      theNumber = number
      exist = false
  end

  while exist do
      Citizen.Wait(10)
      generate(table)
  end
  return theNumber
end