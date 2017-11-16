
local build_tower_base = require('abilities.build_tower_base')

build_anti_boss_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_anti_boss_tower',

    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetRenderColor(32,255,128)
        tower:AddNewModifier(tower, nil, 'modifier_kill', {duration = 45.00})

        local dmgMult = abil:GetSpecialValueFor('dmg_mult')
        local dmg = (tower:GetBaseDamageMin() + tower:GetBaseDamageMax()) / 2
        local lvl = abil:GetLevel()
        for i = 1, lvl - 1, 1 do
            dmg = dmg * dmgMult
        end
        tower:SetBaseDamageMin(dmg)
        tower:SetBaseDamageMax(dmg)
        tower:SetIdleAcquire(true)

        -- need to apply any modifier to update npc gui hp numbers
        tower:AddNewModifier(nil, nil, 'modifier_stunned', {duration = 0.05})
    end,
})
