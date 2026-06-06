
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


---[CLIENT] Get tween functions for bone (by name)
---@param bone string
---@return ParamProperty pos
---@return ParamProperty angs
function Avatar:getForBone(bone)
    local boneId = self.holo:lookupBone(bone)
    if !boneId then
        return tween.ParamProperties.NONE, tween.ParamProperties.NONE
    end
    return {
        set = function(ent, toSet) ent:manipulateBonePosition(boneId, toSet) end,
        get = function(ent) return ent:getManipulateBonePosition(boneId) end
    },
    {
        set = function(ent, toSet) ent:manipulateBoneAngles(boneId, toSet) end,
        get = function(ent) return ent:getManipulateBoneAngles(boneId) end
    }
end


---[CLIENT] Get cached bone properties by identifier. Identifier without ValveBiped.Bip01_
---@param identifier AvatarBone
---@return ParamProperty pos
---@return ParamProperty angs
function Avatar:getBone(identifier)
    return unpack(self.bones[identifier])
end


---[CLIENT] Start idle animation for body
function Avatar:idleAnimation()
    if self.animation then tween.stop(self.animation) end

    local headPos, headAngles = self:getBone("Head1")
    local _, spineAngles = self:getBone("Spine2")
    local pelvisPos, _ = self:getBone("Pelvis")
    pelvisPos.set(self.holo, Vector(0, 0, -16))

    local tbl = {
        param {0, 0.8, self.holo, headAngles, nil, Angle(0.5, -1, 0.5), math.easeInOutSine},
        param {0.8, 2.2, self.holo, headAngles, nil, Angle(-0.5, -1, -0.5), math.easeInOutSine},
        param {2.2, 3, self.holo, headAngles, nil, Angle(), math.easeInOutSine},

        param {0, 1.5, self.holo, headPos, nil, Vector(0, -0.2, 0), math.easeInOutSine},
        param {1.5, 3, self.holo, headPos, nil, Vector(), math.easeInOutSine},

        param {0.2, 1.2, self.holo, spineAngles, Angle(0, 4, 0), Angle(0, 5, 0), math.easeInOutSine},
        param {1.4, 3, self.holo, spineAngles, nil, Angle(0, 4, 0), math.easeInOutSine},
    }
    for _, v in ipairs({-1, 1}) do
        local side = v == 1 and "L" or "R"
        local _, thighAngles = self:getBone(side .. "_Thigh")
        thighAngles.set(self.holo, Angle(-5 * v, -85, 0))
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


---[CLIENT] Start idle animation for body
function Avatar:takeShotgun()
    if self.animation then tween.stop(self.animation) end

    local headPos, headAngles = self:getBone("Head1")
    local _, leftUpperarmAngles = self:getBone("L_UpperArm")
    local _, leftForearmAngles = self:getBone("L_Forearm")
    local _, rightUpperarmAngles = self:getBone("R_UpperArm")
    local _, rightForearmAngles = self:getBone("R_Forearm")
    local _, spine2Angles = self:getBone("Spine2")
    local _, spineAngles = self:getBone("Spine")

    local anim = tween.new({
        param {0, 0.3, self.holo, spine2Angles, nil, Angle(0, 15, 10), math.easeInOutQuart},
        param {0, 0.5, self.holo, spineAngles, nil, Angle(0, 15, 5), math.easeInOutQuart},
        param {0, 0.4, self.holo, rightUpperarmAngles, nil, Angle(10, -70, 0), math.easeInOutQuart},
        param {0.1, 0.4, self.holo, rightForearmAngles, nil, Angle(0, -50, -60), math.easeInOutQuart}
    })
    self.animation = tween.start(anim)
end


local test = Avatar:new(owner())
test.holo:setPos(chip():getPos() + Vector(50, 0, 0))
test.holo:setAngles(chip():getAngles() + Angle(0, 180, 0))
test.holo:setParent(chip())

timer.simple(1, function()
    test:takeShotgun()
end)
