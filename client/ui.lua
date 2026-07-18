local ui = {}

local visible = false
local currentOptions = {}
local currentView = nil
local stack = {}
local selectedIndex = 1

local function send(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

function ui.priceForSelection(option, selected)
    if option.prices and type(option.prices) == 'table' then
        local clientConfig = require 'config.client'
        return ('%s%s'):format(clientConfig.currency, option.prices[selected] or 0)
    end
    return option.price
end

local function priceForSelection(option, selected)
    return ui.priceForSelection(option, selected)
end

local function serializeOptions(options)
    local items = {}
    for i, option in ipairs(options) do
        local selected = option.selected or option.defaultIndex or 1
        items[i] = {
            label = option.label,
            price = priceForSelection(option, selected),
            type = option.type or 'item',
            icon = option.icon,
            values = option.values,
            selected = selected,
        }
    end
    return items
end

local function pushView(view)
    stack[#stack + 1] = view
    currentView = view
end

local function popView()
    stack[#stack] = nil
    currentView = stack[#stack]
    return currentView
end

local function clampSelection()
    local count = #currentOptions
    if count < 1 then
        selectedIndex = 1
        return
    end
    if selectedIndex < 1 then selectedIndex = 1 end
    if selectedIndex > count then selectedIndex = count end
end

local function sendView()
    clampSelection()
    send('setView', {
        title = currentView and currentView.title or 'RM-CUSTOMS',
        subtitle = currentView and currentView.subtitle or '',
        canGoBack = #stack > 1,
        crumb = currentView and currentView.title or '',
        items = serializeOptions(currentOptions),
        activeIndex = selectedIndex,
    })
end

function ui.isOpen()
    return visible
end

function ui.getSelectedIndex()
    return selectedIndex
end

function ui.setSelectedIndex(index)
    selectedIndex = index
    clampSelection()
    send('setSelection', {
        activeIndex = selectedIndex,
        items = serializeOptions(currentOptions),
    })
end

function ui.moveSelection(delta)
    local count = #currentOptions
    if count < 1 then return end
    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then selectedIndex = count end
    if selectedIndex > count then selectedIndex = 1 end
    send('setSelection', {
        activeIndex = selectedIndex,
        items = serializeOptions(currentOptions),
    })
end

function ui.updateSelectedItem()
    local option = currentOptions[selectedIndex]
    if not option then return end
    send('updateItem', {
        index = selectedIndex,
        item = {
            label = option.label,
            price = priceForSelection(option, option.selected or option.defaultIndex or 1),
            type = option.type or 'item',
            icon = option.icon,
            values = option.values,
            selected = option.selected or option.defaultIndex or 1,
        },
        activeIndex = selectedIndex,
    })
end

function ui.show(view)
    currentOptions = view.options or {}
    pushView(view)
    visible = true
    selectedIndex = view.activeIndex or 1
    clampSelection()
    -- Display-only NUI (no cursor) — controls handled in Lua like ox_lib
    SetNuiFocus(false, false)
    send('setVisible', true)
    sendView()
end

function ui.refresh(view)
    currentOptions = view.options or {}
    currentView = view
    stack[#stack] = view
    selectedIndex = view.activeIndex or selectedIndex or 1
    clampSelection()
    sendView()
end

function ui.replace(view)
    if #stack > 0 then
        stack[#stack] = nil
    end
    ui.show(view)
end

function ui.hide()
    if not visible then return end
    visible = false
    currentOptions = {}
    currentView = nil
    stack = {}
    selectedIndex = 1
    send('setVisible', false)
    SetNuiFocus(false, false)
end

function ui.getOption(index)
    return currentOptions[index or selectedIndex]
end

function ui.getOptions()
    return currentOptions
end

function ui.getView()
    return currentView
end

function ui.restoreAll()
    for _, option in ipairs(currentOptions) do
        if option.restore then
            option.restore()
        end
    end
end

function ui.canGoBack()
    return #stack > 1
end

function ui.goBack()
    ui.restoreAll()
    local previous = popView()
    if not previous then
        return false
    end

    if previous.rebuild then
        previous = previous.rebuild()
        if not previous then
            return ui.goBack()
        end
        stack[#stack] = previous
        currentView = previous
    end

    currentOptions = previous.options or {}
    selectedIndex = previous.activeIndex or 1
    clampSelection()
    sendView()
    return true
end

return ui
