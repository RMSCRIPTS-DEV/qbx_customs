lib.versionCheck('Qbox-project/qbx_customs')
local sharedConfig = require 'config.shared'

---@return number?
local function getModPrice(mod, level)
    local price = sharedConfig.prices[mod]
    if price == nil then return nil end
    if mod == 'cosmetic' or mod == 'colors' or mod == 18 then
        return price --[[@as number]]
    end
    if type(price) ~= 'table' then return nil end
    return price[level]
end

---@param source number
---@param amount number
---@param moneyType 'cash'|'bank'|nil
---@return boolean
local function removeMoney(source, amount, moneyType)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    if amount <= 0 then return true end

    if moneyType == 'cash' or moneyType == 'bank' then
        if player.Functions.GetMoney(moneyType) < amount then
            return false
        end
        player.Functions.RemoveMoney(moneyType, amount, locale('general.payReason'))
        return true
    end

    local cashBalance = player.Functions.GetMoney('cash')
    local bankBalance = player.Functions.GetMoney('bank')

    if cashBalance >= amount then
        player.Functions.RemoveMoney('cash', amount, locale('general.payReason'))
        return true
    elseif bankBalance >= amount then
        player.Functions.RemoveMoney('bank', amount, locale('general.payReason'))
        exports.qbx_core:Notify(source, locale('notifications.success.paid', amount), 'success')
        return true
    end

    return false
end

local function hasFreeMods(source)
    local zone = lib.callback.await('qbx_customs:client:zone', source)

    for i, v in ipairs(sharedConfig.zones) do
        if i == zone and v.freeMods then
            local playerJob = exports.qbx_core:GetPlayer(source)?.PlayerData?.job?.name
            for _, job in ipairs(v.freeMods) do
                if playerJob == job then
                    return true
                end
            end
        end
    end

    return false
end

-- Won't charge money for mods if the player's job is in the list
lib.callback.register('qbx_customs:server:pay', function(source, mod, level)
    if hasFreeMods(source) then return true end
    return removeMoney(source, getModPrice(mod, level))
end)

--- Pay for a batch of staged upgrades with an explicit money type (cash or bank/card)
lib.callback.register('qbx_customs:server:payCart', function(source, items, moneyType)
    if type(items) ~= 'table' or #items < 1 then return false end
    if moneyType ~= 'cash' and moneyType ~= 'bank' then return false end

    if hasFreeMods(source) then return true end

    local total = 0
    for i = 1, #items do
        local item = items[i]
        if type(item) ~= 'table' or item.mod == nil or item.level == nil then
            return false
        end
        local price = getModPrice(item.mod, item.level)
        if type(price) ~= 'number' then return false end
        total = total + price
    end

    return removeMoney(source, total, moneyType)
end)

-- Won't charge money for repairs if the player's job is in the list
lib.callback.register('qbx_customs:server:repair', function(source, bodyHealth)
    local zone = lib.callback.await('qbx_customs:client:zone', source)

    for i, v in ipairs(sharedConfig.zones) do
        if i == zone and v.freeRepair then
            local playerJob = exports.qbx_core:GetPlayer(source)?.PlayerData?.job?.name
            for _, job in ipairs(v.freeRepair) do
                if playerJob == job then
                    return true
                end
            end
        end
    end

    local price = math.ceil(1000 - bodyHealth)
    return removeMoney(source, price)
end)

local function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    else
        return false
    end
end

--Copied from qb-mechanicjob
RegisterNetEvent('qbx_customs:server:saveVehicleProps', function()
    local src = source --[[@as number]]
    local vehicleProps = lib.callback.await('qbx_customs:client:vehicleProps', src)
    if IsVehicleOwned(vehicleProps.plate) then
        MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
    end
end)
