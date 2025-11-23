--@name Buckshot Roulette (WIP)
--@author AstricUnion
--@shared
--@include buckshot/libs/turns.lua
--@include buckshot/holos/table.lua
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/tweens.lua as tweens
require("tweens")
require("buckshot/libs/turns.lua")
require("buckshot/holos/table.lua")

CHIP = chip()
OWNER = owner()

---@enum STATES
STATES = {
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


local CHIPPOS = CHIP:getPos()
local dist = 50

---@enum POSITION
POSITION = {
    CHIPPOS + Vector(dist, 0, 0),
    CHIPPOS + Vector(0, dist, 0),
    CHIPPOS + Vector(-dist, 0, 0),
    CHIPPOS + Vector(0, -dist, 0),
}
---@enum ANGLES
ANGLES = {
    Angle(0, 0, 0),
    Angle(0, 90, 0),
    Angle(0, 180, 0),
    Angle(0, -90, 0)
}


if SERVER then
    --@include buckshot/holos/items.lua
    --@include buckshot/holos/animations.lua
    require("buckshot/holos/items.lua")
    require("buckshot/holos/animations.lua")


    -- Items logic
    -- Slots positions (by IDs, for player):
    -- 1 3   7 5
    -- 2 4   8 6
    local TABLEHEIGHT = 32.5
    local ITEMSLOTS = {
        Vector(-29, -18, TABLEHEIGHT),
        Vector(-22, -17, TABLEHEIGHT),
        Vector(-29, -9, TABLEHEIGHT),
        Vector(-21, -10, TABLEHEIGHT),
        Vector(-29, 17.5, TABLEHEIGHT),
        Vector(-20, 18, TABLEHEIGHT),
        Vector(-29, 10, TABLEHEIGHT),
        Vector(-22, 10, TABLEHEIGHT)
    }

    -- beer beer and again beer
    --[[
    for i=1,#POSITION do
        local pos = POSITION[i]
        local ang = ANGLES[i]
        for _, slot in ipairs(ITEMSLOTS) do
            items.Beer(pos + slot:getRotated(ang), Angle())
        end
    end
    ]]

    ---@enum ITEM
    local ITEM = {
        HandSaw = 1,
        MagnifyingGlass = 2,
        Jammer = 3,
        CigarettePack = 4,
        Beer = 5,
        BurnerPhone = 6,
        Adrenaline = 7,
        Inverter = 8
    }

    ---@class Item
    ---@field type ITEM
    ---@field ent Hologram
    local Item = {}
    Item.__index = Item

    ---Item data
    ---@param type ITEM
    ---@param ent Hologram
    ---@return Item
    function Item:new(type, ent)
        return setmetatable(
            {
                type = type,
                ent = ent
            },
            Item
        )
    end

    -- Create game object
    local model = "models/nova/chair_wood01.mdl"
    local seats = {}
    for i=1,4 do
        local seat = prop.createSeat(POSITION[i], ANGLES[i] + Angle(0, 90, 0), model, true)
        seat:setParent(CHIP)
        seats[i] = seat
    end

    ---Initial data for every player
    local initialData = {
        items = {}, -- Maximum 8 items
        health = 6, -- Player health, maximum 6
        isJammed = false, -- Is player jammed by other player
        itemInHand = nil, -- Item in hand, can be an item from box or from table
        state = STATES.Idle -- State of player, yeah
    }
    local game = Game:new(seats, initialData, 1)

    -- LEDs animation
    local ledIndex = 0
    local ledColor = Color(190, 200, 100)
    timer.create("LEDsAnimation", 0.1, 0, function()
        ledIndex = ledIndex + 1
        if ledIndex > 4 then
            ledIndex = 1
        end
        for i, led in ipairs(Table.leds) do
            led:setColor(i ~= ledIndex and ledColor or Color(0, 0, 0))
        end
    end)


    hook.add("PlayerSay", "StartGame", function(ply, text)
        if ply ~= OWNER then return end
        if text == "!start" then
            if !game:isStarted() then
                game:start()
                for _, part in ipairs(game:getParticipants()) do
                    ---@cast part Participant
                    part.seat:lock()
                end
            end
        end
    end)


    hook.add("PlayerLeaveVehicle", "StopGame", function(ply, seat)
        if table.hasValue(seats, seat) then
            net.start("RemoveCamera")
            net.send(ply)
            local turn = game:getTurn()
            if game:isStarted() and turn.seat == seat then
                local next = game:next()
                if !next then game:stop() return end
            end
        end
    end)


    hook.add("GameStarted", "RouletteStarted", function(_, _, players)
        net.start("GameStarted")
        net.send(players)
    end)


    net.receive("Box", function(_, ply)
        local part = game:getParticipant(ply)
        if !part then return end
        part:updateData({state = STATES.Box})
        local seat = part.seat
        local key = table.keyFromValue(seats, seat)
        animations.getBox(Table.boxes[key])
    end)

    net.receive("GotItem", function(_, ply)
        local part = game:getParticipant(ply)
        if !part then return end
        local data = part:getData()
        if data.state ~= STATES.Box then return end
        if data.itemInHand then return end
        local seat = part.seat
        local key = table.keyFromValue(seats, seat)
        local box = Table.boxes[key].box
        local pos = box:getPos()
        local ang = box:getAngles()
        local beer = items.Beer(pos, ang + Angle(0, 0, 90))
        if !beer then return end
        local tw = Tween:new()
        tw:add(
            Param:new(0.1, beer, PROPERTY.POS, pos + Vector(0, 0, 7), math.easeOutSine),
            Param:new(0.1, beer, PROPERTY.ANGLES, ang + Angle(-20, 0, 20), math.easeOutSine, function()
                part:updateData({itemInHand = Item:new(ITEM.Beer, beer)})
            end)
        )
        tw:start()
    end)

    net.receive("PutItem", function(_, ply)
        local part = game:getParticipant(ply)
        if !part then return end
        local data = part:getData()
        if data.state ~= STATES.Box then return end
        if !data.itemInHand then return end
        local id = net.readInt(5)
        if data.items[id] then return end
        local seat = part.seat
        local key = table.keyFromValue(seats, seat)
        local ang = ANGLES[key]
        local pos = POSITION[key] + ITEMSLOTS[id]:getRotated(ang)
        local tw = Tween:new()
        tw:add(
            Param:new(0.1, data.itemInHand.ent, PROPERTY.POS, pos, math.easeOutSine),
            Param:new(0.1, data.itemInHand.ent, PROPERTY.ANGLES, ang, math.easeOutSine)
        )
        tw:start()
        data.items[id] = data.itemInHand
        data.itemInHand = nil
        part:setData(data)
        local length = 0
        for _, v in ipairs(data.items) do
            if v then
                length = length + 1
            end
        end
        if length >= 8 then
            local seat = part.seat
            local key = table.keyFromValue(seats, seat)
            animations.removeBox(Table.boxes[key])
            net.start("BoxRemoved")
            net.send(ply)
            return
        end
    end)
else
    --@include buckshot/libs/camera.lua
    require("buckshot/libs/camera.lua")

    --@include astricunion/libs/ui.lua
    require("astricunion/libs/ui.lua")

    ---Data are relative to seat
    CAMERAS = {
        BOX = {POS = Vector(0, 14, 52), ANG = Angle(55, 90, 0), FOV = 90},
        ATTABLE = {POS = Vector(0, 12, 55), ANG = Angle(50, 90, 0), FOV = 90},
        ATSCREEN = {POS = Vector(0, 20, 40), ANG = Angle(60, 90, 0), FOV = 90},
        ATGAME = {POS = Vector(0, 10, 60), ANG = Angle(10, 90, 0), FOV = 90}
    }
    PLAYER = player()

    local function getLocalToSeat(seat, pos)
        return {POS = seat:localToWorld(pos.POS), ANG = seat:localToWorldAngles(pos.ANG), FOV = pos.FOV}
    end

    ---Seat
    local seat = nil

    ---Local state. Can be used to draw only necessary UI elements and may be different from server
    local state = STATES.Idle


    local sw, sh
    local boxButton
    local slotsButtons
    local visibleCursor = false

    local function createButtons()
        if !(sw and sh) then sw, sh = render.getGameResolution() end
        if !slotsButtons then
            local width, height = sw * 0.1, sh * 0.2
            local firstRow, secondRow = sh * 0.4, sh * 0.65
            slotsButtons = {
                Button:new(sw * 0.18, firstRow, width, height),
                Button:new(sw * 0.13, secondRow, width, height),
                Button:new(sw * 0.3, firstRow, width, height),
                Button:new(sw * 0.25, secondRow, width, height),
            }
            local getCallback = function(n)
                return function()
                    net.start("PutItem")
                    net.writeInt(n, 5)
                    net.send()
                end
            end
            for i=1, #slotsButtons do
                local b = slotsButtons[i]
                slotsButtons[4 + i] = Button:new(sw - b.x - b.w, b.y, width, height)
            end
            for i, b in ipairs(slotsButtons) do
                b:setCallback(getCallback(i))
            end
        end
        if !boxButton then
            boxButton = Button:new(sw * 0.4, sh * 0.6, sw * 0.2, sh * 0.3)
            boxButton:setCallback(function()
                net.start("GotItem")
                net.send()
            end)
        end
    end

    hook.add("DrawHUD", "Mouse", function()
        createButtons()
        render.setColor(Color(0, 0, 0, 0))
        local currentVisibility = input.getCursorVisible()
        if !currentVisibility and visibleCursor then
            input.enableCursor(true)
        elseif currentVisibility and !visibleCursor then
            input.enableCursor(false)
        end
        if state == STATES.Box then
            boxButton:draw()
            for _, v in ipairs(slotsButtons) do
                v:draw()
            end
        end
    end)

    net.receive("RemoveCamera", function()
        local lastCam = camera.get()
        if lastCam then lastCam:remove() end
    end)


    net.receive("GameStarted", function()
        seat = PLAYER:getVehicle()
        local atGame = getLocalToSeat(seat, CAMERAS.ATGAME)
        cam = camera.create(atGame.POS, atGame.ANG, atGame.FOV, 0.15, true)
        if !cam then return end
        camera.set(cam)
        local tw = Tween:new()
        tw:sleep(1, function()
            local cameraPos = getLocalToSeat(seat, CAMERAS.ATSCREEN)
            cam:setTargetAngles(cameraPos.ANG)
            cam:setTargetPos(cameraPos.POS)
        end)
        tw:sleep(3, function()
            local cameraPos = getLocalToSeat(seat, CAMERAS.BOX)
            cam:setTargetAngles(cameraPos.ANG)
            cam:setTargetPos(cameraPos.POS)
            state = STATES.Box
            net.start("Box")
            net.send()
        end)
        tw:sleep(1, function()
            visibleCursor = true
        end)
        tw:start()
    end)


    net.receive("BoxRemoved", function()
        state = STATES.Idle
        local cameraPos = getLocalToSeat(seat, CAMERAS.ATTABLE)
        cam:setTargetAngles(cameraPos.ANG)
        cam:setTargetPos(cameraPos.POS)
    end)
end
