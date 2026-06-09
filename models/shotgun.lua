---@class model
local model = model
local part = model.part
local holo = model.holo
local rig = model.rig


model.new("shotgun", part {
    rig (Vector(), Angle()),
    holo {Vector(), Angle(0, 0, 90), "models/weapons/w_annabelle.mdl"}
})
