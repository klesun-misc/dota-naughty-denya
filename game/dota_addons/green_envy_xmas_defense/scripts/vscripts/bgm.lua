
local lang = require('reloaded.lang')

-- this module is responsible for custom music playback - it decides when/what/how

--local GetPlayers = function()
--    local players = {}
--    for _, hero in pairs(HeroList:GetAllHeroes()) do
--        if hero ~= nil and hero:IsRealHero() then
--            local hPlayer = hero:GetPlayerOwner()
--            if hPlayer ~= nil then
--                table.insert(players, hPlayer)
--            end
--        end
--    end
--    return players
--end

local Init = function()
    local PlayAt = function(time, songName, songLength)
        lang.Timeout(time).callback = function()
            local oldValue = Convars:GetFloat('snd_musicvolume')
            lang.Animate({
                from = oldValue,
                to = 0,
                period = 10.00,
                setter = function(val) Convars:SetFloat('snd_musicvolume', val) end,
                callback = function()
                    lang.Timeout(10).callback = function()
                        EmitGlobalSound(songName)
                        lang.Timeout(songLength + 10).callback = function()
                            Convars:SetFloat('snd_musicvolume', oldValue)
                        end
                    end
                end,
            })
        end
    end

    PlayAt(180, 'bgm_chuvstva_yuzefi', 90)
end

return {
    Init = Init,
}