---@class BuckshotRoulette: turns
local turns = turns
turns.timeout = 5
turns.minPlayers = 1

if SERVER then
    local initialData = {}
    local chairModel = "models/nova/chair_wood01.mdl"
    turns.addParticipant(Vector(50, 0, 0), Angle(0, 90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, -50, 0), Angle(0, 0, 0), chairModel, initialData)
    turns.addParticipant(Vector(-50, 0, 0), Angle(0, -90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, 50, 0), Angle(0, 180, 0), chairModel, initialData)
end

if SERVER then
    function turns.newParticipant(ply)
        enableHud(ply, true)
    end

    function turns.participantLeft(ply)
        enableHud(ply, false)
    end

    hook.add("KeyPress", "TestGame", function(ply, key)
        if !turns.isStarted then return end
        local part = turns.getParticipant(ply)
        if !part or part.sortedId ~= turns.currentTurn then return end
        if key ~= IN_KEY.ATTACK then return end
        turns.nextTurn()
    end)

    hook.add("PlayerSay", "StartGame", function(ply, text)
        if ply == owner() and text == "!start" then
            turns.start()
        end
    end)
else
    function turns.gameStarted()
        if !turns.getLocalPlayerParticipant() then return end
        printMessage(3, "Game started")
    end

    function turns.turnChanged(oldTurn, newTurn)
        local old = oldTurn:getPlayer()
        local new = newTurn:getPlayer()
        if !old or !new then return end
        printMessage(3, string.format("%s gave turn to %s", old:getName(), new:getName()))
    end
end
