---@name Turns lib
---@author AstricUnion
---@shared

local Ply = CLIENT and player() or nil

---Class to manipulate games with turns
---@class turns
---@field participants table<number, Participant> Initialized participants
---@field participantsSorted Participant[] Sorted participants
---@field ent Entity
---@field minPlayers number How many players game requires. By default 2
---@field timeout number Timeout for participant, in seconds. By default 60
---@field private partDataToUpdate table<number, table<string, any>> [SERVER] Participants to update data
---@field private partDataHandles boolean [SERVER] Is participant data handles now
---@field data table<string, any> Game data
---@field private dataHandles boolean [SERVER] Is data handles now
---@field currentTurn number? Current turn with sorted ID. Nil if game not started
---@field turnDirection number Turn direction. Can be 1 (clock-wise) or -1 (counter-clock-wise), but addicted to chair position
---@field isStarted boolean Is game started
local turns = {}
turns.participants = {}
turns.participantsSorted = {}
turns.ent = chip()
turns.minPlayers = 2
turns.timeout = 60
turns.partDataToUpdate = {}
turns.partDataHandles = false
turns.data = {}
turns.dataHandles = false
turns.currentTurn = nil
turns.turnDirection = 1
turns.isStarted = false


---------- Participant class ----------

---Game participant. This is a networked chair. Don't use it separatly from Game
---@class Participant
---@field ent Vehicle Entity of chair
---@field entId number Entity index, to network
---@field sortedId number Sorted index, for participantsSorted
---@field timeout number When participant timeouts
---@field data table<string, any> Data of the chair. Will be networked at all clients
---@field initialData table<string, any> Initial data of the chair
local Participant = {}
Participant.__index = Participant
function Participant:__tostring()
    return string.format("Participant[%s]", self.entId)
end

function Participant:__eq(obj)
    return self.entId == obj.entId
end


if SERVER then
    ---[SERVER] Create new participant for game
    ---@param offset Vector Offset of chair
    ---@param angs Angle Angles of chair
    ---@param model string Model of chair
    ---@param initialData table<string, any> Initial data for this participant
    function turns.addParticipant(offset, angs, model, initialData)
        local ent = prop.createSeat(turns.ent:localToWorld(offset), turns.ent:localToWorldAngles(angs), model)
        ent:setParent(turns.ent)
        local entId = ent:entIndex()
        local sortedId = #turns.participantsSorted+1
        local obj = setmetatable({ ent = ent, entId = entId, sortedId = sortedId, data = table.copy(initialData), initialData = initialData }, Participant)
        net.start("TurnsInitializeParticipants")
            net.writeTable({obj})
        net.send(find.allPlayers())
        turns.participants[entId] = obj
        turns.participantsSorted[sortedId] = obj
    end

    -- this code is 100% not from bmodentity lib

    ---[SERVER] Set some data for participant
    ---@param key string
    ---@param value any
    function Participant:setData(key, value)
        if !istable(value) and self.data[key] == value then return end
        self.data[key] = value
        local toUpdate = turns.partDataToUpdate[self.entId] or {}
        toUpdate[key] = value ~= nil and value or false
        turns.partDataToUpdate[self.entId] = toUpdate
        local sendChanges = function()
            if table.isEmpty(turns.partDataToUpdate) then return true end
            net.start("TurnsUpdateParticipantData")
                net.writeTable(turns.partDataToUpdate)
            net.send(find.allPlayers())
            turns.partDataToUpdate = {}
            return true
        end
        if !turns.partDataHandles then
            turns.partDataHandles = true
            timer.simple(0, function()
                if sendChanges() then
                    turns.partDataHandles = false
                end
            end)
        end
    end

    ---[SERVER] Set data for game
    ---@param key string
    ---@param value any
    function turns.setData(key, value)
        if !istable(value) and turns.data[key] == value then return end
        turns.data[key] = value
        local sendChanges = function()
            net.start("TurnsUpdateData")
                net.writeTable(turns.data)
            net.send(find.allPlayers())
            return true
        end
        if !turns.dataHandles then
            turns.dataHandles = true
            timer.simple(0, function()
                if sendChanges() then
                    turns.dataHandles = false
                end
            end)
        end
    end

    ---[SERVER] Get data from game
    ---@param key string
    ---@return any value
    function turns.getData(key)
        return turns.data[key]
    end

    ---[SERVER] Reset participant data
    function Participant:reset()
        self.data = table.copy(self.initialData)
    end

    hook.add("ClientInitialized", "TurnsInitialize", function(ply)
        if !table.isEmpty(turns.participants) then
            local toInit = {}
            for _, v in pairs(turns.participants) do
                toInit[#toInit+1] = v
            end
            net.start("TurnsInitializeParticipants")
                net.writeTable(toInit)
            net.send(ply)
        end
        if !table.isEmpty(turns.data) then
            net.start("TurnsUpdateData")
                net.writeTable(turns.data)
            net.send(ply)
        end
    end)
else
    local toInit = {}

    local cor = coroutine.wrap(function()
        while true do
            coroutine.yield()
            local newToInit = {}
            for i, v in ipairs(toInit) do
                ---@cast v Participant
                newToInit[i] = v
                local data = v.data
                local ent = entity(v.entId)
                if !isValid(ent) then goto cont end
                local obj = setmetatable({ ent = ent, entId = v.entId, sortedId = v.sortedId, data = data }, Participant)
                turns.participants[ent:entIndex()] = obj
                turns.participantsSorted[v.sortedId] = obj
                newToInit[i] = nil
                ::cont::
            end
            toInit = newToInit
        end
    end)

    hook.add("Think", "TurnsInitializeParticipants", function()
        if next(toInit) == nil then return end
        cor()
    end)

    net.receive("TurnsInitializeParticipants", function()
        toInit = table.add(toInit, net.readTable())
    end)

    net.receive("TurnsUpdateParticipantData", function()
        local toUpdate = net.readTable()
        for entId, data in pairs(toUpdate) do
            local part = turns.participants[entId]
            local oldData = table.copy(part.data)
            if !part then return end
            for key, value in pairs(data) do
                part.data[key] = value
            end
            turns.participantDataChanged(part, oldData, part.data, Ply == part:getPlayer())
        end
    end)

    net.receive("TurnsUpdateData", function()
        local data = net.readTable()
        turns.dataChanged(turns.data, data)
        turns.data = data
    end)
end

---[SHARED] Get participant player
---@return Player? ply
function Participant:getPlayer()
    local dr = self.ent:getDriver()
    return isValid(dr) and dr or nil
end

---[SHARED] Get participant timeout.
---@return number? timeout
function Participant:getTimeoutRemaining()
    local diff = self.timeout and self.timeout - timer.curtime() or 0
    return diff > 0 and diff or nil
end

---[SHARED] Get participant data.
---@param key string
---@return any value
function Participant:getData(key)
    return self.data[key]
end


---------- Game hooks ----------

---[SHARED] Hook on game start
---@param participant Participant Current turn
function turns.gameStarted(participant) end

---[SHARED] Hook on game stop
function turns.gameStopped() end

---[SHARED] Some player becomes participant
---@param ply Player Player, that became participant
---@param participant Participant Participant
function turns.newParticipant(ply, participant) end

---[SHARED] Participant left
---@param ply Player Player, that left game
---@param participant Participant Participant
function turns.participantLeft(ply, participant) end

---[SHARED] Participant timeout
---@param participant Participant Participant
function turns.participantTimedOut(participant) end

---[SHARED] Participant turn changed
---@param oldTurn Participant
---@param newTurn Participant
function turns.turnChanged(oldTurn, newTurn) end


if SERVER then
    ---[SERVER] When player became participant
    hook.add("PlayerEnteredVehicle", "TurnsParticipantEnter", function(ply, veh)
        local entId = veh:entIndex()
        local part = turns.participants[entId]
        if !part then return end
        net.start("TurnsNewParticipantPlayer")
            net.writeUInt(part.sortedId, 8)
            net.writeEntity(ply)
        net.send(find.allPlayers())
        turns.newParticipant(ply, part)
    end)

    ---[SERVER] When player left game
    hook.add("PlayerLeaveVehicle", "TurnsParticipantLeft", function(ply, veh)
        local entId = veh:entIndex()
        local part = turns.participants[entId]
        if !part then return end
        net.start("TurnsParticipantPlayerLeft")
            net.writeUInt(part.sortedId, 8)
            net.writeEntity(ply)
        net.send(find.allPlayers())
        if turns.isStarted then
            part.timeout = timer.curtime() + turns.timeout
        end
        turns.participantLeft(ply, part)
    end)
else
    ---[CLIENT] Participant data changed
    ---@param part Participant Participant with data change
    ---@param oldData table<string, any> Old data
    ---@param newData table<string, any> New data
    ---@param isLocalPlayer boolean Is participant local player
    function turns.participantDataChanged(part, oldData, newData, isLocalPlayer) end

    ---[CLIENT] Game data changed
    ---@param oldData table<string, any> Old data
    ---@param newData table<string, any> New data
    function turns.dataChanged(oldData, newData) end

    net.receive("TurnsNewParticipantPlayer", function()
        local partId = net.readUInt(8)
        net.readEntity(function(ply)
            local part = turns.participantsSorted[partId]
            if !part then return end
            turns.newParticipant(ply, part)
        end)
    end)

    net.receive("TurnsParticipantPlayerLeft", function()
        local partId = net.readUInt(8)
        net.readEntity(function(ply)
            local part = turns.participantsSorted[partId]
            if !part then return end
            part.timeout = timer.curtime() + turns.timeout
            turns.participantLeft(ply, part)
        end)
    end)
end

hook.add("Think", "TurnsParticipantTimeout", function()
    if !turns.isStarted then return end
    for _, v in ipairs(turns.participantsSorted) do
        if !v.timeout or timer.curtime() < v.timeout then goto cont end
        turns.participantTimedOut(v)
        v.timeout = nil
        ::cont::
    end
end)


---------- Game functions ----------

---[SHARED] Get participant from player
---@param ply Player
---@return Participant? participant
function turns.getParticipant(ply)
    local veh = ply:getVehicle()
    if !isValid(veh) then return end
    return turns.participants[veh:entIndex()]
end

---[SHARED] Get active participants of this game
---@return Participant[]
function turns.getActiveParticipants()
    local active = {}
    for _, v in ipairs(turns.participantsSorted) do
        if v:getPlayer() then active[#active+1] = v end
    end
    return active
end

---[SHARED] Get current turn
---@return Participant? participant Participant. Can be nil, if game not started
function turns.getTurn()
    if !turns.isStarted then return end
    return turns.participantsSorted[turns.currentTurn]
end

-- from SpaceMapSF
---Cycle value
---@param num number
---@param min number
---@param max number
---@return number cycledNum
local function cycle(num, min, max)
    while num < min or num > max do
        if num < min then
            num = max - (min - num)
        elseif num > max then
            num = min + (num - max)
        end
    end
    return num
end


---[SHARED] Get participant by local id (when 4, 1 will be left, 2 will be forward, 3 will be right, 0 is you)
---@param part Participant Participant
---@param localId number Local ID
---@return Participant
function turns.getLocalParticipant(part, localId)
    local sorted = turns.participantsSorted
    local id = cycle(part.sortedId + localId, 0, #sorted)
    local found = sorted[id]
    return found
end


---[SHARED] Get local id of participant
---@param part Participant Participant
---@param part2 Participant Participant to found ID
---@return number
function turns.getParticipantLocalId(part, part2)
    local sorted = turns.participantsSorted
    local diff = part2.sortedId - part.sortedId
    return cycle(diff, 0, #sorted)
end


if SERVER then
    ---[SERVER] Start game
    function turns.start()
        if turns.isStarted then return end
        local parts = turns.getActiveParticipants()
        local count = #parts
        if count < turns.minPlayers then return end
        local participant = parts[math.random(1, count)]
        net.start("TurnsGameStarted")
            net.writeUInt(participant.sortedId, 8)
        net.send(find.allPlayers())
        turns.isStarted = true
        turns.currentTurn = participant.sortedId
        turns.gameStarted(participant)
    end

    ---[SERVER] Stop game
    function turns.stop()
        if !turns.isStarted then return end
        net.start("TurnsGameStopped")
        net.send(find.allPlayers())
        turns.gameStopped()
        turns.isStarted = false
        turns.currentTurn = nil
        for _, v in ipairs(turns.participantsSorted) do
            v:reset()
        end
    end

    ---[SERVER] Change turn to next participant
    ---@return Participant? newTurn Participant, that received turn or nil, if game stopped
    function turns.nextTurn()
        if !turns.isStarted then
            throw("Game is not started!")
            return
        end
        local partCount = #turns.participantsSorted
        local loopedIndex = turns.currentTurn
        local dir = turns.turnDirection
        for _=1, partCount, dir do
            loopedIndex = loopedIndex + dir
            if dir * loopedIndex > dir * partCount then
                loopedIndex = dir == 1 and 1 or partCount
            end
            local part = turns.participantsSorted[loopedIndex]
            if part:getPlayer() then
                turns.turnChanged(turns.participantsSorted[turns.currentTurn], part)
                turns.currentTurn = loopedIndex
                net.start("TurnsTurnChanged")
                    net.writeUInt(loopedIndex, 8)
                net.send(find.allPlayers())
                return part
            end
        end
        turns.stop()
    end

    ---[SERVER] Turn again
    function turns.turnAgain()
        if !turns.isStarted then
            throw("Game is not started!")
            return
        end
        net.start("TurnsTurnChanged")
            net.writeUInt(turns.currentTurn, 8)
        net.send(find.allPlayers())
        turns.turnChanged(turns.participantsSorted[turns.currentTurn], turns.participantsSorted[turns.currentTurn])
    end
else
    ---[CLIENT] Get participant of local player
    function turns.getLocalPlayerParticipant()
        return turns.getParticipant(Ply)
    end

    net.receive("TurnsGameStarted", function()
        turns.isStarted = true
        local partId = net.readUInt(8)
        local part = turns.participantsSorted[partId]
        if !part then return end
        turns.currentTurn = part.sortedId
        turns.gameStarted(part)
    end)

    net.receive("TurnsGameStopped", function()
        turns.gameStopped()
        turns.isStarted = false
        turns.currentTurn = nil
    end)

    net.receive("TurnsTurnChanged", function()
        local partId = net.readUInt(8)
        local newTurn = turns.participantsSorted[partId]
        local oldTurn = turns.participantsSorted[turns.currentTurn]
        turns.turnChanged(oldTurn, newTurn)
        turns.currentTurn = partId
    end)
end


return turns
