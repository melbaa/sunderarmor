
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end



local _G = getfenv(0)

local hooks = {}

function hooksecurefunc(name, func, append)
  if not _G[name] then return end

  hooks[tostring(func)] = {}
  hooks[tostring(func)]["old"] = _G[name]
  hooks[tostring(func)]["new"] = func

  if append then
    hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  else
    hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  end

  _G[name] = hooks[tostring(func)]["function"]
end


local sundercount = 0
local lastsunder = 0

hooksecurefunc("CastSpellByName", function(spell, target)
    if not spell then return end
    if type(spell) ~= 'string' then return end
    spell = string.lower(spell)
    print(string.format('testing %s %s', tostring(spell), tostring(target)))
    if not string.find(spell, 'sunder armor') then
        print('spell name?')
        return
    end

    -- Now we've found sunder. Check the cooldown
    local cd = Roids.GetSpellCooldownByName('Sunder Armor')
    if cd == 0 then
        print(string.format('cooldown? %s ', cd))
        return
    end

    -- Test for target
    if UnitCanAttack("player", "target") == nil then 
        print('attack?')
        return
    end

    local now = GetTime()
    if lastsunder + cd >= now then
        print('cooldown 2?')
        return
    end

    lastsunder = GetTime()

    sundercount = sundercount + 1
    print(string.format('sunder count %s', sundercount))
end, true)



