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
	local kv = {}
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget() )
	
	ParticleManager:SetParticleControl(particle, 0, targetTower)
	ParticleManager:SetParticleControl(particle, 1, casterTower)

	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self:GetCursorTarget(), "prison_tether_modifier", { duration = 10 })	

	CreateModifierThinker( caster, self, "prison_tether_modifier_thinker", kv, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )

end

--[[function prison_tether:OnIntervalThink()
		ProjectileManager:CreateLinearProjectile( {
		Ability				= self,
		vSpawnOrigin		= self.GetCaster():GetAbsOrigin(),
		fDistance			= (self:GetCursorTarget():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D(),
		Source				= self:GetCaster(),
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= GameRules:GetGameTime() + 0.06,
		bDeleteOnHit		= false,
	} )
end--]]
