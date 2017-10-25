
local lang = require('reloaded.lang')
local types = require('types')
local build_tower_base = require('abilities.build_tower_base')

-- describes logic of how hero controlled by a bot should behave

local GetBuildableCellsNear = function(point, hero)
    local maxDist = 700
    local towRad = 64
    local towDia = towRad * 2
    local cells = {}

    local minX = -maxDist / towDia
    local maxX = maxDist / towDia
    local minY = -maxDist / towDia
    local maxY = maxDist / towDia

    for x = minX, maxX, 1 do
        for y = minY, maxY, 1 do
            local cell = Vector(
                point.x + x * towDia,
                point.y + y * towDia,
                point.z - 1 -- looks like info_target is always 1 px above ground
            )
            cell = GetGroundPosition(cell, hero)
            if (cell - point):Length() >  maxDist
            or not build_tower_base.CanBuildThere(cell)
            or (cell - point).z < 126 -- less than one level above
            then --[[skip]] else
                table.insert(cells, cell)
            end
        end
    end
    table.sort(cells, function(a,b)
        return (a - point):Length() < (b - point):Length()
    end)
    return cells
end

---@param hero CDOTA_BaseNPC_Hero
local GiveOrders = function(hero, botPlayerId)
    local asNpc = types:t_npc(hero)
    local asEnt = types:t_ent(hero)

    if asNpc:GetUnitName() ~= 'npc_dota_hero_templar_assassin' then
        print('Tried to give order to a non-builder - ' + asNpc:GetUnitName() + ' - not implemented yet')
        return
    end

    local spawnRegion = Entities:FindByName(nil, 'ai_spawning_tower_region'):GetAbsOrigin()
    local healRegion = Entities:FindByName(nil, 'ai_heal_tower_region'):GetAbsOrigin()
    local antiArmyRegion = Entities:FindByName(nil, 'ai_anti_army_tower_region'):GetAbsOrigin()
    local enemyBaseRegion = Entities:FindByName(nil, 'creep_spawn_mark'):GetAbsOrigin()

    local buildAntiArmy = asNpc:FindAbilityByName('build_anti_army_tower');
    local buildHeal = asNpc:FindAbilityByName('build_healing_tower');
    local buildSpawn = asNpc:FindAbilityByName('build_spawning_tower');
    local buildAntiBoss = asNpc:FindAbilityByName('build_anti_boss_tower');

    local antiArmyCost = buildAntiArmy:GetGoldCost(buildAntiArmy:GetLevel() - 1)
    local healCost = buildHeal:GetGoldCost(buildHeal:GetLevel() - 1)

    local upAbilities = function()
        local pts = hero:GetAbilityPoints()
        local lvl = asNpc:GetLevel()
        local skillBuild = {
            buildAntiArmy,buildHeal,buildAntiArmy,buildHeal,buildAntiArmy,
            buildHeal,buildAntiArmy,buildHeal,buildAntiArmy,buildHeal,
            buildSpawn,buildSpawn,buildSpawn,buildSpawn,buildSpawn,
            buildAntiBoss,buildAntiBoss,buildAntiBoss,buildAntiBoss,buildAntiBoss
        }

        if pts > 0 then
            local abilToLvl = {}
            for i = 1, math.min(lvl, lang.Size(skillBuild)), 1 do
                local abil = types:t_abil(skillBuild[i])
                local abilNum = abil:GetAbilityIndex()
                abilToLvl[abilNum] = (abilToLvl[abilNum] or 0) + 1
                if abilToLvl[abilNum] > abil:GetLevel() then
                    hero:UpgradeAbility(abil)
                end
            end
        end
    end

    ---@param npc CDOTA_BaseNPC
    local HpPerc = function(npc)
        return npc:GetHealth() / npc:GetMaxHealth()
    end

    local DecideToBuildHeal = function()
        if HpPerc(hero) > 0.50
        or buildHeal:GetLevel() == 0
        or not buildHeal:IsCooldownReady()
        or not buildHeal:IsOwnersManaEnough()
        or not buildHeal:IsOwnersGoldEnough(botPlayerId)
        then return false else
            for _, point in pairs(GetBuildableCellsNear(healRegion, hero)) do
                asNpc:CastAbilityOnPosition(point, buildHeal, hero:GetPlayerID())
                break
            end
            -- try to build tower - on fail...
            return false
        end
    end

    local DecideToBuildAntiArmy = function()
        local gold = PlayerResource:GetGold(botPlayerId)
        local leftEnoughForHeal = buildHeal:GetLevel() == 0 or gold - antiArmyCost >= healCost

        if buildAntiArmy:GetLevel() == 0
        or not buildAntiArmy:IsCooldownReady()
        or not buildAntiArmy:IsOwnersManaEnough()
        or not buildAntiArmy:IsOwnersGoldEnough(botPlayerId)
        or not leftEnoughForHeal
        then return false else
            local freeCells = GetBuildableCellsNear(antiArmyRegion, hero)
            for _, point in pairs(freeCells) do
                asNpc:CastAbilityOnPosition(point, buildAntiArmy, hero:GetPlayerID())
                break
            end
            -- try to build tower - on fail...
            return false
        end
    end

    upAbilities(hero)
    if (asEnt:GetAbsOrigin() - healRegion):Length() > 850
    or (asEnt:GetAbsOrigin() - healRegion):Length() > 250 and HpPerc(hero) < 0.33
    then
        ExecuteOrderFromTable({
            UnitIndex = hero:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = healRegion,
            Queue = false
        })
    end
    if asNpc:IsIdle() or asNpc:IsAttacking() then
        if DecideToBuildHeal()
        or DecideToBuildAntiArmy()
        then
            -- this guy is building a tower, real talk real talk
        end
    end
    if asNpc:IsIdle() then
        ExecuteOrderFromTable({
            UnitIndex = hero:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = enemyBaseRegion,
            Queue = true
        })
    end
end

return {
    GiveOrders = GiveOrders,
}