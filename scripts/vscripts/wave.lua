
-- this module encapsulates logic related to waves: who/how often/what modifiers/special events/etc...

local Spawn = function()
    local waveInterval = 6.0 -- seconds
    local spawnMark = Entities:FindByName(nil, 'huj123')
    local goalMark = Entities:FindByName(nil, 'pizda456')
    local point = spawnMark:GetAbsOrigin()
    local goal = goalMark:GetAbsOrigin()

    local SpawnUnit = function(dataDrivenName)
        local unit = CreateUnitByName(
            dataDrivenName,
            point + RandomVector(RandomInt(100, 200)),
            true, nill, nill, DOTA_TEAM_BADGUYS
        )
        -- need to apply any modifier to update npc gui hp numbers
        unit:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 2.0})

        ExecuteOrderFromTable({
            UnitIndex = unit:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = goal, Queue = true
        })

        return unit
    end

    local SpawnCreep = function(wave)
        local seconds = GameRules:GetGameTime()
        local golem = SpawnUnit('npc_dota_creature_gnoll_assassin')
        local hp = 50 + seconds;
        local dmg = 15 + seconds / 30
        golem:SetBaseAttackTime(1)
        golem:SetBaseDamageMin(dmg)
        golem:SetBaseDamageMax(dmg)
        golem:SetBaseMaxHealth(hp)
        golem:SetBaseHealthRegen(5)
        golem:SetBaseMoveSpeed(350)

        if wave % 5 == 0 then
            GameRules:SendCustomMessage('Creep spawned with hp: ' .. math.floor(hp) ..' dmg: ' .. math.floor(dmg), DOTA_TEAM_FIRST, 0)
        end
    end

    local SpawnBoss = function()
        local seconds = GameRules:GetGameTime()
        local golem = SpawnUnit('npc_dota_creature_gnoll_boss')
        local hp = 3000 + seconds * 30;
        local dmg = 15 + seconds / 3
        golem:SetBaseAttackTime(2)
        golem:SetBaseDamageMin(dmg)
        golem:SetBaseDamageMax(dmg)
        golem:SetBaseMaxHealth(hp)
        golem:SetBaseHealthRegen(10)
        golem:SetBaseMoveSpeed(200)

        GameRules:SendCustomMessage('Boss spawned with hp: ' .. math.floor(hp) ..' dmg: ' .. math.floor(dmg), DOTA_TEAM_FIRST, 0)
    end

    local seconds = GameRules:GetGameTime()

    cnt = 2
    if seconds > 60 then cnt = cnt + 1 end
    if seconds > 180 then cnt = cnt + 1 end
    if seconds > 540 then cnt = cnt + 1 end
    if seconds > 1620 then cnt = cnt + 1 end

    local wave = math.floor(GameRules:GetGameTime() / waveInterval)
    if wave > 0 and wave % 15 == 0 then
        SpawnBoss()
    end
    for i = 1,cnt,1 do
        SpawnCreep(wave)
    end

    return waveInterval
end

return {
    Spawn = Spawn
}