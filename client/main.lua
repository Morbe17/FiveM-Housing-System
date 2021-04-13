clientActiveProperties = {}
tempMarkers = {}
playerInsideInterior = false
playerInteriorId = 0

local firstSpawn = 0

function returnError(text)
    print(text)
end

-- Creates new property command. Grabs the player coords and the interior type and ID and sends it to the server

RegisterCommand("createProperty", function(source, args, rawCommand)

    local price

    if not args[1] then
        returnError("Missing the property type.")
        return
    elseif not args[2] then
        returnError("Missing the interior ID.")
        return
    elseif args[1] ~= 1 and not args[3] then
        price = 0
    elseif args[1] == 1 and not args[3] then 
        returnError("Missing the interior ID.")
        return
    elseif args[3] then
        price = args[3]
    end
  
    local type = args[1]
    local interiorId = args[2]
    local location = GetEntityCoords(PlayerPedId())

    TriggerServerEvent("properties:CreateNewProperty", type, interiorId, location, price)
  
end, false)

TriggerEvent('chat:addSuggestion', '/createProperty', "Create a new property where you're standing!", {
    { name="Property Type", help="1 for houses/apartments, 2 for businesses, 3 for government buildings" },
    { name="Interior ID", help="ID of the interior for the property. Make sure it exist!" },
    { name="Property Price", help="The property price if left in blank, will be set to 0!" }
})
  
RegisterNetEvent("properties:updateProperties")
AddEventHandler("properties:updateProperties", function(properties)
    local tempTimer = Config.LoaderRefresher
    clientActiveProperties = {}
    --tempMarkers = {}
    clientActiveProperties = properties
    Config.LoaderRefresher = tempTimer
end)

RegisterNetEvent("properties:enterProperty2")
AddEventHandler("properties:enterProperty2", function(property)

    local ped = PlayerPedId()
    local id = tonumber(property.interiorId)

    RequestCollisionAtCoord(Interiors[id].x, Interiors[id].y, Interiors[id].z)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, Interiors[id].x, Interiors[id].y, Interiors[id].z, false, false, false, false)
    while not HasCollisionLoadedAroundEntity(ped) do
        Citizen.Wait(0)
    end
    FreezeEntityPosition(ped, false)
    playerInsideInterior = true
    playerInteriorId = property.id

end)

RegisterNetEvent("properties:setPlayerInsideInteriorForLeader")
AddEventHandler("properties:setPlayerInsideInteriorForLeader", function(propertyId)

    playerInsideInterior = true
    playerInteriorId = propertyId

end)

RegisterNetEvent("properties:leaveProperty2")
AddEventHandler("properties:leaveProperty2", function(property, fromInterior)

    if fromInterior == true then
        local ped = PlayerPedId()
        local id = tonumber(property.location)

        RequestCollisionAtCoord(property.location.x, property.location.y, property.location.z)
        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, property.location.x, property.location.y, property.location.z, false, false, false, false)
        while not HasCollisionLoadedAroundEntity(ped) do
            Citizen.Wait(0)
        end
        FreezeEntityPosition(ped, false)

        if property.previousInt == 0 then
            playerInsideInterior = false
            playerInteriorId = 0
        end
        playerInteriorId = property.previousInt
    elseif fromInterior == false then
            playerInsideInterior = false
            playerInteriorId = 0
    end

end)


RegisterNetEvent("playerSpawned")
AddEventHandler('playerSpawned', function(spawn)
    if firstSpawn == 0 then
        if Config.IsLastPositionEnabled then
            TriggerServerEvent('properties:checkIfInstanced')
            firstSpawn = 1
        end
    end
end)


RegisterCommand("setfee", function(source, args, rawCommand)

    if args[1] then
        local type = type(tonumber(args[1]))

        if type == "number" then
            TriggerServerEvent("properties:setFee", args[1])
        end
    else
    end
end)

RegisterCommand("sellto", function(source, args, rawCommand)

    if args[1] then
        local type = type(tonumber(args[1]))

        if type == "number" then
            TriggerServerEvent("properties:sellPropertyToPlayer", args[1])
        end
    else
    end
end)

TriggerEvent('chat:addSuggestion', '/sellto', 'Sell this current property to a person.', {
    { name="User ID", help="ID of the person you're selling to." }
})

RegisterCommand("sellproperty", function(source, args, rawCommand)

    local tbl = {}

    for k,v in pairs(GetActivePlayers()) do
        table.insert(tbl, GetPlayerServerId(v))
    end
    
    TriggerServerEvent('properties:sellProperty', tbl)

end)

TriggerEvent('chat:addSuggestion', '/sellproperty', 'You will receive 50% of the price you paid for it!', {
})


RegisterNetEvent("properties:updateProperty")
AddEventHandler("properties:updateProperty", function(property)
    local tempTimer = Config.LoaderRefresher

    if clientActiveProperties[property.id] then
        clientActiveProperties[property.id] = property
    end

    if tempMarkers[property.id] then
        tempMarkers[property.id] = property
    end
end)

RegisterNetEvent("onClientResourceStart")
AddEventHandler("onClientResourceStart", function(resource)

    TriggerServerEvent("properties:RequestProperties")
    
end)

--[[ RegisterCommand("getcoords", function()
    print(GetEntityCoords(PlayerPedId()))
end, false) ]]

RegisterCommand("unbuginterior", function()
    SetEntityCoords(PlayerPedId(), -78.45, -1152.902, 74, false, false, false ,false)
    TriggerServerEvent("resetBucket")
end, false)