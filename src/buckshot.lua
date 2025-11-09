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


    hook.add("PlayerEnteredVehicle", "StartGame", function(_, seat)
        local index = table.keyFromValue(seats, seat)
        if index then
            if !game:isStarted() then
                game:start()
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


    net.receive("Box", function()
        local seat = net.readEntity()
        local key = table.keyFromValue(seats, seat)
        animations.getBox(Table.boxes[key].box)
    end)

    net.receive("GotItem", function()
        local seat = net.readEntity()
        local key = table.keyFromValue(seats, seat)
        local box = Table.boxes[key].box
        local pos = box:getPos()
        local ang = box:getAngles()
        local beer = items.Beer(pos, ang + Angle(0, 0, 90))
        local tw = Tween:new()
        tw:add(
            Param:new(0.1, beer, PROPERTY.POS, pos + Vector(0, 0, 7), math.easeInSine),
            Param:new(0.1, beer, PROPERTY.ANGLES, ang + Angle(-20, 0, 20), math.easeInSine)
        )
        tw:start()
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
    local state = STATES.Idle


    local sw, sh
    local boxButton
    local slotsButtons

    hook.add("DrawHUD", "Mouse", function()
        if !(sw and sh) then sw, sh = render.getGameResolution() end
        if boxButton then
            render.setColor(Color(0, 0, 0, 0))
            boxButton:draw()
            render.setColor(Color())
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
            net.writeEntity(seat)
            net.send()
        end)
        tw:sleep(1, function()
            input.enableCursor(true)
            boxButton = Button:new(sw * 0.4, sh * 0.6, sw * 0.2, sh * 0.3)
            slotsButtons = {
                Button:new(sw * 0.16, sh * 0.4, sw * 0.1, sh * 0.2),
                Button:new(sw * 0.13, sh * 0.65, sw * 0.1, sh * 0.2),
                Button:new(sw * 0.3, sh * 0.4, sw * 0.1, sh * 0.2),
                Button:new(sw * 0.25, sh * 0.65, sw * 0.1, sh * 0.2),
            }
            boxButton:setCallback(function()
                net.start("GotItem")
                net.writeEntity(seat)
                net.send()
            end)
        end)
        tw:start()
    end)
end
