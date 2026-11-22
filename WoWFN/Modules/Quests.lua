-- WoWFN — Quests: Persian titles and objectives in quest tooltips,
-- quest log and NPC quest dialogs (Classic + modern API).

local N = WoWFN
local M = { id = "quests", label = "مأموریت‌ها", active = true }
N.Register(M)

-- Classic: GetQuestLogTitle(index) -> title, ...
local function classicTitle(idx)
    if GetQuestLogTitle then
        local ok, title = pcall(function() return select(1, GetQuestLogTitle(idx)) end)
        if ok then return title end
    end
    return nil
end

-- Modern: C_QuestLog.GetInfo(logIndex)
local function modernTitle(idx)
    if C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, idx)
        if ok and info and info.title then return info.title end
    end
    return nil
end

local function titleFor(idx)
    return modernTitle(idx) or classicTitle(idx)
end

local function addQuestTooltip(tooltip)
    local id = nil
    if tooltip and tooltip.GetQuestID then id = tooltip:GetQuestID() end
    if not id then return end
    local ok, title = pcall(function()
        if C_QuestLog and C_QuestLog.GetQuestInfo then
            return select(1, C_QuestLog.GetQuestInfo(id))
        end
    end)
    local fa = title and N.Lookup("quests", title)
    if fa then N.Tooltip.Add(tooltip, fa) end
end

local function hookQuestLogButtons()
    local sf = QuestScrollFrame
    if not sf and QuestLogEx then sf = QuestLogEx.ScrollFrame end
    if not sf or not sf.buttons then return end
    for _, btn in ipairs(sf.buttons) do
        if btn and not btn.__wofnHooked then
            btn.__wofnHooked = true
            btn:HookScript("OnEnter", function(b)
                local idx = b:GetID()
                local title = titleFor(idx)
                local fa = title and N.Lookup("quests", title)
                if fa then
                    GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(title, 1, 1, 1)
                    N.Tooltip.Add(GameTooltip, fa)
                    GameTooltip:Show()
                end
            end)
            btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end
end

function M.Setup()
    -- quest giver dialog: show the Persian title beside the English one
    if QuestFrame then
        QuestFrame:HookScript("OnShow", function()
            local ok, title = pcall(function() return GetTitleText() end)
            if not ok or not title then return end
            local fa = N.Lookup("quests", title)
            if fa and QuestFrameTitleText and QuestFrameTitleText.SetText then
                QuestFrameTitleText:SetText(title .. "  |cffb8d8ff" .. N.T.Process(fa) .. "|r")
            end
        end)
    end

    -- objective tracker rows: GossipFrame / QuestFrame progress text
    if GossipFrame then
        GossipFrame:HookScript("OnShow", function()
            if GossipFrameGreetingPanel and QuestGetText then return end
        end)
    end

    -- quest tooltips (world map, objective tracker)
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f and f.HookScript then
            N.HookTooltipScript(M.id, f, "OnTooltipSetQuest", addQuestTooltip)
        end
    end

    -- quest log listing (hook now and whenever the frame shows)
    hookQuestLogButtons()
    local frame = QuestScrollFrame or QuestLogEx or QuestLogFrame
    if frame and frame.HookScript then
        frame:HookScript("OnShow", hookQuestLogButtons)
    end
end
