-- Draw system for in-game screens with health and rounds

if SERVER then return end

---@class screen
---@field inited table<number, LifeScreen>
---@field font string
local screen = {}
screen.inited = {}
screen.font = render.createFont("Arial", 72, 500, true, false, false, false, 0, false, 0)

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


function LifeScreen:drawLighting(x, y)
    render.drawPoly {
        {x = x + 16, y = y},
        {x = x, y = y + 48},
        {x = x + 16, y = y + 48},
    }
end


function LifeScreen:draw()
    local ply = self.participant:getPlayer()
    if !isValid(ply) then return end
    render.setColor(Color(217, 244, 189))
    render.drawRectFast(0, 64, 1024, 16)
    render.drawRectFast(0, 512, 1024, 16)
    self:drawLighting(64, 64)
end

hook.add("RenderOffscreen", "LifeScreens", function()
    for i, v in pairs(screen.inited) do
        render.selectRenderTarget("LifeScreen" .. i)
        render.clear(Color(0, 0, 0))
        v:draw()
    end
    render.selectRenderTarget()
end)


return screen
