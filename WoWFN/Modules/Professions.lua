-- WoWFN — Professions: Persian profession and skill names in tooltips
-- and the tradeskill frame.

local N = WoWFN
local M = { id = "professions", label = "حرفه‌ها", active = true }
N.Register(M)

local PROFESSIONS = {
    ["Alchemy"] = "کیمیاگری", ["Blacksmithing"] = "آهنگری",
    ["Enchanting"] = "افسون‌گری", ["Engineering"] = "مهندسی",
    ["Herbalism"] = "گیاه‌شناسی", ["Inscription"] = "نگارگری",
    ["Jewelcrafting"] = "جواهرسازی", ["Leatherworking"] = "چرم‌دوزی",
    ["Mining"] = "معدن‌کاری", ["Skinning"] = "پوست‌کنی", ["Tailoring"] = "خیاطی",
    ["Cooking"] = "آشپزی", ["First Aid"] = "کمک‌های اولیه",
    ["Fishing"] = "ماهیگیری", ["Archaeology"] = "باستان‌شناسی",
    ["Riding"] = "سوارکاری", ["Lockpicking"] = "کلیدسازی",
    ["Survival"] = "بقا", ["Runeforging"] = "رون‌سازی",
}

-- Secondary/specialization labels
local SPECIALIZATIONS = {
    ["Gnomish Engineering"] = "مهندسی گنومی", ["Goblin Engineering"] = "مهندسی گابلین",
    ["Dragon Scale Leatherworking"] = "چرم‌دوزی فلس اژدها",
    ["Elemental Leatherworking"] = "چرم‌دوزی بنیادی",
    ["Tribal Leatherworking"] = "چرم‌دوزی قبیله‌ای",
    ["Master of Elixirs"] = "استاد اکسیرها", ["Potion Master"] = "استاد معجون‌ها",
    ["Transmutation Master"] = "استاد دگردیسی",
    ["Hammer of the North"] = "پتک شمال",
    ["Weaponsmith"] = "سازندهٔ سلاح", ["Armorsmith"] = "سازندهٔ زره",
    ["Hammersmith"] = "سازندهٔ پتک", ["Axesmith"] = "سازندهٔ تبر",
    ["Swordsmith"] = "سازندهٔ شمشیر",
}

local ALL = {}
for en, fa in pairs(PROFESSIONS) do ALL[en] = fa end
for en, fa in pairs(SPECIALIZATIONS) do ALL[en] = fa end

function M.Lookup(en) return ALL[en] end

local function addTradeTooltip(tooltip)
    -- tradeskill/recipe tooltips carry the profession in line 2+
    local ok, lines = pcall(function() return tooltip and tooltip:NumLines() or 0 end)
    if not ok or not lines then return end
    local name = tooltip.GetName and tooltip:GetName() or ""
    for i = 1, lines do
        local fs = _G[name .. "TextLeft" .. i]
        if fs then
            local txt = fs:GetText()
            local fa = txt and ALL[txt]
            if fa then
                N.Tooltip.Add(tooltip, fa)
                return
            end
        end
    end
end

function M.Setup()
    -- profession/skill line tooltips (skills pane)
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f and f.HookScript then
            N.HookTooltipScript(M.id, f, "OnShow", addTradeTooltip)
        end
    end

    -- tradeskill frame header: append Persian name
    if TradeSkillFrame then
        TradeSkillFrame:HookScript("OnShow", function()
            local ok, txt = pcall(function()
                return TradeSkillFrameTitleText and TradeSkillFrameTitleText:GetText()
            end)
            if ok and txt then
                local fa = ALL[txt]
                if fa and TradeSkillFrameTitleText then
                    TradeSkillFrameTitleText:SetText(txt .. "  |cffb8d8ff" .. N.T.Process(fa) .. "|r")
                end
            end
        end)
    end
end

M.PROFESSIONS = PROFESSIONS
M.SPECIALIZATIONS = SPECIALIZATIONS
