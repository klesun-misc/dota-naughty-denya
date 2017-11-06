
local lang = require('reloaded.lang')

local Init = function()
    local PlayAt = function(time, songName, songLength)
        lang.Timeout(time).callback = function()
            local oldValue = Convars:GetFloat('snd_musicvolume')
            lang.Animate({
                from = oldValue,
                to = 0,
                period = 10.00,
                -- changes volume setting of every player
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

    PlayAt(60 * 3, 'bgm_chuvstva_yuzefi', 90)
    PlayAt(60 * 9, 'bgm_chuvstva_yuzefi', 90)
    PlayAt(60 * 15, 'bgm_chuvstva_yuzefi', 90)end

return {
    Init = Init,
}