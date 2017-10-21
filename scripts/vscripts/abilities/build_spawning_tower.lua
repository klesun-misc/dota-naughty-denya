
local build_tower_base = require('abilities.build_tower_base')

build_spawning_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_spawning_tower',
    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetRenderColor(0,192,0)
        local spell = tower:FindAbilityByName("spawn_tower_creep")
        if spell ~= nil then
            spell:ToggleAutoCast()
        end
        local dmgBase = abil:GetSpecialValueFor('dmg_base')
        local dmgMult = abil:GetSpecialValueFor('dmg_mult')
        local hpBase = abil:GetSpecialValueFor('hp_base')
        local hpMult = abil:GetSpecialValueFor('hp_mult')
        local dmg = dmgBase * math.pow(dmgMult, abil:GetLevel())
        local creepHp = hpBase * math.pow(hpMult, abil:GetLevel())
        tower:SetBaseDamageMin(dmg)
        tower:SetBaseDamageMax(dmg)
        -- 250 is likely something like "default" hp in dota, it is not included to "BaseMaxHealth"
        tower:SetBaseMaxHealth(math.max(creepHp * 4 - 250, 1))

        -- need to apply any modifier to update npc gui hp numbers
        tower:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 0.05})
    end,
})