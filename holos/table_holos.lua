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
    function render.drawPolyOutline(vertices, thickness)
        for i=1,#vertices do
            local current = vertices[i]
            local next = vertices[i + 1] or vertices[1]
            for l=0, -thickness / 2, -0.5 do
                render.drawLine(current.x + l, current.y + l, next.x + l, next.y + l)
            end
        end
    end

    render.createRenderTarget("mat")
    render.createRenderTarget("cells")
    render.createRenderTarget("cellsPerPlayer")
    render.createRenderTarget("uv")

    local mat
    local function createMat()
        mat = material.create("VertexLitGeneric")
        mat:setTextureRenderTarget("$basetexture", "uv")
        mat:setInt("$flags", 256)
    end
    createMat()

    hook.add("PlayerDisconnected", "", createMat)
    hook.add("PlayerConnect", "", createMat)

    hook.add("RenderOffscreen", "", function()
        render.selectRenderTarget("cells")
        do
            local null = {x = 408, y = 392}
            local size = {x = 100, y = 132}
            render.clear(Color(0, 0, 0, 0))
            render.drawPolyOutline({
                {x = null.x, y = null.y + 100},
                {x = null.x, y = null.y + size.y},
                {x = null.x + size.x, y = null.y + size.y},
                {x = null.x + size.x, y = null.y},
            }, 2)
            render.drawRectOutline(null.x + size.x + 8, null.y, size.x, size.y, 2)
            render.drawRectOutline(null.x, null.y + size.y + 8, size.x, size.y, 2)
            render.drawRectOutline(null.x + size.x + 8, null.y + size.y + 8, size.x, size.y, 2)
        end
        render.selectRenderTarget("cellsPerPlayer")
        do
            render.clear(Color(0, 0, 0, 0))
            render.setRenderTargetTexture("cells")
            render.drawTexturedRectUV(-200, -330, 1024, 1024, 0, 0, 1, -1)
            render.drawTexturedRectUV(200, -330, 1024, 1024, 0, 0, -1, -1)
        end
        render.selectRenderTarget("mat")
        do
            local green = material.load("models/props_pipes/GutterMetal01a")
            render.clear(Color(0, 0, 0, 0))
            render.setColor(Color(150, 200, 150))

            render.drawFilledCircle(512, 512, 332)
            render.drawRect(0, 0, 460, 460)
            render.drawRect(564, 0, 460, 460)
            render.drawRect(0, 564, 460, 460)
            render.drawRect(564, 564, 460, 460)
            render.drawRectOutline(0, 0, 1024, 1024, 130)

            render.setMaterialEffectSub(green)
            render.drawTexturedRect(0, 0, 1024, 1024)

            render.setMaterial()
            render.setColor(Color())
            render.setRenderTargetTexture("cellsPerPlayer")
            render.drawTexturedRectRotated(512, 512, 1024, 1024, 0)
            render.drawTexturedRectRotated(512, 512, 1024, 1024, 90)
            render.drawTexturedRectRotated(512, 512, 1024, 1024, -90)
            render.drawCircle(512, 512, 316)
            render.drawLine(0, 0, 1024, 1024)
            render.drawLine(1024, 0, 0, 1024)
        end
        render.selectRenderTarget("uv")
        do
            render.clear(Color(0, 0, 0, 0))
            render.setRenderTargetTexture("mat")
            render.drawTexturedRectUV(0, 0, 1024, 1024, 0, 0, -1, 0.5)
        end
        render.selectRenderTarget()
        hook.remove("RenderOffscreen", "")
    end)

    hook.add("HoloInitialized", "", function(_, holo)
        holo:setMaterial("!" .. mat:getName())
    end)
end
