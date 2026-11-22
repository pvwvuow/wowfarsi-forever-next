-- WoWFN — Quests: Persian titles and objectives in quest tooltips,
-- quest log and NPC quest dialogs.

local N = WoWFN
local M = { id = "quests", label = "مأموریت‌ها", active = true }
N.Register(M)

-- Quest log entries: hook the blizz quest log title rows via their
-- OnEnter tooltip when the client exposes QuestMapTitle with a tooltip.
local function questTitle()
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        local id = C_QuestLog.GetSelectedQuest()
        if id then
            local info = C_QuestLog.GetQuestInfo and C_QuestLog.GetQuestInfo(id)
            return info and info.title or (GetTitleFromQuest and GetTitleFromQuest(id))
        end
    end
    local title = GetQuestLogTitle and select(1, GetQuestLogSelection and GetQuestLogSelection())
    return title
end

function M.Setup()
    -- quest giver dialog: current / available quest title shown to the player
    if QuestFrame then
        QuestFrame:HookScript("OnShow", function()
            local title = GetTitleText and GetTitleText()
            local fa = title and N.Lookup("quests", title)
            if fa then N.Say(("مأموریت: %s"):format(fa)) end
        end)
    end

    -- quest tooltip on the objective tracker and world map buttons
    for _, key in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
        local f = _G[key]
        if f then
            N.HookTooltipScript(M.id, f, "OnTooltipSetQuest", function(self)
                local ok, info = pcall(function() return self and self:GetQuestID() end)
                if ok and info then
                    local title = C_QuestLog and C_QuestLog.GetQuestInfo
                        and select(1, C_QuestLog.GetQuestInfo(info)) or nil
                    local fa = title and N.Lookup("quests", title)
                    if fa then N.Tooltip.Add(self, fa) end
                end
            end)
        end
    end

    -- quest log listing
    if QuestLogEx and QuestLogEx.ScrollFrame or QuestScrollFrame then
        local sf = QuestScrollFrame or QuestLogEx and QuestLogEx.ScrollFrame
        if sf and sf.buttons then
            for _, btn in ipairs(sf.buttons) do
                if btn and btn.title and not btn.__wofnHooked then
                    btn.__wofnHooked = true
                    btn:HookScript("OnEnter", function(b)
                        local idx = b:GetID()
                        local ok, title = pcall(function() return select(1, GetQuestLogTitle(idx)) end)
                        if ok and title then
                            local fa = N.Lookup("quests", title)
                            if fa then N.Tooltip.Add(GameTooltip, fa) end
                        end
                    end)
                end
            end
        end
    end
end
