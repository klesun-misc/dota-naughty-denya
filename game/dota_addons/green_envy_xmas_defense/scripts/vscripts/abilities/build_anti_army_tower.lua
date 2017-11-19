
local types = require('types')
local lang = require('reloaded.lang')
local build_tower_base = require('abilities.build_tower_base')
local bgm = require('bgm')

local ChooseTheNeighborest = function(units, range)
    local neighborest = nil
    local maxNeighbors = -1
    for _,unit in pairs(units) do
        local neighborCnt = 0
        for _,neighbor in pairs(units) do
            if (unit:GetAbsOrigin() - neighbor:GetAbsOrigin()):Length() <= range then
                neighborCnt = neighborCnt + 1
            end
        end
        if neighborCnt >= maxNeighbors then
            neighborest = unit
            maxNeighbors = neighborCnt
        end
    end
    return neighborest
end

---@param attacker CDOTA_BaseNPC
---@return CDOTA_BaseNPC
local ChooseAttackTarget = function(attacker)
    local targets = {}
    local ent = Entities:FindInSphere(nil, attacker:GetAbsOrigin(), attacker:GetAttackRange())
    while ent do
        if not ent:IsAlive()
        or type(ent.IsHero) ~= 'function'
        or not ent:IsOpposingTeam(attacker:GetTeamNumber())
        or ent:GetHealth() < 1
        then --[[skip]] else
            table.insert(targets, ent)
        end
        ent = Entities:FindInSphere(ent, attacker:GetAbsOrigin(), attacker:GetAttackRange())
    end
    return ChooseTheNeighborest(targets, 200)
end

build_anti_army_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_anti_army_tower',

    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetRenderColor(192,128,0)

        local dmgMult = abil:GetSpecialValueFor('dmg_mult')
        local dmg = (tower:GetBaseDamageMin() + tower:GetBaseDamageMax()) / 2
        local lvl = abil:GetLevel()
        for i = 1, lvl - 1, 1 do
            dmg = dmg * dmgMult
        end
        tower:SetBaseDamageMin(dmg)
        tower:SetBaseDamageMax(dmg)
        tower:SetIdleAcquire(true)

        -- need to apply any modifier to update npc gui hp numbers
        tower:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 0.05})

        tower:SetThink(function()
            local target = ChooseAttackTarget(tower)
            if target then ExecuteOrderFromTable({
                UnitIndex = tower:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = target:entindex(),
            }) end
            return 0.5
        end)

        bgm().SoundOn('bgm_small_victory', tower, 3)
    end,
})