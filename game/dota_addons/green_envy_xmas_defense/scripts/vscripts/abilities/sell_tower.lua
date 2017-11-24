sell_tower = ({})

function sell_tower:OnSpellStart()
    local casterTower = self:GetCursorTarget()
	local sellPrice = (casterTower.envyNs or {}).goldCost or nil

	if sellPrice and casterTower then
		local refundGold = sellPrice * 0.6
		local playerId = casterTower:GetPlayerOwnerID()
		PlayerResource:ModifyGold(playerId, refundGold, true, 0)
		UTIL_Remove(casterTower)
	end
end