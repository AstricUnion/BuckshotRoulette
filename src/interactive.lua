-- vanility oreo
---Interactive area class. All coordinates is number from 0 to 1 (screen percentage)
---@class InteractiveArea
---@field x number
---@field y number
---@field w number
---@field h number
---@field enable boolean
---@field hovered boolean

---Base class to manipulate interactive areas at screen
---@class interactive
---@field areas table<string, InteractiveArea>
---@field groups table<string, InteractiveArea[]> Areas groups
---@field draw boolean Draw areas or not
local interactive = {}
interactive.areas = {}
interactive.groups = {}
interactive.draw = false

---[SHARED] Hook on area input
---@param ply Player Player clicked
---@param area string Area identifier
function interactive.onInput(ply, area) end

if CLIENT then
    ---[CLIENT] Hook on area hover
    ---@param area string Area identifier
    ---@param state boolean
    function interactive.onHoverChanged(area, state) end

    ---[CLIENT] Add new interactive area. All coordinates is number from 0 to 1 (screen percentage)
    ---@param id string Individual identifier of area
    ---@param x number
    ---@param y number
    ---@param w number
    ---@param h number
    ---@param groupId string? Identifier of area group to add
    function interactive.addArea(id, x, y, w, h, groupId)
        local area = {x = x, y = y, w = w, h = h, enable = false, hovered = false}
        interactive.areas[id] = area
        if groupId then
            local group = interactive.groups[groupId] or {}
            group[#group+1] = area
            interactive.groups[groupId] = group
        end
    end

    ---[CLIENT] Enable interactive area
    ---@param id string Identifier of area
    ---@param state boolean Enable or not
    function interactive.enable(id, state)
        interactive.areas[id].enable = state
    end

    ---[CLIENT] Enable interactive areas group
    ---@param id string Identifier of area
    ---@param state boolean Enable or not
    function interactive.enableGroup(id, state)
        local group = interactive.groups[id]
        for _, v in ipairs(group) do
            v.enable = state
        end
    end

    ---[CLIENT] Enable drawing of areas
    ---@param state boolean Enable or not
    function interactive.enableDraw(state)
        interactive.draw = state
    end

    ---Is point hovers area
    local function isPointHoversArea(x, y, x1, y1, w, h)
        local x2, y2 = x1 + w, y1 + h
        return (x > x1 and y > y1) and (x < x2 and y < y2)
    end

    hook.add("InputReleased", "InteractiveAreaReceiveInput", function(key)
        if key ~= MOUSE.LEFT then return end
        if !input.getCursorVisible() then return end
        local cX, cY = input.getCursorPos()
        local sw, sh = render.getGameResolution()
        for id, v in pairs(interactive.areas) do
            if !v.enable then goto cont end
            local x, y = v.x * sw, v.y * sh
            local w, h = v.w * sw, v.h * sh
            if isPointHoversArea(cX, cY, x, y, w, h) then
                net.start("AreaReceivedInput")
                    net.writeString(id)
                net.send()
                return
            end
            ::cont::
        end
    end)

    hook.add("DrawHUD", "InteractiveAreaDraw", function()
        if !interactive.draw then return end
        if !input.getCursorVisible() then return end
        local sw, sh = render.getGameResolution()
        local cX, cY = input.getCursorPos()
        render.setFont("Default")
        local alreadyHover = false
        for id, v in pairs(interactive.areas) do
            if !v.enable then goto cont end
            local x, y = v.x * sw, v.y * sh
            local w, h = v.w * sw, v.h * sh
            local hovered = false
            if !alreadyHover then
                hovered = isPointHoversArea(cX, cY, x, y, w, h)
                if !v.hovered and hovered then
                    interactive.onHoverChanged(id, true)
                elseif v.hovered and !hovered then
                    interactive.onHoverChanged(id, false)
                end
                v.hovered = hovered
                alreadyHover = hovered
            end
            render.setColor(hovered and Color(255, 0, 0) or Color())
            render.drawRectOutline(x, y, w, h)
            render.drawSimpleText(x, y, id, nil, TEXT_ALIGN.BOTTOM)
            ::cont::
        end
    end)
else
    net.receive("AreaReceivedInput", function(_, ply)
        interactive.onInput(ply, net.readString())
    end)
end

return interactive
