-- WoWFN — Options panel: modes, font size, module switches, data counts.

local N = WoWFN
local P = {}
N.Panel = P

local frame

local function checkbox(parent, label, get, set, x, y)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)
    cb:SetChecked(get())
    cb:SetScript("OnClick", function(self) set(self:GetChecked()) end)
    cb:SetPoint("TOPLEFT", x, y)
    return cb
end

function P.Build()
    if frame then return frame end
    frame = CreateFrame("Frame", "WoWFNPanel", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(420, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("WoWFN — فارسی‌ساز Forever")

    -- display mode
    local modes = { [1] = "حالت ۱: فشرده‌سازی حروف (توصیه‌شده)", [2] = "حالت ۲: خام — بدون تغییر",
                    [3] = "حالت ۳: کامل — راست‌به‌چپ دستی" }
    local y = -46
    P.modeBtns = {}
    for m, label in pairs(modes) do
        local rb = CreateFrame("CheckButton", "WoWFNMode" .. m, frame, "UIRadioButtonTemplate")
        rb:SetPoint("TOPLEFT", 18, y)
        local txt = rb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        txt:SetPoint("LEFT", rb, "RIGHT", 6, 0)
        txt:SetText(label)
        rb:SetScript("OnClick", function()
            N.db.mode = m
            for mm, btn in pairs(P.modeBtns) do btn:SetChecked(mm == m) end
        end)
        P.modeBtns[m] = rb
        y = y - 24
    end

    -- font size slider
    local slider = CreateFrame("Slider", "WoWFNSize", frame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 18, y - 10)
    slider:SetWidth(280)
    slider:SetMinMaxValues(8, 22)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    _G["WoWFNSizeLow"]:SetText("۸")
    _G["WoWFNSizeHigh"]:SetText("۲۲")
    _G["WoWFNSizeText"]:SetText("اندازهٔ فونت")
    slider:SetScript("OnValueChanged", function(self, v)
        N.db.fontSize = math.floor(v + 0.5)
        _G["WoWFNSizeText"]:SetText("اندازهٔ فونت: " .. N.db.fontSize)
    end)
    y = y - 60

    -- per-module switches
    y = y - 6
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, y)
    title:SetText("ماژول‌ها")
    y = y - 26
    for id, m in pairs(N.Modules) do
        checkbox(frame, m.label or id,
            function() return m.active end,
            function(v) m.active = v end, 18, y)
        y = y - 28
    end

    -- data counts
    local info = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    info:SetPoint("BOTTOMLEFT", 18, 30)
    info:SetJustifyH("LEFT")
    info:SetMultiLine(true)
    local c = N.Counts()
    info:SetText(("ترجمه‌های بارگذاری‌شده — طلسم: %d | کلاس: %d | آمار: %d | رابط: %d")
        :format(c.spells or 0, c.classes or 0, c.stats or 0, c.ui or 0))

    local ver = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("BOTTOMLEFT", 18, 14)
    ver:SetText(("نسخه %s — wowfarsi.ir"):format(N.VERSION))

    return frame
end

function P.Toggle()
    if frame and frame:IsShown() then
        frame:Hide()
    else
        P.Build()
        if P.modeBtns then
            for m, btn in pairs(P.modeBtns) do btn:SetChecked((N.db.mode or 1) == m) end
        end
        frame:Show()
    end
end
