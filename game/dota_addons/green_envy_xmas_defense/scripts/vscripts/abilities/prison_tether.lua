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
	local projectileInfo =
	{
		Ability	= self,
		EffectName = "particles/units/heroes/hero_wisp/wisp_tether.vpcf",
		vSpawnOrigin = casterTower,
		fStartRadius = 64,
		fEndRadius = 64,
		vVelocity = 500,
		fDistance = 700,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		iUnitTargetType = DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC
	}
	ProjectileManager:CreateLinearProjectile(projectileInfo)
	--local pfx = ParticleManager:CreateParticle(effectName, PATTACH_ABSORIGIN, caster)
	--ParticleManager:SetParticleControl(pfx, 0, casterTower)
	--ParticleManager:SetParticleControl(pfx, 1, targetTower)

end

function prison_tether:OnProjectileHit(hTarget, vLocation)
	print("xyu")
	if hTarget ~= nil then 
		print('somebody is here')
	end
end