-- WoWFN — Spells: Persian spell/talent names and descriptions in tooltips.

local N = WoWFN
local M = { id = "spells", label = "طلسم‌ها", active = true }
N.Register(M)

-- GameTooltip OnTooltipSetSpell / OnTooltipSetUnit style handlers.
local function addSpellLine(tooltip, info)
    local id = info and (info.id or info[1])
    if not id or not tooltip then return end
    local name, _, icon = C_Spell and C_Spell.GetSpellInfo and select(1, C_Spell.GetSpellInfo(id))
        or select(1, GetSpellInfo(id))
    if not name then return end
    local fa = N.Lookup("spells", name)
    if not fa then
        -- talent rows: try stripping "Rank x"
        fa = N.Lookup("spells", name:gsub("%s*%((Rank %d+)%)$", ""))
    end
    if fa then N.Tooltip.Add(tooltip, fa) end
end

local function hookTooltip(tooltip)
    if tooltip.__wofnSpellHooked then return end
    tooltip.__wofnSpellHooked = true
    N.HookTooltipScript(M.id, tooltip, "OnTooltipSetSpell", function(self)
        local ok, info = pcall(function() return self and self:GetSpell() end)
        if ok then addSpellLine(self, info) end
    end)
end

function M.Setup(m)
    hookTooltip(GameTooltip)
    hookTooltip(ItemRefTooltip)

    -- spellbook / talent frame buttons (Blizzard reuses SpellButtonTemplate)
    local hooked = 0
    local function hookButtons(parentKey)
        local frame = _G[parentKey]
        if not frame or not frame.buttons then return end
        for _, btn in ipairs(frame.buttons) do
            if btn and not btn.__wofnHooked then
                btn.__wofnHooked = true
                btn:HookScript("OnEnter", function(b)
                    local slot = b:GetID()
                    local tab = SpellBookFrame and SpellBookFrame.selectedTab or 1
                    local ids = { GetSpellBookItemInfo(slot, tab) }
                    if ids and ids[1] then
                        local name = select(1, GetSpellInfo(ids[1], "spell"))
                        local fa = name and N.Lookup("spells", name)
                        if fa then N.Tooltip.Add(GameTooltip, fa) end
                    end
                end)
                hooked = hooked + 1
            end
        end
    end

    if SpellBookFrame then
        hookButtons("SpellBookFrame")
        SpellBookFrame:HookScript("OnShow", function() hookButtons("SpellBookFrame") end)
    end
    if TalentFrame then
        hookButtons("TalentFrame")
    end
    if PlayerTalentFrame then
        hookButtons("PlayerTalentFrame")
    end
    m.hookCount = hooked
end
