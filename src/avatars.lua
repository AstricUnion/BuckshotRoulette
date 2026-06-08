
-- Avatars lib. To made holograms of players with full customizable visual

---@include buckshot/libs/tween/tweens.lua
---@class tween
local tween = require("buckshot/libs/tween/tweens.lua")
local param = tween.param

if SERVER then return end


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


---Avatar class. With it we can made animations for players at table
---@class Avatar
---@field holo Hologram Holo of player
---@field bones table<AvatarBone, ParamProperties> Holo of player
---@field animation number?
local Avatar = {}
Avatar.__index = Avatar


---[CLIENT] Create new avatar of player
---@param ply Player
---@return Avatar?
function Avatar:new(ply)
    local holo = hologram.create(Vector(), Angle(), ply:getModel())
    if !holo then return end
    holo:setPlayerColor(ply:getPlayerColor())
    for _, v in ipairs(ply:getBodygroups()) do
        ---@cast v BodyGroupData
        local bg = ply:getBodygroup(v.id)
        holo:setBodygroup(v.id, bg)
    end
    holo:setSkin(ply:getSkin())
    local obj = setmetatable({holo = holo}, Avatar)
    local bones = {}
    for i=0, holo:getBoneCount() do
        local name = holo:getBoneName(i)
        local prettyName = string.replace(name, "ValveBiped.Bip01_", "")
        bones[prettyName] = {obj:getForBone(name)}
    end
    self.bones = bones
    obj:idleAnimation()
    return obj
end


---[CLIENT] Remove avatar
function Avatar:remove()
    tween.stop(self.animation)
    self.holo:remove()
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

    local headPos, headAngles = self:getBone("Head1")
    local _, spineAngles = self:getBone("Spine")
    local _, spine2Angles = self:getBone("Spine2")
    local pelvisPos, pelvisAngles = self:getBone("Pelvis")
    pelvisPos.set(self.holo, Vector(2, 0, -16))
    pelvisAngles.set(self.holo, Angle(0, 0, -80))
    spineAngles.set(self.holo, Angle(0, 80, 0))

    local tbl = {
        param {0, 0.8, self.holo, headAngles, nil, Angle(0.5, -1, 0.5), math.easeInOutSine},
        param {0.8, 2.2, self.holo, headAngles, nil, Angle(-0.5, -1, -0.5), math.easeInOutSine},
        param {2.2, 3, self.holo, headAngles, nil, Angle(), math.easeInOutSine},

        param {0, 1.5, self.holo, headPos, nil, Vector(0, -0.2, 0), math.easeInOutSine},
        param {1.5, 3, self.holo, headPos, nil, Vector(), math.easeInOutSine},

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

local function getEase(easeIn, easeOut)
    return function(process)
        return math.easeInOut(process, easeIn, easeOut)
    end
end

local function mergeShotgun(startAt, endAt, holo, shotgun, boneId)
    return function(process)
        if process < startAt then return end
        if process > endAt then return true end
        local mat = holo:getBoneMatrix(boneId)
        if !mat then return end
        local pos, ang = localToWorld(Vector(14, 0, -6), Angle(210, 0, 0), mat:getTranslation(), mat:getAngles())
        shotgun:setPos(pos)
        shotgun:setAngles(ang)
    end
end

---[CLIENT] Start idle animation for body
---@param shotgun Hologram Shotgun holo
function Avatar:takeShotgun(shotgun)
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
        -- Take shotgun
        param {0, 0.2, self.holo, headAngles, nil, Angle(0, -40, 0), math.easeInQuart},
        param {0.2, 0.5, self.holo, headAngles, nil, Angle(0, 20, -10), math.easeOutBack},

        param {0, 0.2, self.holo, spine2Angles, nil, Angle(0, -5, -5), math.easeInQuart},
        param {0.2, 0.5, self.holo, spine2Angles, nil, Angle(0, 40, 20), math.easeOutCubic},

        param {0.1, 0.5, self.holo, rightUpperarmAngles, nil, Angle(30, -120, 0), math.easeOutBack},
        param {0.1, 0.4, self.holo, rightForearmAngles, nil, Angle(0, -60, -60), math.easeOutSine},
        param {0.3, 0.5, self.holo, rightForearmAngles, nil, Angle(0, 0, -60), math.easeOutBack},
    })
    self.animation = tween.start(anim)
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
        param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 80, 0), math.easeInOutSine},
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
        param {0, 0.4, self.holo, headAngles, nil, Angle(5, 0, 0), math.easeOutBack},
        param {0, 0.4, self.holo, spine2Angles, nil, Angle(3, 0, 0), math.easeInOutSine},
        param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 80, 0), math.easeInOutSine},
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
        param {0, 0.4, self.holo, spineAngles, nil, Angle(0, 80, (2/3 * ang)), math.easeOutBack},
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
        param {0, 0.2, self.holo, spineAngles, nil, Angle(0, 80, (2/3 * ang)), math.easeOutBack},

        param {0, 0.05, self.holo, rightForearmAngles, nil, Angle(0, -80, 30), math.easeOutQuart},
        param {0.05, 0.6, self.holo, rightForearmAngles, nil, Angle(0, -100, 30), math.easeOutQuart},
        param {0, 0.05, self.holo, rightHandAngles, nil, Angle(-30, 20, 0), math.easeOutBack},
        param {0.05, 0.6, self.holo, rightHandAngles, nil, Angle(-60, 20, 0), math.easeOutBack},
        mergeShotgun(0, 0.6, self.holo, shotgun, rightHandId)
    })
    self.animation = tween.start(anim)
end

function Avatar:dropShotgun(shotgun)
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
        param {0, 0.5, self.holo, rightUpperarmAngles, nil, Angle(20, -90, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, rightForearmAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, rightHandAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftUpperarmAngles, nil, Angle(-20, -90, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftForearmAngles, nil, Angle(0, 0, 0), math.easeInOutBack},
        param {0, 0.5, self.holo, leftHandAngles, nil, Angle(0, 0, 0), math.easeInOutBack},

        param {0.5, 0.9, self.holo, rightUpperarmAngles, nil, Angle(-20, -11, 0), math.easeOutBack},
        param {0.5, 0.9, self.holo, rightForearmAngles, nil, Angle(0, -85, 50), math.easeOutBack},
        mergeShotgun(0, 0.1, self.holo, shotgun, rightHandId),
    })
    self.animation = tween.start(anim)
end

function Avatar:atPlayer0()
    self:atPlayer2()
end

function Avatar:atPlayer1()
    local _, headAngles = self:getBone("Head1")
    tween.start(tween.new {
        param {0, 0.3, self.holo, headAngles, nil, Angle(0, 0, 45), math.easeInOutCubic}
    })
end

function Avatar:atPlayer2()
    local _, headAngles = self:getBone("Head1")
    tween.start(tween.new {
        param {0, 0.3, self.holo, headAngles, nil, Angle(0, 0, 0), math.easeInOutCubic}
    })
end

function Avatar:atPlayer3()
    local _, headAngles = self:getBone("Head1")
    tween.start(tween.new {
        param {0, 0.5, self.holo, headAngles, nil, Angle(0, 0, -45), math.easeInOutCubic}
    })
end


local test = Avatar:new(owner())
if !test then return end
test.holo:setPos(chip():getPos() + Vector(50, 0, 0))
test.holo:setAngles(chip():getAngles() + Angle(0, 180, 0))
test.holo:setParent(chip())
local shotgunHolo = hologram.create(chip():getPos() + Vector(0, 0, 32), chip():getAngles() + Angle(0, 0, 90), "models/weapons/w_annabelle.mdl")
if !shotgunHolo then return end
shotgunHolo:setParent(chip())

timer.simple(1, function()
    test:takeShotgun(shotgunHolo)
    timer.simple(0.5, function()
        test:shotgunToHands(shotgunHolo)
    end)
end)
timer.simple(2.5, function()
    test:atPlayer1()
end)
timer.simple(3, function()
    test:shootPose(shotgunHolo, 45)
end)

timer.simple(3.5, function()
    test:shootAtPlayer(shotgunHolo, 45)
end)

timer.simple(4, function()
    test:shotgunToHands(shotgunHolo)
end)

timer.simple(4.5, function()
    test:shotgunReload(shotgunHolo)
end)

timer.simple(5.5, function()
    test:dropShotgun(shotgunHolo)
    -- timer.simple(1.2, function()
    --     test:idleAnimation()
    -- end)
end)

return Avatar
