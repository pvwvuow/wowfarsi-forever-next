-- WoWFN — Minimap button (square, classic style) with tooltip.

local N = WoWFN
local MM = {}
N.Minimap = MM

local BUTTON_KEY = "WoWFNMinimapButton"

function MM.Setup()
    if _G[BUTTON_KEY] then return end

    local btn = CreateFrame("Button", BUTTON_KEY, Minimap)
    btn:SetFrameStrata("MEDIUM")
    btn:SetSize(31, 31)
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("AnyUp")
    btn:SetMovable(true)

    local border = btn:CreateTexture(nil, "BACKGROUND")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(56, 56)
    border:SetPoint("TOPLEFT")
    border:SetTexCoord(0, 0.625, 0, 0.625)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(N.ROOT .. "Media\\icon")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER", 0, 0)
    btn.icon = icon

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8)
        GameTooltip:AddLine("|cff19aeffWoWFN|r فارسی‌ساز Forever", 1, 1, 1)
        GameTooltip:AddLine("کلیک چپ: پنل تنظیمات", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("کلیک راست: راهنما (/wofn)", 0.9, 0.9, 0.9)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(_, click)
        if click == "LeftButton" then
            if N.Panel and N.Panel.Toggle then N.Panel.Toggle() end
        else
            SlashCmdList["WOFN"]("help")
        end
    end)

    -- draggable around the minimap, position remembered
    local radius = 80
    btn:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local dx, dy = (cx / scale - mx), (cy / scale - my)
            local d = math.sqrt(dx * dx + dy * dy)
            local ang = math.atan2(dy, dx)
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", Minimap, "CENTER",
                math.cos(ang) * radius - self:GetWidth() / 2,
                math.sin(ang) * radius - self:GetHeight() / 2)
            N.db.minimapAngle = math.deg(ang)
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnShow", function(self)
        local a = N.db and N.db.minimapAngle
        if a then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", Minimap, "CENTER",
                math.cos(math.rad(a)) * radius - self:GetWidth() / 2,
                math.sin(math.rad(a)) * radius - self:GetHeight() / 2)
        end
    end)

    return btn
end
