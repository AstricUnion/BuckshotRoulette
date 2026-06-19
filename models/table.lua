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

local materm = "models/gibs/metalgibs/metal_gibs"
local copper = "metal4"
local white = "models/debug/debugwhite"

if CLIENT then
    for i=1, 4 do
        local id = "LifeScreen" .. i
        render.createRenderTarget(id)
        local screenMat = model.newMaterial(id, "VertexLitGeneric")
        screenMat:setTextureRenderTarget("$basetexture", id)
    end
    local mat = model.newMaterial("table", "VertexLitGeneric")
    mat:setTextureURL("$basetexture", "https://raw.githubusercontent.com/AstricUnion/BuckshotRoulette/refs/heads/main/textures/table.png")
    mat:setInt("$flags", 256)
end


local function tablo(ang)
    return function()
        local prt = part {
            rig(Vector(0,0,29)),



            holo {Vector(10, 0, 29), Angle(0, 0, 90), "models/props_pipes/pipeset02d_64_001a.mdl", Vector(0.47, 0.8, 0.5), material = materm},

            holo {Vector(37.0, 25, 22), Angle(0, 0, -90), "models/props_pipes/pipecluster16d_002a.mdl", Vector(0.1, 0.1, 0.15), material = materm},
            holo {Vector(37.0, 25, 20), Angle(0, 0, -90), "models/props_pipes/pipecluster16d_002a.mdl", Vector(0.1, 0.1, 0.15), material = materm},

            holo {Vector(28.0, 28.2, 10.45), Angle(0, 90, -90), "models/props_pipes/pipecluster32d_001a.mdl", Vector(0.075, 0.05, 0.15), material = materm},

            holo {Vector(37.5, 7.75, 29), Angle(0, 0, 0), "models/props_vents/vent_large_straight002.mdl", Vector(0.05, 0.075, 0.07), material = materm},
            holo {Vector(38.0, 7.75, 30), Angle(90, 0, 0), "models/props_vents/vent_large_straight002.mdl", Vector(0.05, 0.075, 0.07), material = materm},
            holo {Vector(37.4, 5.7, 30), Angle(90, 90, 0), "models/props_vents/vent_large_straight002.mdl", Vector(0.05, 0.04, 0.05), material = materm},
            holo {Vector(37.4, 10, 30), Angle(90, 90, 0), "models/props_vents/vent_large_straight002.mdl", Vector(0.05, 0.04, 0.05), material = materm},
            holo {Vector(37.0, 9.05, 29), Angle(0, 180, 0), "models/props_pipes/pipecluster32d_001a.mdl", Vector(0.025, 0.015, 0.025), color = Color(255, 90, 0), material = copper},
            holo {Vector(37.0, 7.95, 29), Angle(0, 180, 0), "models/props_pipes/pipecluster32d_001a.mdl", Vector(0.025, 0.015, 0.025), color = Color(255, 90, 0), material = copper},
            holo {Vector(37.0, 6.85, 29), Angle(0, 180, 0), "models/props_pipes/pipecluster32d_001a.mdl", Vector(0.025, 0.015, 0.025), color = Color(255, 90, 0), material = copper},
            holo {Vector(22, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.026, 0.11, 0.05), material = materm},
            holo {Vector(22, 0, 29), Angle(0, 0, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.1, 0.11, 0.05), material = materm},
            holo {Vector(22.5, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(22.4, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(19, 0, 29), Angle(0, 180, 0), "models/hunter/tubes/tube1x1x1c.mdl", Vector(0.05, 0.22, 0.05), material = materm},
            holo {Vector(20.8, 4.91, 29), Angle(0, 180, 0), "models/hunter/plates/plate.mdl", Vector(1.17, 0.2, 0.79), material = materm},
            holo {Vector(20.8, -4.91, 29), Angle(0, 180, 0), "models/hunter/plates/plate.mdl", Vector(1.17, 0.2, 0.79), material = materm},
            holo {Vector(37.8, 15, 31), Angle(0, 0, 90), "models/holograms/cube.mdl", Vector(0.2, 0.5, 0.78), material = materm}, -- optimized
            -- holo {Vector(38, 15, 31), Angle(0, 0, 90), "models/props_c17/furnitureshelf001a.mdl", Vector(0.1, 0.1, 0.109), material = materm},
            -- holo {Vector(38, 15, 31), Angle(0, 180, 90), "models/props_c17/furnitureshelf001a.mdl", Vector(0.1, 0.1, 0.109), material = materm},
            holo {Vector(37, 15, 31.5), Angle(83, 180, 0), "models/xqm/panel1x1.mdl", Vector(0.16, 0.35, 1.2), material = materm},
            holo {Vector(27.3, 0, 29.2), Angle(90, 90, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.025, 0.125, 0.109), material = materm},
            holo {Vector(27.3, 0, 29.2), Angle(90, -90, 0), "models/props_c17/furnitureshelf001a.mdl", Vector(0.025, 0.125, 0.109), material = materm},
            holo {Vector(27.15, 0, 29.5), Angle(7, 0, 0), "models/xqm/panel1x1.mdl", Vector(0.225, 0.35, 0.9), material = materm},
            holo {Vector(37, 0, 25.1), Angle(0, 0, 180), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.314, 1.2), material = materm},
            holo {Vector(29, 29, 25.1), Angle(0, 45, 180), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.175, 1.2), material = materm},
            holo {Vector(26, 26, 12), Angle(-90, 45, 180), "models/props_wasteland/prison_doortrack001a.mdl", Vector(5, 0.175, 1.2), material = materm},
            holo {Vector(32, 0, 12), Angle(-90, 0, 180), "models/props_wasteland/prison_doortrack001a.mdl", Vector(5, 0.314, 1.2), material = materm},
            holo {Vector(37, 0, 29), Angle(0, 180, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.314, 0.3), material = materm},
            holo {Vector(29, 29, 29), Angle(0, 225, 0), "models/props_wasteland/prison_doortrack001a.mdl", Vector(0.7, 0.175, 0.3), material = materm}
        }
        local tab = prt()
        tab:setAngles(Angle(0, ang, 0))
        return tab
    end
end

local function screen(ang)
    ang = math.normalizeAngle(ang - 90)
    local mat = "LifeScreen" .. math.ceil(ang / 90) + 3
    return part {
        holo {
            Vector(28.7, 0, 30.0):getRotated(Angle(0, ang, 0)),
            Angle(7, ang, 0),
            "models/holograms/plane.mdl",
            Vector(0.6, 0.6, 0.6),
            material = mat,
            noLight = true,
            clips = {{Vector(1, 0, 0), Vector(-1, 0, 0)}}
        },
        holo {
            Vector(36, 15, 30.1):getRotated(Angle(0, ang, 0)),
            Angle(97, ang, 0),
            "models/holograms/plane.mdl",
            Vector(0.6, 0.6, 0.6),
            material = mat,
            noLight = true,
            clips = {
                {Vector(0, 0, 0), Vector(-1, 0, 0)},
                {Vector(-5, 0, 0), Vector(1, 0, 0)}
            }
        },
    }
end

local function light(ang)
    return part {
        holo {Vector(0, 0, 29.8), Angle(0, ang, 0), "models/hunter/plates/plate.mdl", Vector(0.5, 14.15, 0.35), color = Color(100, 100, 100), material = white},
        holo {Vector(0, 0, 30), Angle(0, ang, 0), "models/hunter/plates/plate.mdl", Vector(0.35, 14.2, 0.25), color = Color(0, 0, 0), material = white},
    }
end

local piedistal1 = part {
    rig(Vector(0,0,29)),
    holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.4, 0.4, 0.3), material = materm},
    holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.6, 0.6, 0.4), material = materm},
    holo {Vector(0, 0, 29), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.5, 0.5, 0.4), material = materm},
    holo {Vector(0, 0, 31), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.5, 0.5, 0.15), material = "mechanics/metal2"},
    holo {Vector(0, 0, 31), Angle(), "models/props_phx/wheels/metal_wheel2.mdl", Vector(0.575, 0.575, 0.15), material = "mechanics/metal2"},
    holo {Vector(0, 0, 29), Angle(0, -45, 0), "models/hunter/plates/plate.mdl", Vector(0.1, 14.15, 1), material = "mechanics/metal2"},
    holo {Vector(0, 0, 29), Angle(0, 45, 0), "models/hunter/plates/plate.mdl", Vector(0.1, 14.15, 1), material = "mechanics/metal2"},
    -- потом фор сделаю, хз когда
    light(20), light(-20),
    light(25), light(-25),
    light(30), light(-30),
    light(35), light(-35),
    light(40), light(-40),
    light(50), light(-50),
    light(55), light(-55),
    light(60), light(-60),
    light(65), light(-65),
    light(70), light(-70),
    holo {Vector(11.7, 11.7, 25.7), Angle(0, -45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 2.45, 2.11), color = Color(200, 200, 200), material = white},
    holo {Vector(-11.7, -11.7, 25.7), Angle(0, -45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 2.45, 2.11), color = Color(200, 200, 200), material = white},
    holo {Vector(-11.7, 11.7, 25.7), Angle(0, 45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 2.45, 2.11), color = Color(200, 200, 200), material = white},
    holo {Vector(11.7, -11.7, 25.7), Angle(0, 45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 2.45, 2.11), color = Color(200, 200, 200), material = white}
}


local piedistal2 = part {
    rig(Vector(0,0,29)),
    holo {Vector(1, 0, 30), Angle(0, 180, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.225, 0.24, 2), material = "mechanics/metal2"},
    holo {Vector(-1, 0, 30), Angle(), "models/hunter/tubes/circle2x2c.mdl", Vector(0.225, 0.24, 2), material = "mechanics/metal2"},
    holo {Vector(0, 0, 27), Angle(), "models/hunter/plates/plate.mdl", Vector(2, 5, 2), material = "mechanics/metal2"},
    holo {Vector(0, 0, 31), Angle(0, 0, 180), "models/hunter/plates/plate.mdl", Vector(2, 5, 2), material = "mechanics/metal2"},
    holo {Vector(1, 0, 28), Angle(0, 180, 180), "models/hunter/tubes/circle2x2c.mdl", Vector(0.225, 0.24, 2), material = "mechanics/metal2"},
    holo {Vector(-1, 0, 28), Angle(0, 0, 180), "models/hunter/tubes/circle2x2c.mdl", Vector(0.225, 0.24, 2), material = "mechanics/metal2"},
    holo {Vector(1.2, 0, 30), Angle(0, 180, 0), "models/hunter/tubes/circle2x2c.mdl", Vector(0.215, 0.23, 2.2), material = "metal5"},
    holo {Vector(-1.2, 0, 30), Angle(), "models/hunter/tubes/circle2x2c.mdl", Vector(0.215, 0.23, 2.2), material = "metal5"},
    holo {Vector(0, 0, 27), Angle(), "models/hunter/plates/plate.mdl", Vector(1.7, 4.7, 2.1), material = "metal5"},
    holo {Vector(0, 0, 31), Angle(0, 0, 180), "models/hunter/plates/plate.mdl", Vector(1.7, 4.7, 2.1), material = "metal5"},
    holo {Vector(1.2, 0, 28), Angle(0, 180, 180), "models/hunter/tubes/circle2x2c.mdl", Vector(0.215, 0.23, 2.2), material = "metal5"},
    holo {Vector(-1.2, 0, 28), Angle(0, 0, 180), "models/hunter/tubes/circle2x2c.mdl", Vector(0.215, 0.23, 2.2), material = "metal5"},
    holo {Vector(0, 0, 27), Angle(0, 45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 7.55, 2.11), color = Color(200, 200, 200), material = white},
    holo {Vector(0, 0, 27), Angle(0, -45, 0), "models/hunter/plates/plate.mdl", Vector(0.05, 7.55, 2.11), color = Color(200, 200, 200), material = white}
}

local mdl = model.new("table", part {
    rig ( Vector(), Angle() ),

    piedistal1,
    piedistal2,
    tablo(0),
    tablo(90),
    tablo(-90),
    tablo(180)
})
    :add("surface", holo {Vector(0, 0, 29), Angle(), "models/holograms/plane.mdl", Vector(6.25), material = "table"})
    :add("screens", part {
        screen(90),
        screen(0),
        screen(-90),
        screen(180)
    })

-- Для теста (раскомментировать, желательно закомментировать обратно перед коммитом)
if SERVER then
    local origin = mdl:create()
    origin:setPos(chip():getPos())
    origin:setAngles(chip():getAngles())
end
