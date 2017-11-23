prison_tether_slow_modifier = class ({})

function prison_tether_slow_modifier:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function prison_tether_slow_modifier:IsDebuff()
	return true
end

function prison_tether_slow_modifier:GetTexture()
	return "ancient_apparition_ice_vortex"
end

function prison_tether_slow_modifier:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function prison_tether_slow_modifier:DestroyOnExpire()
	return true
end

function prison_tether_slow_modifier:GetModifierMoveSpeedBonus_Percentage()
	return -30
end

-- function prison_tether_slow_modifier:OnCreated(kv)
-- 	if self:GetParent() and self:GetParent() ~= nil then
-- 		self:GetParent():SetRenderColor(87, 171, 249)
-- 	end
-- end

-- function prison_tether_slow_modifier:OnDestroy()
-- 	if self:GetParent() and self:GetParent() ~= nil then
-- 		self:GetParent():SetRenderColor(255, 255, 255)
-- 	end
-- end