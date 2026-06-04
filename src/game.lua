---@class items
local items = items

---@class BuckshotRouletteInteractive: interactive
local interactive = interactive

---@class BuckshotRoulette: turns
local turns = turns
turns.timeout = 5
turns.minPlayers = 1


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
    ---Interround time (displays)
    Interround = 3
}

---@enum CAMERA
local CAMERA = CLIENT and {
    Default = camera.preset(Vector(0, 10, 60), Angle(10, 90, 0), 90),
    AtTable = camera.preset(Vector(0, 12, 55), Angle(50, 90, 0), 90),
    AtScreen = camera.preset(Vector(0, 20, 40), Angle(60, 90, 0), 90),
    AtBox = camera.preset(Vector(0, 14, 52), Angle(55, 90, 0), 90),
    AtShotgun = camera.preset(Vector(0, 42, 48), Angle(60, 120, 0), 90)
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
        itemInHand = nil, -- Item in hand, can be an item from box or from table
        state = STATE.Idle -- State of player, yeah
    }
    local chairDist = 50
    local chairModel = "models/nova/chair_wood01.mdl"
    turns.addParticipant(Vector(chairDist, 0, 0), Angle(0, 90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, -chairDist, 0), Angle(0, 0, 0), chairModel, initialData)
    turns.addParticipant(Vector(-chairDist, 0, 0), Angle(0, -90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, chairDist, 0), Angle(0, 180, 0), chairModel, initialData)

    turns.setData("gameStep", STEP.NoGame)
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
    for i, v in ipairs(slots) do
        interactive.addArea("slot" .. i, unpack(v))
    end
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
    for _, v in ipairs(turns.participantsSorted) do
        if !v:getPlayer() then
            v.ent:lock()
            goto cont
        end
        v:setData("state", STATE.Box)
        v:setData("itemsToTook", {"beer", "beer", "beer"})
        ::cont::
    end
    turns.setData("gameStep", STEP.Items)
end

if SERVER then
    local shotgunHolo = hologram.create(chip():getPos() + Vector(0, 0, 32), chip():getAngles() + Angle(0, 0, 90), "models/weapons/w_annabelle.mdl")
    if !shotgunHolo then return end
    shotgunHolo:setParent(chip())

    hook.add("PlayerSay", "StartGame", function(ply, text)
        if ply == owner() and text == "!start" then
            turns.start()
        end
    end)

    ---On area input, like taking item
    function interactive.onInput(ply, area)
        local part = turns.getParticipant(ply)
        if !part then return end
        local state = part:getData("state")
        local inHand = part:getData("itemInHand")
        if state == STATE.Box then
            local toTook = part:getData("itemsToTook")
            -- If player tried to take something from box and doesn't have item in his hands
            if area == "box" and !inHand then
                local tookId = #toTook
                local class = toTook[tookId]
                toTook[tookId] = nil
                part:setData(toTook)
                local item = items.new(part.ent, class)
                part:setData("itemInHand", item.id)
                return
            end

            if string.startsWith(area, "slot") and inHand then
                local slotStr = string.gsub(area, "slot", "")
                local slot = tonumber(slotStr)
                ---@cast slot number
                local slots = part:getData("items")
                if slots[slot] then return end
                slots[slot] = inHand
                part:setData("itemInHand", nil)
                part:setData("items", slots)
                if next(toTook) == nil then
                    part:setData("state", STATE.Idle)
                    local activeParts = turns.getActiveParticipants()
                    for _, activePart in ipairs(activeParts) do
                        if activePart:getData("state") == STATE.Box then
                            return
                        end
                    end
                    turns.setData("gameStep", STEP.Shotgun)
                    timer.simple(5, function()
                        turns.setData("gameStep", STEP.Gameplay)
                    end)
                end
                return
            end
            return
        end
    end
else
    function turns.participantDataChanged(part, oldData, newData, isLocal)
        if oldData.state == STATE.Idle and newData.state == STATE.Box then
            if isLocal then
                CAMERA.AtBox()
                interactive.enableGroup("slots", true)
                interactive.enable("box", true)
                -- todo: hook to enable cursor persistent
                input.enableCursor(true)
            end
        end
        if oldData.state == STATE.Box and oldData.itemInHand and !newData.itemInHand then
            for slot, itemId in pairs(newData.items) do
                if itemId ~= oldData.itemInHand then goto cont end
                local item = items.inited[itemId]
                if !item then goto cont end
                item:moveToSlot(slot)
                ::cont::
            end
            if newData.state == STATE.Idle and isLocal then
                CAMERA.AtTable()
                interactive.enableGroup("slots", false)
                interactive.enable("box", false)
                input.enableCursor(false)
            end
        end
    end

    function turns.dataChanged(old, new)
        if old.gameStep == STEP.Items and new.gameStep == STEP.Shotgun then
            CAMERA.AtShotgun()
            return
        end
        if old.gameStep == STEP.Shotgun and new.gameStep == STEP.Gameplay then
            local part = turns.getLocalPlayerParticipant()
            if turns.getTurn() == part then
                CAMERA.AtTable()
            else
                CAMERA.Default()
            end
            return
        end
    end
end
