
require('libs.timers')
local json = require('reloaded.json')

-- vars that are kept after code reload
if klesun == nil then klesun = {} end
if klesun.eventToFunc == nil then klesun.eventToFunc = {} end

-- listen for Dota game event or update function if already listening
local Relisten = function(eventName, func)
    if klesun.eventToFunc[eventName] == nil then
        ListenToGameEvent(eventName, function(e)
            klesun.eventToFunc[eventName](e)
        end, nil)
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
    player:MakeRandomHeroSelection()
    ---@debug
    print('Player connected - ' .. PlayerResource:GetPlayerName(event.PlayerID))
    --PlayerResource:SetHasRandomed(event.PlayerID)
    --PlayerResource:SetOverrideSelectionEntity(event.PlayerID, ...)
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
    print('OnPlayerTeam')
    DeepPrintTable(event)
end

local game_rules_state_change = function(_)
    print('game_rules_state_change - ' .. GameRules:State_Get())
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
        local playerId = 0 -- 0 = debug player id
        local player = PlayerResource:GetPlayer(playerId)
        player:MakeRandomHeroSelection()
    end
end

Timers:RemoveTimers(true)
Timers:CreateTimer(function()
    --print('Executing code in a timer! Game Time - ' .. GameRules:GetGameTime() .. ' Server Time - ' .. Time())

    -- spawning a golem at a certain point
    local spawnMark = Entities:FindByName(nil, 'huj123')
    local goalMark = Entities:FindByName(nil, 'pizda456')
    --local spawnMark = Entities:FindByTarget(nil, 'spawn_point_golem')
    --local goalMark = Entities:FindByTarget(nil, 'castle_to_defend')
    local point = spawnMark:GetAbsOrigin()
    local goal = goalMark:GetAbsOrigin()

    local seconds = GameRules:GetGameTime();
    local hp = 50 + seconds;
    local dmg = 15 + seconds / 20;

    if seconds > 60 then cnt = cnt + 1 end
    if seconds > 180 then cnt = cnt + 1 end
    if seconds > 540 then cnt = cnt + 1 end
    if seconds > 1620 then cnt = cnt + 1 end

    for i = 1,cnt,1 do
        local golem = CreateUnitByName(
        'npc_dota_creature_gnoll_assassin',
        point + RandomVector(RandomInt(100, 200)),
        true, nill, nill, DOTA_TEAM_BADGUYS
        )
        golem:SetBaseAttackTime(1)
        golem:SetBaseDamageMin(dmg)
        golem:SetBaseDamageMax(dmg)
        golem:SetBaseMaxHealth(hp)
        golem:SetBaseHealthRegen(5)
        golem:SetBaseMoveSpeed(500)

        -- need to apply any modifier to update npc gui numbers
        golem:AddNewModifier(nil, nil, "modifier_stunned", {duration = 2.0})
        GameRules:SendCustomMessage('Creep spawned with hp: ' .. math.floor(hp) ..' dmg: ' .. math.floor(dmg), DOTA_TEAM_FIRST, 0)

        ExecuteOrderFromTable({
            UnitIndex = golem:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = goal, Queue = true
        })
    end

    return 5.0
end)

return function()
    -- how much time on "TEAM SELECT" screen
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    -- how many seconds before you start losing gold for not picking a hero
    GameRules:SetHeroSelectionTime(0)
    -- the 30 seconds to buy wards after hero pick
    GameRules:SetStrategyTime(0)
    -- Set the duration of the 'radiant versus dire' showcase screen
    GameRules:SetShowcaseTime(0)
    -- how many seconds before Kenarius says "Let's the battle begin!"
    GameRules:SetPreGameTime(0)

    Relisten('entity_killed', entity_killed)
    Relisten('dota_player_pick_hero', dota_player_pick_hero)
    Relisten('dota_player_used_ability', dota_unit_used_ability)
    Relisten('dota_non_player_used_ability', dota_unit_used_ability)
    Relisten('player_chat', player_chat)
    Relisten('player_connect_full', player_connect_full)
    Relisten('player_team', player_team)
    Relisten('game_rules_state_change', game_rules_state_change)
end
