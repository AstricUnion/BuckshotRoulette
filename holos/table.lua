--@shared

--[[ Holos ]]--
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
require("holos")

if SERVER then
    --@include buckshot/holos/items.lua
    require("buckshot/holos/items.lua")

    local function itemBox(pos, ang)
        local holos = {
            box = hologram.createPart(
                Holo(Rig(Vector(),Angle())),
                Holo(SubHolo(Vector(),Angle(),"models/holograms/cube.mdl",Vector(0.6,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-3.313,0,2),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.3,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(3.313,0,2),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.3,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(0,4.52,2),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.3,0.505,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(0,-4.52,2),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.3,0.505,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-3.413,0,3.6),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(3.413,0,3.6),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-3.413,0,-0.1),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(3.413,0,-0.1),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(0,4.62,3.6),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.52,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(0,-4.62,3.6),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.52,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(0,4.62,-0.1),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.52,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(0,-4.62,-0.1),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.52,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(3.43,-4.62,2),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.3,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-3.43,-4.62,2),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.3,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(3.43,4.62,2),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.3,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-3.43,4.62,2),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.3,0.05),false,nil,"phoenix_storms/pro_gear_top2"))
            ),
            boxLid = hologram.createPart(
                Holo(Rig(Vector(-3.75,0,3.92),Angle())),
                Holo(SubHolo(Vector(-7.5,0,2),Angle(),"models/holograms/cube.mdl",Vector(0.6,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-4.18,0,2.9),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.15,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-10.794,0,2.9),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.15,0.8,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-7.5,4.52,2.9),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.15,0.51,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-7.5,-4.52,2.9),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.15,0.51,0.05),false,nil,"phoenix_storms/concrete1")),
                Holo(SubHolo(Vector(-10.913,0,3.6),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-4.087,0,3.6),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-10.913,0,1.9),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-4.087,0,1.9),Angle(90,0,0),"models/holograms/cube.mdl",Vector(0.05,0.815,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-7.5,4.62,3.6),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.54,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-7.5,-4.62,3.6),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.54,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-7.5,4.62,1.9),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.54,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-7.5,-4.62,1.9),Angle(90,90,0),"models/holograms/cube.mdl",Vector(0.05,0.54,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-4.09,-4.62,3),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.15,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-10.93,-4.62,3),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.15,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-4.09,4.62,3),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.15,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-10.93,4.62,3),Angle(0,90,90),"models/holograms/cube.mdl",Vector(0.05,0.15,0.05),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-3.7,-2.5,3.9),Angle(90,90,0),"models/holograms/hq_cylinder.mdl",Vector(0.085,0.085,0.15),false,nil,"phoenix_storms/pro_gear_top2")),
                Holo(SubHolo(Vector(-3.7,2.5,3.9),Angle(90,90,0),"models/holograms/hq_cylinder.mdl",Vector(0.085,0.085,0.15),false,nil,"phoenix_storms/pro_gear_top2"))
            )
        }
        holos.boxLid:setParent(holos.box)
        holos.boxLid:setLocalAngles(Angle(-180, 0, 0))
        holos.box:setAngles(ang)
        holos.box:setPos(holos.box:getPos() + pos)
        return holos
    end

    ---Create table surface
    local function tablePart(multiplier, clientId)
        local clipOffset = 18
        local scale = Vector(3 * multiplier, 6, 6)
        local position = Vector(18, 0, 0)
        local holo = SubHolo(Vector(0, 0, 36) - position * multiplier, nil, "models/holograms/plane.mdl", scale, nil, nil, nil, clientId)
        if !holo then return end
        holo:setCullMode(math.max(-multiplier, 0))
        return Holo(
            holo,
            nil,
            {
                Clip(Vector(-clipOffset, -clipOffset, 0) * multiplier, Vector(0.5, 0.5, 0) * multiplier),
                Clip(Vector(-clipOffset, clipOffset, 0) * multiplier, Vector(0.5, -0.5, 0) * multiplier),
            }
        )
    end

    ---Create led surface
    ---TODO: replace it with custom texture
    local function led(angle)
        return SubHolo(Vector(0,0,37),Angle(0,angle),"models/Mechanics/gears2/gear_18t1.mdl",Vector(0.8865,0.8865,0.12),true,Color(190,200,100),"models/debug/debugwhite")
    end

    Table = {
        main = hologram.createPart(
            Holo(Rig()),
            Holo(SubHolo(Vector(0,0,18),nil,"models/hunter/blocks/cube075x075x025.mdl",Vector(1.5,1.5,3),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,22.575,18),Angle(90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,-22.575,18),Angle(-90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,0,18),nil,"models/hunter/blocks/cube05x05x05.mdl",Vector(0.35,1.552,1.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,22.575,18),Angle(-90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,-22.575,18),Angle(90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,0,18),nil,"models/hunter/blocks/cube05x05x05.mdl",Vector(0.35,1.552,1.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(22.575,30.82,18),Angle(-90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-22.575,30.82,18),Angle(90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,30.82,18),nil,"models/hunter/blocks/cube05x05x05.mdl",Vector(1.552,0.35,1.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(22.575,-30.82,18),Angle(90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-22.575,-30.82,18),Angle(-90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-30.82,18),nil,"models/hunter/blocks/cube05x05x05.mdl",Vector(1.552,0.35,1.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(34.82,0,35),nil,"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-34.82,0,35),nil,"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,34.82,35),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-34.82,35),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(26.455,26.455,35),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(26.455,-26.455,35),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-26.455,26.455,35),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-26.455,-26.455,35),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(35.92,0,35.5),nil,"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-35.92,0,35.5),nil,"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,35.92,35.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-35.92,35.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(27.03,27.03,35.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(27.03,-27.03,35.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-27.03,27.03,35.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,nil,"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-27.03,-27.03,35.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,nil,"models/props/CS_militia/roofbeams01"))
        ),
        surface = hologram.createPart(
            Holo(Rig(Vector(0,0,36))),
            tablePart(1, "table1"),
            tablePart(-1, "table2")
        ),
        shotgunStand = hologram.createPart(
            Holo(SubHolo(Vector(0,0,37),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.4,0.4,0.2),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.28,0.28,0.2),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.24,0.24,0.2),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37.7),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.25,0.25,0.05),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37.7),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.26,0.26,0.05),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37.7),nil,"models/hunter/tubes/tube2x2x025.mdl",Vector(0.27,0.27,0.05),false,Color(80,80,80),"models/props_canal/canal_bridge_railing_01c")),
            Holo(SubHolo(Vector(0,0,37.7),nil,"models/holograms/cplane.mdl",Vector(3.15,3.15,1),false,nil,nil,"stand"))
        ),
        leds = {
            led(0),
            led(5),
            led(10),
            led(15)
        },
        shotgun = hologram.createPart(
            Holo(Rig(Vector(0, 0, 38))),
            Holo(SubHolo(Vector(-3,0,38),Angle(2.5,-6,-90),"models/weapons/w_annabelle.mdl"))
        ),
        boxes = {
            itemBox(Vector(29, 0, 25), Angle()),
            itemBox(Vector(0, 29, 25), Angle(0, 90, 0)),
            itemBox(Vector(-29, 0, 25), Angle(0, 180, 0)),
            itemBox(Vector(0, -29, 25), Angle(0, -90, 0))
        }
    }

    -- sex with holos
    Table.surface:setParent(Table.main)
    Table.shotgun:setParent(Table.main)
    Table.shotgunStand:setParent(Table.main)
    for _, led in ipairs(Table.leds) do
        led:setParent(Table.main)
    end
    for _, box in ipairs(Table.boxes) do
        box.box:setParent(Table.main)
    end
    Table.main:setPos(Table.main:getPos() - Vector(0, 0, 7))
    Table.main:setParent(chip())
else
    --@include buckshot/textures/table.lua
    --@include buckshot/textures/stand.lua
    require("buckshot/textures/table.lua")
    require("buckshot/textures/stand.lua")

    hook.add("HoloInitialized", "", function(id, holo)
        -- Why submaterial? Clients can forget about main material
        if string.startsWith(id, "table") then
            holo:setSubMaterial(0, "!" .. TableTexture:getName())
        elseif id == "stand" then
            holo:setSubMaterial(0, "!" .. StandTexture:getName())
        end
    end)
end
