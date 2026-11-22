-- WoWFN — Reputations: Persian faction names and standing labels.

local N = WoWFN
local M = { id = "reputations", label = "شهرت‌ها", active = true }
N.Register(M)

-- Standing labels shown in the reputation pane and tooltips.
local STANDINGS = {
    ["Hated"] = "مورد نفرت", ["Hostile"] = "خشمگین", ["Unfriendly"] = "غیردوستانه",
    ["Neutral"] = "بی‌طرف", ["Friendly"] = "دوستانه", ["Honored"] = "محترم",
    ["Revered"] = "بزرگ‌داشت", ["Exalted"] = "آزموخته",
}

-- Faction names: FactionData from the release data pack or the seed table.
local FACTIONS = {}

function M.AddFactions(tbl)
    if type(tbl) == "table" then
        for en, fa in pairs(tbl) do
            if type(fa) == "string" and fa ~= "" then FACTIONS[en] = fa end
        end
    end
end

local function translateStanding(text, tooltip)
    local fa = STANDINGS[text]
    if fa and tooltip then
        N.Tooltip.Add(tooltip, fa)
        return true
    end
    return false
end

function M.Setup()
    -- seed from main data registry if a factions table exists there
    local D = N.Data and N.Data.factions
    if D then M.AddFactions(D) end

    -- reputation pane rows: FactionStandingTemplate buttons carry the
    -- English faction name in their FontString
    local pane = ReputationFrame or ReputationListFrame
    if pane and pane.scrollFrame and pane.scrollFrame.buttons then
        for _, btn in ipairs(pane.scrollFrame.buttons) do
            if btn and not btn.__wofnHooked then
                btn.__wofnHooked = true
                btn:HookScript("OnEnter", function(b)
                    local ok, name = pcall(function()
                        return b.name and b.name:GetText() or nil
                    end)
                    if not ok or not name then return end
                    local fa = FACTIONS[name]
                    if fa then
                        GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
                        GameTooltip:AddLine(name, 1, 1, 1)
                        N.Tooltip.Add(GameTooltip, fa)
                        GameTooltip:Show()
                    end
                end)
                btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
            end
        end
    end

    -- standing labels in tooltips (inspect, guild rep pane)
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f and f.HookScript then
            N.HookTooltipScript(M.id, f, "OnShow", function(self)
                local ok, lines = pcall(function()
                    return self and self:NumLines() or 0
                end)
                if not ok or not lines then return end
                for i = 1, lines do
                    local fs = _G[(self:GetName() or "") .. "TextLeft" .. i]
                    if fs then
                        local txt = fs:GetText()
                        if txt and STANDINGS[txt] then
                            local fa = STANDINGS[txt]
                            if not txt:find("\239\174") then -- already translated
                                N.Tooltip.Add(self, fa)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end

M.FACTIONS = FACTIONS
M.STANDINGS = STANDINGS
