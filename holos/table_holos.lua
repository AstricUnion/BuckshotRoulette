--@shared

--[[ Holos ]]--
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
require("holos")

if SERVER then
    local function tablePart(multiplier, clientId)
        local clipOffset = 35
        local scale = Vector(6 * multiplier, 12, 12)
        local position = Vector(36, 0, 0)
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
    render.createRenderTarget("mat")
    render.createRenderTarget("uv")

    local mat
    local function createMat()
        mat = material.create("VertexLitGeneric")
        mat:setTextureRenderTarget("$basetexture", "uv")
        mat:setInt("$flags", 256)
    end
    createMat()

    hook.add("RenderOffscreen", "", function()
        render.selectRenderTarget("mat")
        do
            local green = material.load("models/props_pipes/GutterMetal01a")
            render.clear(Color(0, 0, 0, 0))
            render.setColor(Color(150, 200, 150))

            render.drawRect(0, 0, 460, 460)
            render.drawRect(564, 0, 460, 460)
            render.drawRect(0, 564, 460, 460)
            render.drawRect(564, 564, 460, 460)
            render.drawRectOutline(0, 0, 1024, 1024, 256)
            render.drawRect(312, 312, 400, 400)

            render.setMaterialEffectSub(green)
            render.drawTexturedRect(0, 0, 1024, 1024)

            render.setMaterial()
            render.setColor(Color())
            render.drawRectOutline(612, 8, 100, 150, 2)
            render.drawRectOutline(312, 8, 100, 150, 2)
            render.drawRectOutline(720, 8, 100, 150, 2)
            render.drawRectOutline(204, 8, 100, 150, 2)
        end
        render.selectRenderTarget("uv")
        do
            render.clear(Color(0, 0, 0, 0))
            render.setRenderTargetTexture("mat")
            render.drawTexturedRectUV(0, 0, 1024, 1024, 0, 0, 1, 0.5)
        end
        render.selectRenderTarget()
        hook.remove("RenderOffscreen", "")
    end)

    hook.add("HoloInitialized", "", function(_, holo)
        holo:setMaterial("!" .. mat:getName())
    end)
end
