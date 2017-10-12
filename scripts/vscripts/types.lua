
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

return {
    ---@return Vector | t_vec
    t_vec = function(userdata) return userdata end,
    ---@return CDOTABaseAbility
    t_abil = function(v) return v end

}