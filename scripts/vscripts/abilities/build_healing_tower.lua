
local build_tower_base = require('abilities.build_tower_base')

build_healing_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_healing_tower',
    ---@param tower CDOTA_BaseNPC
    OnCreated = function(tower)
        tower:SetRenderColor(128,32,0)
        local spell = tower:FindAbilityByName("tower_heal")
        if spell ~= nil then
            spell:ToggleAutoCast()
        end
    end,
})