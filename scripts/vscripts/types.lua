
-- I'll put here classes definitions for auto-completion

---@class t_vec
---@field     x number
---@field     y number
---@field     z number

---@class t_ability_event
---@field     caster_entindex
---@field     unit CDOTA_BaseNPC
---@field     caster CDOTA_BaseNPC
---@field     attacker CDOTA_BaseNPC
---@field     target CDOTA_BaseNPC
---@field     ability CDOTABaseAbility
---@field     target_points
---@field     target_entities
---@field     ScriptFile string
---@field     Function string

---@class t_spawn_event
---@field target CDOTA_BaseNPC
---@field caster CDOTA_BaseNPC
---@field caster_entindex
---@field ScriptFile
---@field Function
---@field ability CDOTABaseAbility

local self = {}

---@return CDOTABaseAbility
function self:t_abil(v) return v end

---@return Vector | t_vec
function self:t_vec(v) return v end

return self
