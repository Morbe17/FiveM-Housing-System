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
RegisterNUICallback("sWithdrawItem", function(data)
  local amount = data.quantity

  TriggerServerEvent("properties:withdrawItem", data.isBank, tonumber(amount))
end)

RegisterNUICallback("grabPropertyName", function(data)
    
    TriggerServerEvent("properties:buyProperty", tonumber(data.property.id), data.name)

    SetDisplay("propertyName", false, nil)
end)

RegisterKeyMapping('+getInventory', 'Open House Inventory', 'keyboard', 'F3')