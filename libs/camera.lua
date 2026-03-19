--@name Camera
--@author AstricUnion
--@client


---@type Camera?
local activeCamera = nil


---@class Camera
---@field pinPoint Hologram
---@field lerpRatio number
---@field fov number?
---@field targetAngle Angle?
---@field targetPos Vector?
---@field targetFov number?
local Camera = {}
Camera.__index = Camera


---Get camera field of view
---@return number?
function Camera:getFOV()
    return self.fov
end


---Set camera field of view
---@param fov? number
function Camera:setFOV(fov)
    self.fov = fov
end


---Set camera target field of view. Will not work without lerpRatio
---@param fov? number
function Camera:setTargetFOV(fov)
    self.targetFov = fov
end


---Set camera target position. Will not work without lerpRatio
---@param pos? Vector
function Camera:setTargetPos(pos)
    self.targetPos = pos
end

---Set camera target angles. Will not work without lerpRatio
---@param ang? Angle
function Camera:setTargetAngles(ang)
    self.targetAngle = ang
end


---Get pin point
---@return Hologram
function Camera:getPinPoint()
    return self.pinPoint
end


---Remove camera
function Camera:remove()
    self.pinPoint:remove()
    if activeCamera == self then camera.set(nil) end
    setmetatable(self, nil)
end



hook.add("CalcView", "PinCamera", function()
    if !activeCamera then return end
    local pin = activeCamera.pinPoint
    local pos = pin:getPos()
    local angs = pin:getAngles()
    local fov = activeCamera:getFOV()
    if activeCamera.lerpRatio then
        local ratio = activeCamera.lerpRatio
        if activeCamera.targetPos then
            pin:setPos(math.lerpVector(ratio, pos, activeCamera.targetPos))
        end
        if activeCamera.targetAngle then
            pin:setAngles(math.lerpAngle(ratio, angs, activeCamera.targetAngle))
        end
        if activeCamera.targetFov and fov then
            activeCamera:setFOV(math.lerp(ratio, fov, activeCamera.targetFov))
        end
    end
    return {
        origin = pos,
        angles = angs,
        fov = fov
    }
end)

---@class camera
local camera = {}


---Create new camera
---@param pos Vector Position of camera
---@param ang Angle Angle of camera
---@param fov? number Initial field of view. Default to player FOV
---@param lerpRatio? number Ratio for lerp. Default to nil, e.g. lerp will be turned off
---@param noDraw? boolean No draw camera. Default to true
---@return Camera?
function camera.create(pos, ang, fov, lerpRatio, noDraw)
    noDraw = noDraw and true or false
    local pinPoint = hologram.create(pos, ang, "models/editor/camera.mdl")
    if !pinPoint then return end
    pinPoint:setNoDraw(noDraw)
    return setmetatable({
        pinPoint = pinPoint,
        lerpRatio = lerpRatio,
        targetPos = nil,
        targetAngle = nil,
        targetFov = nil,
        fov = fov
    }, Camera)
end


---Set player camera
---@param cam? Camera Nil to reset
function camera.set(cam)
    activeCamera = cam
end


---Get player camera
---@return Camera? cam Nil, if no camera
function camera.get()
    return activeCamera
end


return camera
