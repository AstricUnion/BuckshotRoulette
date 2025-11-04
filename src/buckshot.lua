--@name Buckshot Roulette (WIP)
--@author AstricUnion
--@shared
--@include buckshot/libs/turns.lua
--@include buckshot/holos/table.lua

require("buckshot/libs/turns.lua")
require("buckshot/holos/table.lua")

CHIP = chip()

---@enum STATES
STATES = {
    ---Player have no health on round
    Death = -1,
    ---Player do nothing
    Idle = 0,
    ---Player got shotgun in hands
    WithShotgun = 1,
    ---Player shoots other player or himself 
    Shoot = 2,
    ---Player using adrenaline
    Adrenaline = 3,
    ---Player using jammer
    Jammer = 4,
}


if SERVER then
    --@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/tweens.lua as tweens
    require("tweens")

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
        health = 5, -- Player health, maximum 6
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


    hook.add("PlayerEnteredVehicle", "StartGame", function(ply, seat)
        local index = table.keyFromValue(seats, seat)
        if index then
            timer.simple(0.1, function()
                local camera = Table.cameras[index]
                ply:setViewEntity(camera)
            end)
            if !game:isStarted() then
                game:start()
            end
        end
    end)

    hook.add("PlayerLeaveVehicle", "StopGame", function(_, seat)
        if table.hasValue(seats, seat) then
            local turn = game:getTurn()
            if game:isStarted() and turn.seat == seat then
                local next = game:next()
                if !next then game:stop() return end
            end
        end
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
end
