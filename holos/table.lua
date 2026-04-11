---@shared
---@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
local holos = require("holos")
---@class Holo
local Holo = holos.Holo
local Rig = holos.Rig
local SubHolo = holos.SubHolo


if SERVER then
    ---@class table
    local table = {
        origin = Holo(Rig()),
        surface = Holo(SubHolo(Vector(0, 0, 20), Angle(), "models/hunter/blocks/cube1x1x1.mdl", Vector(7, 7, 7), nil, nil, nil, "table"))
    }

    return table
else
    render.createRenderTarget("table")

    local mat = material.create("VertexLitGeneric")
    mat:setTextureURL("$basetexture", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/textures/table.png")
    mat:setInt("$flags", 256)

    hook.add("HoloInitialized", "table", function(id, holo)
        if id == "table" then
            holo:setSubMaterial(0, "!" .. mat:getName())
        end
    end)
end
