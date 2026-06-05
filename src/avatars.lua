-- Avatars lib. To made holograms of players with full customizable visual
if SERVER then return end
local holo = hologram.create(chip():getPos(), chip():getAngles(), "models/player/combine_super_soldier.mdl")
if !holo then return end
holo:setPlayerColor(Vector(0, 0, 1))
local head = holo:lookupBone("ValveBiped.Bip01_Head1")
hook.add("RenderOffscreen", "", function()
    holo:manipulateBoneAngles(head, holo:getManipulateBoneAngles(head) + Angle(0, 0, game.serverFrameTime() * 30))
end)
