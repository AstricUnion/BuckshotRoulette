--@shared

--[[ Holos ]]--
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
require("holos")

if SERVER then
    local function tablePart(multiplier, clientId)
        local clipOffset = 35
        local scale = Vector(3 * multiplier, 6, 6)
        local position = Vector(18, 0, 0)
        local holo = SubHolo(Vector(0, 0, 36) - position * multiplier, Angle(), "models/holograms/plane.mdl", scale, nil, nil, nil, clientId)
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

    tableholos = {
        hologram.createPart(
            Holo(Rig(Vector(0))),
            Holo(SubHolo(Vector(0,0,18),Angle(0),"models/hunter/blocks/cube075x075x025.mdl",Vector(3),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(61.64,45.15,18),Angle(90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(61.64,-45.15,18),Angle(-90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(61.64,0,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(0.7,3.105,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-61.64,45.15,18),Angle(-90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-61.64,-45.15,18),Angle(90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-61.64,0,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(0.7,3.105,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(45.15,61.64,18),Angle(-90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-45.15,61.64,18),Angle(90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,61.64,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(3.105,0.7,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(45.15,-61.64,18),Angle(90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-45.15,-61.64,18),Angle(-90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.7,0.7),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-61.64,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(3.105,0.7,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(69.64,0,34),Angle(0),"models/hunter/plates/plate075.mdl",Vector(1,2.07,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-69.64,0,34),Angle(0),"models/hunter/plates/plate075.mdl",Vector(1,2.07,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,69.64,34),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(1,2.07,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-69.64,34),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(1,2.07,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(52.91,52.91,34),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(1,1.365,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(52.91,-52.91,34),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(1,1.365,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-52.91,52.91,34),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(1,1.365,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-52.91,-52.91,34),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(1,1.365,1),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(71.84,0,34.5),Angle(0),"models/hunter/plates/plate075.mdl",Vector(1.8,2.1,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-71.84,0,34.5),Angle(0),"models/hunter/plates/plate075.mdl",Vector(1.8,2.1,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,71.84,34.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(1.8,2.1,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-71.84,34.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(1.8,2.1,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(54.06,54.06,34.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(1.8,1.475,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(54.06,-54.06,34.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(1.8,1.475,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-54.06,54.06,34.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(1.8,1.475,1.8),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-54.06,-54.06,34.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(1.8,1.475,1.8),false,Color(255),"models/props/CS_militia/roofbeams01"))
        ),
        hologram.createPart(
            Holo(Rig(Vector(0,0,36))),
            tablePart(1, "right"),
            tablePart(-1, "left")
        )
        --[[hologram.createPart(
            Holo(SubHolo(Vector(0,0,37),Angle(0),))
        )]]
    }
else
    --@include buckshot/textures/table.lua
    require("buckshot/textures/table.lua")

    hook.add("HoloInitialized", "", function(_, holo)
        -- Why submaterial? Clients can forget about main material
        holo:setSubMaterial(0, "!" .. TableTexture:getName())
    end)
end
