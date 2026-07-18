local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@param primary boolean
return function(primary)
    local originalPrimary, originalSecondary = GetVehicleColours(vehicle)
    local options = {}

    for category, values in pairs(config.paints) do
        local labels = {}
        local ids = {}
        local selectedIndex = 1
        local current = primary and originalPrimary or originalSecondary

        for i, paint in ipairs(values) do
            labels[i] = paint.label
            ids[i] = paint.id
            if paint.id == current then
                selectedIndex = i
            end
        end

        options[#options + 1] = {
            type = 'item',
            icon = 'paint',
            id = category,
            payType = 'colors',
            label = category,
            price = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
            values = labels,
            selected = selectedIndex,
            defaultIndex = selectedIndex,
            set = function(index)
                if primary then
                    SetVehicleColours(vehicle, ids[index], originalSecondary)
                else
                    SetVehicleColours(vehicle, originalPrimary, ids[index])
                end
                return ids[index] == current, locale('menus.general.applied', labels[index])
            end,
            restore = function()
                SetVehicleColours(vehicle, originalPrimary, originalSecondary)
            end,
        }
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return {
        id = 'paint',
        title = primary and locale('menus.paint.primary') or locale('menus.paint.secondary'),
        subtitle = 'Browse paint categories',
        options = options,
        rebuild = function()
            return require('client.menus.paint')(primary)
        end,
    }
end
