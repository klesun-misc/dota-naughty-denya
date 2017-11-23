
local build_tower_base = require('abilities.build_tower_base')

---@param casterTower CDOTA_BaseNPC|CBaseEntity
---@param tetherSpell CDOTA_Ability_Lua
local ChooseTetherTarget = function(casterTower, tetherSpell)
    local center = casterTower:GetAbsOrigin()
    local range = 1200
    local targets = {}

    local ent = Entities:FindInSphere(nil, center, range)
    while ent do
        if not ent:IsAlive()
        or type(ent.IsHero) ~= 'function'
        or ent:GetHealth() < 1
        or (
            tetherSpell:CastFilterResultTarget(ent) ~= UF_SUCCESS and
            tetherSpell:CastFilterResultTarget(ent) ~= nil
        )
        then --[[skip]] else
            if ent:FindAbilityByName("prison_tether") then
                return ent
            else
                -- should fix so that tower could not be linked
                -- to everything at once before uncommenting
                --table.insert(targets, ent)
            end
        end
        ent = Entities:FindInSphere(ent, center, range)
    end
    return targets[1]
end

build_prison_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_prison_tower',
    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTA_Ability_Lua
    OnCreated = function(tower, abil)
    	local dmg = abil:GetSpecialValueFor('dps')

        tower:SetBaseDamageMax(dmg)

        tower:SetControllableByPlayer(abil:GetCaster():GetPlayerID(), true)
        tower:SetRenderColor(128,128,192)

        local tether = tower:FindAbilityByName('prison_tether')
        if tether then
            local target = ChooseTetherTarget(tower, tether)
            if target then
                -- does not work, is it because of ability_lua?
                --tower:CastAbilityOnTarget(target, tether, abil:GetCaster():GetPlayerID())
                ExecuteOrderFromTable({
                    UnitIndex = tower:GetEntityIndex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    TargetIndex = target:GetEntityIndex(),
                    AbilityIndex = tether:GetEntityIndex(),
                    Queue = true,
                })
            end
        end
    end,
})
