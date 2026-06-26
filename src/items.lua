---@class items
---@field registered table<string, Item> Registered items
---@field inited table<number, Item> Inited items, player already took it from box
local items = {}
items.registered = {}
items.inited = {}

local TABLEHEIGHT = 32
---Slots positions (by IDs, for player, relative to seat):
---1 3   7 5
---2 4   8 6
items.slotPositions = {
    {Vector(-18, 29, TABLEHEIGHT), Angle()},
    {Vector(-17, 22, TABLEHEIGHT), Angle()},
    {Vector(-9, 29, TABLEHEIGHT), Angle()},
    {Vector(-10, 21, TABLEHEIGHT), Angle()},

    {Vector(17.5, 29, TABLEHEIGHT), Angle()},
    {Vector(18, 20, TABLEHEIGHT), Angle()},
    {Vector(10, 29, TABLEHEIGHT), Angle()},
    {Vector(10, 22, TABLEHEIGHT), Angle()},
}

---@class Item
---@field Identifier string Identifier of item
---@field Name string Pretty name of item, you can see this on hover on item slot
---@field Model string|fun() Model of item
---@field Offset Vector Offset of model
---@field Angle Angle Angle offset of model
---@field id number
---@field animation number
---@field seat Vehicle
---@field model Entity [CLIENT] Client-side hologram. For view
local Item = {}
Item.__index = Item

Item.Offset = Vector()
Item.Angle = Angle()



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

    ---[SERVER] Remove item
    function Item:remove()
        items.inited[self.id] = nil
        net.start("BuckshotItemRemove")
            net.writeUInt(self.id, 32)
        net.send(find.allPlayers())
        setmetatable(self, nil)
    end

    ---[SERVER] Use item
    function Item:use()
        items.inited[self.id] = nil
        net.start("BuckshotItemUse")
            net.writeUInt(self.id, 32)
        net.send(find.allPlayers())
        self:onUse()
        setmetatable(self, nil)
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
                obj.model:setPos(ent:localToWorld(Vector(0, 20, 32)))
                obj.model:setParent(ent)
                local pos, ang = localToWorld(self.Offset, self.Angle, Vector(0, 20, 36), Angle(30, 20, 0))
                obj.animation = tween.start(tween.new {
                    tween.param {0, 0.3, obj.model, tween.ParamProperties.LOCALPOS, nil, pos, math.easeOutQuart},
                    tween.param {0, 0.3, obj.model, tween.ParamProperties.LOCALANGLES, nil, ang, math.easeOutQuart}
                })
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
        local pos, ang = localToWorld(self.Offset, self.Angle, unpack(items.slotPositions[id]))
        if self.animation then tween.stop(self.animation) end
        self.animation = tween.start(tween.new {
            tween.param {0, 0.2, self.model, tween.ParamProperties.LOCALPOS, nil, pos, math.easeOutQuart},
            tween.param {0, 0.2, self.model, tween.ParamProperties.LOCALANGLES, nil, ang, math.easeOutQuart}
        })
    end

    ---[CLIENT] Hover item
    ---@param id number Index of slot
    function Item:hover(id)
        local pos = localToWorld(self.Offset, self.Angle, unpack(items.slotPositions[id]))
        if self.animation then tween.stop(self.animation) end
        self.animation = tween.start(tween.new {
            tween.param {0, 0.2, self.model, tween.ParamProperties.LOCALPOS, nil, pos + Vector(0, 0, 2), math.easeOutQuart},
        })
    end

    ---[CLIENT] Unhover item
    ---@param id number Index of slot
    function Item:unhover(id)
        local pos = localToWorld(self.Offset, self.Angle, unpack(items.slotPositions[id]))
        if self.animation then tween.stop(self.animation) end
        self.animation = tween.start(tween.new {
            tween.param {0, 0.2, self.model, tween.ParamProperties.LOCALPOS, nil, pos, math.easeOutQuart},
        })
    end


    hook.add("Think", "BuckshotInitializeItems", function()
        if table.isEmpty(toInit) then return end
        cor()
    end)

    -- Initialize entity on client
    net.receive("BuckshotInitializeItems", function()
        toInit = table.add(toInit, net.readTable())
    end)

    -- Remove entity on client
    net.receive("BuckshotItemRemove", function()
        local id = net.readUInt(32)
        local item = items.inited[id]
        item.model:remove()
        setmetatable(item, nil)
        items.inited[id] = nil
    end)

    -- Use entity on client
    net.receive("BuckshotItemUse", function()
        local id = net.readUInt(32)
        local item = items.inited[id]
        item:onUse()
        setmetatable(item, nil)
        items.inited[id] = nil
    end)
end

---[SHARED] Hook on use item
function Item:onUse() end

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

return items
