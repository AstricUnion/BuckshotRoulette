---@name Buckshot Roulette
---@author AstricUnion
---@shared
---@include buckshot/libs/turns.lua
---@include buckshot/libs/camera.lua
---@include buckshot/src/items.lua
---@include buckshot/src/interactive.lua
---@include buckshot/src/game.lua

---@class turns
turns = require("buckshot/libs/turns.lua")

---@class camera
camera = require("buckshot/libs/camera.lua")

---@class items
items = require("buckshot/src/items.lua")

---@class interactive
interactive = require("buckshot/src/interactive.lua")


require("buckshot/src/game.lua")
