---@class items
local items = items

---@class model
local model = model

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
        turns.setData("shells", shells)
        table.remove(shells)
        if shells[#shells] == nil then
            turns.startItems()
        end
    else
        local shells = turns.getData("shells")
        if turns.getLocalPlayerParticipant() then
            printHud("Shell drawed, it's " .. (shells[#shells] and "live" or "blank"))
        end
        self.model:remove()
    end
end

items.register(Beer)


---@type table<number, Avatar>
local avatars = {}


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


if SERVER then
    -- local tableHolo = hologram.create(chip():getPos() + Vector(0, 0, 29), chip():getAngles(), "models/holograms/plane.mdl", Vector(6, 6, 6))
    -- if !tableHolo then return end
    -- tableHolo:setColor(Color(20, 125, 25))
    -- tableHolo:setParent(chip())

    local initialData = {
        itemsToTook = {}, -- Items to pickup, server generates it
        items = {}, -- Maximum 8 items
        health = 6, -- Player health, maximum 6
        isJammed = false, -- Is player jammed by other player
        state = STATE.Idle -- State of player, yeah
    }
    local chairDist = 50
    local chairModel = "models/nova/chair_wood01.mdl"
    turns.addParticipant(Vector(-chairDist, 0, 0), Angle(0, -90, 0), chairModel, initialData)
    turns.addParticipant(Vector(0, -chairDist, 0), Angle(0, 0, 0), chairModel, initialData)
    turns.addParticipant(Vector(chairDist, 0, 0), Angle(0, 90, 0), chairModel, initialData)
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
    interactive.addArea("player1", 0.8, 0.2, 0.2, 0.6, "players") -- Right
    interactive.addArea("player2", 0.4, 0.25, 0.2, 0.4, "players") -- Forward
    interactive.addArea("player3", 0, 0.2, 0.2, 0.6, "players") -- Left
    interactive.enableDraw(true)
end

function turns.newParticipant(ply, part)
    if SERVER then
        enableHud(ply, true)
        return
    end
    screen.new(part)
    local avatar = Avatar:new(ply)
    if avatar then
        avatar.holo:setPos(part.ent:getPos())
        avatar.holo:setAngles(part.ent:localToWorldAngles(Angle(0, 90, 0)))
        avatar.holo:setParent(part.ent)
        avatars[part.sortedId] = avatar
    end
end

function turns.participantLeft(ply, part)
    if SERVER then
        enableHud(ply, false)
        return
    end
    local avatar = avatars[part.sortedId]
    if avatar then
        avatar:remove()
    end
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


    net.receive("LookAtPlayer", function(_, ply)
        local localId = net.readUInt(2)
        local part = turns.getParticipant(ply)
        local turn = turns.getTurn()
        if !part or turn ~= part then return end
        turns.sendSignal("LookAtPlayer", {localId = localId})
    end)

    -- Start new sequence of shells
    local function tryToStartNewSequence()
        turns.setData("shells", {true, false, true})
        local activeParts = turns.getActiveParticipants()
        for _, activePart in ipairs(activeParts) do
            local state = activePart:getData("state")
            local health = activePart:getData("health")
            if state == STATE.Box or (state == STATE.Death and health < 0) then
                return
            end
        end
        timer.simple(1.5, function()
            turns.setData("gameStep", STEP.Shotgun)
        end)
        timer.simple(5, function()
            turns.setData("gameStep", STEP.Gameplay)
        end)
    end

    -- Take boxes and start take items
    function turns.startItems()
        local gotBox = {}
        for _, v in ipairs(turns.participantsSorted) do
            if !v:getPlayer() then goto cont end
            local currentItems = table.count(v:getData("items"))
            if v:getData("health") <= 0 then goto cont end
            local toTake = {"beer"} -- , "beer", "beer", "beer", "beer", "beer", "beer", "beer"}
            toTake = {unpack(toTake, 1, 8 - currentItems)}
            if #toTake == 0 then
                v:setData("state", STATE.Idle)
                goto cont
            end
            v:setData("state", STATE.Box)
            v:setData("itemsToTook", toTake)
            gotBox[#gotBox+1] = v
            ::cont::
        end
        if #gotBox ~= 0 then
            turns.setData("gameStep", STEP.Items)
        else
            tryToStartNewSequence()
        end
    end

    function turns.gameStarted()
        turns.startItems()
    end

    function turns.turnStart(part)
        if part:getData("isJammed") then return true end
        local shells = turns.getData("shells")
        if #shells == 0 then
            turns.startItems()
        end
    end

    local inputByState = {
        [STATE.Box] = function(part, area, data)
            -- If player tried to take something from box
            if area == "box" and !data.itemInHand then
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
                if turns.getData("gameStep") ~= STEP.Gameplay or turns.getTurn() ~= part then return end
                part:setData("state", STATE.WithShotgun)
                turns.sendSignal("TakeShotgun", {participantId = part.sortedId})
            end
        end,
        [STATE.WithShotgun] = function(part, area)
            if string.startsWith(area, "player") then
                local partAdd = tonumber(string.replace(area, "player", ""))
                if !partAdd then return end
                local target = turns.getLocalParticipant(part, partAdd)
                if !target:getPlayer() then return end
                local shells = turns.getData("shells")
                local lastShell = table.remove(shells)
                turns.sendSignal("ShootAt", {participantId = part.sortedId, shootAt = partAdd, isDeath = lastShell})
                if lastShell then
                    local health = target:getData("health") - 1
                    target:setData("health", health)
                    if health == 0 then
                        target:setData("state", STATE.Death)
                    end
                end
                timer.simple(4, function()
                    part:setData("state", STATE.Idle)
                    local lastTurn = turns.getTurn()
                    if !lastTurn then return end
                    local newTurn = lastTurn
                    if lastShell or target ~= part then
                        newTurn = turns.nextTurn() or newTurn
                    end
                    if #shells == 0 then
                        turns.startItems()
                    else
                        turns.sendSignal("ChangeTurn", {
                            oldParticipantId = lastTurn.sortedId,
                            newParticipantId = newTurn.sortedId
                        })
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
    local shotgunHolo = model.create("shotgun")
    local shotgunAnim
    if !shotgunHolo then return end
    shotgunHolo:setPos(chip():getPos() + Vector(0, 0, 35))
    shotgunHolo:setParent(chip())

    local function turnShotgun(angle)
        if shotgunAnim then tween.stop(shotgunAnim) end
        shotgunHolo:emitSound("buttons/lever8.wav")
        shotgunAnim = tween.start(tween.new {
            tween.param {0, 0.6, shotgunHolo, tween.ParamProperties.LOCALANGLES, nil, Angle(0, angle - 90, 0), math.easeInOutSine }
        })
    end

    function interactive.onHoverChanged(area, hovered)
        local part = turns.getLocalPlayerParticipant()
        if !part then return end
        local state = part:getData("state")
        if string.startsWith(area, "slot") and state == STATE.Idle then
            local slots = part:getData("items")
            local slot = tonumber(string.replace(area, "slot", ""))
            if !slot then return end
            local itemId = slots[slot]
            if !itemId then return end
            local item = items.inited[itemId]
            if hovered then
                item:hover(slot)
            else
                item:unhover(slot)
            end
            return
        end

        if string.startsWith(area, "player") and state == STATE.WithShotgun then
            local partAdd = tonumber(string.replace(area, "player", ""))
            if !partAdd or partAdd == 2 or partAdd == 0 then return end
            net.start("LookAtPlayer")
                net.writeUInt(hovered and partAdd or 2, 2)
            net.send()
        end
    end

    -- Move item to slot
    turns.signal("MoveToSlot", function(data)
        local item = items.inited[data.itemId]
        if !item then return end
        item:moveToSlot(data.slot)
        local part = turns.getLocalPlayerParticipant()
        if !(part and data.lastItem and part.sortedId == data.participantId) then return end
        local avatar = avatars[part.sortedId]
        if avatar then
            avatar:removeBox()
        end
        interactive.enableGroup("slots", false)
        interactive.enable("box", false)
        input.enableCursor(false)
    end)

    -- Animation to take shotgun
    turns.signal("TakeShotgun", function(data)
        local currentPart = turns.getLocalPlayerParticipant()
        if currentPart and currentPart.sortedId == data.participantId then
            interactive.enableGroup("slots", false)
            interactive.enable("shotgun", false)
            timer.simple(1, function()
                interactive.enableGroup("players", true)
            end)
        end
        local part = turns.participantsSorted[data.participantId]
        local avatar = avatars[part.sortedId]
        if avatar then
            avatar:takeShotgun(shotgunHolo)
        end
    end)

    turns.signal("LookAtPlayer", function(data)
        local localId = data.localId
        local turn = turns.getTurn()
        if !turn then return end
        local currentPart = turns.getLocalPlayerParticipant()
        if turn == currentPart then return end
        local avatar = avatars[turn.sortedId]
        if avatar then
            avatar["atPlayer" .. localId](avatar)
        end
    end)

    turns.signal("ShootAt", function(data)
        local currentPart = turns.getLocalPlayerParticipant()
        local part = turns.participantsSorted[data.participantId]
        if part == currentPart then
            interactive.enableGroup("players", false)
            input.enableCursor(false)
        end
        local avatar = avatars[part.sortedId]
        if avatar then
            avatar:shootPose(shotgunHolo, data.shootAt)
        end

        timer.simple(1, function()
            local target = turns.getLocalParticipant(part, data.shootAt)
            local targetAvatar = avatars[target.sortedId]
            local targetScreen = screen.inited[target.sortedId]
            if targetAvatar then
                local isSelf = data.shootAt == 0
                if data.isDeath then
                    targetAvatar:death(isSelf and shotgunHolo or nil)
                    if target == currentPart then
                        targetAvatar["atPlayer" .. turns.getParticipantLocalId(target, part)](targetAvatar, true)
                    end
                    timer.simple(currentPart == target and 3.5 or 0.5, function()
                        targetScreen:updateHealth()
                    end)
                    if target:getData("health") > 0 then
                        timer.simple(1, function()
                            targetAvatar:revive()
                        end)
                    end
                end
                if !(data.shootAt == 0 and data.isDeath) then
                    avatar:shootAtPlayer(shotgunHolo, data.shootAt, data.isDeath)
                    timer.simple(2, function()
                        avatar:dropShotgun(shotgunHolo)
                    end)
                end
            end
        end)
    end)

    local function changeTurn(lastTurn, newTurn)
        local turn = !newTurn and lastTurn or newTurn
        lastTurn = !newTurn and turns.getTurn() or lastTurn
        if turns.getData("gameStep") == STEP.Items then return end
        local part = turns.getLocalPlayerParticipant()
        if !part then return end
        local avatar = avatars[part.sortedId]
        if lastTurn ~= turn then
            turnShotgun(turn.ent:getLocalAngles().y)
        end
        if turn == part then
            interactive.enableGroup("slots", true)
            interactive.enable("shotgun", true)
            input.enableCursor(true)
            if avatar then
                avatar:turn()
            end
        else
            if avatar then
                local localId = turns.getParticipantLocalId(part, turn)
                avatar["atPlayer" .. localId](avatar, true)
            end
        end
    end

    turns.signal("ChangeTurn", function(data)
        changeTurn(
            turns.participantsSorted[data.oldParticipantId],
            turns.participantsSorted[data.newParticipantId]
        )
    end)

    function turns.participantDataChanged(part, old, new, isLocal)
        -- On box items
        if old.state ~= STATE.Box and new.state == STATE.Box then
            local avatar = avatars[part.sortedId]
            if !avatar then return end
            local function animation()
                if avatar then
                    avatar:takeBox()
                end
                if isLocal then
                    interactive.enableGroup("slots", true)
                    interactive.enable("box", true)
                    input.enableCursor(true)
                end
            end
            if avatar.contrast ~= 1 then
                timer.simple(1, function()
                    animation()
                end)
            else
                animation()
            end
        end
    end

    function turns.dataChanged(old, new)
        if old.gameStep ~= STEP.Shotgun and new.gameStep == STEP.Shotgun then
            local part = turns.getLocalPlayerParticipant()
            if !part then return end
            local avatar = avatars[part.sortedId]
            avatar:atShotgun()
            local shells = turns.getData("shells")
            local holos = {}
            local pos = shotgunHolo:getPos()
            local halfOfCount = #shells / 2
            for i, v in ipairs(shells) do
                local holo = hologram.create(pos + ((i - halfOfCount) * Vector(0, 3, 0)), Angle(), "models/weapons/shotgun_shell.mdl")
                if !holo then goto cont end
                holo:setColor(v and Color() or Color(0, 0, 255))
                holos[i] = holo
                ::cont::
            end
            timer.simple(3.5, function()
                for _, v in ipairs(holos) do
                    if !isValid(v) then goto cont end
                    v:remove()
                    ::cont::
                end
            end)
            return
        end
        if old.gameStep == STEP.Shotgun and new.gameStep == STEP.Gameplay then
            local turn = turns.getTurn()
            if !turn then return end
            changeTurn(nil, turn)
            return
        end
    end
end
