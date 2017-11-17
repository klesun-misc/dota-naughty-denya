
local lang = require('reloaded.lang')
local types = require('types')

local makeSelf = function()
    local bgmEnt = types:t_ent(Entities:CreateByClassname("info_target"))
    local bgmStack = 0
    local initialVolume = Convars:GetFloat('snd_musicvolume')

    local StackBgm = function(sign)
        bgmStack = bgmStack + sign
        if bgmStack == 0 then
            Convars:SetFloat('snd_musicvolume', initialVolume)
        end
    end
    local interruptCurrentSound = nil

    -- disable music for a duration
    local Quiet = function(fadeTime, duration)
        local result = { callback = function() return function() end end}
        StackBgm(1)
        local interrupted = false;
        local stopSound = function() end
        if interruptCurrentSound then interruptCurrentSound() end
        interruptCurrentSound = function()
            if not interrupted then
                StackBgm(-1)
                interruptCurrentSound = nil
            end
            interrupted = true
            stopSound()
        end
        lang.Animate({
            from = Convars:GetFloat('snd_musicvolume'),
            to = 0,
            period = fadeTime,
            -- changes volume setting of every player
            setter = function(val)
                if not interrupted then
                    Convars:SetFloat('snd_musicvolume', val)
                end
            end,
            callback = function()
                if not interrupted then
                    stopSound = result.callback()
                    lang.Timeout(duration + fadeTime).callback = interruptCurrentSound
                end
            end,
        })
        return result
    end

    local Init = function()
        local PlayAt = function(time, songName, songLength)
            lang.Timeout(time).callback = function()
                Quiet(5, songLength).callback = function()
                    bgmEnt:EmitSound(songName)
                    return function() bgmEnt:StopSound(songName) end
                end
            end
        end

        PlayAt(60 * 10, 'bgm_chuvstva_yuzefi', 90)
    end

    ---@param songName string - name in the .../content/.../soundevents/custom_sounds.vsndevts_c
    ---@param ent CBaseEntity
    local SoundOn = function(songName, ent, dura)
        -- don't use GetSoundDuration(), it returns 2.00
        -- on first call per dota process for some reason
        --dura = dura or ent:GetSoundDuration(songName, '')
        Quiet(0.1, dura).callback = function()
            ent:EmitSound(songName)
            return function()
                if ent and not ent:IsNull() then
                    ent:StopSound(songName)
                end
            end
        end
    end

    local RestorePlayerSettings = function()
        Convars:SetFloat('snd_musicvolume', initialVolume)
    end

    return {
        -- call on map load to schedule bgm music at time
        Init = Init,
        -- play some random jingle. quiet all other music down temporarily
        SoundOn = SoundOn,
        RestorePlayerSettings = RestorePlayerSettings,
    }
end

envy_ns = envy_ns or {}
envy_ns.bgm = envy_ns.bgm or function()
    if envy_ns.bgm_instantiated then
        return envy_ns.bgm_instantiated
    else
        envy_ns.bgm_instantiated = makeSelf()
        return envy_ns.bgm_instantiated
    end
end
return envy_ns.bgm
