
local json = require('libs/json')

if org == nil then org = {} end
if org.klesun == nil then org.klesun = {} end

org.klesun.Main = function()

	local Log = function(text, data)
		DebugDrawScreenTextLine(100, 100, 0, text, 255, 255, 0, 255, 10)
		if data ~= nil then
			local jsonText = json.stringify(data)
			print(jsonText)
			DebugDrawScreenTextLine(100, 200, 0, jsonText, 127, 127, 255, 255, 10)
		end
	end

	local OnEntityKilled = function(event)
		print('Unit lost!')
		-- none of these works for some reason
		DebugDrawScreenTextLine(100, 100, 0, 'Denya Uronil Shkaf na ekran!', 255, 127, 127, 255, 10)
		GameRules:SendCustomMessage('Denya Uronil Shkaf v chat!', DOTA_TEAM_FIRST, 0)
		DeepPrintTable(event)
	end

	local OnHeroPicked = function(event)
		local hero = EntIndexToHScript(event.heroindex)
		if hero:HasRoomForItem("item_blink", true, true) then
			local dagger = CreateItem("item_blink", hero, hero)
			dagger:SetPurchaseTime(0)
			hero:AddItem(dagger)
		end
	end

	-- here goes logic of my trigger spells
	---@param event t_ability_event
	---@class t_ability_event
	---@field     caster_entindex   number
	---@field     abilityname       string
	---@field     PlayerID          number
	---@field     splitscreenplayer number
	local OnAbilityUsed = function(event)
		if event.abilityname == 'uronitj_shkaf' then
			print('dzhigurda')
			local code = 'print("zalupa")'
			local func = loadstring(code)
			func()

			GameRules:Playtesting_UpdateAddOnKeyValues()

			DeepPrintTable(event)
			Log('An ability was used!', event)
		end
	end

	---@param event t_chat_event
	---@class t_chat_event
	---@field playerid          number
	---@field text              string
	---@field teamonly          number
	---@field userid            number
	---@field splitscreenplayer number
	local OnPlayerChat = function(event)
		if event.text:sub(1, 3) == 'do|' then
			Log('player chatted', event)
			code = event.text:sub(4)
			local func = loadstring(code)
			func()
			DeepPrintTable(event)
		end
	end

	GameRules:SetHeroSelectionTime(15)
	GameRules:SetPreGameTime(10)

	ListenToGameEvent('entity_killed', OnEntityKilled, nil)
	ListenToGameEvent('dota_player_pick_hero', OnHeroPicked, nil)
	ListenToGameEvent('dota_player_used_ability', OnAbilityUsed, nil)
	ListenToGameEvent('dota_non_player_used_ability', OnAbilityUsed, nil)
	ListenToGameEvent('player_chat', OnPlayerChat, nil)
end