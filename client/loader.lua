local loadMarkers = false
local markerIcon = {}
local markerColor = {}
local realEstateAgent = false

Citizen.CreateThread(function()
    while true do

        local ped = PlayerPedId()

        for k, v in pairs(clientActiveProperties) do
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), v.location.x, v.location.y, v.location.z, true)

            if distance <= Config.LoaderMinDistanceToLoad then
                loadMarkers = true
                tempMarkers[v.id] = v
            else
                if tempMarkers[v.id] then
                    tempMarkers[v.id] = nil
                end
                if markerIcon[v.id] then
                    markerIcon[v.id] = nil
                end
                if markerColor[v.id] then
                    markerColor[v.id] = nil
                end
            end
        end

        Citizen.Wait(Config.LoaderRefresher)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5) 
        local ped = PlayerPedId()
        if not playerInsideInterior then
            if loadMarkers then
                for k, v in pairs(tempMarkers) do
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), v.location.x, v.location.y, v.location.z, true)

                    if v.forSale then
                        if v.interiorType == 1 then
                            DrawMarker(29, v.location.x, v.location.y, v.location.z, 0.0, 180, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                        else
                            DrawMarker(29, v.location.x, v.location.y, v.location.z, 0.0, 180, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, nil, nil, false)
                        end

                        if distance < Config.ShowPropertyDetailsDistance then
                            local interiorType = "Loading ..."
                            if v.interiorType == 1 then
                                interiorType = "House/Apartment"
                            elseif v.interiorType == 2 then
                                interiorType = "Business"
                            elseif v.interiorType == 3 then
                                interiorType = "Government"
                            end

                            if not Config.RealStateScript then
                                drawText3D(v.location.x, v.location.y, v.location.z+0.65, "["..v.id.."] "..Lenguage[Config.Leng]['intType'].." "..interiorType.."\nSale Price: $"..comma_value(v.salePrice).."\n"..Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact2'], {255, 255, 255, 255}, 0.25)
                            else
                                if realEstateAgent then
                                    drawText3D(v.location.x, v.location.y, v.location.z+0.65, "["..v.id.."] "..Lenguage[Config.Leng]['intType'].." "..interiorType.."\nSale Price: $"..comma_value(v.salePrice).."\n"..Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact4'], {255, 255, 255, 255}, 0.25)
                                else
                                    drawText3D(v.location.x, v.location.y, v.location.z+0.65, "["..v.id.."] "..Lenguage[Config.Leng]['intType'].." "..interiorType.."\nSale Price: $"..comma_value(v.salePrice).."\n", {255, 255, 255, 255}, 0.25)
                                end
                            end
                        end
                    else
                        if distance < Config.ShowPropertyDetailsDistance then
                            if v.fee > 0 then
                                drawText3D(v.location.x, v.location.y, v.location.z+0.78, "["..v.id.."] "..v.name.."\n"..Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact'].."\n"..Lenguage[Config.Leng]['fee'].."$"..comma_value(v.fee), {255, 255, 255, 255}, 0.25)
                            else
                                drawText3D(v.location.x, v.location.y, v.location.z+0.78, "["..v.id.."] "..v.name.."\n"..Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact'], {255, 255, 255, 255}, 0.25)
                            end
                        end
                        --DrawMarker(Config.EnterMarkerId, v.location.x, v.location.y, v.location.z, 0.0, 0.0, 0.0, 0.0, 180.00, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 155, false, true, 2, false, nil, nil, false)
                        DrawMarker(Config.EnterMarkerId, v.location.x, v.location.y,v.location.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 155, false, true, 2, true, nil, nil, false)
                    end

                    if distance < 0.8 then
                        if IsControlJustReleased(0, Keys[Config.HotKeys.ActionKey]) then
                            if v.forSale then
                                if not Config.RealStateScript then
                                    SetDisplay("propertyName", true, v)
                                else
                                    TriggerServerEvent("checkBeforeOpeningRequestWindow", v)
                                end
                            else 
                                if not IsPedInAnyVehicle(ped) then
                                    TriggerServerEvent("properties:enterProperty", v.id)
                                end
                            end
                        end

                        if IsControlJustReleased(0, Keys[Config.HotKeys.LockKey]) then
                            TriggerServerEvent("properties:toggleLock", v.id)
                        end
                    end
                end
            end
        else
            local localInteriorId = clientActiveProperties[playerInteriorId].interiorId
            local intLocation = Interiors[localInteriorId]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), intLocation.x, intLocation.y, intLocation.z, true)

            if distance < Config.ShowPropertyDetailsDistance then
                DrawMarker(22, intLocation.x, intLocation.y, intLocation.z, 0.0, 180, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 155, false, true, 2, nil, nil, false)
                drawText3D(intLocation.x, intLocation.y, intLocation.z+0.65, Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact3'], {255, 255, 255, 255}, 0.25)
                if IsControlJustReleased(0, Keys[Config.HotKeys.ActionKey]) then
                    TriggerServerEvent("properties:leaveProperty")
                end

                if IsControlJustReleased(0, Keys[Config.HotKeys.LockKey]) then
                    TriggerServerEvent("properties:toggleLock", playerInteriorId)
                end
            end

            local ped = PlayerPedId()
            if loadMarkers then
                for k, v in pairs(tempMarkers) do
                    if playerInteriorId == v.previousInt then
                        local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), v.location.x, v.location.y, v.location.z, true)

                        if v.forSale then
                            if v.interiorType == 1 then
                                DrawMarker(29, v.location.x, v.location.y, v.location.z, 0.0, 180, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                            else
                                DrawMarker(29, v.location.x, v.location.y, v.location.z, 0.0, 180, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, nil, nil, false)
                            end

                            if distance < Config.ShowPropertyDetailsDistance then
                                local interiorType = "Loading ..."
                                if v.interiorType == 1 then
                                    interiorType = "House/Apartment"
                                elseif v.interiorType == 2 then
                                    interiorType = "Business"
                                elseif v.interiorType == 3 then
                                    interiorType = "Government"
                                end
                                drawText3D(v.location.x, v.location.y, v.location.z+0.65, "["..v.id.."] "..Lenguage[Config.Leng]['intType'].." "..interiorType, {255, 255, 255, 255}, 0.25)
                                drawText3D(v.location.x, v.location.y, v.location.z+0.55, "Sale Price: $"..comma_value(v.salePrice), {255, 255, 255, 255}, 0.25)

                                if not Config.RealStateScript then
                                    drawText3D(v.location.x, v.location.y, v.location.z+0.45, Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact2'], {255, 255, 255, 255}, 0.22)
                                else
                                    if realEstateAgent then
                                        drawText3D(v.location.x, v.location.y, v.location.z+0.45, Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact4'], {255, 255, 255, 255}, 0.22)
                                    else
                                        drawText3D(v.location.x, v.location.y, v.location.z+0.65, "["..v.id.."] "..Lenguage[Config.Leng]['intType'].." "..interiorType.."\nSale Price: $"..comma_value(v.salePrice).."\n", {255, 255, 255, 255}, 0.25)
                                    end
                                end
                            end
                        else
                            if distance < Config.ShowPropertyDetailsDistance then
                                drawText3D(v.location.x, v.location.y, v.location.z+0.73, "["..v.id.."] "..v.name, {255, 255, 255, 255}, 0.25)
                                drawText3D(v.location.x, v.location.y, v.location.z+0.65, Lenguage[Config.Leng]['press'].." ["..Config.HotKeys.ActionKey.."] "..Lenguage[Config.Leng]['interact'], {255, 255, 255, 255}, 0.25)
                                if v.fee > 0 then
                                    drawText3D(v.location.x, v.location.y, v.location.z+0.58, Lenguage[Config.Leng]['fee'].."$"..comma_value(v.fee), {255, 255, 255, 255}, 0.25)
                                end
                            end
                            DrawMarker(Config.EnterMarkerId, v.location.x, v.location.y, v.location.z, 0.0, 0.0, 0.0, 0.0, 0.0, 180, 1.0, 1.0, 1.0, 255, 255, 255, 155, false, true, 2, true, nil, nil, false)
                        end

                        if distance < 0.8 then
                            if IsControlJustReleased(0, Keys[Config.HotKeys.ActionKey]) then
                                if v.forSale then
                                    --TriggerServerEvent("properties:buyProperty", v.id)
                                    if not Config.RealStateScript then
                                        SetDisplay("propertyName", true, v)
                                    else
                                        TriggerServerEvent("checkBeforeOpeningRequestWindow", v)
                                    end
                                else 
                                    TriggerServerEvent("properties:enterProperty", v.id)
                                end
                            end

                            if IsControlJustReleased(0, Keys[Config.HotKeys.LockKey]) then
                                TriggerServerEvent("properties:toggleLock", v.id)
                            end
                        end
                    end
                end
            end
        end
    end
end)


RegisterNetEvent("updatePlayerJob")
AddEventHandler("updatePlayerJob", function(bool)
    realEstateAgent = bool
end)   