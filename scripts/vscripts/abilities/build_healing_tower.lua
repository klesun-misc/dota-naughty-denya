
local build_tower_base = require('abilities.build_tower_base')

build_healing_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_healing_tower',
    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetRenderColor(128,32,0)

        local healMult = abil:GetSpecialValueFor('heal_mult')
        local healBase = abil:GetSpecialValueFor('heal_base')

        local heal = healBase
        local lvl = abil:GetLevel()
        for i = 1, lvl - 1, 1 do
            heal = heal * healMult
        end
        tower:SetBaseDamageMin(heal)
        tower:SetBaseDamageMax(heal)

        local spell = tower:FindAbilityByName("tower_heal")
        if spell ~= nil then
            spell:ToggleAutoCast()
        end

        -- need to apply any modifier to update npc gui hp numbers
        tower:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 0.05})
    end,
})