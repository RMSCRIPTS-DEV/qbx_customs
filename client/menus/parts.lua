local VehicleClass = require('client.enums.VehicleClass')
local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function plateIndex()
    local originalPlateIndex = GetVehicleNumberPlateTextIndex(vehicle)

    local plateIndexLabels = {}
    for i, v in ipairs(config.plateIndexes) do
        plateIndexLabels[i] = v.label
    end

    return {
        type = 'item',
        icon = 'plate',
        id = 'plate_index',
        payType = 'cosmetic',
        label = locale('menus.options.plateIndex.title'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
        values = plateIndexLabels,
        selected = originalPlateIndex + 1,
        defaultIndex = originalPlateIndex + 1,
        set = function(index)
            SetVehicleNumberPlateTextIndex(vehicle, index - 1)
            return originalPlateIndex == index - 1, locale('menus.options.plateIndex.installed', plateIndexLabels[index])
        end,
        restore = function()
            SetVehicleNumberPlateTextIndex(vehicle, originalPlateIndex)
        end,
    }
end

local function buildOptions()
    local options = {}
    local originalMods = {}

    for _, mod in ipairs(config.mods) do
        local modCount = GetNumVehicleMods(vehicle, mod.id)

        if mod.category ~= 'parts'
            or mod.enabled == false
            or modCount == 0
            or mod.id == 23
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

        options[#options + 1] = {
            type = 'item',
            icon = mod.icon or 'parts',
            id = mod.id,
            payType = 'cosmetic',
            label = mod.label,
            price = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
            values = modLabels,
            selected = currentMod + 2,
            defaultIndex = currentMod + 2,
            set = function(index)
                SetVehicleMod(vehicle, mod.id, index - 2, false)
                return originalMods[mod.id] == index - 2, locale('menus.general.installed', modLabels[index])
            end,
            restore = function()
                SetVehicleMod(vehicle, mod.id, originalMods[mod.id], false)
            end,
        }

        ::continue::
    end

    if GetVehicleClass(vehicle) ~= VehicleClass.Cycles then
        options[#options + 1] = {
            type = 'nav',
            icon = 'wheels',
            label = locale('menus.parts.wheels'),
            submenu = 'client.menus.wheels',
        }
    end

    options[#options + 1] = plateIndex()

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

return function()
    return {
        id = 'parts',
        title = locale('menus.parts.title'),
        subtitle = 'Body parts, plates and wheels',
        options = buildOptions(),
        rebuild = function()
            return require('client.menus.parts')()
        end,
    }
end
