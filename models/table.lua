-- Памятка по стилю (просто рекомендация)
--[[
    * Если что-то можно не писать (прописать nil, например) -  не пишите
    * Частоиспользуемые материалы/цвет можно выводить в переменные (таблицы цвета, например)
    * Ставить пробелы после запятых и для таблиц параметров (после `{` и перед `}`)
    * Vector() и Angle() для нулевых
    * Если получается очень длинная холка (дофига параметров) - разделите на строки, не пожалеете
    * Указывайте уточнения в комментариях
--]]


---@class model
local model = model
local hitbox = model.hitbox
local vertex = model.vertex
local part = model.part
local holo = model.holo
local rig = model.rig

-- Раскомментировать для вида ригов
-- model.setRigVisible(true)

local function tablo(ang)
    return function()
        local prt = part {
            rig(Vector(0,0,0)),
            holo {Vector(24.5, 0, 28.75), Angle(90, 0, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.05, 0.27, 0.075), material = "models/gibs/metalgibs/metal_gibs"},
            holo {Vector(24.5, 0, 28.75), Angle(90, 180, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.05, 0.27, 0.075), material = "models/gibs/metalgibs/metal_gibs"},
            holo {Vector(24.5, 0, 29.0), Angle(7, 0, 0), "models/xqm/panel1x1.mdl", Vector(0.225, 0.45, 0.9), material = "models/gibs/metalgibs/metal_gibs"},
            holo {Vector(24.5, 0, 29.5), Angle(7, 0, 0), "models/xqm/panel1x1.mdl", Vector(0.215, 0.44, 0), color = Color(0, 0, 0), material = "models/gibs/metalgibs/metal_gibs"},
            holo {Vector(37, 0, 30), Angle(0, 180, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.226, 0.3), material = "models/gibs/metalgibs/metal_gibs"},
            holo {Vector(26, 26, 30), Angle(0, 225, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.235, 0.3), material = "models/gibs/metalgibs/metal_gibs"}
        }
        local tab = prt()
        tab:setAngles(ang)
        return tab
    end
end


if CLIENT then
    local mat = model.newMaterial("table", "VertexLitGeneric")
    mat:setTextureURL("$basetexture", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/textures/table.png")
    mat:setInt("$flags", 256)
end

local mdl = model.new("table", part {
    rig ( Vector(), Angle() ),
    tablo(Angle(0, 0, 0)),
    tablo(Angle(0, 90, 0)),
    tablo(Angle(0, -90, 0)),
    tablo(Angle(0, 180, 0))
})
    :add("surface", holo {Vector(0, 0, 29), Angle(), "models/holograms/plane.mdl", Vector(6), material = "table"})

-- Для теста (раскомментировать, желательно закомментировать обратно перед коммитом)
if SERVER then
    local origin = mdl:create()
    origin:setPos(chip():getPos())
    origin:setAngles(chip():getAngles())
end
