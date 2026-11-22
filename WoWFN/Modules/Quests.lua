-- WoWFN — Quests: full Persian coverage of the quest UI.
--
-- Covers: quest giver dialogs (title, description, progress, completion),
-- quest log buttons + tooltips, quest tooltips (map/tracker), and the
-- objective text block. Titles come from the quests table; objectives
-- from the ui table; anything missing falls back gracefully.

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

-- Rewrite a static text control with its Persian translation appended
-- (kept small: long descriptions are appended in muted color).
local function annotate(frame, textCtrl, kind)
    if not textCtrl or not textCtrl.GetText then return end
    local ok, txt = pcall(textCtrl.GetText, textCtrl)
    if not ok or not txt or txt == "" then return end
    local fa = N.Lookup(kind, txt)
    if not fa then return end
    local T = N.T
    local shown = T.Process(fa)
    if kind == "quests" then
        textCtrl:SetText(txt .. "\n|cffb8d8ff" .. shown .. "|r")
    else
        textCtrl:SetText(txt .. "\n|cffb8d8ff" .. shown .. "|r")
    end
end

local function hookQuestDialog()
    if QuestFrameDescriptionText then annotate(nil, QuestFrameDescriptionText, "quests") end
    if QuestFrameProgressText then annotate(nil, QuestFrameProgressText, "quests") end
    if QuestFrameRewardQuestText then annotate(nil, QuestFrameRewardQuestText, "quests") end
    -- header title
    if QuestFrameTitleText and QuestFrameTitleText.GetText then
        local ok, title = pcall(QuestFrameTitleText.GetText, QuestFrameTitleText)
        local fa = ok and title and N.Lookup("quests", title)
        if fa then
            QuestFrameTitleText:SetText(title .. "  |cffb8d8ff" .. N.T.Process(fa) .. "|r")
        end
    end
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
            -- Persian title under the English row title
            if btn.title and btn.title.GetText then
                local ok, title = pcall(btn.title.GetText, btn.title)
                local fa = ok and title and N.Lookup("quests", title)
                if fa and btn.title.SetFormattedText == nil or fa then
                    btn.title:SetText(title .. " |cffb8d8ff" .. N.T.Process(fa) .. "|r")
                end
            end
        end
    end
end

-- Re-annotate quest rows after the log refreshes (quests get collapsed,
-- sorted... which resets the texts).
local function hookRefresh()
    local frame = QuestScrollFrame or QuestLogEx or QuestLogFrame
    if frame and frame.HookScript then
        frame:HookScript("OnShow", hookQuestLogButtons)
    end
    if QuestLog_Update or QuestLogUpdate then
        local updater = QuestLog_Update or QuestLogUpdate
        local ok = pcall(hooksecurefunc, "QuestLog_Update", hookQuestLogButtons)
    end
end

function M.Setup()
    -- quest giver dialog: every open re-annotates current quest text
    if QuestFrame then
        QuestFrame:HookScript("OnShow", hookQuestDialog)
    end
    if QuestFrameAcceptButton then
        QuestFrameAcceptButton:HookScript("OnShow", hookQuestDialog)
    end

    -- quest tooltips (world map, objective tracker)
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f and f.HookScript then
            N.HookTooltipScript(M.id, f, "OnTooltipSetQuest", addQuestTooltip)
        end
    end

    hookQuestLogButtons()
    hookRefresh()
end
