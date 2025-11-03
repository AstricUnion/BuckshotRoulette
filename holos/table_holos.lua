--@shared

--[[ Holos ]]--
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
require("holos")

if SERVER then
    local function tablePart(multiplier, clientId)
        local clipOffset = 18
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
            Holo(SubHolo(Vector(0,0,18),Angle(0),"models/hunter/blocks/cube075x075x025.mdl",Vector(1.5,1.5,3),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,22.575,18),Angle(90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,-22.575,18),Angle(-90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(30.82,0,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(0.35,1.552,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,22.575,18),Angle(-90,0,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,-22.575,18),Angle(90,180,0),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-30.82,0,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(0.35,1.552,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(22.575,30.82,18),Angle(-90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-22.575,30.82,18),Angle(90,180,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,30.82,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(1.552,0.35,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(22.575,-30.82,18),Angle(90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-22.575,-30.82,18),Angle(-90,0,90),"models/hunter/triangles/05x05x05.mdl",Vector(1.5,0.35,0.35),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-30.82,18),Angle(0),"models/hunter/blocks/cube05x05x05.mdl",Vector(1.552,0.35,1.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(34.82,0,35),Angle(0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-34.82,0,35),Angle(0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,34.82,35),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-34.82,35),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.5,1.035,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(26.455,26.455,35),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(26.455,-26.455,35),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-26.455,26.455,35),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-26.455,-26.455,35),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.5,0.682,0.5),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(35.92,0,35.5),Angle(0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-35.92,0,35.5),Angle(0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,35.92,35.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(0,-35.92,35.5),Angle(0,90,0),"models/hunter/plates/plate075.mdl",Vector(0.9,1.05,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(27.03,27.03,35.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(27.03,-27.03,35.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-27.03,27.03,35.5),Angle(0,-45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,Color(255),"models/props/CS_militia/roofbeams01")),
            Holo(SubHolo(Vector(-27.03,-27.03,35.5),Angle(0,45,0),"models/hunter/plates/plate075.mdl",Vector(0.9,0.738,0.9),false,Color(255),"models/props/CS_militia/roofbeams01"))
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
