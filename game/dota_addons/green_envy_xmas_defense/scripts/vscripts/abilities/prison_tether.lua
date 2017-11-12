prison_tether = class ({})

function prison_tether:CastFilterResultTarget (target)
    if self:GetCaster() == target then
        return UF_FAIL_CUSTOM
    end

    if target:IsHero() or target:IsCreep() then
        return UF_FAIL_CUSTOM
    end
end

function prison_tether:GetCustomCastErrorTarget(target)
    if self:GetCaster() == target then
        return "#dota_hud_error_cant_cast_on_self"
    end

    if target:IsHero() or target:IsCreep() then
        return "Ability Can't Target Hero or Creep"
    end
end

function prison_tether:OnSpellStart ()
    local caster = self:GetCaster()
    local casterTower = caster:GetAbsOrigin()
    local targetTower = self:GetCursorTarget():GetAbsOrigin()
    local distance = (targetTower - casterTower):Length2D()
    local effectName = "particles/units/heroes/hero_wisp/wisp_tether.vpcf"
    local pfx = ParticleManager:CreateParticle(effectName, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pfx, 0, casterTower)
    ParticleManager:SetParticleControl(pfx, 1, targetTower)

end

function prison_tether:OnProjectileHit(hTarget, vLocation)
    print("xyu")
    print(hTarget)
end