local sharedConfig = require 'config.shared'
local config = require 'config.client'

local pending = {
    baseline = nil,
    entries = {},
}

---@param option table
---@return string
function pending.keyFor(option)
    if option.cartKey then return option.cartKey end
    return ('%s:%s'):format(tostring(option.payType or 'item'), tostring(option.id or option.label))
end

---@param option table
---@param selected number
---@return number
function pending.priceAmount(option, selected)
    if option.prices and type(option.prices) == 'table' then
        return option.prices[selected] or 0
    end

    local payType = option.payType or 'cosmetic'
    local price = sharedConfig.prices[payType]
    if type(price) == 'table' then
        return price[selected] or 0
    end
    return price or 0
end

function pending.start()
    pending.baseline = lib.getVehicleProperties(vehicle)
    pending.entries = {}
end

function pending.clear()
    pending.baseline = nil
    pending.entries = {}
end

function pending.hasEntries()
    return next(pending.entries) ~= nil
end

---@return number
function pending.total()
    local sum = 0
    for _, entry in pairs(pending.entries) do
        sum = sum + entry.price
    end
    return sum
end

---@return number
function pending.count()
    local n = 0
    for _ in pairs(pending.entries) do
        n = n + 1
    end
    return n
end

---@return { mod: string|number, level: number }[]
function pending.itemsForServer()
    local items = {}
    for _, entry in pairs(pending.entries) do
        items[#items + 1] = {
            mod = entry.payType,
            level = entry.level,
        }
    end
    return items
end

function pending.restoreBaseline()
    if pending.baseline and vehicle and vehicle ~= 0 then
        lib.setVehicleProperties(vehicle, pending.baseline)
        SetVehicleModKit(vehicle, 0)
    end
end

function pending.reapply()
    for _, entry in pairs(pending.entries) do
        if entry.apply then
            entry.apply()
        end
    end
end

function pending.resetVisual()
    pending.restoreBaseline()
    pending.reapply()
end

---@param option table
---@param selected number
function pending.upsert(option, selected)
    local key = pending.keyFor(option)
    local defaultIndex = option.defaultIndex or 1

    if selected == defaultIndex then
        pending.entries[key] = nil
        return
    end

    local idx = selected
    local setFn = option.set

    pending.entries[key] = {
        key = key,
        label = option.label,
        payType = option.payType or 'cosmetic',
        level = idx,
        price = pending.priceAmount(option, idx),
        apply = function()
            setFn(idx)
        end,
    }
end

---@param option table
---@return number
function pending.lockedIndex(option)
    local entry = pending.entries[pending.keyFor(option)]
    if entry then return entry.level end
    return option.defaultIndex or 1
end

--- Undo an unlocked A/D preview and restore the locked (or stock) choice
---@param option table
function pending.revertPreview(option)
    if not option or not option.set then return end

    local index = pending.lockedIndex(option)
    option.selected = index
    option.set(index)
    option.price = ('%s%s'):format(config.currency, pending.priceAmount(option, index))
end

---@param options table[]
function pending.syncOptions(options)
    for _, option in ipairs(options) do
        if option.id ~= nil or option.cartKey then
            local entry = pending.entries[pending.keyFor(option)]
            if entry then
                option.selected = entry.level
                option.price = ('%s%s'):format(config.currency, entry.price)
            end
        end
    end
end

function pending.commit()
    pending.baseline = lib.getVehicleProperties(vehicle)
    pending.entries = {}
end

---@return string
function pending.totalLabel()
    return ('%s%s'):format(config.currency, pending.total())
end

return pending
