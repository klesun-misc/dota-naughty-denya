
local build_tower_base = require('abilities.build_tower_base')

build_spawning_tower = build_tower_base.MakeAbility({
    datadrivenName = 'npc_dota_spawning_tower',
    ---@param tower CDOTA_BaseNPC
    OnCreated = function(tower)
        tower:SetRenderColor(0,192,0)
        local raiseDead = tower:FindAbilityByName("dark_troll_warlord_raise_dead")
        if raiseDead ~= nil then
            raiseDead:ToggleAutoCast()
            tower:SetThink(function()
                -- for some reason it does not use skill on
                -- it's own, even when built-in auto-cast is on...
                if raiseDead:GetAutoCastState() then
                    if raiseDead:GetCooldownTimeRemaining() < 0.00000001 then
                        raiseDead:CastAbility()
                    end
                end
                return 1
            end)
        end
    end,
})