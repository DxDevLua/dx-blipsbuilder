local ESX = exports["es_extended"]:getSharedObject()
local blips = {}

local mainMenu = RageUI.CreateMenu("Blip Builder", "Menu Principal")
local blipListMenu = RageUI.CreateSubMenu(mainMenu, "Liste des Blips", "Blips existants")
local createBlipMenu = RageUI.CreateSubMenu(mainMenu, "Créer un Blip", "Nouveau blip")
local editBlipMenu = RageUI.CreateSubMenu(blipListMenu, "Modifier le Blip", "Options")
local selectedBlip = nil

local newBlip = {
    name = "",
    sprite = nil,
    color = nil,
    scale = nil,
    x = 0,
    y = 0,
    z = 0,
    useCurrentPos = true
}

local editingBlip = {
    name = "",
    sprite = nil,
    color = nil,
    scale = nil,
    x = 0,
    y = 0,
    z = 0,
    id = nil,
    useCurrentPos = true
}

local function refreshBlips()
    for _, blipData in pairs(blips) do
        if blipData.handle and DoesBlipExist(blipData.handle) then
            RemoveBlip(blipData.handle)
        end
    end
    
    blips = {}
    TriggerServerEvent('blipbuilder:getBlips')
end

local function createBlipOnMap(data)
    local blip = AddBlipForCoord(data.x, data.y, data.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.color)
    local scale = tonumber(data.scale) or 1.0
    if scale == 0 then scale = 1.0 end
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, data.shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    return blip
end

RegisterNetEvent('blipbuilder:receiveBlips')
AddEventHandler('blipbuilder:receiveBlips', function(serverBlips)
    for _, blipData in pairs(blips) do
        if blipData.handle and DoesBlipExist(blipData.handle) then
            RemoveBlip(blipData.handle)
        end
    end
    
    blips = {}
    
    for _, blipData in ipairs(serverBlips) do
        local blipHandle = createBlipOnMap(blipData)
        table.insert(blips, {
            handle = blipHandle,
            data = blipData
        })
    end
end)

local function hasAccess()
    local xPlayer = ESX.PlayerData
    for _, rank in ipairs(Config.AuthorizedRanks) do
        if xPlayer.group == rank then
            return true
        end
    end
    return false
end

local function ShowNotification(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end

RegisterCommand('blipbuilder', function()
    if hasAccess() then
        RageUI.Visible(mainMenu, true)
        refreshBlips()
    else
        ShowNotification(Config.NoAccessMessage)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        RageUI.IsVisible(mainMenu, function()
            RageUI.Button("Créer un blip", "Ajouter un nouveau blip", {}, true, {}, createBlipMenu)
            RageUI.Button("Liste des blips", "Gérer les blips existants", {}, true, {}, blipListMenu)
        end)

        RageUI.IsVisible(createBlipMenu, function()
            RageUI.Separator("↓ Position ↓")

            RageUI.Checkbox("Utiliser position actuelle", "Cocher pour utiliser votre position actuelle", newBlip.useCurrentPos, {}, {
                onChecked = function()
                    newBlip.useCurrentPos = true
                end,
                onUnChecked = function()
                    newBlip.useCurrentPos = false
                    local pos = GetEntityCoords(PlayerPedId())
                    newBlip.x = pos.x
                    newBlip.y = pos.y
                    newBlip.z = pos.z
                end
            })

            if not newBlip.useCurrentPos then
                RageUI.Button("Position X : " .. string.format("%.2f", newBlip.x), "Définir la coordonnée X", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée X", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                newBlip.x = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })

                RageUI.Button("Position Y : " .. string.format("%.2f", newBlip.y), "Définir la coordonnée Y", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée Y", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                newBlip.y = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })

                RageUI.Button("Position Z : " .. string.format("%.2f", newBlip.z), "Définir la coordonnée Z", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée Z", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                newBlip.z = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })
            end

            RageUI.Separator("↓ Apparence ↓")

            RageUI.Button("Nom : " .. newBlip.name, "Définir le nom du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("Nom du blip", "", 30)
                    if input then
                        newBlip.name = input
                    end
                end
            })

            RageUI.Button("Sprite ID : " .. (newBlip.sprite or ""), "Définir l'icône du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("ID du sprite (1-826)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 1 and num <= 826 then
                            newBlip.sprite = num
                        else
                            ShowNotification("~r~ID de sprite invalide (1-826)")
                        end
                    end
                end
            })

            RageUI.Button("Couleur ID : " .. (newBlip.color or ""), "Définir la couleur du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("ID de la couleur (1-85)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 1 and num <= 85 then
                            newBlip.color = num
                        else
                            ShowNotification("~r~ID de couleur invalide (1-85)")
                        end
                    end
                end
            })

            RageUI.Button("Taille : " .. (newBlip.scale or ""), "Définir la taille du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("Taille (0.1-3.0)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 0.1 and num <= 3.0 then
                            if num == 1.0 then
                                ShowNotification("~r~Veuillez utiliser 0.9 ou 1.1 au lieu de 1.0")
                                return
                            end
                            newBlip.scale = num + 0.0
                        else
                            ShowNotification("~r~Taille invalide (0.1-3.0)")
                        end
                    end
                end
            })

            RageUI.Separator("↓ Action ↓")

            RageUI.Button("~g~Créer le blip", "Créer le blip à la position définie", {}, true, {
                onSelected = function()
                    if newBlip.name == "" then
                        ShowNotification("~r~Veuillez définir un nom pour le blip")
                        return
                    end

                    if not newBlip.sprite then
                        ShowNotification("~r~Veuillez définir un sprite")
                        return
                    end

                    if not newBlip.color then
                        ShowNotification("~r~Veuillez définir une couleur")
                        return
                    end

                    if not newBlip.scale then
                        ShowNotification("~r~Veuillez définir une taille")
                        return
                    end

                    local pos
                    if newBlip.useCurrentPos then
                        pos = GetEntityCoords(PlayerPedId())
                    else
                        pos = vector3(newBlip.x, newBlip.y, newBlip.z)
                    end

                    local blipData = {
                        name = newBlip.name,
                        sprite = newBlip.sprite,
                        color = newBlip.color,
                        scale = newBlip.scale,
                        x = pos.x,
                        y = pos.y,
                        z = pos.z,
                        shortRange = true
                    }
                    
                    TriggerServerEvent('blipbuilder:createBlip', blipData)
                    Wait(200)
                    refreshBlips()

                    newBlip.name = ""
                    newBlip.sprite = nil
                    newBlip.color = nil
                    newBlip.scale = nil
                end
            })
        end)

        RageUI.IsVisible(blipListMenu, function()
            for i, blip in ipairs(blips) do
                RageUI.Button(blip.data.name, "Position: "..math.floor(blip.data.x)..", "..math.floor(blip.data.y), {}, true, {
                    onSelected = function()
                        selectedBlip = blip.data
                        editingBlip.name = selectedBlip.name
                        editingBlip.sprite = selectedBlip.sprite
                        editingBlip.color = selectedBlip.color
                        editingBlip.scale = selectedBlip.scale
                        editingBlip.x = selectedBlip.x
                        editingBlip.y = selectedBlip.y
                        editingBlip.z = selectedBlip.z
                        editingBlip.id = selectedBlip.id
                        editingBlip.useCurrentPos = false
                    end
                }, editBlipMenu)
            end
        end)

        RageUI.IsVisible(editBlipMenu, function()
            RageUI.Separator("↓ Position ↓")

            RageUI.Checkbox("Utiliser position actuelle", "Cocher pour utiliser votre position actuelle", editingBlip.useCurrentPos, {}, {
                onChecked = function()
                    editingBlip.useCurrentPos = true
                end,
                onUnChecked = function()
                    editingBlip.useCurrentPos = false
                end
            })

            if not editingBlip.useCurrentPos then
                RageUI.Button("Position X : " .. string.format("%.2f", editingBlip.x), "Définir la coordonnée X", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée X", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                editingBlip.x = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })

                RageUI.Button("Position Y : " .. string.format("%.2f", editingBlip.y), "Définir la coordonnée Y", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée Y", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                editingBlip.y = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })

                RageUI.Button("Position Z : " .. string.format("%.2f", editingBlip.z), "Définir la coordonnée Z", {}, true, {
                    onSelected = function()
                        local input = KeyboardInput("Coordonnée Z", "", 20)
                        if input then
                            local num = tonumber(input)
                            if num then
                                editingBlip.z = num
                            else
                                ShowNotification("~r~Valeur invalide")
                            end
                        end
                    end
                })
            end

            RageUI.Separator("↓ Apparence ↓")

            RageUI.Button("Nom : " .. editingBlip.name, "Définir le nom du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("Nom du blip", "", 30)
                    if input then
                        editingBlip.name = input
                    end
                end
            })

            RageUI.Button("Sprite ID : " .. (editingBlip.sprite or ""), "Définir l'icône du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("ID du sprite (1-826)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 1 and num <= 826 then
                            editingBlip.sprite = num
                        else
                            ShowNotification("~r~ID de sprite invalide (1-826)")
                        end
                    end
                end
            })

            RageUI.Button("Couleur ID : " .. (editingBlip.color or ""), "Définir la couleur du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("ID de la couleur (1-85)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 1 and num <= 85 then
                            editingBlip.color = num
                        else
                            ShowNotification("~r~ID de couleur invalide (1-85)")
                        end
                    end
                end
            })

            RageUI.Button("Taille : " .. (editingBlip.scale or ""), "Définir la taille du blip", {}, true, {
                onSelected = function()
                    local input = KeyboardInput("Taille (0.1-3.0)", "", 10)
                    if input then
                        local num = tonumber(input)
                        if num and num >= 0.1 and num <= 3.0 then
                            if num == 1.0 then
                                ShowNotification("~r~Veuillez utiliser 0.9 ou 1.1 au lieu de 1.0")
                                return
                            end
                            editingBlip.scale = num + 0.0
                        else
                            ShowNotification("~r~Taille invalide (0.1-3.0)")
                        end
                    end
                end
            })

            RageUI.Separator("↓ Actions ↓")

            RageUI.Button("~g~Sauvegarder les modifications", "Appliquer les changements", {}, true, {
                onSelected = function()
                    if editingBlip.name == "" then
                        ShowNotification("~r~Veuillez définir un nom pour le blip")
                        return
                    end

                    if not editingBlip.sprite then
                        ShowNotification("~r~Veuillez définir un sprite")
                        return
                    end

                    if not editingBlip.color then
                        ShowNotification("~r~Veuillez définir une couleur")
                        return
                    end

                    if not editingBlip.scale then
                        ShowNotification("~r~Veuillez définir une taille")
                        return
                    end

                    local pos
                    if editingBlip.useCurrentPos then
                        pos = GetEntityCoords(PlayerPedId())
                    else
                        pos = vector3(editingBlip.x, editingBlip.y, editingBlip.z)
                    end

                    local blipData = {
                        id = editingBlip.id,
                        name = editingBlip.name,
                        sprite = editingBlip.sprite,
                        color = editingBlip.color,
                        scale = editingBlip.scale,
                        x = pos.x,
                        y = pos.y,
                        z = pos.z,
                        shortRange = true
                    }
                    
                    TriggerServerEvent('blipbuilder:updateBlip', blipData)
                    Wait(200)
                    refreshBlips()
                    RageUI.GoBack()
                end
            })

            RageUI.Button("Se téléporter", "Se téléporter au blip", {}, true, {
                onSelected = function()
                    SetEntityCoords(PlayerPedId(), editingBlip.x, editingBlip.y, editingBlip.z)
                end
            })

            RageUI.Button("~r~Supprimer", "Supprimer ce blip", {}, true, {
                onSelected = function()
                    if editingBlip.id then
                        TriggerServerEvent('blipbuilder:deleteBlip', editingBlip.id)
                        Wait(200)
                        refreshBlips()
                        RageUI.GoBack()
                    end
                end
            })
        end)
    end
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        return result
    else
        Wait(500)
        return nil
    end
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    refreshBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    refreshBlips()
end)

AddEventHandler('playerSpawned', function()
    refreshBlips()
end) 