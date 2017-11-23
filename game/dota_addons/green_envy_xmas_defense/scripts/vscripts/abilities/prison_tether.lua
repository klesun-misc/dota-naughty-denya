prison_tether = class ({})

LinkLuaModifier("prison_tether_modifier", "abilities/prison_tether_modifier.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "prison_tether_modifier_thinker", "abilities/prison_tether_modifier_thinker.lua", LUA_MODIFIER_MOTION_NONE )

function prison_tether:CastFilterResultTarget (target)
    if self:GetCaster() == target then
        return UF_FAIL_CUSTOM
    end

    if target:IsHero() or target:IsCreep() then
        return UF_FAIL_CUSTOM
    end

    if target:HasModifier("prison_tether_modifier") then
    	return UF_FAIL_CUSTOM
	end

  	if self:GetCaster():HasModifier("prison_tether_modifier") then
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

    if target:HasModifier("prison_tether_modifier") then
    	return "Targeted Tower Is Already Tethered"
	end

  	if self:GetCaster():HasModifier("prison_tether_modifier") then
        return "Cannot Cast Laser"
    end
end

function prison_tether:OnSpellStart ()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local casterOrigin = caster:GetAbsOrigin()
    local targetOrigin = target:GetAbsOrigin()

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl(particle, 0, casterOrigin)
    ParticleManager:SetParticleControl(particle, 1, targetOrigin)

    target:AddNewModifier(caster, target, "prison_tether_modifier", {})
    caster:AddNewModifier(target, caster, "prison_tether_modifier", {})

    local thinker = CreateModifierThinker( caster, self, "prison_tether_modifier_thinker", {}, self:GetCursorPosition(), caster:GetTeamNumber(), false )

    thinker.envyCasterTower = caster
    thinker.envyTargetTower = target
    thinker.envyParticleId = particle
end
