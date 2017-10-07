
---@class CDOTABaseAbility
build_lua_test_tower = {}

local towerRadius = 64
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

---@param point Vector | t_vec
function build_lua_test_tower:CastFilterResultLocation(point)
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

function build_lua_test_tower:GetCustomCastErrorLocation(point)
    return 'I can\' build there'
end

---@param event t_ability_event
function build_lua_test_tower:OnSpellStart(event)
    local caster = self:GetCaster()
    local spellPoint = NormalizeTowerPoint(self:GetCursorPosition(), towerRadius)

    local spawnedCreep = CreateUnitByName(
        'npc_dota_anti_army_tower', spellPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)
    spawnedCreep:SetControllableByPlayer(caster:GetPlayerID(), true)
    spawnedCreep:SetRenderColor(192,128,0)
    spawnedCreep:SetHullRadius(towerRadius)
end

function build_lua_test_tower:GetAOERadius(event)
    local point = lastCursorPosition
    local towerPoint = NormalizeTowerPoint(point, towerRadius)
    local maxDistance = math.sqrt(towerRadius ^ 2 + towerRadius ^ 2)
    local distance = (point - towerPoint):Length()
    return math.max(1, (maxDistance - distance) * 1.5)
end
