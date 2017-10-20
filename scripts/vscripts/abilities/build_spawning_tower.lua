
local build_tower_base = require('abilities.build_tower_base')

build_spawning_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_spawning_tower',
    ---@param tower CDOTA_BaseNPC
    OnCreated = function(tower, abil)
        tower:SetRenderColor(0,192,0)
        local spell = tower:FindAbilityByName("spawn_tower_creep")
        if spell ~= nil then
            spell:ToggleAutoCast()
        end
        local dmgBase = abil:GetSpecialValueFor('dmg_base')
        tower:SetBaseDamageMin(dmgBase)
        tower:SetBaseDamageMax(dmgBase)
    end,
})