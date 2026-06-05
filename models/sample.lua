-- Пример для модели, достаточно скопировать файл и херачить
-- (да, я превратил вилку HoloCreator в кухонный комбайн)

-- Памятка по параметрам holo (можно использовать без имен в том же порядке):
--[[
    1. pos -          Оффсет холки
    2. ang -          Угол холки
    3. model -        Модель холки
    4. scale -        Скейл
    5. size -         Размер (по юнитам)
    6. submaterial -  Айди сабматериала (для использования setSubMaterial на модели)
    7. subcolor -     Айди сабколора (для использования setSubColor на модели)
    8. material -     Материал. Может быть идентификатором для кастомного материала, просто материалом или таблицей сабматериалов
    9. color -        Цвет холки
    10. noLight -     Отключить освещение холки
    11. mesh -        Идентификатор мэша холки
    12. meshPart -    Идентификатор части мэша. Можно найти в obj: "o meshPart"
    13. clips -       Список клипов. Первым указывается позиция, вторым нормаль. Прошу заметить, что размер и скейл умножают значение, так что выставленное на миниатюрной версии будет также и на полной
    14. cullmode -    Выворачивает нормали при 1. Можно использовать, чтобы отражать холки
]]


-- Примеры использования функции holo:
--[[
    holo { ang = Angle(90, 0, 0), scale = Vector(1.07, 1, 1.1), model = "models/holograms/cube.mdl", mesh = "armor", meshPart = "helmet_light"}

    holo { Vector(-8, -36, 96), Angle(30, 90, 0), "models/props_c17/handrail04_short.mdl", subcolor = 1, Vector(6, 2, 6) },

    holo { Vector(0, 0, 168), Angle(0, 0, 0), "models/mechanics/robotics/stand.mdl", Vector(0.4, 0.4, 0.25), material = {[1] = "phoenix_storms/roadside", [2] = "phoenix_storms/roadside"}, submaterial = 1 },

    holo { 
        Vector(-108, 81, 10), Angle(90, 0, 0),
        "models/props_c17/canister_propane01a.mdl", Vector(1.8, 1.8, 3.5),
        subcolor = 1, clips = {
            {Vector(0, 0, 59.64), Vector(0, 0, -1)}
        }
    }
]]


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

local mdl = model.new("identifier", part {
    rig ( Vector(), Angle() )
    -- Здесь должна быть серверная часть, основная статическая часть моделей
})
    -- Кость с парентом к ригу
    :add("bone_name", part {})
    -- Кость с парентом к кости
    :add("bone_parent", "bone_name", part {})
    -- Создать новую последовательность (анимацию короче)
    :addSequence(
        "name", -- идентификатор
        2, -- продолжительность
        function(ent)
            -- старт
        end,

        function(ent, process)
            -- процесс
        end,

        function(ent)
            -- конец
        end
    )


-- Для теста (раскомментировать, желательно закомментировать обратно перед коммитом)
--[[
if SERVER then
    local origin = mdl:create()
    origin:setPos(chip():getPos())
    origin:setAngles(chip():getAngles())
end
--]]
