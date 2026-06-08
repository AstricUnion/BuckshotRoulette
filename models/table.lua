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

materm = "models/gibs/metalgibs/metal_gibs"

local function tablo(ang)
    return function()
        local prt = part {
            rig(Vector(0,0,0)),
            
            
            
            holo {Vector(10, 0, 29), Angle(0, 0, 90), "models/props_pipes/pipeset02d_64_001a.mdl", Vector(0.47, 0.8, 0.5), material = materm},
            holo {Vector(37, 15, 29.1), Angle(0, 90, 90), "models/props_debris/rebar_smallnorm01c.mdl", Vector(0.5, 0.1, 0.4), material = materm},
            
            holo {Vector(37, -16, 29), Angle(0, -90, -90), "models/props_debris/rebar_smallnorm01c.mdl", Vector(0.5, 0.1, 0.5), material = materm},
            holo {Vector(14.25, 13.25, 29.2), Angle(0, -45.45, 90), "models/props_debris/rebar001b_48.mdl", Vector(0.75, 0.1, 0.75), material = materm},
            holo {Vector(37, -5, 29), Angle(0, 175, 90), "models/props_debris/rebar001b_48.mdl", Vector(0.75, 0.1, 0.75), material = materm},
            holo {Vector(26.75, 25.75, 28.9), Angle(0, -45, 0), "models/props_pipes/pipe03_tjoint01.mdl", Vector(0.1, 0.15, 0.1), material = materm},
            
            holo {Vector(37, -16, 28.9), Angle(0, 90, 0), "models/props_pipes/pipe03_connector01.mdl", Vector(0.2, 0.075, 0.075), material = materm},
        
            
            holo {Vector(22, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.026, 0.11, 0.05), material = materm},
            holo {Vector(22, 0, 29), Angle(0, 0, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.1, 0.11, 0.05), material = materm},
            holo {Vector(22.5, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(22.4, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(22.3, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(22.2, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(19, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(20.8, 4.91, 29), Angle(0, 180, 0), "models/hunter/plates/plate.mdl", Vector(1.17, 0.2, 0.79), material = materm},
            holo {Vector(20.8, -4.91, 29), Angle(0, 180, 0), "models/hunter/plates/plate.mdl", Vector(1.17, 0.2, 0.79), material = materm},
            holo {Vector(38, 12, 31), Angle(0, 0, 90), "models/props_c17/furnitureshelf001a.mdl", Vector(0.1, 0.1, 0.109), material = materm},
            holo {Vector(38, 12, 31), Angle(0, 180, 90), "models/props_c17/furnitureshelf001a.mdl", Vector(0.1, 0.1, 0.109), material = materm},
            holo {Vector(37, 12, 31), Angle(83, 180, 0), "models/xqm/panel1x1.mdl", Vector(0.175, 0.375, 0.8), material = materm},
            holo {Vector(36.9, 12, 31), Angle(83, 180, 0), "models/xqm/panel1x1.mdl", Vector(0.175, 0.375, 0), color = Color(0, 0, 0), material = materm},
            holo {Vector(27.3, 0, 29.2), Angle(90, 90, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.025, 0.125, 0.109), material = materm},
            holo {Vector(27.3, 0, 29.2), Angle(90, -90, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.025, 0.125, 0.109), material = materm},
            holo {Vector(27.15, 0, 29.5), Angle(7, 0, 0), "models/xqm/panel1x1.mdl", Vector(0.225, 0.35, 0.9), material = materm},
            holo {Vector(27.15, 0, 30.0), Angle(7, 0, 0), "models/xqm/panel1x1.mdl", Vector(0.215, 0.34, 0), color = Color(0, 0, 0), material = materm},
            holo {Vector(37, 0, 29), Angle(0, 180, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.314, 0.3), material = materm},
            holo {Vector(29, 29, 29), Angle(0, 225, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.175, 0.3), material = materm}
        }
        local tab = prt()
        tab:setAngles(ang)
        return tab
    end
end

local function piedistal1(ang)
    return function()
        local prt = part {
            rig(Vector(0,0,0)),
            holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.4,0.4,0.3), material = materm},
            holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.6,0.6,0.4), material = materm},
            holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.5,0.5,0.4), material = materm}
        }
        local tab = prt()
        tab:setAngles(ang)
        return tab
    end
end

local function piedistal2(ang)
    return function()
        local prt = part {
            rig(Vector(0,0,0)),
            holo {Vector(0, 0, 29), Angle(), "models/mechanics/wheels/wheel_speed_72.mdl", Vector(0.3,0.3,0.6), material = materm}
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
    
    piedistal1(Angle()),
    piedistal2(Angle()),
    tablo(Angle()),
    tablo(Angle(0, 90, 0)),
    tablo(Angle(0, -90, 0)),
    tablo(Angle(0, 180, 0))
})
    :add("surface", holo {Vector(0, 0, 29), Angle(), "models/holograms/plane.mdl", Vector(6.25), material = "table"})

-- Для теста (раскомментировать, желательно закомментировать обратно перед коммитом)
if SERVER then
    local origin = mdl:create()
    origin:setPos(chip():getPos())
    origin:setAngles(chip():getAngles())
end
