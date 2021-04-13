function drawText3D(x, y, z, text, col, scale)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
        if onScreen then
        SetTextScale(scale,scale)--(0.3, 0.3)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(col[1],col[2],col[3],col[4])--(255, 255, 255, 140)
        SetTextDropshadow(0, 0, 0, 0, 0)
        --SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        end
end

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
        break
        end
    end
    return formatted
end

function SetDisplay(type, bool, prop)

    display = bool
    SetNuiFocus(bool, bool)
    local objectName = {
        type = type,
        status = bool,
        prop = prop
    }
    SendNUIMessage(objectName)
end

function loadInventory(playerInventory, propertyInventory, propertyId, storage)
    display = bool
    SetNuiFocus(bool, bool)
    local objectName = {
        type = "sendInventory",
        plInventory = playerInventory,
        prInventory = propertyInventory,
        propertyId = propertyId,
        storageValues = storage
    }
    SendNUIMessage(objectName)
end

function log(message)
    TriggerEvent("chatMessage",  "[Server]", {255,0,0}, message)
end

function setPedInsideInterior()
    RequestCollisionAtCoord(Interiors[id].Location.x, Interiors[id].Location.y, Interiors[id].Location.z)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, Interiors[id].Location.x, Interiors[id].Location.y, Interiors[id].Location.z, false, false, false, false)
    while not HasCollisionLoadedAroundEntity(ped) do
        Citizen.Wait(0)
    end
    FreezeEntityPosition(ped, false)
end