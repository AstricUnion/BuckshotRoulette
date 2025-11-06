--@client

--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/cmaterial.lua as cmat
require("cmat")

local function generate(name)
    render.selectRenderTarget("standUV")
    do
        local green = material.load("models/props_pipes/GutterMetal01a")
        render.clear(Color(0, 0, 0, 0))
        render.setColor(Color(150, 200, 150))
        render.drawRect(0, 0, 1024, 1024)
        render.setMaterialEffectSub(green)
        render.drawTexturedRect(0, 0, 1024, 1024)
        render.setMaterial()
        render.setColor(Color())
        render.drawLine(0, 0, 1024, 1024)
        render.drawLine(1024, 0, 0, 1024)
    end
    render.selectRenderTarget(name)
    do
        render.clear(Color(0, 0, 0, 0))
        render.setRenderTargetTexture("standUV")
        render.drawTexturedRectUV(0, 0, 1024, 1024, -0.6, -0.6, 0.6, 0.6)
    end
    render.selectRenderTarget()
    render.destroyRenderTarget("standUV")
    return true
end



StandTexture = CMaterial:new("stand", "VertexLitGeneric")
    :setInitialize(function(mat)
        mat:setInt("$flags", 256)
        if render.renderTargetExists("standUV") then return end
        render.createRenderTarget("standUV")
    end)
    :setGeneration(generate)
    :create()

