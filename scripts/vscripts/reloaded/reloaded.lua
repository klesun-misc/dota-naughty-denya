
-- vars that are kept after code reload
if klesun == nil then klesun = {} end
if klesun.eventToFunc == nil then klesun.eventToFunc = {} end

-- put files that contain code you want to be reloaded on "reload code" here
klesun.filesToReload = {
    'json', 'abil_impl', 'lang',
}

---@debug
print('executing reloaded.lua')

if klesun.loadedModules == nil then
    -- first time this script is loaded
    klesun.loadedModules = {}
    for key,fileName in pairs(klesun.filesToReload) do
        klesun.loadedModules[fileName] = require('reloaded.' .. fileName)
    end
end

local modules = klesun.loadedModules

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
        local jsonText = modules.json.stringify(data)
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
        elseif event.text == 'reload code' then
            getFreshCode('reloaded').thn = function(code)
                eval(code)()
                -- will be updated by eval
                for key,fileName in pairs(klesun.filesToReload) do
                    getFreshCode(fileName).thn = function(code)
                        klesun.loadedModules[fileName] = eval(code)
                    end
                end
            end
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
---@param event t_ability_brief_event
---@class t_ability_brief_event
---@field     caster_entindex   number
---@field     abilityname       string
---@field     PlayerID          number
---@field     splitscreenplayer number
local OnAbilityUsed = function(event)
    if event.abilityname == 'uronitj_shkaf' then
        Log('An ability was used!', event)
        local caster = EntIndexToHScript(event.caster_entindex)
        local abil = caster:FindAbilityByName(event.abilityname)
        Log('GetCastPoint', abil:GetCastPoint())
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
    GameRules:SetHeroSelectionTime(0)
    -- how many seconds before Kenarius says "Let's the battle begin!"
    GameRules:SetPreGameTime(0)

    Relisten('entity_killed', OnEntityKilled)
    Relisten('dota_player_pick_hero', OnHeroPicked)
    Relisten('dota_player_used_ability', OnAbilityUsed)
    Relisten('dota_non_player_used_ability', OnAbilityUsed)
    Relisten('player_chat', OnPlayerChat)
end
