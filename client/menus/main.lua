vehicle = 0
openedWithExports = false

local inMenu = false
local dragcam = require('client.dragcam')
local startDragCam = dragcam.startDragCam
local stopDragCam = dragcam.stopDragCam
local config = require 'config.client'
local ui = require('client.ui')
local pending = require('client.pending')

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

    if pending.hasEntries() then
        options[#options + 1] = {
            type = 'checkout',
            icon = 'checkout',
            label = locale('menus.main.payUpgrades'),
            price = pending.totalLabel(),
            meta = locale('menus.main.payUpgradesMeta', pending.count()),
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

local function buildCheckoutView()
    return {
        id = 'checkout',
        title = locale('menus.checkout.title'),
        subtitle = locale('menus.checkout.subtitle', pending.totalLabel()),
        options = {
            {
                type = 'pay',
                icon = 'cash',
                label = locale('menus.checkout.cash'),
                price = pending.totalLabel(),
                moneyType = 'cash',
            },
            {
                type = 'pay',
                icon = 'card',
                label = locale('menus.checkout.card'),
                price = pending.totalLabel(),
                moneyType = 'bank',
            },
        },
        rebuild = buildCheckoutView,
    }
end

local function navSound()
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

local function upgradeSound()
    PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', true)
end

local function closeMenu()
    if not ui.isOpen() then return end

    -- Discard unpaid previews so free upgrades cannot stick
    pending.restoreBaseline()
    pending.clear()

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
        pending.start()
    else
        exports.qbx_core:Notify(locale('notifications.error.money'), 'error')
    end

    ui.replace(buildMainView())
end

local function openSubmenu(option)
    if not option?.submenu then return end

    pending.restoreBaseline()

    local builder = require(option.submenu)
    local view
    if option.submenuArgs then
        view = builder(table.unpack(option.submenuArgs))
    else
        view = builder()
    end

    if not view then
        pending.reapply()
        ui.refresh(buildMainView())
        return
    end

    pending.reapply()
    pending.syncOptions(view.options or {})
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

    -- A/D only previews — ENTER locks the choice in
    option.selected = nextIndex
    option.set(nextIndex)
    option.price = ui.priceForSelection(option, nextIndex)
    navSound()
    ui.updateSelectedItem()
end

local function lockInSelection(option)
    local selected = option.selected or option.defaultIndex or 1
    pending.upsert(option, selected)
    upgradeSound()

    local valueLabel = option.values and option.values[selected] or option.label
    if selected == (option.defaultIndex or 1) then
        exports.qbx_core:Notify(locale('notifications.inform.deselected', option.label), 'inform')
    else
        exports.qbx_core:Notify(locale('notifications.inform.selected', valueLabel), 'success')
    end
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

    if option.type == 'checkout' then
        navSound()
        ui.show(buildCheckoutView())
        return
    end

    if option.type == 'pay' then
        navSound()
        local totalLabel = pending.totalLabel()
        local ok = openedWithExports or lib.callback.await(
            'qbx_customs:server:payCart',
            false,
            pending.itemsForServer(),
            option.moneyType
        )
        if ok then
            pending.commit()
            exports.qbx_core:Notify(locale('notifications.success.cartPaid', totalLabel), 'success')
            qbx.playAudio({
                audioName = 'PICK_UP',
                audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
            })
            ui.replace(buildMainView())
        else
            exports.qbx_core:Notify(locale('notifications.error.money'), 'error')
        end
        return
    end

    -- Mod rows: ENTER locks in the previewed choice (no payment yet)
    if option.values and option.set then
        lockInSelection(option)
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

            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 200, true)
            DisablePlayerFiring(cache.playerId, true)

            for _, control in ipairs({ 32, 33, 34, 35, 172, 173, 174, 175, 201, 202, 177, 194 }) do
                DisableControlAction(0, control, true)
            end
            for i = 81, 85 do
                DisableControlAction(0, i, true)
            end

            if not ui.isOpen() then goto continue end

            if IsDisabledControlJustPressed(0, 32) or IsDisabledControlJustPressed(0, 172) then
                pending.revertPreview(ui.getOption())
                navSound()
                ui.moveSelection(-1)

            elseif IsDisabledControlJustPressed(0, 33) or IsDisabledControlJustPressed(0, 173) then
                pending.revertPreview(ui.getOption())
                navSound()
                ui.moveSelection(1)

            elseif IsDisabledControlJustPressed(0, 34) or IsDisabledControlJustPressed(0, 174) then
                changeValue(-1)

            elseif IsDisabledControlJustPressed(0, 35) or IsDisabledControlJustPressed(0, 175) then
                changeValue(1)

            elseif IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(0, 191) then
                confirmSelection()

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
    pending.start()
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
        pending.restoreBaseline()
        pending.clear()
        ui.hide()
        inMenu = false
        stopDragCam()
    end
end)

return function()
    openedWithExports = false
    openCustoms()
end
