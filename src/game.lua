---@class turns
local turns = turns
turns.minPlayers = 2

if SERVER then
    turns.addParticipant(Vector(50, 0, 0), Angle(0, -90, 0), "models/nova/chair_wood01.mdl", {})
    turns.addParticipant(Vector(-50, 0, 0), Angle(0, 90, 0), "models/nova/chair_wood01.mdl", {})
end
