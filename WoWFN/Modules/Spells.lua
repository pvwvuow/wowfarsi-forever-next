-- WoWFN — Spells: Persian spell/talent names and descriptions.
-- Covers GameTooltip spell tooltips, the spellbook, the talent frame
-- and spell book page headers.

local N = WoWFN
local M = { id = "spells", label = "طلسم‌ها", active = true }
N.Register(M)

local function spellNameFromId(id)
    if not id then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, id)
        if ok and info and info.name then return info.name end
    end
    if GetSpellInfo then
        local ok, name = pcall(select, 1, GetSpellInfo(id))
        if ok then return name end
    end
    return nil
end

local function lookupSpell(name)
    if not name then return nil end
    local fa = N.Lookup("spells", name)
    if not fa then
        -- talent rows: strip "Rank x"
        fa = N.Lookup("spells", name:gsub("%s*%((Rank %d+)%)$", ""))
    end
    if not fa then
        -- passive/passive-rank forms "Name (Passive)"
        fa = N.Lookup("spells", name:gsub("%s*%(Passive%)$", ""))
    end
    return fa
end

local function addSpellLine(tooltip, info)
    local id = info and (info.id or info[1])
    if not id or not tooltip then return end
    local fa = lookupSpell(spellNameFromId(id))
    if fa then N.Tooltip.Add(tooltip, fa) end
end

local function hookTooltip(tooltip)
    if not tooltip or not tooltip.HookScript then return end
    if tooltip.__wofnSpellHooked then return end
    tooltip.__wofnSpellHooked = true
    N.HookTooltipScript(M.id, tooltip, "OnTooltipSetSpell", function(self)
        local ok, info = pcall(function() return self and self:GetSpell() end)
        if ok then addSpellLine(self, info) end
    end)
end

-- Spellbook pages: the big header shows the selected spell name.
local function annotateSpellBookHeader()
    if not SpellBookFrame then return end
    local header = _G["SpellBookSkillLineTab" ] or SpellBookFrame and SpellBookFrame.title
    -- per-spell header text lives in SpellBookFrame.titleText on modern builds
    local titleCtrl = SpellBookFrame and SpellBookFrame.titleText
        or _G["SpellBookFrameTitleText"]
    if not titleCtrl or not titleCtrl.GetText then return end
    local ok, txt = pcall(titleCtrl.GetText, titleCtrl)
    if not ok or not txt then return end
    local fa = lookupSpell(txt)
    if fa then
        titleCtrl:SetText(txt .. "  |cffb8d8ff" .. N.T.Process(fa) .. "|r")
    end
end

local function hookButtons(parentKey)
    local frame = _G[parentKey]
    if not frame or not frame.buttons then return end
    for _, btn in ipairs(frame.buttons) do
        if btn and not btn.__wofnHooked then
            btn.__wofnHooked = true
            btn:HookScript("OnEnter", function(b)
                local slot = b:GetID()
                local tab = SpellBookFrame and SpellBookFrame.selectedTab or 1
                local ok, spellType, id = pcall(GetSpellBookItemInfo, slot, tab)
                if not ok or not id then return end
                local name
                if spellType == "spell" or spellType == "futurewild" then
                    name = spellNameFromId(id)
                elseif spellType == "petaction" and GetSpellBookItemName then
                    local okN, nm = pcall(select, 1, GetSpellBookItemName(slot, tab))
                    name = okN and nm or nil
                end
                local fa = lookupSpell(name)
                if fa then N.Tooltip.Add(GameTooltip, fa) end
            end)
        end
    end
end

function M.Setup()
    hookTooltip(GameTooltip)
    hookTooltip(ItemRefTooltip)

    -- spellbook buttons: hook on show (Blizzard builds the list lazily)
    if SpellBookFrame then
        hookButtons("SpellBookFrame")
        SpellBookFrame:HookScript("OnShow", function()
            hookButtons("SpellBookFrame")
            annotateSpellBookHeader()
        end)
    end

    -- talent frames (classic + modern names)
    for _, key in ipairs({ "TalentFrame", "PlayerTalentFrame", "ClassTalentFrame" }) do
        local f = _G[key]
        if f then hookButtons(key) end
    end

    -- spellbook page-turn also swaps the header
    if SpellBookPrevPageButton then
        SpellBookPrevPageButton:HookScript("OnClick", annotateSpellBookHeader)
    end
    if SpellBookNextPageButton then
        SpellBookNextPageButton:HookScript("OnClick", annotateSpellBookHeader)
    end
end
