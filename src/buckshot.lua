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


if SERVER then
    --@include buckshot/holos/animations.lua
    require("buckshot/holos/animations.lua")

    local CHIPPOS = CHIP:getPos()
    -- Create game object
    local model = "models/nova/chair_wood01.mdl"
    local dist = 50
    local seats = {
        prop.createSeat(CHIPPOS + Vector(dist, 0, 0), Angle(0, 90, 0), model, true),
        prop.createSeat(CHIPPOS + Vector(0, dist, 0), Angle(0, 180, 0), model, true),
        prop.createSeat(CHIPPOS + Vector(-dist, 0, 0), Angle(0, -90, 0), model, true),
        prop.createSeat(CHIPPOS + Vector(0, -dist, 0), Angle(0, 0, 0), model, true)
    }
    for _, seat in ipairs(seats) do
        seat:setParent(CHIP)
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

    hook.add("KeyPress", "", function(ply, key)
        if game:isStarted() then
            local turn = game:getTurn()
            local turnPly = turn:getPlayer()
            if key == IN_KEY.ATTACK and turn and ply == turnPly then
                local rn = math.random(0, 5)
                if rn ~= 1 then
                    printHud(turnPly, "You're clicked! Next turn")
                else
                    printHud(turnPly, "How unfortunatenaly!")
                    turn.seat:ejectDriver()
                    turn.seat:lock()
                end
                local next = game:next()
                if !next then game:stop() return end
                local nextPly = next:getPlayer()
                printHud(nextPly, "Your turn!")
            end
        end
    end)

    net.receive("Box", function()
        local seat = net.readEntity()
        local key = table.keyFromValue(seats, seat)
        animations.getBox(Table.boxes[key].box)
    end)
else
    --@include buckshot/libs/camera.lua
    require("buckshot/libs/camera.lua")

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
            net.start("Box")
            net.writeEntity(seat)
            net.send()
        end)
        tw:start()
    end)
end
