---@class items
local items = items

---@class BuckshotRouletteInteractive: interactive
local interactive = interactive

---@class BuckshotRoulette: turns
local turns = turns
turns.timeout = 5
turns.minPlayers = 1


---@class Beer: Item
local Beer = {}
Beer.Identifier = "beer"
Beer.Model = "models/props_junk/popcan01a.mdl"

function Beer:onUse()
    if SERVER then
        local shells = turns.getData("shells")
        local lastShell = table.remove(shells)
        if shells[#shells] == nil then
            turns.startItems()
        end
        turns.setData("shells", shells)
    else
        local shells = turns.getData("shells")
        if turns.getLocalPlayerParticipant() then
            printHud("Shell drawed, it's " .. (shells[#shells] and "live" or "blank"))
        end
        self.model:remove()
    end
end

items.register(Beer)


---@enum STATE
local STATE = {
    ---Player have no health on round
    Death = -1,
    ---Player do nothing
    Idle = 0,
    ---Player unpacking box
    Box = 1,
    ---Player got shotgun in hands
    WithShotgun = 2,
    ---Player shoots other player or himself 
    Shoot = 3,
    ---Player using adrenaline
    Adrenaline = 4,
    ---Player using jammer
    Jammer = 5,
}

---@enum STEP
local STEP = {
    ---Default step, before game
    NoGame = -1,
    ---Players take items from boxes
    Items = 0,
    ---Shotgun demostration with shells
    Shotgun = 1,
    ---Participants plays game
    Gameplay = 2,
}

---@enum CAMERA
local CAMERA = CLIENT and {
    Default = camera.preset(Vector(0, 10, 60), Angle(10, 90, 0), 100),
    AtTable = camera.preset(Vector(0, 12, 55), Angle(50, 90, 0), 90),
    AtScreen = camera.preset(Vector(0, 20, 40), Angle(60, 90, 0), 90),
    AtBox = camera.preset(Vector(0, 14, 52), Angle(55, 90, 0), 90),
    AtShotgun = camera.preset(Vector(0, 42, 48), Angle(60, 120, 0), 90),

    AtPlayer0 = camera.preset(Vector(0, 10, 60), Angle(30, 90, 0), 90),
    AtPlayer1 = camera.preset(Vector(0, 10, 60), Angle(10, 120, 0), 90),
    AtPlayer2 = camera.preset(Vector(0, 10, 60), Angle(10, 90, 0), 90),
    AtPlayer3 = camera.preset(Vector(0, 10, 60), Angle(10, 60, 0), 90),
} or {}

---@enum SHOTGUN
local SHOTGUN = CLIENT and {
    InHands = {Vector(0, 24, 38), Angle(30, 0, 0)},
    OnTable = {Vector(0, 50, 32), Angle(0, -90, 90)},
    AtPlayer0 = {Vector(0, 30, 30), Angle(90, 90, 0)},
    AtPlayer1 = {Vector(-18, 30, 45), Angle(10, -30, 0)},
    AtPlayer2 = {Vector(10, 36, 45), Angle(10, -90, 0)},
    AtPlayer3 = {Vector(18, 30, 45), Angle(10, -150, 0)},
} or {}

if SERVER then
    local tableHolo = hologram.create(chip():getPos() + Vector(0, 0, 29), chip():getAngles(), "models/holograms/plane.mdl", Vector(6, 6, 6))
    if !tableHolo then return end
    tableHolo:setColor(Color(20, 125, 25))
    tableHolo:setParent(chip())

    local initialData = {
        itemsToTook = {}, -- Items to pickup, server generates it
        items = {}, -- Maximum 8 items
        health = 6, -- Player health, maximum 6
        isJammed = false, -- Is player jammed by other player
        state = STATE.Idle -- State of player, yeah
    }
    local chairDist = 50
    local chairModel = "models/nova/chair_wood01.mdl"
    turns.addParticipant(Vector(chairDist, 0, 0), Angle(0, 90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, -chairDist, 0), Angle(0, 0, 0), chairModel, initialData)
    turns.addParticipant(Vector(-chairDist, 0, 0), Angle(0, -90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, chairDist, 0), Angle(0, 180, 0), chairModel, initialData)

    turns.setData("gameStep", STEP.NoGame)
    turns.setData("shells", {})
else
    -- Add interactive areas
    local width, height = 0.1, 0.2
    local firstRow, secondRow = 0.4, 0.65
    local group = "slots"
    local slots = {
        {0.18, firstRow, width, height, group},
        {0.13, secondRow, width, height, group},
        {0.3, firstRow, width, height, group},
        {0.25, secondRow, width, height, group},
    }
    -- To mirror slots
    for i=1, #slots do
        local slot = slots[i]
        slots[4 + i] = {1 - slot[1] - width, slot[2], width, height, group}
    end

    interactive.addArea("box", 0.4, 0.6, 0.2, 0.3)
    interactive.addArea("shotgun", 0.4, 0, 0.2, 0.4)
    for i, v in ipairs(slots) do
        interactive.addArea("slot" .. i, unpack(v))
    end
    interactive.addArea("player0", 0.3, 0.8, 0.4, 0.2, "players") -- Self
    interactive.addArea("player1", 0, 0.2, 0.2, 0.6, "players") -- Left
    interactive.addArea("player2", 0.4, 0.25, 0.2, 0.4, "players") -- Forward
    interactive.addArea("player3", 0.8, 0.2, 0.2, 0.6, "players") -- Right
    interactive.enableDraw(true)
end

function turns.newParticipant(ply, part)
    if SERVER then
        enableHud(ply, true)
        return
    end
    if ply ~= player() then return end
    camera.setParent(part.ent)
    CAMERA.Default(1)
    camera.enable(true)
end

function turns.participantLeft(ply)
    if SERVER then
        enableHud(ply, false)
        return
    end
    camera.enable(false)
end

function turns.gameStarted()
    if CLIENT then
        local part = turns.getLocalPlayerParticipant()
        if !part then return end
        printMessage(3, "Game started")
        return
    end
end

if SERVER then
    hook.add("PlayerSay", "StartGame", function(ply, text)
        if ply == owner() and text == "!start" then
            turns.start()
        end
    end)

    -- Take boxes and start take items
    function turns.startItems()
        local parts = {}
        for _, v in ipairs(turns.participantsSorted) do
            if v:getData("health") == 0 then goto cont end
            v:setData("state", STATE.Box)
            v:setData("itemsToTook", {"beer"})
            parts[v.sortedId] = true
            ::cont::
        end
        turns.setData("gameStep", STEP.Items)
        turns.sendSignal("TakeBox", {
            participants = parts
        })
    end

    -- Start new sequence of shells
    local function tryToStartNewSequence()
        turns.setData("shells", {true, false, true})
        local activeParts = turns.getActiveParticipants()
        for _, activePart in ipairs(activeParts) do
            local state = activePart:getData("state")
            local health = activePart:getData("health")
            if state == STATE.Box or (state == STATE.Death and health > 0) then
                return
            end
        end
        turns.setData("gameStep", STEP.Shotgun)
        timer.simple(2, function()
            turns.setData("gameStep", STEP.Gameplay)
        end)
    end

    function turns.gameStarted()
        turns.startItems()
    end

    local inputByState = {
        [STATE.Box] = function(part, area, data)
            -- If player tried to take something from box
            if area == "box" and !data.inHand then
                local class = table.remove(data.itemsToTook)
                if !class then return end
                local item = items.new(part.ent, class)
                part:setData("itemsToTook", data.itemsToTook)
                part:setData("itemInHand", item.id)
                return
            end

            -- If player tried to put item
            if string.startsWith(area, "slot") and data.itemInHand then
                local slot = tonumber(string.replace(area, "slot", ""))  -- Get slot area
                ---@cast slot number
                local slots = data.items
                if slots[slot] then return end
                slots[slot] = data.itemInHand
                local lastItem = false
                if next(data.itemsToTook) == nil then
                    part:setData("state", STATE.Idle)
                    tryToStartNewSequence()
                    lastItem = true
                end
                turns.sendSignal("MoveToSlot", {
                    itemId = data.itemInHand,
                    participantId = part.sortedId,
                    lastItem = lastItem,
                    slot = slot
                })
                part:setData("itemInHand", nil)
                part:setData("items", slots)
            end
        end,
        [STATE.Idle] = function(part, area, data)
            if turns.getTurn() ~= part then return end
            -- If player tried to use item
            if string.startsWith(area, "slot") then
                local slot = tonumber(string.replace(area, "slot", ""))  -- Get slot area
                ---@cast slot number
                local slots = data.items
                local itemId = slots[slot]
                if !itemId then return end
                slots[slot] = nil
                part:setData("items", slots)
                local item = items.inited[itemId]
                if !item then return end
                item:use()
            end
            if area == "shotgun" then
                part:setData("state", STATE.WithShotgun)
                turns.sendSignal("TakeShotgun", {participantId = part.sortedId})
            end
        end,
        [STATE.WithShotgun] = function(part, area, data)
            if string.startsWith(area, "player") then
                local partAdd = tonumber(string.replace(area, "player", ""))
                if !partAdd then return end
                local target = turns.getLocalParticipant(part, partAdd)
                if !target:getPlayer() then return end
                local shells = turns.getData("shells")
                turns.sendSignal("ShootAt", {participantId = part.sortedId, shootAt = partAdd})
                local lastShell = table.remove(shells)
                if lastShell then
                    timer.simple(1, function()
                        local health = target:getData("health") - 1
                        target:setData("state", STATE.Death)
                        target:setData("health", health)
                        if health > 0 then
                            timer.simple(1, function()
                                target:setData("state", turns.getData("gameStep") == STEP.Items and STATE.Box or STATE.Idle)
                            end)
                        end
                    end)
                end
                timer.simple(2, function()
                    if !lastShell and target == part then
                        turns.turnAgain()
                    else
                        turns.nextTurn()
                    end
                    part:setData("shootAt", nil)
                    part:setData("state", STATE.Idle)
                    if shells[#shells] == nil then
                        turns.startItems()
                    end
                end)
                turns.setData("shells", shells)
            end
        end
    }

    ---On area input, like taking item
    function interactive.onInput(ply, area)
        local part = turns.getParticipant(ply)
        if !part then return end
        local data = part.data
        inputByState[data.state](part, area, data)
    end

    function turns.participantTimedOut(part)
        part:setData("state", STATE.Idle)
        part:setData("itemInHand", nil)
        tryToStartNewSequence()
    end
else

    local shotgunHolo = hologram.create(chip():getPos() + Vector(0, 0, 32), chip():getAngles() + Angle(0, 0, 90), "models/weapons/w_annabelle.mdl")
    if !shotgunHolo then return end
    shotgunHolo:setParent(chip())

    -- Visually move item to slot
    turns.signal("MoveToSlot", function(data)
        items.inited[data.itemId]:moveToSlot(data.slot)
        local part = turns.getLocalPlayerParticipant()
        if !(data.lastItem and part.sortedId == data.participantId) then return end
        CAMERA.AtTable()
        interactive.enableGroup("slots", false)
        interactive.enable("box", false)
        input.enableCursor(false)
    end)

    -- Animation to take box
    turns.signal("TakeBox", function(data)
        local part = turns.getLocalPlayerParticipant()
        local function animation()
            if !data.participants[part.sortedId] then return end
            CAMERA.AtBox()
            interactive.enableGroup("slots", true)
            interactive.enable("box", true)
            -- todo: hook to enable cursor persistent
            input.enableCursor(true)
        end
        if part:getData("state") == STATE.Death then
            timer.simple(2, function()
                animation()
            end)
        else
            animation()
        end
    end)

    -- Animation to take shotgun
    turns.signal("TakeShotgun", function(data)
        local currentPart = turns.getLocalPlayerParticipant()
        if currentPart.sortedId == data.participantId then
            CAMERA.Default()
            interactive.enableGroup("players", true)
            interactive.enableGroup("slots", false)
            interactive.enable("shotgun", false)
        end
        local part = turns.participantsSorted[data.participantId]
        shotgunHolo:setPos(part.ent:localToWorld(SHOTGUN.InHands[1]))
        shotgunHolo:setAngles(part.ent:localToWorldAngles(SHOTGUN.InHands[2]))
    end)


    turns.signal("ShootAt", function(data)
        local currentPart = turns.getLocalPlayerParticipant()
        if data.participantId == currentPart.sortedId then
            CAMERA["AtPlayer" .. data.shootAt]()
            interactive.enableGroup("players", false)
        end
        local part = turns.participantsSorted[data.participantId]
        local shotgun = SHOTGUN["AtPlayer" .. data.shootAt]
        shotgunHolo:setPos(part.ent:localToWorld(shotgun[1]))
        shotgunHolo:setAngles(part.ent:localToWorldAngles(shotgun[2]))
    end)

    local function changeTurn(turn)
        local part = turns.getLocalPlayerParticipant()
        if turn == part then
            CAMERA.AtTable()
            interactive.enableGroup("slots", true)
            interactive.enable("shotgun", true)
            input.enableCursor(true)
        else
            local localId = turns.getParticipantLocalId(part, turn)
            CAMERA["AtPlayer" .. localId]()
        end
        shotgunHolo:setPos(turn.ent:localToWorld(SHOTGUN.OnTable[1]))
        shotgunHolo:setAngles(turn.ent:localToWorldAngles(SHOTGUN.OnTable[2]))
    end

    function turns.dataChanged(old, new)
        if old.gameStep == STEP.Items and new.gameStep == STEP.Shotgun then
            CAMERA.AtShotgun()
            return
        end
        if old.gameStep == STEP.Shotgun and new.gameStep == STEP.Gameplay then
            local turn = turns.getTurn()
            if !turn then return end
            changeTurn(turn)
            return
        end
    end

    function turns.turnChanged(old, new)
        changeTurn(new)
    end

    hook.add("PostDrawHUD", "deathEffect", function()
        local part = turns.getLocalPlayerParticipant()
        if !part then return end
        local sw, sh = render.getGameResolution()
        if part:getData("state") == STATE.Death then
            render.setColor(Color(0, 0, 0))
            render.drawRect(0, 0, sw, sh)
        end

        render.setFont("Trebuchet18")
        for i, v in ipairs(turns.getActiveParticipants()) do
            render.drawSimpleText(sw - 32, sh - (i * 18), string.format("%s: %s", v:getPlayer():getName(), v:getData("health")), TEXT_ALIGN.RIGHT, TEXT_ALIGN.BOTTOM)
        end
    end)
end
