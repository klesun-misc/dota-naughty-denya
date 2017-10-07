
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
