display = false

RegisterNUICallback("exit", function(data)
    SetDisplay("propertyName", false, false)
    SetDisplay("propertyInventory", false, false)
end)

RegisterNUICallback("depositItem", function(data)
    local amount = data.itemData.count
    TriggerServerEvent("properties:depositItem", data.itemData, tonumber(amount))
end)
RegisterNUICallback("withdrawItem", function(data)
  local amount = data.itemData.count
  TriggerServerEvent("properties:withdrawItem", data.itemData, tonumber(amount))
end)

RegisterNUICallback("sDepositItem", function(data)
    local amount = data.quantity

    TriggerServerEvent("properties:depositItem", data.isInventory, tonumber(amount))
end)

RegisterNUICallback("sDepositItemSplit", function(data)
    local amount = data.quantity

    if isAWeapon(data.isInventory.name) then
        returnError("You cannot split weapons!")
    end

    TriggerServerEvent("properties:depositItem", data.isInventory, tonumber(amount))
end)

RegisterNUICallback("sWithdrawItem", function(data)
  local amount = data.quantity

  TriggerServerEvent("properties:withdrawItem", data.isBank, tonumber(amount))
end)

RegisterNUICallback("grabPropertyName", function(data)
    
    TriggerServerEvent("properties:buyProperty", tonumber(data.property.id), data.name)

    SetDisplay("propertyName", false, nil)
end)

RegisterKeyMapping('+getInventory', 'Open House Inventory', 'keyboard', Config.HotKeys.StorageKey)

function isAWeapon(itemName)
    if string.len(itemName) >= 5 then
        local identificator = string.sub(itemName, 1, 6)
        if identificator == "WEAPON" then return true
        else return false
        end
    else return false
    end
end
