-- WoWFN — Items: Persian item names in tooltips (bag, chat link, loot).

local N = WoWFN
local M = { id = "items", label = "آیتم‌ها", active = true }
N.Register(M)

local function addForTooltip(tooltip)
    if not tooltip or not tooltip.GetItem then return end
    local ok, link = pcall(function() return tooltip:GetItem() end)
    if not ok or not link then return end
    local name = link:match("^|%c+.-|h%[(.-)%]|h")
    if not name then
        local ok2, id = pcall(function() return tooltip:GetItem() end)
        if not ok2 then return end
    end
    local fa = name and N.Lookup("items", name)
    if fa then N.Tooltip.Add(tooltip, fa) end
end

local TOOLTIPS = { "GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2" }

function M.Setup()
    for _, key in ipairs(TOOLTIPS) do
        local f = _G[key]
        if f then
            N.HookTooltipScript(M.id, f, "OnTooltipSetItem", addForTooltip)
        end
    end
end
