
if klesun == nil then klesun = {} end

-- this file provides actual code with abilities logic
-- need to put it here cuz we want to reload it in game


-- DeepPrintTable(getmetatable(point))
---@class t_vec
---@field     x number
---@field     y number
---@field     z number
---@return Vector | t_vec
local t_vec = function(userdata) return userdata end

---@class t_ability_event
---@field     caster_entindex
---@field     unit CDOTA_BaseNPC
---@field     caster CDOTA_BaseNPC
---@field     attacker CDOTA_BaseNPC
---@field     ability CDOTABaseAbility
---@field     target_points
---@field     target_entities
---@field     ScriptFile string
---@field     Function string

---@param event t_ability_event | t_uronitj_shkaf_event
---@class t_uronitj_shkaf_event
---@field     AoERadius number
---@field     huj Vector
local UronitjShkaf = function(event)
    local keys = klesun.lang.Keys(event)
    klesun.lang.Log('keys', keys)

    local caster = event.caster
    local aoe = event.AoERadius
    local spellPoint = t_vec(event.target_points[1])
    print('Ronjaem Cabriolet Alexa hujalexa!')
    klesun.lang.Log('point x', spellPoint.x)
    klesun.lang.Log('point y', spellPoint.y)
    klesun.lang.Log('point z', spellPoint.z)
    klesun.lang.Log('aoe', aoe)
    --DeepPrintTable(event.AoERadius)

    local creepTeam = math.random() > 0.5
        and caster:GetTeam()
        or DOTA_TEAM_NEUTRALS;

    local offsets = {
        Vector(aoe, 0, 128),
        Vector(0, aoe, 128),
        Vector(-aoe, 0, 128),
        Vector(0,- aoe, 128),
    }
    for _,offset in pairs(offsets) do
        local creepPoint = spellPoint + offset
        local spawnedCreep = CreateUnitByName(
            "npc_dota_creature_gnoll_assassin", creepPoint,
            false, caster, caster, creepTeam
        )
    end
end

klesun.abilImpl = {
    UronitjShkaf = UronitjShkaf,
}