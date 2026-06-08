---@include buckshot/libs/model/model.lua
---@include buckshot/libs/tween/tweens.lua
---@includedir buckshot/models

---@class model
model = require("buckshot/libs/model/model.lua")

---@class tween
tween = require("buckshot/libs/tween/tweens.lua")

dodir("buckshot/models", {})
