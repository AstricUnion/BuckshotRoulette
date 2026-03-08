--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/tweens.lua as tweens
--@server
require("tweens")

animations = {}

function animations.getBox(box)
    local tw = Tween:new()
    local position = box.box:getPos()
    local angles = box.box:getLocalAngles()
    box.box:setLocalAngles(angles + Angle(90, -90, 0))
    tw:add(
        Param:new(0.25, box.box, PROPERTY.POS, position + Vector(12, 0, 0):getRotated(angles), math.easeInCubic)
    )
    tw:add(
        Param:new(0.25, box.box, PROPERTY.POS, position + Vector(12, 0, 20):getRotated(angles), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.25, box.box, PROPERTY.POS, position + Vector(0, 0, 11):getRotated(angles), math.easeInOutCubic),
        Param:new(0.25, box.box, PROPERTY.LOCALANGLES, angles, math.easeInOutCubic)
    )
    tw:add(Param:new(0.5, box.boxLid, PROPERTY.LOCALANGLES, Angle(30, 0, 0), math.easeOutBack))
    tw:start()
end


function animations.removeBox(box)
    local tw = Tween:new()
    local angles = box.box:getLocalAngles()
    local position = box.box:getPos() - Vector(0, 0, 11):getRotated(angles)
    tw:add(Param:new(0.5, box.boxLid, PROPERTY.LOCALANGLES, Angle(180, 0, 0), math.easeOutBack))
    tw:add(
        Param:new(0.25, box.box, PROPERTY.POS, position + Vector(12, 0, 20):getRotated(angles), math.easeInCubic),
        Param:new(0.25, box.box, PROPERTY.LOCALANGLES, angles + Angle(90, -90, 0), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.1, box.box, PROPERTY.POS, position + Vector(12, 0, 0):getRotated(angles), math.easeInOutCubic)
    )
    tw:add(
        Param:new(0.2, box.box, PROPERTY.POS, position, math.easeInOutCubic),
        Param:new(0.2, box.box, PROPERTY.LOCALANGLES, angles, math.easeInOutCubic)
    )
    tw:start()
end
