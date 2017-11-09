
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

---@param unit CDOTA_BaseNPC
local GetInsufHpPerc = function(unit)
    return (unit:GetMaxHealth() - unit:GetHealth()) / unit:GetMaxHealth()
end

---@param caster CDOTA_BaseNPC
---@param ability CDOTABaseAbility
local ChooseHealTarget = function(caster, ability)
    -- if there is a hero with less than 75% hp - heal him
    -- else heal the unit with least hp
    local sickestUnit = nil
    local sickestHero = nil
    local ent = Entities:FindInSphere(nil, caster:GetAbsOrigin(), ability:GetCastRange())
    while ent do
        local isValid = ent:IsAlive()
            and ent:GetTeamNumber() == caster:GetTeamNumber()
            and GetInsufHpPerc(ent) > 0.00000001
            and type(ent.IsHero) == 'function'

        if isValid then
            sickestUnit = sickestUnit or ent
            if GetInsufHpPerc(sickestUnit) < GetInsufHpPerc(ent) then
                sickestUnit = ent
            end
            if ent:IsHero() then
                sickestHero = sickestHero or ent
                if GetInsufHpPerc(sickestHero) < GetInsufHpPerc(ent) then
                    sickestHero = ent
                end
            end
        end
        ent = Entities:FindInSphere(ent, caster:GetAbsOrigin(), ability:GetCastRange())
    end

    return sickestHero
        and GetInsufHpPerc(sickestHero) > 0.25
        and sickestHero
        or sickestUnit
end

---@param event t_ability_event
HealAutocast = function(event)
    local caster = event.caster
    local ability = event.ability

    if ability:GetAutoCastState() then
        if ability:IsCooldownReady() then
            if not ability:IsChanneling() then
                local target = ChooseHealTarget(caster, ability)
                if target ~= nil then
                    caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
                end
            end
        end
    end
end

---@param event t_ability_event
SpawnTowerCreep = function(event)
    for i = 0, 1, 1 do
        local builder = event.caster.envyNs.builder
        local unit = CreateUnitByName(
            'npc_dota_tower_creep', event.caster:GetAbsOrigin() - Vector(0,-20,0),
            false, builder, builder, builder:GetTeam()
        )

        -- to prevent it from being stuck in parent
        unit:AddNewModifier(nil, nil, 'modifier_phased', {duration = 0.05})
		unit:AddNewModifier(builder, nil, 'modifier_kill', {duration = 60.00})

        unit:SetControllableByPlayer(event.caster:GetPlayerOwnerID(), true)
        unit:SetBaseDamageMin(event.caster:GetAttackDamage())
        unit:SetBaseDamageMax(event.caster:GetAttackDamage())
        unit:SetBaseMaxHealth(event.caster:GetMaxHealth() / 4)

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
SpawnEnvyMeleeCreep = function(event)
    local abil = event.ability
    local cost = abil:GetGoldCost(abil:GetLevel());
    if cost < 0 then 
        local playerId = event.caster:GetPlayerOwnerID()
        PlayerResource:ModifyGold(playerId, -cost, true, 0)
    end


    for i = 1, 1, 1 do
        local builder = event.caster.envyNs.builder
        local unit = CreateUnitByName(
            'npc_dota_creature_gnoll_assassin', event.caster:GetAbsOrigin() - Vector(0,-20,0),
            false, builder, builder, builder:GetTeam()
        )

        -- to prevent it from being stuck in parent
        unit:AddNewModifier(nil, nil, 'modifier_phased', {duration = 0.05})
		unit:AddNewModifier(builder, nil, 'modifier_kill', {duration = 90.00})

        --unit:SetControllableByPlayer(event.caster:GetPlayerOwnerID(), true)
        unit:SetBaseDamageMin(event.caster:GetAttackDamage())
        unit:SetBaseDamageMax(event.caster:GetAttackDamage())
        unit:SetBaseMaxHealth(event.caster:GetMaxHealth() / 4)

        local goal = Entities:FindByName(nil, 'creep_goal_mark')
            or Entities:FindByClassnameNearest('npc_dota_creature', unit:GetAbsOrigin(), 30000)
        if goal ~= nil then
            ExecuteOrderFromTable({
                UnitIndex = unit:GetEntityIndex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = goal, Queue = true
            })
        end
    end
end

---@param event t_ability_event
AutocastByColdown = function(event)
    local ability = event.ability
    if ability:GetAutoCastState() then
        if ability:IsCooldownReady() then
            ability:CastAbility()
        end
    end
end

--- show briefly what keys does table have, truncate if there is too much
Shorten = function(tbl)
    if type(tbl) ~= 'table' then
        return tbl
    end
    local shortTbl = {}
    local i = 0
    for k,v in pairs(tbl) do
        i = i + 1
        shortTbl[k] = Shorten(v)
        if i > 7 then
            break
        end
    end
    if tbl.GetName then
        shortTbl.name = tbl:GetName()
    end
    return shortTbl
end

local Log = function(msg, data)
    print('&& LOG && ' .. msg)
    if data ~= nil then
        local short = Shorten(data)
        DeepPrintTable(short)
    end
end



GrantXpToEnemyHeroes = function(event)
    local unit = types:t_npc(event.unit)
    local hero = types:t_hero(event.caster)
    if unit and hero and hero.AddExperience then
        local xp = unit:GetDeathXP() * 1.25
        hero:AddExperience(xp, DOTA_ModifyXP_Unspecified, false, true)
    end
end