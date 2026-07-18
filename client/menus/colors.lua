local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function xenon()
    local originalToggle = IsToggleModOn(vehicle, 22)
    local originalXenon = GetVehicleXenonLightsColor(vehicle)
    originalXenon = originalXenon == 255 and -1 or originalXenon

    local xenonLabels = { locale('menus.general.disabled') }
    for i, v in ipairs(config.xenon) do
        xenonLabels[i + 1] = v.label
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'xenon',
        payType = 'colors',
        label = locale('menus.options.xenon.title'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = xenonLabels,
        selected = not originalToggle and 1 or originalXenon + 3,
        defaultIndex = not originalToggle and 1 or originalXenon + 3,
        set = function(index)
            if index == 1 then
                ToggleVehicleMod(vehicle, 22, false)
                return not originalToggle, 'Disabled'
            end
            ToggleVehicleMod(vehicle, 22, true)
            SetVehicleXenonLightsColor(vehicle, index - 3)
            return originalXenon == index - 3, locale('menus.options.xenon.installed', xenonLabels[index])
        end,
        restore = function()
            ToggleVehicleMod(vehicle, 22, originalToggle)
            SetVehicleXenonLightsColor(vehicle, originalXenon)
        end,
    }
end

local function pearlescent()
    local originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, colour in ipairs(config.paints.Classic) do
        ids[i] = colour.id
        labels[i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = i
        end
    end

    local size = #ids
    for i, colour in ipairs(config.paints.Chameleon) do
        ids[size + i] = colour.id
        labels[size + i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = size + i
        end
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'pearlescent',
        payType = 'colors',
        label = locale('menus.options.pearlescent'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = labels,
        selected = defaultIndex,
        defaultIndex = defaultIndex,
        set = function(index)
            SetVehicleExtraColours(vehicle, ids[index], originalWheelColor)
            return originalPearlescent == ids[index], ('%s applied'):format(labels[index])
        end,
        restore = function()
            SetVehicleExtraColours(vehicle, originalPearlescent, originalWheelColor)
        end,
    }
end

local function wheelcolor()
    local originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, color in ipairs(config.paints.Classic) do
        ids[i] = color.id
        labels[i] = color.label
        if color.id == originalWheelColor then
            defaultIndex = i
        end
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'wheelcolor',
        payType = 'colors',
        label = locale('menus.options.wheelColor'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = labels,
        selected = defaultIndex,
        defaultIndex = defaultIndex,
        set = function(index)
            SetVehicleExtraColours(vehicle, originalPearlescent, ids[index])
            return originalWheelColor == ids[index], locale('menus.general.applied', labels[index])
        end,
        restore = function()
            SetVehicleExtraColours(vehicle, originalPearlescent, originalWheelColor)
        end,
    }
end

local function windowTint()
    local originalWindowTint = GetVehicleWindowTint(vehicle)
    local windowTintLabels = {}
    for i, v in ipairs(config.windowTints) do
        windowTintLabels[i] = v.label
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'window_tint',
        payType = 'colors',
        label = locale('menus.options.windowTint.title'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = windowTintLabels,
        selected = originalWindowTint + 1,
        defaultIndex = originalWindowTint + 1,
        set = function(index)
            SetVehicleWindowTint(vehicle, index - 1)
            return originalWindowTint == index - 1, locale('menus.options.windowTint.installed', windowTintLabels[index])
        end,
        restore = function()
            SetVehicleWindowTint(vehicle, originalWindowTint)
        end,
    }
end

local function tyresmoke()
    ToggleVehicleMod(vehicle, 20, true)
    local r, g, b = GetVehicleTyreSmokeColor(vehicle)
    local originalLabelIndex = 1
    local smokeLabels = {}

    for i, v in ipairs(config.tyreSmoke) do
        smokeLabels[i] = v.label
        if v.r == r and v.g == g and v.b == b then
            originalLabelIndex = i
        end
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'tyre_smoke',
        payType = 'colors',
        label = locale('menus.options.tyreSmoke'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = smokeLabels,
        selected = originalLabelIndex,
        defaultIndex = originalLabelIndex,
        set = function(index)
            local rgb = config.tyreSmoke[index]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
            return originalLabelIndex == index, locale('menus.general.installed', config.tyreSmoke[index].label)
        end,
        restore = function()
            local rgb = config.tyreSmoke[originalLabelIndex]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
        end,
    }
end

local function interior()
    local originalInterior = GetVehicleInteriorColor(vehicle)
    local interiorLabels = {}
    local interiorIds = {}
    local defaultIndex = 1

    for i, v in ipairs(config.paints.Classic) do
        interiorLabels[i] = v.label
        interiorIds[i] = v.id
        if v.id == originalInterior then
            defaultIndex = i
        end
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'interior',
        payType = 'colors',
        label = locale('menus.options.interior'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = interiorLabels,
        selected = defaultIndex,
        defaultIndex = defaultIndex,
        set = function(index)
            SetVehicleInteriorColor(vehicle, interiorIds[index])
            return originalInterior == interiorIds[index], locale('menus.general.applied', interiorLabels[index])
        end,
        restore = function()
            SetVehicleInteriorColor(vehicle, originalInterior)
        end,
    }
end

local function livery()
    local oldLiveryMethod = GetVehicleLivery(vehicle)
    local newLiveryMethod = GetVehicleMod(vehicle, 48)
    local originalLivery

    if newLiveryMethod >= 0 or oldLiveryMethod >= -1 then
        originalLivery = { index = newLiveryMethod, old = false }
    else
        originalLivery = { index = oldLiveryMethod, old = true }
    end

    local liveryLabels = {}
    if originalLivery.old then
        local liveryCount = GetVehicleLiveryCount(vehicle) - 1
        if liveryCount > -1 then
            for i = 0, liveryCount do
                liveryLabels[i + 1] = ('%s %d'):format(locale('menus.options.livery'), i + 1)
            end
        end
    else
        local liveryCount = GetNumVehicleMods(vehicle, 48) - 1
        if liveryCount > -1 then
            liveryLabels[1] = locale('menus.general.stock')
            for i = 0, liveryCount do
                liveryLabels[i + 2] = ('%s'):format(GetLabelText(GetModTextLabel(vehicle, 48, i)))
            end
        end
    end

    if #liveryLabels == 0 then
        return nil
    end

    return {
        type = 'item',
        icon = 'colors',
        id = 'livery',
        payType = 'colors',
        label = locale('menus.options.livery'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = liveryLabels,
        selected = originalLivery.old and originalLivery.index + 1 or originalLivery.index + 2,
        defaultIndex = originalLivery.old and originalLivery.index + 1 or originalLivery.index + 2,
        set = function(index)
            if originalLivery.old then
                SetVehicleLivery(vehicle, index - 1)
                return originalLivery.index == index - 1, locale('menus.general.installed', liveryLabels[index])
            end
            SetVehicleMod(vehicle, 48, index - 2, false)
            return originalLivery.index == index - 2, locale('menus.general.installed', liveryLabels[index])
        end,
        restore = function()
            if originalLivery.old then
                SetVehicleLivery(vehicle, originalLivery.index)
            else
                SetVehicleMod(vehicle, 48, originalLivery.index, false)
            end
        end,
    }
end

local function buildOptions()
    local options = {
        {
            type = 'nav',
            icon = 'paint',
            label = locale('menus.colors.primary'),
            submenu = 'client.menus.paint',
            submenuArgs = { true },
        },
        {
            type = 'nav',
            icon = 'paint',
            label = locale('menus.colors.secondary'),
            submenu = 'client.menus.paint',
            submenuArgs = { false },
        },
        {
            type = 'nav',
            icon = 'neon',
            label = locale('menus.colors.neon'),
            submenu = 'client.menus.neon',
        },
        xenon(),
        pearlescent(),
        wheelcolor(),
        windowTint(),
        tyresmoke(),
        interior(),
    }

    local liveryOption = livery()
    if liveryOption then
        options[#options + 1] = liveryOption
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

return function()
    return {
        id = 'colors',
        title = locale('menus.colors.cosmetics_colors'),
        subtitle = 'Paint, neon, tint and finishes',
        options = buildOptions(),
        rebuild = function()
            return require('client.menus.colors')()
        end,
    }
end
