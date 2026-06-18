-- Draw system for in-game screens with health and rounds

if SERVER then return end

---@class screen
---@field inited table<number, LifeScreen>
local screen = {}
screen.inited = {}

---@class LifeScreen
---@field id number
---@field participant Participant
local LifeScreen = {}
LifeScreen.__index = LifeScreen


---@param part Participant Participant link for this screen
---@return LifeScreen
function screen.new(part)
    local obj = setmetatable({
        id = part.sortedId,
        participant = part
    }, LifeScreen)
    screen.inited[obj.id] = obj
    return obj
end


function LifeScreen:draw()
    render.drawRect(0, 0, 1024, 1024)
end

hook.add("RenderOffscreen", "LifeScreens", function()
    for i, v in pairs(screen.inited) do
        render.selectRenderTarget("LifeScreen" .. i)
        v:draw()
    end
    render.selectRenderTarget()
end)


return screen
