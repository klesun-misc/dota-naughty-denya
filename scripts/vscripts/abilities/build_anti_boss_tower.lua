
local build_tower_base = require('abilities.build_tower_base')

build_anti_boss_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_anti_boss_tower',
    ---@param tower CDOTA_BaseNPC
    OnCreated = function(tower)
        tower:SetRenderColor(32,255,128)
        tower:AddNewModifier(tower, nil, 'modifier_kill', {duration = 30.00})
    end,
})