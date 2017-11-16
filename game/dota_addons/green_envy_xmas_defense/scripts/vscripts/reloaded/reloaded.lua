
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

local SETUP_MAX_TIME = 15
local RADIANT_VICTORY_TIME = 20 * 60
local setupStartTime = nil

local botIdToData = {}
local lastPlayerId = nil

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

local entity_killed = function(event)
    --print('Unit lost!')
    --DebugDrawScreenTextLine(100, 100, 0, 'Denya Uronil Shkaf na ekran!', 255, 127, 127, 255, 10)
    --GameRules:SendCustomMessage('Denya Uronil Shkaf v chat!', DOTA_TEAM_FIRST, 0)
    --DeepPrintTable(event)
end

-- pretty useles event, it doesn't even provide the point where skill was casted
---@param event t_ability_brief_event
---@class t_ability_brief_event
---@field     caster_entindex   number
---@field     abilityname       string
---@field     PlayerID          number
---@field     splitscreenplayer number
local dota_unit_used_ability = function(event) end

---@param event t_pick_hero_event
---@class t_pick_hero_event
---@field     player    number player index starting with 1
---@field     heroindex string
---@field     hero      string datadriven name
---@field     splitscreenplayer number
local dota_player_pick_hero = function(event)
    local hero = EntIndexToHScript(event.heroindex)
    local playerId = event.player - 1

    local role = klesun.playerIdToRole[playerId]
    if role == 'builder' then
        local datadriven = PlayerResource:GetTeam(playerId) == DOTA_TEAM_GOODGUYS
            and 'npc_dota_hero_vengefulspirit'
            or 'npc_dota_hero_lycan'
        if hero:GetUnitName() ~= datadriven then
            lang.Timeout(0.000001).callback = function()
                -- for some reason replace is not allowed instantly
                PlayerResource:ReplaceHeroWith(playerId, datadriven, 800, 0)
            end
        end
    end

    if hero:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then
        local dagger = CreateItem("item_blink", hero, hero)
        dagger:SetPurchaseTime(0)
        hero:AddItem(dagger)
    end
    if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        local abil = hero:AddAbility('dire_xp_gain_aura')
        abil:SetLevel(1)
    end
    if botIdToData[playerId] then
        hero:SetThink(function()
            local ok, data = pcall(function() require('bot_ai').GiveOrders(hero, playerId) end)
            local delay
            if ok then delay = 0.5 else
                print('Got exception while trying to give AI orders')
                DeepPrintTable({data})
                delay = 5
            end
            return delay
        end)
    end
end

---@param event t_chat_event
---@class t_chat_event
---@field     playerid          number
---@field     text              string
---@field     teamonly          number
---@field     userid            number
---@field     splitscreenplayer number
local player_chat = function(event) end

-- happens when you see the "TEAM SELECT" screen
---@param event t_player_connected_full_event
---@class t_player_connected_full_event
---@field     PlayerID          number
---@field     index             number
---@field     userid            number
---@field     splitscreenplayer number
local player_connect_full = function(event)
    klesun.playerIdToUserId[event.PlayerID] = event.userid

    -- default team/role if player does not choose something
    local defaultRole = math.random() < 0.5 and 'builder' or 'hero'
    local defaultTeam = DOTA_TEAM_GOODGUYS
    PlayerResource:SetCustomTeamAssignment(event.PlayerID, defaultTeam)
    klesun.playerIdToRole[event.PlayerID] = defaultRole
end

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
        Tutorial:AddBot('npc_dota_hero_vengefulspirit', 'mid', 'unfair', toGoodTeam)
        local botId = lastPlayerId
        botIdToData[botId] = {}
    end
end

local game_rules_state_change = function(_)
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
        Timers:CreateTimer(function()
            local pause = wave.Spawn()
            return pause
        end)
        bgm().Init()
        -- hud js is executed _after_ this block of code
        lang.Timeout(5).callback = function()
            CustomGameEventManager:Send_ServerToAllClients("display_timer", {
                msg="Sentinels Win In", duration=RADIANT_VICTORY_TIME,
                mode=0, endfade=false, position=0, warning=5, paused=false, sound=true
            })
            GameRules:SetCustomVictoryMessage('The Christmas Tree Was Destroyed')
            lang.Timeout(RADIANT_VICTORY_TIME).callback = function()
                GameRules:SetCustomVictoryMessage('The Christmas Tree Was Saved')
                GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            end
        end
    elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT then
        bgm().RestorePlayerSettings()
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

local entity_hurt = function(event)
    local damage = event.damage
    local unit = EntIndexToHScript(event.entindex_killed)
    if unit and unit.GetUnitName and not (unit.envyNs and unit.envyNs.isDying) then
        local perc = unit:GetHealth() / unit:GetMaxHealth()
        if perc <= 0.33 then
            unit.envyNs = unit.envyNs or {}
            unit.envyNs.isDying = true
            if unit:GetUnitName() == 'npc_dota_creature_gnoll_boss' then
                bgm().SoundOn('bgm_sad_victory', unit, 14)
            elseif unit:GetUnitName() == 'npc_dota_goodguys_fort' then
                bgm().SoundOn('bgm_sad_defeat', unit, 14)
            end
        end
    end
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
end

Timers:RemoveTimers(true)
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
Relisten('entity_hurt', entity_hurt)

RelistenCust('klesun_event_js_to_lua', klesun_event_js_to_lua)

local Main = function()
    -- how many seconds users can spend on page defined by <CustomUIElement type="GameSetup" layoutfile="..." />
    GameRules:SetCustomGameSetupTimeout(SETUP_MAX_TIME)
    -- how much time on "TEAM SELECT" screen
    GameRules:SetCustomGameSetupAutoLaunchDelay(10)
    -- how many seconds before you start losing gold for not picking a hero
    GameRules:SetHeroSelectionTime(30)
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