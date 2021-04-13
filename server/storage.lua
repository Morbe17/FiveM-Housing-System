activeAction = false
plInvenotry = {}
prInventory = {}

RegisterNetEvent("properties:requestServerInventories")
AddEventHandler("properties:requestServerInventories", function()
    local src = source
    local counter = 0
    local otherCounter = 0

    local xPlayer = ESX.GetPlayerFromId(src)
    local inventory = xPlayer.getInventory()
    local weapons = xPlayer.getLoadout()
    local propertyId = GetPlayerRoutingBucket(src)
    plInventory = {}
    prInventory[propertyId] = {}
    local propertyOwner = getPropertyOwner(propertyId)  

    if Config.Framework == 1 then -- Custom FW
 
    elseif Config.Framework == 2 then -- ESX
        if propertyOwner == xPlayer.getIdentifier() and propertyId > 0 then

            -- Get Player Inventory
            for k, v in pairs(inventory) do
                if inventory[k].canRemove then
                    if v.count >= 1 then
                        counter = counter + 1
                        plInventory[counter] = {}
                        plInventory[counter].id = generateIdNotExist(1, 10000, plInventory)
                        plInventory[counter].name = v.name
                        plInventory[counter].label = v.label
                        plInventory[counter].count = v.count
                    end
                end
            end

            for k, v in ipairs(weapons) do
                counter = counter + 1
                plInventory[counter] = {}
                plInventory[counter].id = generateIdNotExist(1, 10000, plInventory)
                plInventory[counter].name = v.name
                plInventory[counter].label = v.label
                plInventory[counter].count = v.ammo
            end
            
            -- Get House inventory
            local result = MySQL.Sync.fetchAll("SELECT inventory FROM properties WHERE id = @id", {["@id"] = tonumber(propertyId)})
            local tempInv = json.decode(result[1].inventory)

            if next(tempInv) then
                for k, v in pairs(tempInv) do
                    if not isAWeapon(v.itemname) then
                        prInventory[propertyId][k] = {}
                        prInventory[propertyId][k].id = generateIdNotExist(1, 10000, plInventory)
                        prInventory[propertyId][k].name = v.itemname
                        prInventory[propertyId][k].label = ESX.GetItemLabel(v.itemname)
                        prInventory[propertyId][k].count = v.amount
                    else
                        prInventory[propertyId][k] = {}
                        prInventory[propertyId][k].id = generateIdNotExist(1, 10000, plInventory)
                        prInventory[propertyId][k].name = v.itemname
                        prInventory[propertyId][k].label = ESX.GetWeaponLabel(v.itemname)
                        prInventory[propertyId][k].count = v.amount
                    end
                end
            else
                prInventory = json.decode(result[1].inventory)
            end

            local storage = {
                propertyMaxCapacity = activeProperties[propertyId].capacity,
                actualCapacity = storageItemCount(propertyId)
            }
            --Send player and property inventory to the client.
            TriggerClientEvent("properties:sendInventoryData", src, plInventory, prInventory[propertyId], propertyId, storage)

        elseif propertyId <= 0 then
            print("'^5[Resmurf Properties System]:^0 Ban player id "..src.." He's attempting to open a house inventory being outside of one!")
        else
            --print("you're not the owner")
        end
    elseif Config.Framework == 3 then -- VRP

    end        
end)

RegisterNetEvent("properties:depositItem")
AddEventHandler("properties:depositItem", function(data, amount)

    if not activeAction then
        activeAction = true
        local item = data

        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local propertyId = GetPlayerRoutingBucket(src)
        local propertyOwner = getPropertyOwner(propertyId)
        local identifier = getPlayerIdentifier(src)

        local isAWeapon = isAWeapon(item.name)

        local propertyMaxCapacity = activeProperties[propertyId].capacity
        local actualCapacity = storageItemCount(propertyId)

        if not isAWeapon then 
            local itm = xPlayer.getInventoryItem(item.name)
            local playerItemAmount = itm.count

            if playerItemAmount >= amount then
                if propertyMaxCapacity > actualCapacity then
                    if propertyOwner == identifier and propertyId > 0 then
                        local stored = storeItem(propertyId, item.name, amount)

                        if stored then
                            xPlayer.removeInventoryItem(item.name, amount)
                            TriggerClientEvent("properties:refresUi", src)
                        end
                    else
                        displayError(src, "You're not the property owner, or are outside a property - Ban coming soon.")
                    end
                else
                    displayError(src, "You have reached the limit")
                end
            else 
                displayError(src, "Player doesn't have enough items")
            end
        else
            local loadoutNum, hasWeapon = xPlayer.getWeapon('WEAPON_PISTOL')
            local weaponAmmo = xPlayer.loadout[loadoutNum].ammo
            if hasWeapon then
                if weaponAmmo >= amount then
                    if propertyMaxCapacity > actualCapacity then
                        if propertyOwner == identifier and propertyId > 0 then
                            local stored = storeItem(propertyId, item.name, amount)

                            if stored then
                                if weaponAmmo == amount then
                                    xPlayer.removeWeapon(item.name)
                                else
                                    xPlayer.removeWeaponAmmo(item.name, amount)
                                end

                                TriggerClientEvent("properties:refresUi", src)
                            end
                        else
                            displayError(src, "You're not the property owner, or are outside a property - Ban coming soon.")
                        end
                    else
                        displayError(src, "You have reached the limit")
                    end
                else
                    displayError(src, "Player doesn't have enough items")
                end
            end

        end
        activeAction = false
    end
end)

RegisterNetEvent("properties:withdrawItem")
AddEventHandler("properties:withdrawItem", function(data, amount)
    if not activeAction then
        activeAction = true

        local item = data

        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local propertyId = GetPlayerRoutingBucket(src)
        local propertyOwner = getPropertyOwner(propertyId)
        local identifier = getPlayerIdentifier(src)

        local isAWeapon = isAWeapon(item.name)

        local hasItem, prAmount = doesPropertyHasItem(propertyId, item.name)

        if hasItem and prAmount >= amount then
            if propertyOwner == identifier and propertyId > 0 then
                if not isAWeapon then
                    local stored = removeItem(propertyId, item.name, amount)

                    if stored then
                        xPlayer.addInventoryItem(item.name, amount)
                        TriggerClientEvent("properties:refresUi", src)
                    end 
                else
                    local stored = removeItem(propertyId, item.name, amount)
                    local loadoutNum, hasWeapon = xPlayer.getWeapon(item.name)

                    if stored then
                        if hasWeapon then
                            xPlayer.addWeaponAmmo(item.name, amount)
                        else
                            xPlayer.addWeapon(item.name, amount)
                        end
                        TriggerClientEvent("properties:refresUi", src)
                    end 
                end
            else
                displayError(src, "You're not the property owner, or are outside a property - Ban coming soon.")
            end
        else
            displayError(src, "You don't have such items, ban coming soon.")
        end
        activeAction = false
    end
end)


function storageItemCount(propertyId)
    local count = 0

    if activeProperties[propertyId] then
        if prInventory[propertyId] then
            for k,v in pairs(prInventory[propertyId]) do
                if not Config.WeaponAmmoCountTowardsStorageLimit then
                    if isAWeapon(v.name) then
                        count = count + 1
                    else
                        count  = count + v.count
                    end
                else
                    count  = count + v.count
                end
            end
            return count
        else
            return count
        end
    else
        --print("Property doesn't exist or it's not loaded properly.")
    end
end

function isAWeapon(itemName)
    if string.len(itemName) >= 5 then
        local identificator = string.sub(itemName, 1, 6)
        if identificator == "WEAPON" then return true
        else return false
        end
    else return false
    end
end