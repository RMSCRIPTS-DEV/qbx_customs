local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function buildOptions()
    local options = {}
    local originalNeon = {}

    for i = 1, 4 do
        local enabled = IsVehicleNeonLightEnabled(vehicle, i - 1)
        originalNeon[i] = enabled

        options[i] = {
            type = 'item',
            icon = 'neon',
            id = ('neon_%d'):format(i),
            payType = 'colors',
            label = locale('menus.neon.neon', config.neon[i].label, ''),
            price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
            values = {
                locale('menus.general.disabled'),
                locale('menus.general.enabled'),
            },
            selected = enabled and 2 or 1,
            defaultIndex = enabled and 2 or 1,
            set = function(index)
                SetVehicleNeonLightEnabled(vehicle, i - 1, index == 2)
                return originalNeon[i] == (index == 2), locale(
                    'menus.neon.neon',
                    config.neon[i].label,
                    ', ' .. (index == 2 and string.lower(locale('menus.general.enabled')) or string.lower(locale('menus.general.disabled')))
                )
            end,
            restore = function()
                SetVehicleNeonLightEnabled(vehicle, i - 1, originalNeon[i])
            end
        }
    end

    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    local originalLabelIndex = 1
    local neonLabels = {}

    for i, v in ipairs(config.neonColors) do
        neonLabels[i] = v.label
        if v.r == r and v.g == g and v.b == b then
            originalLabelIndex = i
        end
    end

    options[5] = {
        type = 'item',
        icon = 'neon',
        id = 'neon_color',
        payType = 'colors',
        label = locale('menus.neon.color'),
        price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        values = neonLabels,
        selected = originalLabelIndex,
        defaultIndex = originalLabelIndex,
        set = function(index)
            local rgb = config.neonColors[index]
            SetVehicleNeonLightsColour(vehicle, rgb.r, rgb.g, rgb.b)
            return originalLabelIndex == index, locale('menus.neon.installed', config.neonColors[index].label)
        end,
        restore = function()
            local rgb = config.neonColors[originalLabelIndex]
            SetVehicleNeonLightsColour(vehicle, rgb.r, rgb.g, rgb.b)
        end,
    }

    return options
end

return function()
    return {
        id = 'neon',
        title = locale('menus.neon.title'),
        subtitle = 'Neon lights and colors',
        options = buildOptions(),
        rebuild = function()
            return require('client.menus.neon')()
        end,
    }
end
