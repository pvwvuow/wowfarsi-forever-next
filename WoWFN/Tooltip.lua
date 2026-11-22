-- WoWFN — Tooltip helper: append a Persian line under the original text.

local N = WoWFN
local H = {}
N.Tooltip = H

-- Append a Persian translation line to a tooltip. Returns the line added
-- or nil. Uses the Vazirmatn font when available and falls back to the
-- tooltip font otherwise.
function H.Add(tooltip, faText, kind)
    if not tooltip or not faText or faText == "" then return nil end
    if not N.db or N.db.showPersian == false then return nil end

    local T = N.T
    local shown = T.Process(faText)
    local color = "|cffb8d8ff"

    local ok, line = pcall(function()
        -- AddLine returns the FontString on modern clients
        return tooltip:AddLine(color .. shown .. "|r")
    end)
    if ok and line and line.SetFont then
        local size = 12
        if GameTooltipText then
            local _, fsz = GameTooltipText:GetFont()
            size = tonumber(fsz) or 12
        end
        line:SetFont(N.FONT, size, "")
        line:SetNonSpaceWrap(true)
        return line
    end

    -- fallback: second fontstring through AddFontStrings is not always
    -- available on cached tooltips; try AddLine without the return value
    if tooltip.AddLine then
        tooltip:AddLine(color .. shown .. "|r", 0.72, 0.85, 1)
        return true
    end
    return nil
end

-- Read the first left-aligned line of a tooltip (the "name" line).
function H.NameOf(tooltip)
    if not tooltip or not tooltip.GetOwner then return nil end
    local ok, name = pcall(function()
        local region = tooltip:GetName() and _G[tooltip:GetName() .. "TextLeft1"] or nil
        return region and region:GetText() or nil
    end)
    return ok and name or nil
end
