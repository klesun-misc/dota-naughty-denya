prison_tether_modifier = class ({})

function prison_tether_modifier:IsDebuff()
	return false
end	

function prison_tether_modifier:OnCreated(table)
	DeepPrintTable(self:GetParent():__self)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget() )
	
	ParticleManager:SetParticleControl(particle, 0, self:GetCursorTarget() )
	ParticleManager:SetParticleControl(particle, 1, self:GetCaster() )
end

function prison_tether_modifier:OnDestroy()

end