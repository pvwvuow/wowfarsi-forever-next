-- WoWFN — NPCs: Persian NPC names in unit tooltips and nameplates.

local N = WoWFN
local M = { id = "npcs", label = "شخصیت‌ها", active = true }
N.Register(M)

local function addUnitLine(tooltip)
    if not tooltip or not tooltip.GetUnit then return end
    local ok, unit = pcall(function() return tooltip:GetUnit() end)
    if not ok or not unit then return end
    local name = UnitName(unit)
    if not name or name == "" then return end
    local fa = N.Lookup("npcs", name)
    if fa then N.Tooltip.Add(tooltip, fa) end
end

function M.Setup()
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f then
            N.HookTooltipScript(M.id, f, "OnTooltipSetUnit", addUnitLine)
        end
    end
end
