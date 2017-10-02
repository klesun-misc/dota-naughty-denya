
local json = require('reloaded.json')

-- this module provides functions to extends Lua's functionality

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
    end
}