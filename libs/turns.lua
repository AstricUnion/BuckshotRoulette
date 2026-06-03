---@name Turns lib
---@author AstricUnion
---@shared

---Class to manipulate games with turns
---@class turns
---@field participants table<number, Participant> Initialized participants
---@field participantsSorted Participant[] Sorted participants
---@field ent Entity
---@field minPlayers number How many players game requires. By default 2
---@field timeout number Timeout for participant, in seconds. By default 60
---@field dataToUpdate table<number, table<string, any>> [SERVER] Participants to update data
---@field dataHandles boolean [SERVER] Is data handles now
---@field currentTurn number? Current turn with sorted ID. Nil if game not started
---@field isStarted boolean Is game started
local turns = {}
turns.participants = {}
turns.participantsSorted = {}
turns.ent = chip()
turns.minPlayers = 2
turns.timeout = 60
turns.dataToUpdate = {}
turns.dataHandles = false
turns.currentTurn = nil
turns.isStarted = false


---------- Participant class ----------

---Game participant. This is a networked chair. Don't use it separatly from Game
---@class Participant
---@field ent Vehicle Entity of chair
---@field entId number Entity index, to network
---@field sortedId number Sorted index, for participantsSorted
---@field timeout number When participant timeouts
---@field data table<string, any> Data of the chair. Will be networked at all clients
local Participant = {}
Participant.__index = Participant


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
        local obj = setmetatable({ ent = ent, entId = entId, sortedId = sortedId, data = initialData }, Participant)
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
        local toUpdate = turns.dataToUpdate[self.entId] or {}
        toUpdate[key] = value
        turns.dataToUpdate[self.entId] = toUpdate
        local sendChanges = function()
            if table.isEmpty(turns.dataToUpdate) then return false end
            net.start("TurnsUpdateParticipantData")
                net.writeTable(turns.dataToUpdate)
            net.send(find.allPlayers())
            turns.dataToUpdate = {}
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


    hook.add("ClientInitialized", "TurnsInitialize", function(ply)
        if table.isEmpty(turns.participants) then return end
        local toInit = {}
        for _, v in pairs(turns.participants) do
            toInit[#toInit+1] = v
        end
        net.start("TurnsInitializeParticipants")
            net.writeTable(toInit)
        net.send(ply)
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
            if !part then return end
            for key, value in pairs(data) do
                part.data[key] = value
            end
        end
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


---------- Game hooks ----------

---[SHARED] Hook on game start
---@param participant Participant Current turn
function turns.gameStarted(participant) end

---[SHARED] Some player becomes participant
---@param ply Player Player, that became participant
---@param participant Participant Participant
function turns.newParticipant(ply, participant) end

---[SHARED] Participant left
---@param ply Player Player, that left game
---@param participant Participant Participant
function turns.participantLeft(ply, participant) end


if SERVER then
    ---[SERVER] When player became participant
    hook.add("PlayerEnteredVehicle", "TurnsParticipantEnter", function(ply, veh)
        local entId = veh:entIndex()
        local part = turns.participants[entId]
        if !part then return end
        enableHud(ply, true)
        net.start("TurnsNewParticipantPlayer")
            net.writeUInt(entId, 32)
            net.writeEntity(ply)
        net.send(find.allPlayers())
        turns.newParticipant(ply, part)
    end)

    ---[SERVER] When player left game
    hook.add("PlayerLeaveVehicle", "TurnsParticipantLeft", function(ply, veh)
        local entId = veh:entIndex()
        local part = turns.participants[entId]
        if !part then return end
        enableHud(ply, false)
        net.start("TurnsParticipantPlayerLeft")
            net.writeUInt(entId, 32)
            net.writeEntity(ply)
        net.send(find.allPlayers())
        part.timeout = timer.curtime() + turns.timeout
        turns.participantLeft(ply, part)
    end)
else
    net.receive("TurnsNewParticipantPlayer", function()
        local partId = net.readUInt(32)
        net.readEntity(function(ply)
            local part = turns.participants[partId]
            if !part then return end
            turns.newParticipant(ply, part)
        end)
    end)

    net.receive("TurnsParticipantPlayerLeft", function()
        local partId = net.readUInt(32)
        net.readEntity(function(ply)
            local part = turns.participants[partId]
            if !part then return end
            part.timeout = timer.curtime() + turns.timeout
            turns.participantLeft(ply, part)
        end)
    end)
end


---------- Game functions ----------

---[SHARED] Get active participants of this game
---@return Participant[]
function turns.getActiveParticipants()
    local active = {}
    for _, v in ipairs(turns.participantsSorted) do
        if v:getPlayer() then active[#active+1] = v end
    end
    return active
end

if SERVER then
    ---[SERVER] Start game
    function turns.start()
        local parts = turns.getActiveParticipants()
        local count = #parts
        if count < turns.minPlayers then return end
        local participant = parts[math.random(1, count)]
        net.start("TurnsGameStarted")
            net.writeUInt(participant.sortedId, 8)
        net.send(find.allPlayers())
        turns.gameStarted(participant)
    end
else
    net.receive("TurnsGameStarted", function()
        turns.isStarted = true
        local partId = net.readUInt(8)
        local part = turns.participantsSorted[partId]
        if !part then return end
        turns.gameStarted(part)
    end)
end



return turns
