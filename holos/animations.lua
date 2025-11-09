--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/tweens.lua as tweens
--@server
require("tweens")

animations = {}

function animations.getBox(box)
    local tw = Tween:new()
    local position = box:getPos()
    local angles = box:getLocalAngles()
    box:setLocalAngles(angles + Angle(90, -90, 0))
    tw:add(
        Param:new(0.25, box, PROPERTY.POS, position + Vector(12, 0, 0):getRotated(angles), math.easeInCubic)
    )
    tw:add(
        Param:new(0.25, box, PROPERTY.POS, position + Vector(12, 0, 14):getRotated(angles), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.25, box, PROPERTY.POS, position + Vector(0, 0, 6):getRotated(angles), math.easeInOutCubic),
        Param:new(0.25, box, PROPERTY.LOCALANGLES, angles, math.easeInOutCubic)
    )
    tw:start()
end


function animations.removeBox(box)
    local tw = Tween:new()
    local position = box:getPos()
    local angles = box:getLocalAngles()
    tw:add(
        Param:new(0.25, box, PROPERTY.POS, position + Vector(12, 0, 7):getRotated(angles), math.easeInCubic),
        Param:new(0.25, box, PROPERTY.LOCALANGLES, angles + Angle(90, 90, 0), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.1, box, PROPERTY.POS, position + Vector(12, -5, 18):getRotated(angles), math.easeInOutCubic),
        Param:new(0.1, box, PROPERTY.LOCALANGLES, angles + Angle(0, 0, 30), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.2, box, PROPERTY.POS, position + Vector(0, 0, 9):getRotated(angles), math.easeInOutCubic),
        Param:new(0.2, box, PROPERTY.LOCALANGLES, angles, math.easeInOutCubic)
    )
    tw:start()
end
