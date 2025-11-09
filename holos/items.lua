--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/holos.lua as holos
--@server
require("holos")

items = {}


function items.Beer(pos, ang)
    local holo = SubHolo(nil, nil, "models/props_junk/PopCan01a.mdl")
    if !holo then return end
    holo:setPos(pos)
    holo:setAngles(ang)
    return holo
end

-- не пиши Angle(0) или Color(255) или Vector(0)
-- - это все бред и лучше написать без цифры внутри
-- а в нашей либе можно тупо nil писать
--
-- шож, дальше тупо создавай по функции на каждый предмет. вот заготовавовачки:
-- не забывай про return!
function items.HandSaw(pos, ang)
end

function items.MagnifyingGlass(pos, ang)
end

function items.Jammer(pos, ang)
end

function items.CigarettePack(pos, ang)
end

-- сигарета и зажигалка, для анимаций --
function items.Cigarette(pos, ang)
end

function items.Lighter(pos, ang)
end
----------------------------------------

function items.BurnerPhone(pos, ang)
end

function items.Adrenaline(pos, ang)
end

function items.Inverter(pos, ang)
end

function items.Remote(pos, ang)
end


-- чтобы тестить, херачь:
-- POS = chip():getPos() + Vector(0, 0, 50)
-- items.Beer(POS, Angle())

-- прочитал? сожги эти записи


return items
