local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end




local frame = CreateFrame("Frame")
local addon_prefix_sunder_cast = 'SACAST'

local sundercounts = {}

frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function()
    if event ~= 'CHAT_MSG_ADDON' then return end
    if arg1 ~= 'SACAST' then return end

    if not sundercounts[arg4] then
        sundercounts[arg4] = 0
    end

    sundercounts[arg4] = sundercounts[arg4] + 1
end)




local spellidcache = {}

local function GetSpellCooldownByName(spellName)
    local checkFor = function(bookType)
        -- check cache first
        local spellid = spellidcache[spellName]
        if spellid then
            -- print('found in cache')
            local _, duration = GetSpellCooldown(spellid, bookType);
            return duration;
        end

        -- nothing in cache, start scanning
        local i = 1
        while true do
            local name, spellRank = GetSpellName(i, bookType);
            
            if not name then
                break;
            end
            
            if name == spellName then
                -- print(string.format('name %s rank %s', name, spellRank))
                spellidcache[name] = i
                local _, duration = GetSpellCooldown(i, bookType);
                return duration;
            end
            
            i = i + 1
        end
        return nil;
    end
    
    
    --local cd = checkFor(BOOKTYPE_PET);
    --if not cd then cd = checkFor(BOOKTYPE_SPELL); end
    local cd = checkFor(BOOKTYPE_SPELL);
    
    return cd;
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


local lastsunder = 0

hooksecurefunc("CastSpellByName", function(spell, target)
    if not spell then return end
    if type(spell) ~= 'string' then return end
    -- if target == nil then return end
    --print(string.format('testing %s %s', tostring(spell), tostring(target)))
    spell = string.lower(spell)
    if not string.find(spell, 'sunder armor') then
        -- print('spell name?')
        return
    end

    -- Now we've found sunder. Check the cooldown
    local cd = GetSpellCooldownByName('Sunder Armor')
    if cd == 0 then
        -- print(string.format('cooldown? %s ', cd))
        return
    end

    -- Test for target
    if UnitCanAttack("player", "target") == nil then
        -- print('cannot attack?')
        return
    end

    local now = GetTime()
    if lastsunder + cd >= now then
        -- print('cooldown 2?')
        return
    end

    lastsunder = GetTime()

    SendAddonMessage(addon_prefix_sunder_cast, 'whatever', "RAID")
    print('sundered!')
end, true)


local function dumpcounts()
    print('sunder counts:')

    local len = 0
    for k, v in pairs(sundercounts) do
        print(string.format('%s %s', k, v))
        len = len + 1
    end

    if len == 0 then
        print('no data')
    end

    print('sunder counts end')
end

local function resetcounts()
    sundercounts = {}
    print('sunder counts reset')
end


SLASH_SUNDERCOUNTS1 = "/sundercounts";
SlashCmdList["SUNDERCOUNTS"] = dumpcounts

SLASH_SUNDERRESET1 = "/sunderreset";
SlashCmdList["SUNDERRESET"] = resetcounts
