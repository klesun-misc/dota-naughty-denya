
local json = require('reloaded.json')

-- this module provides functions to extends Lua's functionality

local Timeout = function(seconds)
    local result = {callback = function() end}
    Timers:CreateTimer({
        endTime = seconds,
        callback = function() result.callback() end,
    })
    return result
end

return {
    Keys = function(tbl)
        local keys = {}
        local i = 1
        for k,v in pairs(tbl) do
            keys[i] = k
            i = i + 1
        end
        return keys
    end,

    Log = function(msg, data)
        print('Lang: ' .. msg)
        if (data ~= nil) then
            print(json.stringify(data):sub(1,200))
        end
    end,

    Size = function(tbl)
        local count = 0
        for _ in pairs(tbl) do count = count + 1 end
        return count
    end,

    Timeout = Timeout,

    Animate = function(params)
        local from = params.from
        local to = params.to
        local period = params.period
        local setter = params.setter
        local callback = params.callback or function() end
        local steps = params.steps or 10
        local rec = {}
        rec.doNext = function(stepsLeft)
            local progress = (steps - stepsLeft) / steps
            local value = from + (to - from) * progress
            setter(value)
            if stepsLeft > 0 then
                Timeout(period / steps).callback =
                    function() rec.doNext(stepsLeft - 1) end
            else
                callback()
            end
        end
        rec.doNext(steps)
    end,
}