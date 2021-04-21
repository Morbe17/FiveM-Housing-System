ESX = nil 

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(200)
        TriggerEvent('esx:getSharedObject', function (obj) ESX = obj end)
    end
end)

RegisterKeyMapping('+getInventory', 'Open House Inventory', 'keyboard', Config.HotKeys.StorageKey)

RegisterCommand("+getInventory", function()
    if Config.EnableStorage then
        if playerInsideInterior then
            TriggerServerEvent("properties:requestServerInventories")
        end
    end
end)

RegisterCommand("-getInventory", function()
    if Config.EnableStorage then
        SetDisplay("propertyName", false, false)
        SetDisplay("propertyInventory", false, false)
    end
end)

RegisterNetEvent("properties:sendInventoryData")
AddEventHandler("properties:sendInventoryData", function(plInventory, prInventory, propertyId, storage)

    loadInventory(plInventory, prInventory, propertyId, storage)
    SetDisplay("propertyInventory", true, {false, false})

end)

RegisterNetEvent("properties:refresUi")
AddEventHandler("properties:refresUi", function(plInventory, prInventory, propertyId)

    TriggerServerEvent("properties:requestServerInventories")

end)
