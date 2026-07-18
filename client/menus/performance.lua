local VehicleClass = require('client.enums.VehicleClass')
local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function priceLabel(price)
    if type(price) ~= 'table' then
        return ('%s%s'):format(config.currency, price)
    end

    local copy = table.clone(price)
    table.remove(copy, 1)

    for i = 1, #copy do
        copy[i] = ('%d: %s%s'):format(i, config.currency, copy[i])
    end

    return table.concat(copy, ' | ')
end

local function buildOptions()
    local options = {}
    local originalMods = {}
    local originalTurbo

    for _, mod in ipairs(config.mods) do
        local modCount = GetNumVehicleMods(vehicle, mod.id)

        if mod.category ~= 'performance'
            or mod.enabled == false
            or modCount == 0
        then
            goto continue
        end

        local modLabels = {}
        modLabels[1] = locale('menus.general.stock')
        for i = -1, modCount - 1 do
            modLabels[i + 2] = GetModLabel(vehicle, mod.id, i)
        end

        local currentMod = GetVehicleMod(vehicle, mod.id)
        originalMods[mod.id] = currentMod

        local prices = sharedConfig.prices[mod.id]
        local selectedIndex = currentMod + 2

        options[#options + 1] = {
            type = 'item',
            icon = 'performance',
            id = mod.id,
            payType = mod.id,
            label = mod.label,
            price = type(prices) == 'table'
                and ('%s%s'):format(config.currency, prices[selectedIndex] or 0)
                or priceLabel(prices),
            prices = type(prices) == 'table' and prices or nil,
            values = modLabels,
            selected = selectedIndex,
            defaultIndex = selectedIndex,
            set = function(index)
                SetVehicleMod(vehicle, mod.id, index - 2, false)
                return currentMod == index - 2, ('%s installed'):format(modLabels[index])
            end,
            restore = function()
                SetVehicleMod(vehicle, mod.id, originalMods[mod.id], false)
            end
        }

        ::continue::
    end

    originalTurbo = IsToggleModOn(vehicle, 18)
    if GetVehicleClass(vehicle) ~= VehicleClass.Cycles then
        options[#options + 1] = {
            type = 'item',
            icon = 'performance',
            id = 18,
            payType = 18,
            label = locale('menus.performance.turbo'),
            price = ('%s%s'):format(config.currency, sharedConfig.prices[18]),
            values = { locale('menus.general.disabled'), locale('menus.general.enabled') },
            selected = originalTurbo and 2 or 1,
            defaultIndex = originalTurbo and 2 or 1,
            set = function(index)
                ToggleVehicleMod(vehicle, 18, index == 2)
                return originalTurbo == (index == 2), ('%s %s'):format(
                    locale('menus.performance.turbo'),
                    index == 2 and string.lower(locale('menus.general.enabled')) or string.lower(locale('menus.general.disabled'))
                )
            end,
            restore = function()
                ToggleVehicleMod(vehicle, 18, originalTurbo)
            end
        }
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

return function()
    local options = buildOptions()

    if #options == 0 then
        exports.qbx_core:Notify(locale('notifications.inform.carNoPerformanceUpgrades'))
        return nil
    end

    return {
        id = 'performance',
        title = locale('menus.performance.title'),
        subtitle = 'Engine, brakes, transmission and more',
        options = options,
        rebuild = function()
            return require('client.menus.performance')()
        end,
    }
end
