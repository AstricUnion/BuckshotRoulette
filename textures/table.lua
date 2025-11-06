--@client

--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/cmaterial.lua as cmat
require("cmat")

local function drawPolyOutline(vertices, thickness)
    for i=1,#vertices do
        local current = vertices[i]
        local next = vertices[i + 1] or vertices[1]
        for l=0, -thickness / 2, -0.5 do
            render.drawLine(current.x + l, current.y + l, next.x + l, next.y + l)
        end
    end
end


local function generate(name)
    render.selectRenderTarget("cells")
    do
        local null = {x = 408, y = 392}
        local size = {x = 100, y = 132}
        render.clear(Color(0, 0, 0, 0))
        drawPolyOutline({
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

        render.drawFilledCircle(512, 512, 330)
        local width = 440
        local center = 512 + (512 - width)
        render.drawRect(0, 0, width, width)
        render.drawRect(center, 0, width, width)
        render.drawRect(0, center, width, width)
        render.drawRect(center, center, width, width)
        render.drawRectOutline(0, 0, 1024, 1024, 110)

        render.setMaterialEffectSub(green)
        render.drawTexturedRect(0, 0, 1024, 1024)

        render.setMaterial()
        render.setColor(Color())
        render.setRenderTargetTexture("cellsPerPlayer")
        render.drawTexturedRectRotated(512, 512, 1024, 1024, 0)
        render.drawTexturedRectRotated(512, 512, 1024, 1024, 90)
        render.drawTexturedRectRotated(512, 512, 1024, 1024, -90)
        render.drawCircle(512, 512, 316)
        center = 176 / 2
        render.drawRectOutline(512 - center, 30, 176, 200, 2)
        render.drawRectOutline(30, 512 - center, 200, 176, 2)
        render.drawRectOutline(994 - 200, 512 - center, 200, 176, 2)
        render.drawLine(0, 0, 1024, 1024)
        render.drawLine(1024, 0, 0, 1024)
    end
    render.selectRenderTarget(name)
    do
        render.clear(Color(0, 0, 0, 0))
        render.setRenderTargetTexture("mat")
        render.drawTexturedRectUV(0, 0, 1024, 1024, 0, 0, -1, 0.5)
    end
    render.destroyRenderTarget("cells")
    render.destroyRenderTarget("cellsPerPlayer")
    render.destroyRenderTarget("mat")
    render.selectRenderTarget()
    return true
end



TableTexture = CMaterial:new("table", "VertexLitGeneric")
    :setInitialize(function(mat)
        mat:setInt("$flags", 256)
        if render.renderTargetExists("cells") then return end
        render.createRenderTarget("mat")
        render.createRenderTarget("cells")
        render.createRenderTarget("cellsPerPlayer")
    end)
    :setGeneration(generate)
    :create()

