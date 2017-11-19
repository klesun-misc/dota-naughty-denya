
local build_tower_base = require('abilities.build_tower_base')

-- 0 is true in lua. sadly this does not go well with
-- some dota c++ functions that return 0 on no value
local def = function(value, defaultValue)
    return value ~= 0 and value or defaultValue
end

build_wizard_barracks = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_envy_wizard_barracks',
    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetRenderColor(0,192,0)
        local spell = tower:FindAbilityByName("train_envy_wizard_creep")
        if spell ~= nil then
            spell:ToggleAutoCast()
        end
        local dmgBase = def(abil:GetSpecialValueFor('dmg_base'), 16)
        local dmgMult = def(abil:GetSpecialValueFor('dmg_mult'), 1.25)
        local hpBase = def(abil:GetSpecialValueFor('hp_base'), 120)
        local hpMult = def(abil:GetSpecialValueFor('hp_mult'), 1.25)
        local dmg = dmgBase * math.pow(dmgMult, abil:GetLevel() - 1)
        local creepHp = hpBase * math.pow(hpMult, abil:GetLevel() - 1)
        tower:SetBaseDamageMin(dmg)
        tower:SetBaseDamageMax(dmg)
        -- 250 is likely something like "default" hp in dota, it is not included to "BaseMaxHealth"
        tower:SetBaseMaxHealth(math.max(creepHp * 4, 1))

        local extraSpell = tower:AddAbility('buy_damage_increase_ranged')
        extraSpell:SetLevel(1)
        local extraSpell = tower:AddAbility('buy_hp_increase')
        extraSpell:SetLevel(1)

        -- need to apply any modifier to update npc gui hp numbers
        tower:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 0.05})
        tower:AddNewModifier(nil, nil, 'modifier_phased', {duration = -1})
        tower:SetControllableByPlayer(abil:GetCaster():GetMainControllingPlayer(), false)
    end,
    ---@param abil CDOTABaseAbility
    CustomPointCheck = function(point, abil)
        if (not GridNav) or GridNav:CanFindPath(point, abil:GetCaster():GetAbsOrigin()) then
            return nil
        else
            return 'There is no path to the point you specified'
        end
    end,
})