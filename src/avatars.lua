
-- Avatars lib. To made holograms of players with full customizable visual

if SERVER then return end

---@class tween
local tween = tween
local param = tween.param

---@class camera
local camera = camera

local Ply = player()

---@alias AvatarBone
---| '"Pelvis"'
---| '"Spine"'
---| '"Spine1"'
---| '"Spine2"'
---| '"Spine4"'
---| '"L_Clavicle"'
---| '"L_UpperArm"'
---| '"L_Forearm"'
---| '"L_Hand"'
---| '"R_Clavicle"'
---| '"R_UpperArm"'
---| '"R_Forearm"'
---| '"R_Hand"'
---| '"Neck1"'
---| '"Head1"'
---| '"L_Thigh"'
---| '"L_Calf"'
---| '"L_Foot"'
---| '"L_Toe0"'
---| '"R_Thigh"'
---| '"R_Calf"'
---| '"R_Foot"'
---| '"R_Toe0"'

local cameraProperties = {
    POS = {
        set = function(_, toSet) camera.setPos(toSet) end,
        get = function(_) return camera.getPos() end
    },
    ANGLES = {
        set = function(_, toSet) camera.setAngles(toSet) end,
        get = function(_) return camera.getAngles() end
    },
    FOV = {
        set = function(_, toSet) camera.setFOV(toSet) end,
        get = function(_) return camera.getFOV() end
    }
}

---@enum CAMERA
local CAMERA = {
    Default = camera.preset(Vector(4, 0, 55), Angle(10, 0, 0), 90),
    AtTable = camera.preset(Vector(10, 0, 55), Angle(50, 0, 0), 90),
    AtScreen = camera.preset(Vector(20, 0, 40), Angle(60, 0, 0), 90),
    AtBox = camera.preset(Vector(12, 0, 52), Angle(55, 0, 0), 90),
    AtShotgun = camera.preset(Vector(42, 0, 48), Angle(60, 30, 0), 90),

    AtPlayer0 = camera.preset(Vector(10, 0, 55), Angle(30, 0, 0), 80),
    AtPlayer1 = camera.preset(Vector(10, 0, 55), Angle(10, 30, 0), 80),
    AtPlayer2 = camera.preset(Vector(10, 0, 55), Angle(10, 0, 0), 80),
    AtPlayer3 = camera.preset(Vector(10, 0, 55), Angle(10, -30, 0), 80),
}

---Avatar class. With it we can made animations for players at table
---@class Avatar
---@field holo Hologram Holo of player
---@field cam Hologram Camera pinpoint
---@field ply Player Player linked to this avatar
---@field bones table<AvatarBone, ParamProperties> Holo of player
---@field animation number?
local Avatar = {}
Avatar.__index = Avatar


---[CLIENT] Create new avatar of player
---@param ply Player
---@return Avatar?
function Avatar:new(ply)
    -- Create player hologram with model
    local holo = hologram.create(Vector(), Angle(), ply:getModel())
    if !holo then return end
    if Ply == ply then
        -- Start camera, if local player
        camera.setParent(holo)
        camera.enable(true)
        CAMERA.Default(1)
    end
    -- Set some settings for player
    holo:setPlayerColor(ply:getPlayerColor())
    for _, v in ipairs(ply:getBodygroups()) do
        ---@cast v BodyGroupData
        local bg = ply:getBodygroup(v.id)
        holo:setBodygroup(v.id, bg)
    end
    holo:setSkin(ply:getSkin())
    local obj = setmetatable({holo = holo, ply = ply}, Avatar)
    -- Cache bones and parameters for tweens
    local bones = {}
    for i=0, holo:getBoneCount() do
        local name = holo:getBoneName(i)
        local prettyName = string.replace(name, "ValveBiped.Bip01_", "")
        bones[prettyName] = {obj:getForBone(name)}
    end
    self.bones = bones
    -- By default start idle animation
    obj:idleAnimation()
    return obj
end


---[CLIENT] Remove avatar
function Avatar:remove()
    tween.stop(self.animation)
    self.holo:remove()
    if Ply == self.ply then
        camera.enable(false)
    end
    setmetatable(self, nil)
end


---[CLIENT] Get tween functions for bone (by name)
---@param bone string
---@return ParamProperty pos
---@return ParamProperty angs
---@return number id
function Avatar:getForBone(bone)
    local boneId = self.holo:lookupBone(bone)
    if !boneId then
        return tween.ParamProperties.NONE, tween.ParamProperties.NONE, boneId
    end
    return {
        set = function(ent, toSet) ent:manipulateBonePosition(boneId, toSet) end,
        get = function(ent) return ent:getManipulateBonePosition(boneId) end
    },
    {
        set = function(ent, toSet) ent:manipulateBoneAngles(boneId, toSet) end,
        get = function(ent) return ent:getManipulateBoneAngles(boneId) end
    }, boneId
end


---[CLIENT] Get cached bone properties by identifier. Identifier without ValveBiped.Bip01_
---@param identifier AvatarBone
---@return ParamProperty pos
---@return ParamProperty angs
---@return number id
function Avatar:getBone(identifier)
    return unpack(self.bones[identifier])
end


---[CLIENT] Start idle animation for body
function Avatar:idleAnimation()
    if self.animation then tween.stop(self.animation) end

    local _, headAngles = self:getBone("Head1")
    local _, spineAngles = self:getBone("Spine")
    local _, spine2Angles = self:getBone("Spine2")
    local pelvisPos, pelvisAngles = self:getBone("Pelvis")
    pelvisPos.set(self.holo, Vector(2, 0, -14))
    pelvisAngles.set(self.holo, Angle(0, 0, -70))
    spineAngles.set(self.holo, Angle(0, 70, 0))

    local tbl = {
        param {0, 0.8, self.holo, headAngles, nil, Angle(0.5, -1, 0.5), math.easeInOutSine},
        param {0.8, 2.2, self.holo, headAngles, nil, Angle(-0.5, -1, -0.5), math.easeInOutSine},
        param {2.2, 3, self.holo, headAngles, nil, Angle(), math.easeInOutSine},

        param {0.2, 1.2, self.holo, spine2Angles, Angle(0, 4, 0), Angle(0, 5, 0), math.easeInOutSine},
        param {1.4, 3, self.holo, spine2Angles, nil, Angle(0, 4, 0), math.easeInOutSine},
    }
    for _, v in ipairs({-1, 1}) do
        local side = v == 1 and "L" or "R"
        local _, calfAngles = self:getBone(side .. "_Calf")
        calfAngles.set(self.holo, Angle(0, 80, 0))
        local _, upperarmAngles = self:getBone(side .. "_UpperArm")
        local _, forearmAngles = self:getBone(side .. "_Forearm")
        table.add(tbl, {
            param {0.2, 1.2, self.holo, upperarmAngles, Angle(20 * v, -10, 0), Angle(20 * v, -11, 0), math.easeInOutSine},
            param {1.4, 3, self.holo, upperarmAngles, nil, Angle(20 * v, -10, 0), math.easeInOutSine},
            param {0, 0.8, self.holo, forearmAngles, Angle(0, -85, 50 * v), Angle(0, -85, 50 * v), math.easeInOutSine},
        })
    end

    local anim = tween.new(tbl)
    self.animation = tween.start(anim, true)
end


---[CLIENT] Start animation on player box
function Avatar:atBox()
    if self.ply == Ply then
        CAMERA.AtBox()
    end
end

---[CLIENT] Start animation to shotgun
function Avatar:atShotgun()
    if self.ply == Ply then
        CAMERA.AtShotgun()
    end
end

---[CLIENT] Start animation on box removing
function Avatar:removeBox()
    if self.ply == Ply then
        CAMERA.AtTable()
    end
end

---[CLIENT] Start animation on player turn
function Avatar:turn()
    if self.ply == Ply then
        CAMERA.AtTable()
    end
end

---[CLIENT] Merge shotgun hologram with bone
local function mergeShotgun(startAt, endAt, holo, shotgun, boneId)
    return function(process)
        if process < startAt then return end
        if process > endAt then return true end
        local mat = holo:getBoneMatrix(boneId)
        if !mat then return end
        local pos, ang = localToWorld(Vector(12, 0, -5), Angle(210, 0, 90), mat:getTranslation(), mat:getAngles())
        shotgun:setPos(pos)
        shotgun:setAngles(ang)
    end
end


---[CLIENT] Get position and angle properties local to holo
function Avatar:localToHolo()
    return {
        set = function(ent, toSet)
            local pos, _ = localToWorld(toSet, Angle(), self.holo:getPos(), self.holo:getAngles())
            ent:setPos(pos)
        end,
        get = function(ent)
            local pos, _ = worldToLocal(ent:getPos(), ent:getAngles(), self.holo:getPos(), self.holo:getAngles())
            return pos
        end
    }, {
        set = function(ent, toSet)
            local _, ang = localToWorld(Vector(), toSet, self.holo:getPos(), self.holo:getAngles())
            ent:setAngles(ang)
        end,
        get = function(ent)
            local _, ang = worldToLocal(ent:getPos(), ent:getAngles(), self.holo:getPos(), self.holo:getAngles())
            return ang
        end
    }
end

---@param shotgun Hologram Shotgun holo
function Avatar:takeShotgun(shotgun)
    if self.animation then tween.stop(self.animation) end

    local anim
    if self.ply ~= Ply then
        local _, headAngles = self:getBone("Head1")
        local _, rightUpperarmAngles = self:getBone("R_UpperArm")
        local _, rightForearmAngles = self:getBone("R_Forearm")
        local _, spine2Angles = self:getBone("Spine2")

        anim = tween.new({
            -- Take shotgun
            param {0, 0.2, self.holo, headAngles, nil, Angle(0, -40, 0), math.easeInQuart},
            param {0.2, 0.5, self.holo, headAngles, nil, Angle(0, 20, -10), math.easeOutBack},

            param {0, 0.2, self.holo, spine2Angles, nil, Angle(0, -5, -5), math.easeInQuart},
            param {0.2, 0.5, self.holo, spine2Angles, nil, Angle(0, 30, 20), math.easeOutCubic},

            param {0.1, 0.5, self.holo, rightUpperarmAngles, nil, Angle(30, -120, 0), math.easeOutBack},
            param {0.1, 0.4, self.holo, rightForearmAngles, nil, Angle(0, -60, -60), math.easeOutSine},
            param {0.3, 0.5, self.holo, rightForearmAngles, nil, Angle(0, 0, -60), math.easeOutBack},
        })
        local id = tween.start(anim)
        self.animation = id
        -- Start animation for shotgun transition to hands
        timer.simple(0.5, function()
            if self.animation ~= id then return end
            self:shotgunToHands(shotgun)
        end)
    else
        local pos, angs = self:localToHolo()
        anim = tween.new({
            param {0, 0.4, shotgun, pos, nil, Vector(45, 0, 36), math.easeInOutQuart},
            param {0, 0.4, nil, cameraProperties.ANGLES, nil, Angle(50, 0, 1), math.easeInCubic},
            param {0, 0.4, nil, cameraProperties.FOV, nil, 89, math.easeInCubic},

            param {0.4, 1, shotgun, pos, nil, Vector(24, 0, 37), math.easeInOutQuart},
            param {0.4, 1, shotgun, angs, nil, Angle(20, 270, -90), math.easeInOutQuart},
            param {0.4, 1, nil, cameraProperties.POS, nil, Vector(5, 0, 55), math.easeOutCubic},
            param {0.4, 1, nil, cameraProperties.ANGLES, nil, Angle(10, 0, 0), math.easeOutCubic},
            param {0.4, 0.8, nil, cameraProperties.FOV, nil, 90, math.easeOutCubic},
        })
        self.animation = tween.start(anim)
    end
end


function Avatar:shotgunToHands(shotgun)
    if self.animation then tween.stop(self.animation) end

    local headPos, headAngles = self:getBone("Head1")
    local _, rightUpperarmAngles = self:getBone("R_UpperArm")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
    local _, leftUpperarmAngles = self:getBone("L_UpperArm")
    local _, leftForearmAngles = self:getBone("L_Forearm")
    local _, leftHandAngles = self:getBone("L_Hand")
    local _, spine2Angles = self:getBone("Spine2")
    local _, spineAngles = self:getBone("Spine")
    local anim = tween.new({
        mergeShotgun(0, 0.8, self.holo, shotgun, rightHandId),
        param {0, 0.4, self.holo, headAngles, nil, Angle(0, 0, 0), math.easeOutBack},
        param {0, 0.4, self.holo, spine2Angles, nil, Angle(0, 0, 0), math.easeInOutSine},
        param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 70, 0), math.easeInOutSine},
        param {0, 0.4, self.holo, rightUpperarmAngles, nil, Angle(10, -30, -60), math.easeOutQuart},
        param {0, 0.4, self.holo, rightForearmAngles, nil, Angle(20, -110, 30), math.easeOutBack},
        param {0, 0.4, self.holo, rightHandAngles, nil, Angle(-10, -40, 0), math.easeInOutQuart},
        param {0, 0.4, self.holo, leftUpperarmAngles, nil, Angle(20, 30, 0), math.easeInOutQuart},
        param {0, 0.4, self.holo, leftForearmAngles, nil, Angle(0, -130, 30), math.easeInOutQuart},
        param {0, 0.4, self.holo, leftHandAngles, nil, Angle(-10, -30, -120), math.easeInOutQuart},
    })
    self.animation = tween.start(anim)
end


function Avatar:shotgunReload(shotgun)
    if self.animation then tween.stop(self.animation) end

    local _, headAngles = self:getBone("Head1")
    local _, rightUpperarmAngles = self:getBone("R_UpperArm")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
    local _, leftUpperarmAngles = self:getBone("L_UpperArm")
    local _, leftForearmAngles = self:getBone("L_Forearm")
    local _, leftHandAngles = self:getBone("L_Hand")
    local _, spine2Angles = self:getBone("Spine2")
    local _, spineAngles = self:getBone("Spine")

    local anim
    if self.ply ~= Ply then
        anim = tween.new({
            param {0, 0.4, self.holo, headAngles, nil, Angle(5, 0, 0), math.easeOutBack},
            param {0, 0.4, self.holo, spine2Angles, nil, Angle(3, 0, 0), math.easeInOutSine},
            param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 70, 0), math.easeInOutSine},
            param {0, 0.4, self.holo, rightUpperarmAngles, nil, Angle(30, -20, -60), math.easeInQuart},
            param {0, 0.4, self.holo, rightForearmAngles, nil, Angle(30, -130, 30), math.easeInQuart},
            param {0, 0.4, self.holo, rightHandAngles, nil, Angle(-10, -40, 0), math.easeInQuart},
            param {0, 0.4, self.holo, leftUpperarmAngles, nil, Angle(20, -20, 0), math.easeInQuart},
            param {0, 0.4, self.holo, leftForearmAngles, nil, Angle(20, -130, 30), math.easeInQuart},
            param {0, 0.4, self.holo, leftHandAngles, nil, Angle(-10, -60, -120), math.easeInQuart},

            param {0.4, 0.8, self.holo, headAngles, nil, Angle(0, 0, 0), math.easeOutBack},
            param {0.4, 0.8, self.holo, spine2Angles, nil, Angle(0, 0, 0), math.easeOutQuart},
            param {0.4, 0.8, self.holo, rightUpperarmAngles, nil, Angle(10, -30, -60), math.easeOutQuart},
            param {0.4, 0.8, self.holo, rightForearmAngles, nil, Angle(20, -110, 30), math.easeOutQuart},
            param {0.4, 0.8, self.holo, rightHandAngles, nil, Angle(-10, -40, 0), math.easeOutQuart},
            param {0.4, 0.8, self.holo, leftUpperarmAngles, nil, Angle(20, 30, 0), math.easeOutQuart},
            param {0.4, 0.8, self.holo, leftForearmAngles, nil, Angle(0, -130, 30), math.easeOutQuart},
            param {0.4, 0.8, self.holo, leftHandAngles, nil, Angle(-10, -30, -120), math.easeOutQuart},

            mergeShotgun(0, 0.8, self.holo, shotgun, rightHandId),
        })
    else
        local pos, angs = self:localToHolo()
        anim = tween.new({
            param {0, 0.8, shotgun, angs, nil, Angle(20, -90, 0), math.easeInOutQuart},
            param {0, 0.8, shotgun, pos, nil, Vector(24, 0, 37), math.easeInOutQuart},
        })
    end
    self.animation = tween.start(anim)
end


function Avatar:shootPose(shotgun, ang)
    if self.animation then tween.stop(self.animation) end

    local headPos, headAngles = self:getBone("Head1")
    local _, rightUpperarmAngles = self:getBone("R_UpperArm")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
    local _, leftUpperarmAngles = self:getBone("L_UpperArm")
    local _, leftForearmAngles = self:getBone("L_Forearm")
    local _, leftHandAngles = self:getBone("L_Hand")
    local _, spine2Angles = self:getBone("Spine2")
    local _, spineAngles = self:getBone("Spine")

    local anim = tween.new({
        param {0, 0.4, self.holo, headAngles, nil, Angle(0, 0, 15), math.easeOutQuart},
        param {0, 0.4, self.holo, rightUpperarmAngles, nil, Angle(-10, -50, -10), math.easeOutQuart},
        param {0, 0.4, self.holo, rightForearmAngles, nil, Angle(0, -100, 30), math.easeOutQuart},
        param {0, 0.4, self.holo, rightHandAngles, nil, Angle(-60, 20, 0), math.easeOutBack},
        param {0, 0.4, self.holo, leftUpperarmAngles, nil, Angle(8, -90, -30), math.easeOutQuart},
        param {0, 0.4, self.holo, leftForearmAngles, nil, Angle(10, -10, 30), math.easeOutQuart},
        param {0, 0.4, self.holo, leftHandAngles, nil, Angle(0, -30, -120), math.easeInOutBack},
        param {0, 0.4, self.holo, spine2Angles, nil, Angle(0, 0, (1/3 * ang) - 15), math.easeOutBack},
        param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 70, (2/3 * ang)), math.easeOutBack},
        mergeShotgun(0, 0.5, self.holo, shotgun, rightHandId),
    })
    self.animation = tween.start(anim)
end

function Avatar:shootAtPlayer(shotgun, ang)
    if self.animation then tween.stop(self.animation) end

    local _, headAngles = self:getBone("Head1")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
    local _, spine2Angles = self:getBone("Spine2")
    local _, spineAngles = self:getBone("Spine")

    local anim = tween.new({
        param {0, 0.05, self.holo, headAngles, nil, Angle(0, -20, 15), math.easeOutQuart},
        param {0, 0.05, self.holo, spine2Angles, nil, Angle(0, -10, (1/3 * ang) - 15), math.easeOutBack},
        param {0.05, 0.6, self.holo, headAngles, nil, Angle(0, 0, 15), math.easeOutQuart},
        param {0.05, 0.6, self.holo, spine2Angles, nil, Angle(0, 0, (1/3 * ang) - 15), math.easeOutBack},
        param {0, 0.2, self.holo, spineAngles, nil, Angle(0, 70, (2/3 * ang)), math.easeOutBack},

        param {0, 0.05, self.holo, rightForearmAngles, nil, Angle(0, -80, 30), math.easeOutQuart},
        param {0.05, 0.6, self.holo, rightForearmAngles, nil, Angle(0, -100, 30), math.easeOutQuart},
        param {0, 0.05, self.holo, rightHandAngles, nil, Angle(-30, 20, 0), math.easeOutBack},
        param {0.05, 0.6, self.holo, rightHandAngles, nil, Angle(-60, 20, 0), math.easeOutBack},
        mergeShotgun(0, 0.6, self.holo, shotgun, rightHandId)
    })
    self.animation = tween.start(anim)
end

function Avatar:shootPoseSelf(shotgun)
    if self.animation then tween.stop(self.animation) end

    local anim
    if self.ply ~= Ply then
        local _, headAngles = self:getBone("Head1")
        local _, rightUpperarmAngles = self:getBone("R_UpperArm")
        local _, rightForearmAngles = self:getBone("R_Forearm")
        local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
        local _, leftUpperarmAngles = self:getBone("L_UpperArm")
        local _, leftForearmAngles = self:getBone("L_Forearm")
        local _, leftHandAngles = self:getBone("L_Hand")
        local _, spine2Angles = self:getBone("Spine2")
        local _, spineAngles = self:getBone("Spine")
        anim = tween.new({
            mergeShotgun(0, 0.4, self.holo, shotgun, rightHandId),
            param {0, 0.4, self.holo, headAngles, nil, Angle(0, 15, 0), math.easeOutBack},
            param {0, 0.4, self.holo, spine2Angles, nil, Angle(0, -20, 0), math.easeInOutSine},
            param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 70, 0), math.easeInOutSine},
            param {0, 0.4, self.holo, rightUpperarmAngles, nil, Angle(-40, -40, 0), math.easeOutQuart},
            param {0, 0.4, self.holo, rightForearmAngles, nil, Angle(-10, -5, 0), math.easeOutBack},
            param {0, 0.4, self.holo, rightHandAngles, nil, Angle(130, 5, 0), math.easeInOutQuart},
            param {0, 0.4, self.holo, leftUpperarmAngles, nil, Angle(0, -30, 60), math.easeInOutQuart},
            param {0, 0.4, self.holo, leftForearmAngles, nil, Angle(-20, -120, 0), math.easeInOutQuart},
            param {0, 0.4, self.holo, leftHandAngles, nil, Angle(-10, -10, 0), math.easeInOutQuart},
        })
    else
        local pos, angs = self:localToHolo()
        anim = tween.new({
            param {0, 0.4, shotgun, pos, nil, Vector(10, 0, 32), math.easeInOutQuart},
            param {0, 0.4, shotgun, angs, nil, Angle(85, 0, -90), math.easeInOutQuart},
            param {0, 0.4, nil, cameraProperties.POS, nil, Vector(4, 0, 55), math.easeInCubic},
            param {0, 0.4, nil, cameraProperties.ANGLES, nil, Angle(50, 0, 1), math.easeInCubic},
            param {0, 0.4, nil, cameraProperties.FOV, nil, 87, math.easeInCubic},
        })
    end
    self.animation = tween.start(anim)
end


function Avatar:dropShotgun(shotgun)
    if self.animation then tween.stop(self.animation) end

    local headAngles = self:getBone("Head1")
    local _, rightUpperarmAngles = self:getBone("R_UpperArm")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, rightHandAngles, rightHandId = self:getBone("R_Hand")
    local _, leftUpperarmAngles = self:getBone("L_UpperArm")
    local _, leftForearmAngles = self:getBone("L_Forearm")
    local _, leftHandAngles = self:getBone("L_Hand")
    local _, spine2Angles = self:getBone("Spine2")
    local holoAngles = self.holo:getAngles()
    local anim = tween.new({
        param {0, 0.5, self.holo, headAngles, nil, Angle(0, 20, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, spine2Angles, nil, Angle(0, 20, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, rightUpperarmAngles, nil, Angle(20, -120, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, rightForearmAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, rightHandAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftUpperarmAngles, nil, Angle(-20, -120, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftForearmAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftHandAngles, nil, Angle(0, 0, 0), math.easeInOutBack},

        param {0.5, 0.9, self.holo, headAngles, nil, Angle(0, 0, 0), math.easeOutBack},
        param {0.5, 0.9, self.holo, spine2Angles, nil, Angle(0, 10, 0), math.easeOutBack},
        param {0.5, 0.9, self.holo, rightUpperarmAngles, nil, Angle(-20, -11, 0), math.easeOutBack},
        param {0.5, 0.9, self.holo, rightForearmAngles, nil, Angle(0, -85, 50), math.easeOutBack},
        param {0.5, 0.9, self.holo, leftUpperarmAngles, nil, Angle(20, -11, 0), math.easeOutBack},
        param {0.5, 0.9, self.holo, leftForearmAngles, nil, Angle(0, -85, 50), math.easeOutBack},
        param {0.4, 0.6, shotgun, tween.ParamProperties.LOCALPOS, nil, Vector(0, 0, 36), math.easeOutCubic},
        param {0.4, 0.6, shotgun, tween.ParamProperties.LOCALANGLES, nil, Angle(0, -180, 90) + holoAngles, math.easeOutCubic},
        mergeShotgun(0, 0.4, self.holo, shotgun, rightHandId),
    })
    self.animation = tween.start(anim)
end

---[CLIENT] Animation to look at player
---@param ang number Angle for head
---@param cam boolean? Only first-person camera
function Avatar:lookAtPlayer(ang, cam)
    if !cam then
        local _, headAngles = self:getBone("Head1")
        tween.start(tween.new {
            param {0, 0.3, self.holo, headAngles, nil, Angle(0, 0, ang), math.easeInOutCubic}
        })
        return
    end
    tween.start(tween.new {
        param {0, 0.3, nil, cameraProperties.ANGLES, nil, Angle(10, ang - (ang * 1/3), 0), math.easeInOutCubic},
        param {0, 0.3, nil, cameraProperties.FOV, nil, 80, math.easeInOutCubic}
    })
end

---[CLIENT] Look at player 0 (self)
---@param cam boolean? Only first-person camera
function Avatar:atPlayer0(cam)
    self:atPlayer2(cam)
end

---[CLIENT] Look at player 1 (left)
---@param cam boolean? Only first-person camera
function Avatar:atPlayer1(cam)
    self:lookAtPlayer(45, cam)
end

---[CLIENT] Look at player 2 (forward)
---@param cam boolean? Only first-person camera
function Avatar:atPlayer2(cam)
    self:lookAtPlayer(0, cam)
end

---[CLIENT] Look at player 3 (right)
---@param cam boolean? Only first-person camera
function Avatar:atPlayer3(cam)
    self:lookAtPlayer(-45, cam)
end

-- local test = Avatar:new(owner())
-- if !test then return end
-- test.holo:setPos(chip():getPos() + Vector(50, 0, 0))
-- test.holo:setAngles(chip():getAngles() + Angle(0, 180, 0))
-- test.holo:setParent(chip())
-- local shotgunHolo = hologram.create(chip():getPos() + Vector(0, 0, 34), chip():getAngles() + Angle(0, 0, 90), "models/weapons/w_annabelle.mdl")
-- if !shotgunHolo then return end
-- shotgunHolo:setParent(chip())
--
-- timer.simple(1, function()
--     test:takeShotgun(shotgunHolo)
-- end)
--
-- timer.simple(2.5, function()
--     test:shootPoseSelf(shotgunHolo)
-- end)
-- timer.simple(4, function()
--     test:shotgunToHands(shotgunHolo)
-- end)
-- timer.simple(4.5, function()
--     test:shotgunReload(shotgunHolo)
-- end)
-- timer.simple(5.5, function()
--     test:dropShotgun(shotgunHolo)
--     timer.simple(1, function()
--         test:idleAnimation()
--     end)
-- end)

return Avatar
