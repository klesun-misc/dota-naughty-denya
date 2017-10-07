
local build_tower_base = require('abilities.build_tower_base')

build_anti_army_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_anti_army_tower',
    ---@param tower CDOTA_BaseNPC
    OnCreated = function(tower)
        tower:SetRenderColor(192,128,0)
    end,
})