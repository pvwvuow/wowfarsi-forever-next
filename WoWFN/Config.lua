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
    local reps = N.Modules.reputations and N.Modules.reputations.FACTIONS
    local profs = N.Modules.professions and N.Modules.professions.PROFESSIONS
    if reps then parts[#parts + 1] = ("factions: %d"):format((function() local n=0 for _ in pairs(reps) do n=n+1 end return n end)()) end
    if profs then parts[#parts + 1] = ("professions: %d"):format((function() local n=0 for _ in pairs(profs) do n=n+1 end return n end)()) end
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
        if arg ~= "" then toggleModule(arg) else N.Say("استفاده: /wofn toggle spells|items|npcs|quests|reputations|professions") end
    elseif cmd == "add" then
        -- /wofn add spells "Fireball" "گوی آتش"
        local kind, rest = arg:match("^(%S+)%s+(.+)$")
        if not kind then
            N.Say('استفاده: /wofn add <نوع> "انگلیسی" "فارسی"')
            N.Say("نوع‌ها: spells items npcs quests ui stats classes")
        else
            local en, fa = rest:match('^%s*"([^"]+)"%s+"([^"]+)"%s*$')
            if not en then
                en, fa = rest:match("^%s*(%S+)%s+(.+)%s*$")
            end
            if not en or not fa then
                N.Say("قالب درست: /wofn add spells \"Fireball\" \"گوی آتش\"")
            else
                local ok, err = N.Custom.Add(kind, en, fa)
                if ok then
                    N.Say(("%s: %s = %s"):format(ok == "added" and "اضافه شد" or "به‌روزرسانی شد", en, fa))
                else
                    N.Say("خطا: " .. tostring(err))
                end
            end
        end
    elseif cmd == "remove" then
        local kind, en = arg:match("^(%S+)%s+(.+)$")
        if kind and N.Custom.Remove(kind, en) then
            N.Say(("حذف شد: %s / %s"):format(kind, en))
        else
            N.Say("چنین ترجمهٔ سفارشی‌ای نبود. فهرست: /wofn custom <نوع>")
        end
    elseif cmd == "custom" then
        local kind = arg ~= "" and arg or "quests"
        local list = N.Custom.List(kind)
        local counts = N.Custom.Counts()
        if not next(counts) then
            N.Say("هیچ ترجمهٔ سفارشی نداری. با /wofn add اضافه کن.")
        elseif #list == 0 then
            N.Say(("ترجمهٔ سفارشی نوع %s نداری (%d سفارشی در کل)."):format(kind, (function() local n=0 for _,c in pairs(counts) do n=n+c end return n end)()))
        else
            for _, line in ipairs(list) do N.Say(line) end
        end
    elseif cmd == "export" then
        N.Say("ترجمه‌های سفارشی (کپی کن جایی نگه دار):")
        N.Say(N.Custom.Export())
    elseif cmd == "help" or cmd == "" then
        N.Say("/wofn panel — پنل تنظیمات")
        N.Say("/wofn mode 1|2|3 — حالت نمایش متن فارسی")
        N.Say("/wofn size <8..22> — اندازهٔ فونت")
        N.Say("/wofn modules — وضعیت ماژول‌ها و تعداد ترجمه‌ها")
        N.Say("/wofn toggle <ماژول> — روشن/خاموش کردن یک ماژول")
        N.Say('/wofn add <نوع> "انگلیسی" "فارسی" — ترجمهٔ سفارشی')
        N.Say("/wofn custom <نوع> — فهرست ترجمه‌های سفارشی")
        N.Say("/wofn remove <نوع> <انگلیسی> — حذف ترجمهٔ سفارشی")
        N.Say("/wofn export — خروجی ترجمه‌های سفارشی")
        N.Say("/wofn debug — نمایش خطاها")
    else
        N.Say("دستور ناشناخته. برای راهنما: /wofn help")
    end
end
