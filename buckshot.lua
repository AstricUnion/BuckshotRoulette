---@name Buckshot Roulette
---@author AstricUnion
---@shared
---@include buckshot/libs/model/model.lua
---@include buckshot/libs/tween/tweens.lua
---@include buckshot/libs/turns.lua
---@include buckshot/libs/camera.lua
---@include buckshot/src/items.lua
---@include buckshot/src/interactive.lua
---@include buckshot/src/avatars.lua
---@include buckshot/src/game.lua
---@includedir buckshot/models

---@class tween
avatars = require("buckshot/src/avatars.lua")

---@class model
model = require("buckshot/libs/model/model.lua")

---@class tween
tween = require("buckshot/libs/tween/tweens.lua")

dodir("buckshot/models", {})

---@class turns
turns = require("buckshot/libs/turns.lua")

---@class camera
camera = require("buckshot/libs/camera.lua")

---@class items
items = require("buckshot/src/items.lua")

---@class interactive
interactive = require("buckshot/src/interactive.lua")


require("buckshot/src/game.lua")
