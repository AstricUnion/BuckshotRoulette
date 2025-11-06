--@name Turns (lib for board games on Starfall)
--@author AstricUnion
--@shared


if SERVER then
    -- Participant - just seat with data
    -- Player - active participant

    ---@class Participant
    ---@field seat Vehicle
    ---@field data table
    Participant = {}
    Participant.__index = Participant

    ---Wrap seat in Participant, to use as player
    ---@param seat Vehicle
    ---@param data? table Default {}
    ---@return Participant
    function Participant:new(seat, data)
        -- Hooks block
        do
            local id = seat:entIndex()

            hook.add("PlayerLeaveVehicle", "ParticipantLeave" .. id, function(ply, veh)
                if seat ~= veh then return end
                enableHud(ply, false)
            end)

            hook.add("PlayerEnteredVehicle", "ParticipantEnter" .. id, function(ply, veh)
                if seat ~= veh then return end
                enableHud(ply, true)
            end)
        end
        return setmetatable({
            seat = seat,
            data = data or {}
        }, Participant)
    end

    ---Replace participant data
    ---@param data table
    function Participant:setData(data)
        self.data = data
    end

    ---Update only some data
    ---@param newData table
    function Participant:updateData(newData)
        for key, value in pairs(newData) do
            self.data[key] = value
        end
    end

    ---Get participant data
    ---@return table
    function Participant:getData()
        return self.data
    end

    ---Get participant player
    ---@return Player
    function Participant:getPlayer()
        return self.seat:getDriver()
    end

    setmetatable(Participant, {__call = Participant.new})



    ---@class Game
    ---@field minPlayers number
    ---@field turn number
    ---@field turnDirection number
    ---@field started boolean
    ---@field participants table[Participant]
    ---@field initialData table
    Game = {}
    Game.__index = Game


    ---Create new game
    ---@param seats table[Vehicle]
    ---@param initialData? table Default {}
    ---@param minPlayers? number Default 2
    ---@return Game
    function Game:new(seats, initialData, minPlayers)
        initialData = initialData or {}
        local participants = {}
        for _, seat in ipairs(seats) do
            table.insert(participants, Participant(seat, initialData))
        end
        return setmetatable({
            minPlayers = minPlayers or 2,
            turn = nil,
            turnDirection = 1,
            started = false,
            participants = participants,
            initialData = initialData
        }, Game)
    end


    ---Get all participants
    ---@return table[Participant]
    function Game:getParticipants()
        return self.participants
    end


    ---Get players in participants
    ---@return number count, table players
    function Game:getPlayers()
        -- Why two variables? Because optimization.
        -- Operator # iterates table again
        local participantsCount = 0
        local participantsPlayers = {}
        for _, part in ipairs(self.participants) do
            local ply = part:getPlayer()
            if isValid(ply) then
                participantsCount = participantsCount + 1
                table.insert(participantsPlayers, ply)
            end
        end
        return participantsCount, participantsPlayers
    end


    ---Is game already started
    ---@return boolean isStarted
    function Game:isStarted()
        return self.started
    end


    ---Start game
    ---@return boolean isStarted Is game successfully started
    function Game:start()
        local participantsCount = 0
        local participantsPlayers = {}
        local activeParticipants = {}
        for _, part in ipairs(self.participants) do
            local ply = part:getPlayer()
            if isValid(ply) then
                participantsCount = participantsCount + 1
                table.insert(participantsPlayers, ply)
                table.insert(activeParticipants, part)
            end
        end
        if participantsCount < self.minPlayers then
            return false
        end
        local randomValue, _ = table.random(activeParticipants)
        self.turn = table.keyFromValue(self.participants, randomValue)
        timer.simple(0.1, function()
            hook.run("GameStarted", activeParticipants, participantsCount, participantsPlayers)
        end)
        self.started = true
        return true
    end


    ---Stop game
    ---@return boolean isStopped Is game successfully stopped
    function Game:stop()
        for _, participant in ipairs(self.participants) do
            participant.seat:unlock()
            participant.seat:ejectDriver()
            participant:setData(self.initialData)
        end
        self.started = false
        return true
    end


    ---Switch to next turn
    ---@return Participant? participant Participant on next turn, or nil if no active participants
    function Game:next()
        local participant = nil
        local firstTurn = self.turn
        while !isValid(participant) do
            self.turn = self.turn + self.turnDirection
            if self.turn > #self.participants then
                self.turn = 1
            end
            participant = self.participants[self.turn]
            if isValid(participant:getPlayer()) then
                break
            else
                if self.turn == firstTurn then
                    return
                end
            end
        end
        return participant
    end


    ---Get turn
    ---@return Participant turn
    function Game:getTurn()
        return self.participants[self.turn]
    end


    ---Set turn direction
    ---@param direction number
    function Game:setTurnDirection(direction)
        self.turnDirection = direction
    end


    setmetatable(Game, {__call = Game.new})
end

