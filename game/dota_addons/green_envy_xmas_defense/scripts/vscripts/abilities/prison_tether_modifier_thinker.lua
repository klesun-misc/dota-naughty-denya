prison_tether_modifier_thinker = class({})

LinkLuaModifier( "prison_tether_slow_modifier", "abilities/prison_tether_slow_modifier.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:OnCreated( kv )
	if IsServer() then
		self:StartIntervalThink( 0.05 )
	end
end

--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:OnIntervalThink()
	if IsServer() then
		local casterTower = self:GetParent().envyCasterTower
		local targetTower = self:GetParent().envyTargetTower
		local particleId = self:GetParent().envyParticleId

		local dps = casterTower:GetBaseDamageMax() / 20

		if not casterTower:IsAlive() then
			targetTower:RemoveModifierByName('prison_tether_modifier')
		end

		if not targetTower:IsAlive() then
			casterTower:RemoveModifierByName('prison_tether_modifier')	
		end

		if not casterTower or not casterTower:IsAlive()
		or not targetTower or not targetTower:IsAlive()
		or not casterTower:FindModifierByName('prison_tether_modifier')
		or not targetTower:FindModifierByName('prison_tether_modifier')
		then
			UTIL_Remove(self:GetParent())
			ParticleManager:DestroyParticle(particleId, false)
			return
		end

		local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetParent():GetAbsOrigin(), nil, 94, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					
					enemy:AddNewModifier(self:GetCaster(), nil, "prison_tether_slow_modifier", {duration = 2} )

					local damage = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = dps,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self:GetAbility()
					}

					ApplyDamage( damage )
				end
			end
		end
	end
end
