
-- this module provides code needed by all
-- towers - use it to avoid copy-pasting

local lastCursorPosition = Vector(0,0,0);

local NormalizeTowerPoint = function(castPoint, hullRadius)
    local xRest = castPoint.x % (hullRadius * 2)
    local yRest = castPoint.y % (hullRadius * 2)

    return Vector(
        castPoint.x - xRest + (xRest > hullRadius and hullRadius * 2 or 0),
        castPoint.y - yRest + (yRest > hullRadius and hullRadius * 2 or 0),
        castPoint.z
    )
end

local MakeAbility = function(params)
    local datadrivenName = params.datadrivenName
    local towerRadius = params.towerRadius or 64
    local OnCreated = params.OnCreated or function(tower) end

    local build_tower_base = {}

    ---@param point Vector | t_vec
    function build_tower_base:CastFilterResultLocation(point)
        lastCursorPosition = point + Vector(0,0,0)
        point = NormalizeTowerPoint(point, towerRadius)

        local floatError = point.z % 128
        if floatError > 0.01 and 128 - floatError > 0.01 then
            -- when trying to build on a wall
            return UF_FAIL_CUSTOM
        end

        local ent = Entities:First()
        while ent ~= nil do
            local entRad = ent.GetHullRadius and ent:GetHullRadius() or 0
            if entRad > 0 then
                local dv = point - ent:GetAbsOrigin()
                if (math.abs(dv.x) - entRad < towerRadius) and (math.abs(dv.y) - entRad < towerRadius) then
                    return UF_FAIL_CUSTOM
                end
            end
            ent = Entities:Next(ent)
        end
        return UF_SUCCESS
    end

    function build_tower_base:GetCustomCastErrorLocation(point)
        return 'I can\' build there'
    end

    ---@param event t_ability_event
    function build_tower_base:OnSpellStart(event)
        local caster = self:GetCaster()
        local spellPoint = NormalizeTowerPoint(self:GetCursorPosition(), towerRadius)

        local tower = CreateUnitByName(
            datadrivenName, spellPoint,
            false, caster, caster, caster:GetTeam()
        )
        if tower.SetInvulnCount ~= nil then
            tower:SetInvulnCount(0)
        end
        tower:SetIdleAcquire(true) -- auto-attack ON
        --tower:SetControllableByPlayer(caster:GetPlayerID(), false)
        tower:SetHullRadius(towerRadius)

        OnCreated(tower)
    end

    function build_tower_base:GetAOERadius(event)
        local point = lastCursorPosition
        local towerPoint = NormalizeTowerPoint(point, towerRadius)
        local maxDistance = math.sqrt(towerRadius ^ 2 + towerRadius ^ 2)
        local distance = (point - towerPoint):Length()
        return math.max(1, (maxDistance - distance) * 1.5)
    end

    return build_tower_base
end

return {
    MakeAbility = MakeAbility,
}