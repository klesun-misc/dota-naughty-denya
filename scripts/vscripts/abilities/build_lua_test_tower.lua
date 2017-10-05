

---@debug
print('redefining code of build_lua_test_tower')
print(build_lua_test_tower)

local zalupa = 'yyyy'

build_lua_test_tower = {
    OnSpellStart = function(ability)
        local point = ability:GetCursorPosition()
        print('Building a lua test tower huj! ' .. zalupa .. ' thi xx s was zalupa')
        print(type(ability))
        DeepPrintTable(ability:GetAbilityKeyValues())
        DeepPrintTable({point})
        print('aoe radius: ' .. ability:GetAOERadius())
    end,

    GetAOERadius = function(ability)
        return 100 + math.abs(math.sin(GameRules:GetGameTime())) * 300
    end,
}
