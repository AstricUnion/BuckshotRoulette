if CLIENT then

    local itemsMat = model.newMaterial("armor", "VertexLitGeneric")
    local mat = Matrix()
    mat:setScale(Vector(0.75, 0.75, 0.75))
    itemsMat:setMatrix("$basetexturetransform", mat)
    itemsMat:setInt("$realwidth", 1024)
    itemsMat:setInt("$realheight", 1024)
    itemsMat:setInt("$flags", 256)
    itemsMat:setTextureURL("$basetexture", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/textures/items.png")

    local itemsMesh = model.newMesh("armor", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/mesh/items.obj")
    itemsMesh:setMaterial("armor")
    itemsMesh:load()

end


---@class model
local model = model
local hitbox = model.hitbox
local vertex = model.vertex
local holo = model.holo

local mdl = model.new("items", hitbox {
    vertex {"cube", Vector(0, 0, 6), Angle(0, 0, 0), Vector(5, 5, 5)},
    mass = 10
})
    :add("base", holo { ang = Angle(90, 0, 0), model = "models/holograms/cube.mdl", mesh = "items", meshPart = "cigarette_box", scale = Vector(1, 1, 1)} )

if SERVER then
    local created = mdl:create()
    created:setPos(chip():getPos() + Vector(0, 0, 50))
end
