
require('reloaded.abil_impl')

-- these functions should all redirect to klesun.abilImpl.* so
-- you could reload their implementation without restarting dota

UronitjShkaf = function(event)
    return klesun.abilImpl.UronitjShkaf(event)
end