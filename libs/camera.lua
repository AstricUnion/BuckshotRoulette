--@name Camera
--@author AstricUnion
--@shared
if !CLIENT then return end


---@class camera
---@field pinPoint Hologram
---@field lerpRatio number
---@field fov number?
---@field targetAngle Angle?
---@field targetPos Vector?
---@field targetFov number?
---@field enabled boolean
local camera = {}
local pinPoint = hologram.create(Vector(), Angle(), "models/editor/camera.mdl")
if !pinPoint then return end
pinPoint:setNoDraw(true)
camera.pinPoint = pinPoint
camera.fov = 70
camera.lerpRatio = 0.15
camera.targetPos = Vector()
camera.targetAngle = Angle()
camera.targetFov = 70
camera.enabled = false


---Create camera preset to use it after
---@param pos Vector Position of camera
---@param ang Angle Angle of camera
---@param fov number FOV of camera
---@return fun(ratio: number?) presetFunction Call this function to load preset
function camera.preset(pos, ang, fov)
    return function(ratio)
        if ratio == 1 then
            camera.setPos(pos)
            camera.setAngles(ang)
            camera.setFOV(fov)
        else
            camera.setLerpRatio(ratio or camera.lerpRatio)
            camera.setTargetPos(pos)
            camera.setTargetAngles(ang)
            camera.setTargetFOV(fov)
        end
    end
end


---Set lerp ratio for camera target positions
---@param ratio number
function camera.setLerpRatio(ratio)
    camera.lerpRatio = ratio
end

---Get lerp ratio for camera target positions
---@return number ratio
function camera.getLerpRatio()
    return camera.lerpRatio
end

---Enable camera for this client
---@param state boolean
function camera.enable(state)
    camera.enabled = state
end

---Is camera enabled for this client
---@return boolean state
function camera.isEnabled()
    return camera.enabled
end

---Set camera field of view
---@param fov? number
function camera.setFOV(fov)
    camera.fov = fov
    camera.targetFov = fov
end

---Get camera field of view
---@return number?
function camera.getFOV()
    return camera.fov
end

---Set camera target field of view. Will not work without lerpRatio
---@param fov? number
function camera.setTargetFOV(fov)
    camera.targetFov = fov
end

---Set camera target position. Will not work without lerpRatio
---@param pos? Vector
function camera.setTargetPos(pos)
    camera.targetPos = pos
end

---Get camera target position
---@return Vector pos
function camera.getTargetPos()
    return camera.targetPos
end

---Set camera target angles. Will not work without lerpRatio
---@param ang? Angle
function camera.setTargetAngles(ang)
    camera.targetAngle = ang
end

---Get camera target angles
---@return Angle ang
function camera.getTargetAngles()
    return camera.targetAngle
end

---Set camera position
---@param pos Vector
function camera.setPos(pos)
    camera.pinPoint:setLocalPos(pos)
    camera.targetPos = pos
end

---Get camera position
---@return Vector pos
function camera.getPos()
    return camera.pinPoint:getLocalPos()
end

---Set camera angles
---@param ang Angle
function camera.setAngles(ang)
    camera.pinPoint:setLocalAngles(ang)
    camera.targetAngle = ang
end

---Get camera angles
---@return Angle pos
function camera.getAngles()
    return camera.pinPoint:getLocalAngles()
end

---Set parent of camera
---@param parent Entity?
function camera.setParent(parent)
    if parent then
        camera.pinPoint:setPos(parent:getPos())
        camera.pinPoint:setAngles(parent:getAngles())
        camera.pinPoint:setParent(parent)
    else
        camera.pinPoint:setParent(parent)
        camera.setPos(camera.pinPoint:getPos())
        camera.setAngles(camera.pinPoint:getAngles())
    end
end

---Get parent of camera
---@return Entity? parent
function camera.getParent()
    return camera.pinPoint:getParent()
end


hook.add("CalcView", "PinCamera", function()
    if !camera.enabled then return end
    local pin = camera.pinPoint
    local pos = pin:getLocalPos()
    local angs = pin:getLocalAngles()
    local fov = camera:getFOV()
    if camera.lerpRatio then
        local ratio = camera.lerpRatio * (game.serverFrameTime() / game.getTickInterval())
        if camera.targetPos then
            pin:setLocalPos(math.lerpVector(ratio, pos, camera.targetPos))
        end
        if camera.targetAngle then
            pin:setLocalAngles(math.lerpAngle(ratio, angs, camera.targetAngle))
        end
        if camera.targetFov and fov then
            camera.setFOV(math.lerp(ratio, fov, camera.targetFov))
        end
    end
    pos = pin:getPos()
    angs = pin:getAngles()
    return {
        origin = pos,
        angles = angs,
        fov = fov
    }
end)


return camera
