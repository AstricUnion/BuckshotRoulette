if CLIENT then

    local itemsMat = model.newMaterial("items", "VertexLitGeneric")
    itemsMat:setInt("$realwidth", 1024)
    itemsMat:setInt("$realheight", 1024)
    itemsMat:setInt("$flags", 256)
    itemsMat:setTextureURL("$basetexture", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/textures/items.png")

    local itemsMesh = model.newMesh("items", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/mesh/items.obj")
    itemsMesh:setMaterial("items")
    itemsMesh:load()

end


---@class model
local model = model
local hitbox = model.hitbox
local vertex = model.vertex
local holo = model.holo
local rig = model.rig

local mdl = model.new("cigarette_box", rig())
    :add("base", holo { ang = Angle(90, 0, 0), model = "models/holograms/cube.mdl", mesh = "items", meshPart = "cigarette_box", scale = Vector(1, 1, 1)} )

if SERVER then
    local created = mdl:create()
    created:setPos(chip():getPos() + Vector(0, 0, 50))
end
