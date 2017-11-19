prison_tether_modifier_thinker = class({})

local startTime
--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:OnCreated( kv )
	if IsServer() then
		startTime = GameRules:GetGameTime()
		self:StartIntervalThink( 0.05 )
	end
end

--------------------------------------------------------------------------------

function prison_tether_modifier_thinker:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetParent():GetAbsOrigin(), nil, 86, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

					local damage = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = 4.5,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self:GetAbility()
					}

					ApplyDamage( damage )
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------