---@class items
---@field registered table<string, Item> Registered items
---@field inited table<number, Item> Inited items, player already took it from box
local items = {}
items.registered = {}
items.inited = {}

local TABLEHEIGHT = 29
---Slots positions (by IDs, for player, relative to seat):
---1 3   7 5
---2 4   8 6
items.slotPositions = {
    Vector(-18, 29, TABLEHEIGHT),
    Vector(-17, 22, TABLEHEIGHT),
    Vector(-9, 29, TABLEHEIGHT),
    Vector(-10, 21, TABLEHEIGHT),

    Vector(17.5, 29, TABLEHEIGHT),
    Vector(18, 20, TABLEHEIGHT),
    Vector(10, 29, TABLEHEIGHT),
    Vector(10, 22, TABLEHEIGHT)
}

---@class Item
---@field Identifier string Identifier of item
---@field Name string Pretty name of item, you can see this on hover on item slot
---@field Model string|fun() Model of item
---@field id number
---@field seat Vehicle
---@field model Entity [CLIENT] Client-side hologram. For view
local Item = {}
Item.__index = Item



if SERVER then
    ---[SERVER] Initialize new item
    ---@param seat Vehicle
    ---@return Item obj
    function Item:new(seat)
        local id = #items.inited+1
        local obj = setmetatable({ id = id, seat = seat }, self)
        items.inited[id] = obj
        net.start("BuckshotInitializeItems")
            net.writeTable({{id = id, seatId = seat:entIndex(), identifier = self.Identifier }})
        net.send(find.allPlayers())
        return obj
    end

    hook.add("ClientInitialized", "BuckshotInitializeItems", function(ply)
        if table.isEmpty(items.inited) then return end
        local toInit = {}
        for _, v in pairs(items.inited) do
            toInit[#toInit+1] = {id = v.id, seatId = v.seat:entIndex(), identifier = v.Identifier}
        end
        net.start("BuckshotInitializeItems")
            net.writeTable(toInit)
        net.send(ply)
    end)

    ---[SERVER] Create new item
    ---@param seat Vehicle Seat to create item
    ---@param identifier string Identifier, to identify item type
    ---@return Item item
    function items.new(seat, identifier)
        local item = items.registered[identifier]
        return item:new(seat)
    end
else
    ---[CLIENT] Create entity model
    ---@return Entity
    function Item:createModel()
        return isstring(self.Model) and hologram.create(Vector(), Angle(), self.Model) or self.Model()
    end

    local toInit = {}
    local cor = coroutine.wrap(function()
        while true do
            coroutine.yield()
            local newToInit = {}
            for i, v in ipairs(toInit) do
                newToInit[i] = v
                local self = items.registered[v.identifier]
                if !self then goto cont end
                local ent = entity(v.seatId)
                if !isValid(ent) then goto cont end
                local obj = setmetatable({ id = v.id, seat = ent }, self)
                obj.model = obj:createModel()
                obj.model:setPos(ent:localToWorld(Vector(0, 20, 36)))
                obj.model:setParent(ent)
                items.inited[v.id] = obj
                newToInit[i] = nil
                ::cont::
            end
            toInit = newToInit
        end
    end)

    ---[CLIENT] Move item to slot
    ---@param id number Index of slot
    function Item:moveToSlot(id)
        local pos = items.slotPositions[id]
        self.model:setPos(self.seat:localToWorld(pos))
    end


    hook.add("Think", "BuckshotInitializeItems", function()
        if table.isEmpty(toInit) then return end
        cor()
    end)

    -- Initialize entity on client
    net.receive("BuckshotInitializeItems", function()
        toInit = table.add(toInit, net.readTable())
    end)
end

---[SHARED] Register new item class
---@param class table
function items.register(class)
    local id = class.Identifier
    if !id then
        throw("This class has no identifier")
        return
    end
    local inheritedClass = setmetatable(class, Item)
    inheritedClass.__index = class
    items.registered[id] = class
end


---@class Beer: Item
local Beer = {}
Beer.Identifier = "beer"
Beer.Model = "models/props_junk/popcan01a.mdl"
items.register(Beer)


return items
