
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

---@param castPoint t_vec | Vector
local NormalizeTowerPoint = function(castPoint, hullRadius)
    local xRest = castPoint.x % (hullRadius * 2)
    local yRest = castPoint.y % (hullRadius * 2)

    return Vector(
        castPoint.x - xRest + (xRest > hullRadius / 2 and hullRadius or 0),
        castPoint.y - yRest + (yRest > hullRadius / 2 and hullRadius or 0),
        castPoint.z
    )
end

---@param event t_ability_event | t_uronitj_shkaf_event
---@class t_uronitj_shkaf_event
---@field     AoERadius number
---@field     huj Vector
UronitjShkaf = function(event)
    local caster = event.caster
    local hullRadius = 130
    local spellPoint = NormalizeTowerPoint(event.target_points[1], hullRadius)

    obstaclesInHull = false -- TODO: implement
    if obstaclesInHull then
        print('Нельзя сотворить здесь')
    end

    local creepPoint = spellPoint
    local spawnedCreep = CreateUnitByName(
        'npc_dota_anti_boss_tower', creepPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)

    --
    spawnedCreep:AddNewModifier(spawnedCreep, nil, "modifier_kill", {duration = 30.00})

    --spawnedCreep:AddAbility('black_dragon_splash_attack')
    --local spell = spawnedCreep:FindAbilityByName("black_dragon_splash_attack")
    --if spell ~= nil then spell:SetLevel(1) end

    --local unit = Entities:FindByClassname(nil, 'npc_dota_base')
    --local unit = Entities:First()
    --while unit ~= nil do
    --    -- entity is unit (not an item/spell/team/dummy/etc...)
    --    if unit.AddNewModifier ~= nil then
    --        print(unit:GetClassname() .. ' ' .. unit:GetName())
    --        unit:AddNewModifier(nil, nil, "modifier_stunned", {duration = 2.0})
    --        print('Ability count: ' .. unit:GetAbilityCount())
    --        --DeepPrintTable({unit})
    --        --if unit:GetClassname() == 'npc_dota_creature' then
    --
    --        --end
    --        --unit = Entities:FindByClassname(unit, 'npc_dota_base')
    --    end
    --    unit = Entities:Next(unit)
    --end
end

---@param event t_ability_event | t_uronitj_shkaf_event
BuildAntiArmyTower = function(event)
    local caster = event.caster
    local hullRadius = 130
    local spellPoint = NormalizeTowerPoint(event.target_points[1], hullRadius)

    obstaclesInHull = false -- TODO: implement
    if obstaclesInHull then
        print('Нельзя сотворить здесь')
    end

    local creepPoint = spellPoint
    local spawnedCreep = CreateUnitByName(
        'npc_dota_anti_army_tower', creepPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)
    spawnedCreep:SetControllableByPlayer(caster:GetPlayerID(), true)
end

---@param event t_ability_event | t_uronitj_shkaf_event
BuildPrisonTower = function(event)
    local caster = event.caster
    local hullRadius = 130
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

---@param event t_ability_event | t_uronitj_shkaf_event
BuildHealingTower = function(event)
    local caster = event.caster
    local hullRadius = 130
    local spellPoint = NormalizeTowerPoint(event.target_points[1], hullRadius)

    obstaclesInHull = false -- TODO: implement
    if obstaclesInHull then
        print('Нельзя сотворить здесь')
    end

    local creepPoint = spellPoint
    local spawnedCreep = CreateUnitByName(
        'npc_dota_healing_tower', creepPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)
    spawnedCreep:SetControllableByPlayer(caster:GetPlayerID(), true)
    spawnedCreep:SetRenderColor(255,255,64)
    local spell = spawnedCreep:FindAbilityByName("forest_troll_high_priest_heal")
    if spell ~= nil then
        spell:ToggleAutoCast()
    end
end

---@param event t_ability_event | t_uronitj_shkaf_event
BuildSpawningTower = function(event)
    local caster = event.caster
    local hullRadius = 130
    local spellPoint = NormalizeTowerPoint(event.target_points[1], hullRadius)

    obstaclesInHull = false -- TODO: implement
    if obstaclesInHull then
        print('Нельзя сотворить здесь')
    end

    local creepPoint = spellPoint
    local spawnedCreep = CreateUnitByName(
        'npc_dota_spawning_tower', creepPoint,
        false, caster, caster, caster:GetTeam()
    )
    spawnedCreep:SetInvulnCount(0)
    spawnedCreep:SetControllableByPlayer(caster:GetPlayerID(), true)
    spawnedCreep:SetRenderColor(0,192,0)
    local raiseDead = spawnedCreep:FindAbilityByName("dark_troll_warlord_raise_dead")
    spawnedCreep:SetThink(function()
        -- for some reason it does not use skill on
        -- it's own, even when built-in auto-cast is on...
        if raiseDead:GetAutoCastState() then
            if raiseDead:GetCooldownTimeRemaining() < 0.00000001 then
                raiseDead:CastAbility()
            end
        end
        return 1
    end)
    if raiseDead ~= nil then
        raiseDead:ToggleAutoCast()
    end
end