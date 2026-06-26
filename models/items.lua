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

model.new(
    "cigarette_pack",
    holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "cigarette_box", scale = Vector(1) }
)
    :add("lid", holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "cigarette_lid", scale = Vector(1)})

model.new(
    "jammer",
    holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "jammer_lod", scale = Vector(0.5) }
)

model.new(
    "adrenaline",
    holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "adrenaline_main_parent", scale = Vector(0.33) }
)
    :add("cap", holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "adrenaline_cap", scale = Vector(0.33)})

model.new(
    "burner_phone",
    holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "burner_phone_main_parent", scale = Vector(0.33)}
)
    :add("lid", holo { model = "models/holograms/cube.mdl", mesh = "items", meshPart = "burner_phone_lid", scale = Vector(0.33)})
