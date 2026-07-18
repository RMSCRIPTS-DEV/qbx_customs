vehicle = 0
openedWithExports = false

local inMenu = false
local dragcam = require('client.dragcam')
local startDragCam = dragcam.startDragCam
local stopDragCam = dragcam.stopDragCam
local config = require 'config.client'
local ui = require('client.ui')

local function buildMainOptions()
    if GetVehicleBodyHealth(vehicle) < 1000.0 then
        return {{
            type = 'repair',
            icon = 'repair',
            label = locale('menus.main.repair'),
            price = ('%s%d'):format(config.currency, math.ceil(1000 - GetVehicleBodyHealth(vehicle))),
        }}
    end

    local options = {
        {
            type = 'nav',
            icon = 'performance',
            label = locale('menus.main.performance'),
            submenu = 'client.menus.performance',
        },
        {
            type = 'nav',
            icon = 'parts',
            label = locale('menus.main.parts'),
            submenu = 'client.menus.parts',
        },
        {
            type = 'nav',
            icon = 'colors',
            label = locale('menus.main.colors'),
            submenu = 'client.menus.colors',
        },
    }

    if DoesExtraExist(vehicle, 1) then
        options[#options + 1] = {
            type = 'nav',
            icon = 'extras',
            label = locale('menus.main.extras'),
            submenu = 'client.menus.extras',
        }
    end

    return options
end

local function buildMainView()
    return {
        id = 'main',
        title = locale('menus.main.title'),
        subtitle = 'Performance, cosmetics and extras',
        options = buildMainOptions(),
        rebuild = buildMainView,
    }
end

local function navSound()
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

local function closeMenu()
    if not ui.isOpen() then return end
    ui.restoreAll()
    ui.hide()
    inMenu = false
    stopDragCam()
    if not openedWithExports then
        lib.showTextUI(locale('textUI.tune'), {
            icon = 'fa-solid fa-car',
            position = 'left-center',
        })
    end
    TriggerServerEvent('qbx_customs:server:saveVehicleProps')
end

local function repair()
    local success = lib.callback.await('qbx_customs:server:repair', false, GetVehicleBodyHealth(vehicle))
    if success then
        exports.qbx_core:Notify(locale('notifications.success.repaired'), 'success')
        qbx.playAudio({
            audioName = 'PICK_UP',
            audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        })
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        local fuelLevel = GetVehicleFuelLevel(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleFuelLevel(vehicle, fuelLevel)
    else
        exports.qbx_core:Notify(locale('notifications.error.money'), 'error')
    end

    ui.replace(buildMainView())
end

local function openSubmenu(option)
    if not option?.submenu then return end

    ui.restoreAll()

    local builder = require(option.submenu)
    local view
    if option.submenuArgs then
        view = builder(table.unpack(option.submenuArgs))
    else
        view = builder()
    end

    if not view then
        ui.refresh(buildMainView())
        return
    end

    ui.show(view)
end

local function changeValue(delta)
    local option = ui.getOption()
    if not option or not option.values or #option.values < 1 or not option.set then
        return
    end

    local len = #option.values
    local current = option.selected or option.defaultIndex or 1
    local nextIndex = current + delta
    if nextIndex < 1 then nextIndex = len end
    if nextIndex > len then nextIndex = 1 end

    option.selected = nextIndex
    option.set(nextIndex)
    option.price = ui.priceForSelection(option, nextIndex)
    navSound()
    ui.updateSelectedItem()
end

local function confirmSelection()
    local option = ui.getOption()
    if not option then return end

    if option.type == 'nav' then
        navSound()
        openSubmenu(option)
        return
    end

    if option.type == 'repair' then
        repair()
        return
    end

    local selected = option.selected or option.defaultIndex or 1
    option.selected = selected

    for _, v in ipairs(ui.getOptions()) do
        if v.restore then v.restore() end
    end

    if option.onPurchaseSideEffects then
        option.onPurchaseSideEffects()
    end

    local duplicate, desc = option.set(selected)
    local success = InstallMod(duplicate, option.payType or 'cosmetic', {
        description = desc,
        icon = option.payType == 'colors' and 'fa-solid fa-spray-can' or nil,
    }, selected)

    if not success and option.restore then
        option.restore()
    end

    local view = ui.getView()
    if view?.rebuild then
        ui.refresh(view.rebuild())
    end
end

local function goBackOrClose()
    if ui.canGoBack() then
        navSound()
        ui.goBack()
        return
    end
    closeMenu()
end

--- Keyboard menu controls (same idea as ox_lib menus — no cursor)
local function startInputLoop()
    inMenu = true
    CreateThread(function()
        while inMenu do
            Wait(0)

            DisableControlAction(0, 71, true)  -- accel
            DisableControlAction(0, 72, true)  -- brake
            DisableControlAction(0, 75, true)  -- exit vehicle
            DisableControlAction(0, 106, true) -- vehicle mouse
            DisableControlAction(0, 200, true) -- pause
            DisablePlayerFiring(cache.playerId, true)

            -- Movement / menu keys
            for _, control in ipairs({ 32, 33, 34, 35, 172, 173, 174, 175, 201, 202, 177, 194 }) do
                DisableControlAction(0, control, true)
            end
            for i = 81, 85 do
                DisableControlAction(0, i, true)
            end

            if not ui.isOpen() then goto continue end

            -- W / Up
            if IsDisabledControlJustPressed(0, 32) or IsDisabledControlJustPressed(0, 172) then
                navSound()
                ui.moveSelection(-1)

            -- S / Down
            elseif IsDisabledControlJustPressed(0, 33) or IsDisabledControlJustPressed(0, 173) then
                navSound()
                ui.moveSelection(1)

            -- A / Left
            elseif IsDisabledControlJustPressed(0, 34) or IsDisabledControlJustPressed(0, 174) then
                changeValue(-1)

            -- D / Right
            elseif IsDisabledControlJustPressed(0, 35) or IsDisabledControlJustPressed(0, 175) then
                changeValue(1)

            -- Enter
            elseif IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(0, 191) then
                confirmSelection()

            -- Backspace / Esc
            elseif IsDisabledControlJustPressed(0, 202)
                or IsDisabledControlJustPressed(0, 177)
                or IsDisabledControlJustPressed(0, 194)
                or IsDisabledControlJustPressed(0, 200)
            then
                goBackOrClose()
            end

            ::continue::
        end
    end)
end

local function openCustoms()
    if not cache.vehicle or inMenu then return false end

    vehicle = cache.vehicle
    SetVehicleModKit(vehicle, 0)
    startInputLoop()
    startDragCam(vehicle)
    ui.show(buildMainView())
    return true
end

lib.callback.register('qbx_customs:client:vehicleProps', function()
    return lib.getVehicleProperties(vehicle)
end)

exports('OpenMenu', function()
    openedWithExports = true
    return openCustoms()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if ui.isOpen() then
        ui.hide()
        inMenu = false
        stopDragCam()
    end
end)

return function()
    openedWithExports = false
    openCustoms()
end
