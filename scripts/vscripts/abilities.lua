
local types = require('types')
local lang = require('reloaded.lang')

---@param castPoint t_vec | Vector
local NormalizeTowerPoint = function(castPoint, hullRadius)
    local xRest = castPoint.x % (hullRadius * 2)
    local yRest = castPoint.y % (hullRadius * 2)

    return Vector(
        castPoint.x - xRest + (xRest > hullRadius and hullRadius * 2 or 0),
        castPoint.y - yRest + (yRest > hullRadius and hullRadius * 2 or 0),
        castPoint.z
    )
end

---@param event t_ability_event | t_uronitj_shkaf_event
BuildPrisonTower = function(event)
    local caster = event.caster
    local hullRadius = 64
    local spellPoint = NormalizeTowerPoint(event.target_points[1], hullRadius)

    obstaclesInHull = false -- TODO: implement
    if obstaclesInHull then
        print('Нельзя сотворить здесь')
    end

    local creepPoint = spellPoint
    local spawnedCreep = CreateUnitByName(
        'npc_dota_prison_tower', creepPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)
    spawnedCreep:SetControllableByPlayer(caster:GetPlayerID(), true)
    spawnedCreep:SetRenderColor(128,128,192)
end

---@param event t_ability_event
TowerHeal = function(event)
    local caster = event.caster
    local target = event.target -- victim of the attack
    local ability = event.ability
    local healAmount = caster:GetAttackDamage()
    target:Heal(healAmount, target)
end

---@param event t_ability_event
HealAutocast = function(event)
    local caster = event.caster
    local target = event.target -- victim of the attack
    local ability = event.ability

    if ability:GetAutoCastState() then
        if ability:IsCooldownReady() then
            if not ability:IsChanneling() then
                if target:GetHealth() < target:GetMaxHealth() then
                    caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
                end
            end
        end
    end
end

---@param event t_ability_event
SpawnTowerCreep = function(event)
    for i = 0, 1, 1 do
        local owner = event.caster:GetPlayerOwner()
        local huj = event.caster.huj -- TODO: do it correctly. If you set the tower as owner, you won't get money from enemies killed by creep
        local unit = CreateUnitByName(
            'npc_dota_tower_creep', event.caster:GetAbsOrigin() - Vector(0,-20,0),
            false, huj, huj, huj:GetTeam()
        )

        -- to prevent it from being stuck in parent
        unit:AddNewModifier(nil, nil, 'modifier_phased', {duration = 0.05})

        unit:SetControllableByPlayer(event.caster:GetPlayerOwnerID(), true)
        unit:SetBaseDamageMin(event.caster:GetAttackDamage())
        unit:SetBaseDamageMax(event.caster:GetAttackDamage())
        unit:SetBaseMaxHealth(250)

        -- order spawned creep to go to nearest enemy
        local nearestEnemy = Entities:FindByClassnameNearest('npc_dota_creature', unit:GetAbsOrigin(), 30000)
        if nearestEnemy ~= nil then
            ExecuteOrderFromTable({
                UnitIndex = unit:GetEntityIndex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = nearestEnemy:GetAbsOrigin(), Queue = true
            })
        end
    end
end

---@param event t_ability_event
SpawnTowerCreepAutocast = function(event)
    local ability = event.ability
    if ability:GetAutoCastState() then
        if ability:IsCooldownReady() then
            ability:CastAbility()
        end
    end
end