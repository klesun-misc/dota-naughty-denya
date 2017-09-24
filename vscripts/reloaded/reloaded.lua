
local json = require('libs.json')

-- vars that are kept after code reload
if org == nil then org = {} end
if org.klesun == nil then org.klesun = {} end
if org.klesun.eventToFunc == nil then org.klesun.eventToFunc = {} end

-- listen for Dota game event or update function if already listening
local Relisten = function(eventName, func)
    if org.klesun.eventToFunc[eventName] == nil then
        ListenToGameEvent(eventName, function(e)
            org.klesun.eventToFunc[eventName](e)
        end, nil)
    end
    org.klesun.eventToFunc[eventName] = func
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
        elseif event.text == 'reload code' then
            local url = 'http://midiana.lv/unversioned/gits/dota-naughty-denya/vscripts/reloaded/reloaded.lua'
            -- don't use GET, steam caches it for couple of minutes
            local rq = CreateHTTPRequestScriptVM('POST', url)
            ---@param resp t_http_rs
            local sending = rq:Send(function(resp)
                local code = resp.Body
                print('got reloaded code \n' .. code)
                local module = eval(code)
                if module ~= nil then module() end
            end)
        end
    end
end)()

local OnEntityKilled = function(event)
    print('Unit lost!')
    -- none of these works for some reason
    DebugDrawScreenTextLine(100, 100, 0, 'Denya Uronil Shkaf na ekran!', 255, 127, 127, 255, 10)
    GameRules:SendCustomMessage('Denya Uronil Shkaf v chat!', DOTA_TEAM_FIRST, 0)
    DeepPrintTable(event)
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
        Log('An ability was used!', event)
    end
end

local OnHeroPicked = function(event)
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
local OnPlayerChat = function(event)
    InterpretCode(event)
end

return function()
    GameRules:SetHeroSelectionTime(15)
    GameRules:SetPreGameTime(10)

    Relisten('entity_killed', OnEntityKilled)
    Relisten('dota_player_pick_hero', OnHeroPicked)
    Relisten('dota_player_used_ability', OnAbilityUsed)
    Relisten('dota_non_player_used_ability', OnAbilityUsed)
    Relisten('player_chat', OnPlayerChat)
end
