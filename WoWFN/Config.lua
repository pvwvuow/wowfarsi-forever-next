-- WoWFN — Config: slash commands (/wofn).

local N = WoWFN

SLASH_WOFN1 = "/wofn"
SLASH_WOFN2 = "/wowfn"

local function toggleModule(name)
    local m = N.Modules[name]
    if not m then
        N.Say(("ماژولی به نام %s نیست."):format(name))
        return
    end
    m.active = not m.active
    if m.active then
        if not m.ready and type(m.Setup) == "function" then
            local ok, err = pcall(m.Setup, m)
            m.ready = ok and true or m.ready
            if not ok then m.active = false end
        end
        N.Say(("ماژول %s روشن شد."):format(m.label or name))
    else
        N.Say(("ماژول %s خاموش شد."):format(m.label or name))
    end
end

local function countsLine()
    local c = N.Counts()
    local parts = {}
    local order = { "spells", "items", "npcs", "quests", "classes", "stats", "ui" }
    for _, k in ipairs(order) do
        if c[k] then parts[#parts + 1] = ("%s: %d"):format(k, c[k]) end
    end
    return table.concat(parts, " | ")
end

SlashCmdList["WOFN"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")

    if cmd == "panel" or cmd == "settings" then
        if N.Panel and N.Panel.Toggle then N.Panel.Toggle() end
    elseif cmd == "mode" then
        local m = tonumber(arg)
        if m == 1 or m == 2 or m == 3 then
            N.db.mode = m
            N.Say(("حالت نمایش: %d"):format(m))
        else
            N.Say("استفاده: /wofn mode 1|2|3")
        end
    elseif cmd == "size" then
        local s = tonumber(arg)
        if s and s >= 8 and s <= 22 then
            N.db.fontSize = s
            N.Say(("اندازهٔ فونت: %d"):format(s))
        else
            N.Say("استفاده: /wofn size 8..22")
        end
    elseif cmd == "debug" then
        N.db.debug = not N.db.debug
        N.Say(("حالت خطایابی: %s"):format(N.db.debug and "روشن" or "خاموش"))
    elseif cmd == "modules" then
        for id, m in pairs(N.Modules) do
            N.Say(("%s — %s (%s)"):format(id, m.label or id, m.active and "فعال" or "خاموش"))
        end
        N.Say(countsLine())
    elseif cmd == "toggle" then
        if arg ~= "" then toggleModule(arg) else N.Say("استفاده: /wofn toggle spells|items|npcs|quests") end
    elseif cmd == "help" or cmd == "" then
        N.Say("/wofn panel — پنل تنظیمات")
        N.Say("/wofn mode 1|2|3 — حالت نمایش متن فارسی")
        N.Say("/wofn size <8..22> — اندازهٔ فونت")
        N.Say("/wofn modules — وضعیت ماژول‌ها و تعداد ترجمه‌ها")
        N.Say("/wofn toggle <ماژول> — روشن/خاموش کردن یک ماژول")
        N.Say("/wofn debug — نمایش خطاها")
    else
        N.Say("دستور ناشناخته. برای راهنما: /wofn help")
    end
end
