
require('libs.timers')
local types = require('types')

local json = require('reloaded.json')
local wave = require('wave')
local bgm = require('bgm')
local lang = require('reloaded.lang')

-- vars that are kept after code reload
if klesun == nil then klesun = {} end
if klesun.eventToFunc == nil then klesun.eventToFunc = {} end
if klesun.playerIdToRole == nil then klesun.playerIdToRole = {} end
if klesun.playerIdToUserId == nil then klesun.playerIdToUserId = {} end
if klesun.roledPlayerIds == nil then klesun.roledPlayerIds = {} end

local SETUP_MAX_TIME = 15;
local setupStartTime = nil

-- listen for Dota game event or update function if already listening
local Relisten = function(eventName, func)
    if klesun.eventToFunc[eventName] == nil then
        ListenToGameEvent(eventName, function(e)
            klesun.eventToFunc[eventName](e)
        end, nil)
    end
    klesun.eventToFunc[eventName] = func
end

local RelistenCust = function(eventName, func)
    if klesun.eventToFunc[eventName] == nil then
        CustomGameEventManager:RegisterListener(eventName, function(s, e)
            klesun.eventToFunc[eventName](s, e)
        end)
    end
    klesun.eventToFunc[eventName] = func
end

local Log = function(text, data)
    print(text)
    DebugDrawScreenTextLine(100, 100, 0, text, 255, 255, 0, 255, 10)
    if data ~= nil then
        local jsonText = json.stringify(data)
        print(jsonText)
        DebugDrawScreenTextLine(100, 200, 0, jsonText, 127, 127, 255, 255, 10)
    end
end

-- processes the chat input and interprets it as Lua code
local InterpretCode = (function()
    local isTakingCode = false;
    local chunkedCode = ''

    local eval = function(code)
        local func = loadstring(code)
        local ok, data = pcall(func)
        if (ok) then
            Log('evaled ok')
            return data
        else
            Log('failed to eval', data)
            return nil
        end
    end

    local getFreshCode = function(fileName)
        local result = {thn = function(resp) end}
        -- `math.random` because stean caches GET requests otherwise
        local url = 'http://localhost/vscripts/reloaded/' .. fileName .. '.lua?rndom=' .. math.random()
        local rq = CreateHTTPRequestScriptVM('GET', url)

        print('Requesting url: ' .. url)
        ---@param resp t_http_rs
        rq:Send(function(resp)
            print('got reloaded code of ' .. fileName .. ' \n' .. resp.Body:sub(15000))
            result.thn(resp.Body)
        end)
        return result
    end

    ---@param event  t_chat_event
    return function(event)
        local msg = event.text
        if msg:sub(1, 3) == 'do|' then
            local code = msg:sub(4)
            Log('evaluating code', code)
            eval(code)
        elseif msg.sub(1, 8) == '--[[do]]' then
            local code = msg:sub(9)
            Log('evaluating code', code)
            eval(code)
        elseif msg == 'klesun speaks' then
            isTakingCode = true
            Log('klesun may now speak')
        elseif msg == 'klesun spoken' then
            eval(chunkedCode)
            chunkedCode = ''
        elseif isTakingCode then
            chunkedCode = chunkedCode .. "\n" .. msg
        end
    end
end)()

local entity_killed = function(event)
    --print('Unit lost!')
    ---- none of these works for some reason
    --DebugDrawScreenTextLine(100, 100, 0, 'Denya Uronil Shkaf na ekran!', 255, 127, 127, 255, 10)
    --GameRules:SendCustomMessage('Denya Uronil Shkaf v chat!', DOTA_TEAM_FIRST, 0)
    --DeepPrintTable(event)
end

-- pretty useles event, it don't even provide the point where skill was cast
---@param event t_ability_brief_event
---@class t_ability_brief_event
---@field     caster_entindex   number
---@field     abilityname       string
---@field     PlayerID          number
---@field     splitscreenplayer number
local dota_unit_used_ability = function(event)
    if event.abilityname == 'uronitj_shkaf' then
        Log('An ability was used!', event)
        local caster = EntIndexToHScript(event.caster_entindex)
        local abil = caster:FindAbilityByName(event.abilityname)
        Log('GetCastPoint', abil:GetCastPoint())
    end
end

local dota_player_pick_hero = function(event)
    local hero = EntIndexToHScript(event.heroindex)
    if hero:HasRoomForItem("item_blink", true, true) then
        local dagger = CreateItem("item_blink", hero, hero)
        dagger:SetPurchaseTime(0)
        hero:AddItem(dagger)
    end
end

---@param event t_chat_event
---@class t_chat_event
---@field     playerid          number
---@field     text              string
---@field     teamonly          number
---@field     userid            number
---@field     splitscreenplayer number
local player_chat = function(event)
    InterpretCode(event)
end

-- happens when you see the "TEAM SELECT" screen
---@param event t_player_connected_full_event
---@class t_player_connected_full_event
---@field     PlayerID          number
---@field     index             number
---@field     userid            number
---@field     splitscreenplayer number
local player_connect_full = function(event)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    DeepPrintTable(event)
    ---@debug
    print('Player connected - ' .. PlayerResource:GetPlayerName(event.PlayerID))
    klesun.playerIdToUserId[event.PlayerID] = event.userid

    -- default team/role if player does not choose something
    local defaultRole = math.random() < 0.5 and 'builder' or 'hero'
    local defaultTeam = DOTA_TEAM_GOODGUYS
    PlayerResource:SetCustomTeamAssignment(event.PlayerID, defaultTeam)
    klesun.playerIdToRole[event.PlayerID] = defaultRole
end

local lastPlayerId = nil

-- happens when you see the "TEAM SELECT" screen
---@param event t_player_team_event
---@class t_player_team_event
---@field     isbot             number
---@field     silent            number
---@field     splitscreenplayer number
---@field     autoteam          number
---@field     team              number
---@field     oldteam           number
---@field     userid            number
---@field     name              string
---@field     disconnect        number
local player_team = function(event)
    print('OnPlayerTeam')
    DeepPrintTable(event)
    lastPlayerId = event.userid - 1
end

local SpawnBots = function()
    local radBuilerCnt = 0
    for playerId, role in pairs(klesun.playerIdToRole) do
        if PlayerResource:GetTeam(playerId) ~= DOTA_TEAM_GOODGUYS
        or role ~= 'builder'
        then --[[skip]] else
            radBuilerCnt = radBuilerCnt + 1
        end
    end

    if radBuilerCnt == 0 then
        local toGoodTeam = true
        Tutorial:AddBot('npc_dota_hero_templar_assassin', 'mid', 'unfair', toGoodTeam)
        local botId = lastPlayerId
        local botPlayer = PlayerResource:GetPlayer(botId)
        -- i dunno which event do I need...
        Timers:CreateTimer({
            endTime = 10,
            callback = function()
                local hero = botPlayer:GetAssignedHero()
                hero:SetThink(function()
                    local ok, data = pcall(function() require('bot_ai').GiveOrders(hero, botId) end)
                    local delay
                    if ok then delay = 0.5 else
                        print('Got exception while trying to give AI orders')
                        DeepPrintTable({data})
                        delay = 5
                    end
                    return delay
                end)
            end,
        })
    end
end

local game_rules_state_change = function(_)
    print('game_rules_state_change - ' .. GameRules:State_Get())
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		setupStartTime = GameRules:GetGameTime()
    elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
        SpawnBots()
        for playerId, role in pairs(klesun.playerIdToRole) do
            if role == 'builder' then
                local player = PlayerResource:GetPlayer(playerId)
                player:MakeRandomHeroSelection()
            end
        end
    elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- dota does not allow rplacing hero instantly, "player has no current hero to replace"
        Timers:CreateTimer({
            endTime = 10,
            callback = function()
                for playerId, role in pairs(klesun.playerIdToRole) do
                    if role == 'builder' then
                        local datadriven = PlayerResource:GetTeam(playerId) == DOTA_TEAM_GOODGUYS
                            and 'npc_dota_hero_templar_assassin'
                            or 'npc_dota_hero_lycan'
                        local hero = PlayerResource:ReplaceHeroWith(playerId, datadriven, 800, 0)
                    end
                end
            end,
        })
        bgm.Init()
    end
end

---@param event t_entity_event
---@class t_entity_event
---@field     entindex          number
---@field     splitscreenplayer number
local npc_spawned = function(event)
    ---@debug
    local unit = EntIndexToHScript(event.entindex)
    local datadrivenName = unit:GetUnitName()
end

---@param event t_klesun_event_js_to_lua
---@class t_klesun_event_js_to_lua
---@field     type          string
---@field     PlayerID      number
---@field     fraction      string|'radiant'|'dire'
---@field     role          string|'hero'|'builder'
local klesun_event_js_to_lua = function(status, event)
    if event.type == 'role_selected' then
        local team = event.fraction == 'radiant' and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
        local playerId = event.PlayerID
        PlayerResource:SetCustomTeamAssignment(playerId, team)
        klesun.playerIdToRole[playerId] = event.role
        table.insert(klesun.roledPlayerIds, event.PlayerID)
        if lang.Size(klesun.roledPlayerIds) == lang.Size(klesun.playerIdToUserId) then
            -- everyone have chosen his role
            GameRules:SetCustomGameSetupRemainingTime(0)
        end
    else
        print('Unexpected klesun_event_js_to_lua event format!')
        DeepPrintTable(event)
    end

	--DeepPrintTable(event.type)
	CustomGameEventManager:Send_ServerToAllClients('klesun_event_lua_to_js', {
		type = 'response_message', value = 'Player #' .. event.PlayerID .. ' said that he likes you!'
	})
end

Timers:RemoveTimers(true)
Timers:CreateTimer(function()
    local pause = wave.Spawn()
    return pause
end)
Timers:CreateTimer(function()
	CustomGameEventManager:Send_ServerToAllClients('klesun_event_lua_to_js', {
		type = 'second_passed',
		setupTimeLeft = GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP
			and setupStartTime - GameRules:GetGameTime() + SETUP_MAX_TIME or nil,
	})
    return 1
end)

Relisten('entity_killed', entity_killed)
Relisten('dota_player_pick_hero', dota_player_pick_hero)
Relisten('dota_player_used_ability', dota_unit_used_ability)
Relisten('dota_non_player_used_ability', dota_unit_used_ability)
Relisten('player_chat', player_chat)
Relisten('player_connect_full', player_connect_full)
Relisten('player_team', player_team)
Relisten('game_rules_state_change', game_rules_state_change)
Relisten('npc_spawned', npc_spawned)

RelistenCust('klesun_event_js_to_lua', klesun_event_js_to_lua)

local Main = function()
	-- how many seconds users can spend on page defined by <CustomUIElement type="GameSetup" layoutfile="..." />
	GameRules:SetCustomGameSetupTimeout(SETUP_MAX_TIME)
    -- how much time on "TEAM SELECT" screen
    GameRules:SetCustomGameSetupAutoLaunchDelay(10)
    -- how many seconds before you start losing gold for not picking a hero
    GameRules:SetHeroSelectionTime(10)
    -- the 30 seconds to buy wards after hero pick
    GameRules:SetStrategyTime(0)
    -- Set the duration of the 'radiant versus dire' showcase screen
    GameRules:SetShowcaseTime(0)
    -- how many seconds before Kenarius says "Let's the battle begin!"
    GameRules:SetPreGameTime(0)
	-- same hero selection enabled
	GameRules:SetSameHeroSelectionEnabled(true)
end

return Main