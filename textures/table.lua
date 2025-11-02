--@include astricunion/libs/cmaterial.lua
--@client
require("astricunion/libs/cmaterial.lua")


local tableTexture = CMaterial:new("table", "VertexLitGeneric")
    :setGeneration(function()
        render.setColor(Color(255, 0, 0))
        render.drawRect(0, 0, 1024, 1024)
        return true
    end)
    :create()

local holo = hologram.create(chip():getPos(), Angle(), "models/holograms/cube.mdl")
holo:setMaterial("!" .. tableTexture:getName())


--[[
if CLIENT then
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
end]]
