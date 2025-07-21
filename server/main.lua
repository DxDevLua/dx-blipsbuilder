local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('blipbuilder:getBlips')
AddEventHandler('blipbuilder:getBlips', function()
    local source = source
    MySQL.query('SELECT *, CAST(scale AS FLOAT) as scale FROM blips', {}, function(results)
        if results then
            for _, blip in ipairs(results) do
                blip.scale = tonumber(blip.scale) or 1.0
                if blip.scale == 0 then blip.scale = 1.0 end
            end
            TriggerClientEvent('blipbuilder:receiveBlips', source, results)
        else
            TriggerClientEvent('blipbuilder:receiveBlips', source, {})
        end
    end)
end)

RegisterServerEvent('blipbuilder:createBlip')
AddEventHandler('blipbuilder:createBlip', function(blipData)
    local source = source
    
    if not blipData then 
        TriggerClientEvent('esx:showNotification', source, '~r~Erreur: données invalides')
        return
    end

    local scale = tonumber(blipData.scale) or 1.0
    if scale == 0 then scale = 1.0 end
    
    MySQL.insert('INSERT INTO blips (name, sprite, color, scale, x, y, z, shortRange) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        blipData.name,
        blipData.sprite,
        blipData.color,
        scale,
        blipData.x,
        blipData.y,
        blipData.z,
        blipData.shortRange
    }, function(id)
        if id then
            TriggerClientEvent('esx:showNotification', source, 'Blip créé avec succès')
            MySQL.query('SELECT *, CAST(scale AS FLOAT) as scale FROM blips', {}, function(results)
                if results then
                    for _, blip in ipairs(results) do
                        blip.scale = tonumber(blip.scale) or 1.0
                        if blip.scale == 0 then blip.scale = 1.0 end
                    end
                    TriggerClientEvent('blipbuilder:receiveBlips', -1, results)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~Erreur lors de la création du blip')
        end
    end)
end)

RegisterServerEvent('blipbuilder:deleteBlip')
AddEventHandler('blipbuilder:deleteBlip', function(blipId)
    local source = source
    
    if not blipId then
        TriggerClientEvent('esx:showNotification', source, '~r~ID du blip invalide')
        return
    end

    MySQL.execute('DELETE FROM blips WHERE id = ?', {
        blipId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Blip supprimé avec succès')
            MySQL.query('SELECT *, CAST(scale AS FLOAT) as scale FROM blips', {}, function(results)
                if results then
                    for _, blip in ipairs(results) do
                        blip.scale = tonumber(blip.scale) or 1.0
                        if blip.scale == 0 then blip.scale = 1.0 end
                    end
                    TriggerClientEvent('blipbuilder:receiveBlips', -1, results)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~Erreur lors de la suppression du blip')
        end
    end)
end)

RegisterServerEvent('blipbuilder:updateBlip')
AddEventHandler('blipbuilder:updateBlip', function(blipData)
    local source = source
    
    local scale = tonumber(blipData.scale) or 1.0
    if scale == 0 then scale = 1.0 end
    
    MySQL.update('UPDATE blips SET name = ?, sprite = ?, color = ?, scale = ?, x = ?, y = ?, z = ?, shortRange = ? WHERE id = ?', {
        blipData.name,
        blipData.sprite,
        blipData.color,
        scale,
        blipData.x,
        blipData.y,
        blipData.z,
        blipData.shortRange,
        blipData.id
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Blip mis à jour avec succès')
            MySQL.query('SELECT *, CAST(scale AS FLOAT) as scale FROM blips', {}, function(results)
                if results then
                    for _, blip in ipairs(results) do
                        blip.scale = tonumber(blip.scale) or 1.0
                        if blip.scale == 0 then blip.scale = 1.0 end
                    end
                    TriggerClientEvent('blipbuilder:receiveBlips', -1, results)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~Erreur lors de la mise à jour du blip')
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
end) 