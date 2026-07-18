local WheelType = require('client.enums.WheelType')
local VehicleClass = require('client.enums.VehicleClass')
local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@param wheelType WheelType
local function isWheelTypeAllowed(wheelType)
    local class = GetVehicleClass(vehicle)
    if class == VehicleClass.Cycles then return false end

    if class == VehicleClass.Motorcycles then
        return wheelType == WheelType.Bike
    end

    if class == VehicleClass.OpenWheels then
        return wheelType == WheelType.OpenWheel
    end

    return true
end

local function buildOptions()
    local options = {}
    local originalWheelType = GetVehicleWheelType(vehicle)
    local originalMod = GetVehicleMod(vehicle, 23)
    local originalRearWheel = GetVehicleMod(vehicle, 24)

    for _, category in ipairs(config.wheels) do
        if not isWheelTypeAllowed(category.id) then goto continue end

        SetVehicleWheelType(vehicle, category.id)
        local modCount = GetNumVehicleMods(vehicle, 23)
        local labels = {}
        for j = 1, modCount do
            labels[j] = GetLabelText(GetModTextLabel(vehicle, 23, j - 1))
        end

        if #labels > 0 then
            local catId = category.id
            options[#options + 1] = {
                type = 'item',
                icon = 'wheels',
                id = catId,
                payType = 'cosmetic',
                label = category.label,
                price = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
                values = labels,
                selected = originalWheelType == catId and originalMod + 1 or 1,
                defaultIndex = originalWheelType == catId and originalMod + 1 or 1,
                set = function(index)
                    SetVehicleWheelType(vehicle, catId)
                    SetVehicleMod(vehicle, 23, index - 1, false)
                    return catId == originalWheelType and (index - 1) == originalMod,
                        locale('menus.wheels.installed', category.label, labels[index])
                end,
                restore = function()
                    SetVehicleWheelType(vehicle, originalWheelType)
                    SetVehicleMod(vehicle, 23, originalMod, false)
                    SetVehicleMod(vehicle, 24, originalRearWheel, false)
                end,
                onPurchaseSideEffects = function()
                    if catId == 6 then
                        SetVehicleMod(vehicle, 24, originalRearWheel, false)
                    end
                end,
            }
        end

        if GetVehicleClass(vehicle) == VehicleClass.Motorcycles and #labels > 0 then
            options[#options + 1] = {
                type = 'item',
                icon = 'wheels',
                id = 'rear',
                payType = 'cosmetic',
                label = locale('menus.wheels.bikeRear'),
                price = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
                values = labels,
                selected = originalWheelType == 6 and originalRearWheel + 1 or 1,
                defaultIndex = originalWheelType == 6 and originalRearWheel + 1 or 1,
                set = function(index)
                    SetVehicleWheelType(vehicle, 6)
                    SetVehicleMod(vehicle, 24, index - 1, false)
                    return false, locale('menus.wheels.installed', locale('menus.wheels.bikeRear'), labels[index])
                end,
                restore = function()
                    SetVehicleWheelType(vehicle, originalWheelType)
                    SetVehicleMod(vehicle, 23, originalMod, false)
                    SetVehicleMod(vehicle, 24, originalRearWheel, false)
                end,
                onPurchaseSideEffects = function()
                    SetVehicleMod(vehicle, 23, originalMod, false)
                end,
            }
        end

        ::continue::
    end

    SetVehicleWheelType(vehicle, originalWheelType)

    table.sort(options, function(a, b)
        if a.id == 'rear' then return false end
        if b.id == 'rear' then return true end
        return a.label < b.label
    end)

    return options
end

return function()
    return {
        id = 'wheels',
        title = locale('menus.wheels.title'),
        subtitle = 'Choose a wheel style',
        options = buildOptions(),
        rebuild = function()
            return require('client.menus.wheels')()
        end,
    }
end
