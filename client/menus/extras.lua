local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function buildOptions()
    local options = {}
    local originalExtras = {}

    for i = 1, 14 do
        if not DoesExtraExist(vehicle, i) then
            goto continue
        end

        local extraTurnedOn = IsVehicleExtraTurnedOn(vehicle, i)
        originalExtras[i] = extraTurnedOn

        options[#options + 1] = {
            type = 'item',
            icon = 'extras',
            id = ('extra_%d'):format(i),
            payType = 'cosmetic',
            label = ('Extra %d'):format(i),
            price = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
            values = { locale('menus.general.enabled'), locale('menus.general.disabled') },
            selected = extraTurnedOn and 1 or 2,
            defaultIndex = extraTurnedOn and 1 or 2,
            set = function(index)
                -- SetVehicleExtra: 0 = enabled, 1 = disabled
                SetVehicleExtra(vehicle, i, index - 1)
                return originalExtras[i] == (index == 1), ('%s %s'):format(
                    ('Extra %d'):format(i),
                    index == 1 and string.lower(locale('menus.general.enabled')) or string.lower(locale('menus.general.disabled'))
                )
            end,
            restore = function()
                SetVehicleExtra(vehicle, i, originalExtras[i] and 0 or 1)
            end,
        }

        ::continue::
    end

    return options
end

return function()
    return {
        id = 'extras',
        title = locale('menus.main.extras'),
        subtitle = 'Toggle vehicle extras',
        options = buildOptions(),
        rebuild = function()
            return require('client.menus.extras')()
        end,
    }
end
