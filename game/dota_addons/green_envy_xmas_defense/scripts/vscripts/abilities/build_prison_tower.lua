
local build_tower_base = require('abilities.build_tower_base')

build_prison_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_prison_tower',

    ---@param tower CDOTA_BaseNPC
    ---@param abil CDOTABaseAbility
    OnCreated = function(tower, abil)
        tower:SetControllableByPlayer(abil:GetCaster():GetPlayerID(), true)
        tower:SetRenderColor(128,128,192)
    end,
})
