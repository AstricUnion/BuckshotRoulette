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
    AtShotgun = camera.preset(Vector(0, 42, 48), Angle(60, 120, 0), 90),

    AtPlayer0 = camera.preset(Vector(0, 10, 60), Angle(30, 90, 0), 90),
    AtPlayer1 = camera.preset(Vector(0, 10, 60), Angle(10, 120, 0), 90),
    AtPlayer2 = camera.preset(Vector(0, 10, 60), Angle(10, 90, 0), 90),
    AtPlayer3 = camera.preset(Vector(0, 10, 60), Angle(10, 60, 0), 90),
} or {}

---@enum SHOTGUN
local SHOTGUN = CLIENT and {
    InHands = {Vector(0, 24, 38), Angle(30, 0, 0)},
    OnTable = {Vector(0, 50, 32), Angle(0, 0, 90)}
} or {}

if SERVER then
    local tableHolo = hologram.create(chip():getPos() + Vector(0, 0, 29), chip():getAngles(), "models/holograms/plane.mdl", Vector(6, 6, 6))
    if !tableHolo then return end
    tableHolo:setColor(Color(20, 125, 25))
    tableHolo:setParent(chip())

    local initialData = {
        itemsToTook = {}, -- Items to pickup, server generates it
        shootAt = nil, -- Current shoot at player
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
    for _, v in ipairs(turns.participantsSorted) do
        if !v:getPlayer() then
            v.ent:lock()
            goto cont
        end
        v:setData("state", STATE.Box)
        v:setData("itemsToTook", {"beer"})
        ::cont::
    end
    turns.setData("gameStep", STEP.Items)
    turns.setData("shells", {true, false, true, false, true})
end

if SERVER then
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

        if state == STATE.Idle then
            if area == "shotgun" then
                part:setData("state", STATE.WithShotgun)
            end
        end

        if state == STATE.WithShotgun then
            if string.startsWith(area, "player") then
                local partAddStr = string.gsub(area, "player", "")
                local partAdd = tonumber(partAddStr)
                if !partAdd then return end
                local target = turns.getLocalParticipant(part, partAdd)
                print(target:getPlayer())
                if !target:getPlayer() then return end
                local shells = turns.getData("shells")
                part:setData("shootAt", partAdd)
                local lastShellId = #shells
                local lastShell = shells[lastShellId]
                if lastShell then
                    timer.simple(1, function()
                        local health = target:getData("health") - 1
                        target:setData("state", STATE.Death)
                        print(target, health)
                        if health > 0 then
                            timer.simple(1, function()
                                target:setData("state", STATE.Idle)
                            end)
                        end
                        target:setData("health", health)
                    end)
                end
                timer.simple(2, function()
                    if (lastShell and target == part) or target ~= part then
                        turns.nextTurn()
                    else
                        turns.turnAgain()
                    end
                    part:setData("shootAt", nil)
                    part:setData("state", STATE.Idle)
                    if shells[#shells] == nil then
                        for _, v in ipairs(turns.participantsSorted) do
                            v:setData("state", STATE.Box)
                            v:setData("itemsToTook", {"beer"})
                        end
                        turns.setData("gameStep", STEP.Items)
                        turns.setData("shells", {false, true})
                    end
                end)
                shells[lastShellId] = nil
                turns.setData("shells", shells)
            end
        end
    end

else

    local shotgunHolo = hologram.create(chip():getPos() + Vector(0, 0, 32), chip():getAngles() + Angle(0, 0, 90), "models/weapons/w_annabelle.mdl")
    if !shotgunHolo then return end
    shotgunHolo:setParent(chip())

    function turns.participantDataChanged(part, oldData, newData, isLocal)
        if newData.state == STATE.Box then
            if isLocal then
                CAMERA.AtBox()
                interactive.enableGroup("slots", true)
                interactive.enable("box", true)
                -- todo: hook to enable cursor persistent
                input.enableCursor(true)
            end
            return
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
            return
        end
        if oldData.state == STATE.Idle and newData.state == STATE.WithShotgun then
            if isLocal then
                CAMERA.Default()
                interactive.enableGroup("players", true)
                interactive.enableGroup("slots", false)
                interactive.enable("shotgun", false)
            end
            shotgunHolo:setPos(part.ent:localToWorld(SHOTGUN.InHands[1]))
            shotgunHolo:setAngles(part.ent:localToWorldAngles(SHOTGUN.InHands[2]))
            return
        end
        if newData.state == STATE.WithShotgun and !oldData.shootAt and newData.shootAt then
            if isLocal then
                CAMERA["AtPlayer" .. newData.shootAt]()
                interactive.enableGroup("players", false)
            end
            return
        end
    end

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
        shotgunHolo:setPos(part.ent:localToWorld(SHOTGUN.OnTable[1]))
        shotgunHolo:setAngles(part.ent:localToWorldAngles(SHOTGUN.OnTable[2]))
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
        local sw, sh = render.getGameResolution()
        if part:getData("state") == STATE.Death then
            render.setColor(Color(0, 0, 0))
            render.drawRect(0, 0, sw, sh)
        end
    end)
end
