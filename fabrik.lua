-- Test for FABRIK alghorithm
if CLIENT then return end

local CHIPPOS = chip():getPos()
local NODEDIST = 30
local NODENUM = 5
local tol = 0.1

local p = {}
local d = {}
local allDist = 0

for i=1, NODENUM do
    if i == NODENUM then
        local endRig = hologram.create(CHIPPOS, Angle(), "models/editor/axis_helper.mdl", Vector(1, 1, 1))
        p[i] = endRig
        break
    end
    local nodeHeight = (i - 1) * NODEDIST
    local rig = hologram.create(CHIPPOS + Vector(0, 0, nodeHeight), Angle(), "models/editor/axis_helper.mdl", Vector(1, 1, 1))
    local holo = hologram.create(CHIPPOS + Vector(0, 0, nodeHeight + NODEDIST / 2), Angle(), "models/holograms/cube.mdl", Vector(0.3, 0.3, NODEDIST / 12))
    if !(holo and rig) then return end
    holo:setParent(rig)
    p[i] = rig
    d[i] = NODEDIST
    allDist = allDist + NODEDIST
end
p[1]:setParent(chip())

local bone = prop.create(CHIPPOS + Vector(0, 0, allDist), Angle(), "models/props_junk/popcan01a.mdl", true)

hook.add("Think", "", function()
    local t = bone:getPos()
    local dist = p[1]:getPos():getDistance(t)
    if dist > allDist then
        for i=1, #p-1 do
            local nodePos = p[i]:getPos()
            local nodeDist = t:getDistance(nodePos)
            local lambda = d[i] / nodeDist
            p[i+1]:setPos((1 - lambda) * nodePos + lambda * t)
        end
    else
        local startNode = p[1]
        local startPos = startNode:getPos()
        local endNode = p[#p]
        -- local endPos = endNode:getPos()
        local diff = endNode:getPos():getDistance(t)
        while diff > tol do
            endNode:setPos(t)
            for i=#p-1, 1, -1 do
                local nodePos = p[i]:getPos()
                local secondNodePos = p[i+1]:getPos()
                local nodeDist = secondNodePos:getDistance(nodePos)
                local lambda = d[i] / nodeDist
                p[i]:setPos((1 - lambda) * secondNodePos + lambda * nodePos)
            end
            startNode:setPos(startPos)
            for i=1, #p-1 do
                local nodePos = p[i]:getPos()
                local secondNodePos = p[i+1]:getPos()
                local nodeDist = secondNodePos:getDistance(nodePos)
                local lambda = d[i] / nodeDist
                p[i+1]:setPos((1 - lambda) * nodePos + lambda * secondNodePos)
            end
            diff = endNode:getPos():getDistance(t)
        end
    end

    for i=1, #p-1 do
        local ang = (p[i+1]:getPos() - p[i]:getPos()):getAngle()
        p[i]:setAngles(ang:rotateAroundAxis(ang:getRight(), -90))
    end
end)
