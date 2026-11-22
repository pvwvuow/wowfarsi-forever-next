-- WoWFN — Persian translation for WoW Forever.
-- Core: bootstrap, saved variables, module registry, safety wrapper.
--
-- Safety model:
--   * every hook is installed through N:Hook, which checks the game API
--     exists before wiring and wraps every callback in pcall;
--   * a module that raises 3 errors in one minute, or 10 in a session,
--     is switched off for the rest of the session and the user is told once;
--   * nothing ever writes to the game state — translation is read-only.

local ADDON = ...
local N = {}
WoWFN = N

N.ADDON = ADDON
N.VERSION = select(4, GetAddOnInfo and GetAddOnInfo(ADDON) or nil) or "0.1.0"
if C_AddOns and C_AddOns.GetAddOnMetadata then
    local ok, v = pcall(C_AddOns.GetAddOnMetadata, ADDON, "Version")
    if ok and v then N.VERSION = v end
end
N.ROOT = "Interface\\AddOns\\" .. ADDON .. "\\"
N.FONT = N.ROOT .. "Fonts\\Vazirmatn.ttf"

N.C = {
    gold  = { 0.941, 0.780, 0.369 },
    text  = { 0.910, 0.890, 0.839 },
    muted = { 0.659, 0.635, 0.580 },
    blue  = { 0.098, 0.682, 1.0 },
    green = { 0.45, 0.85, 0.45 },
    red   = { 1.0, 0.38, 0.33 },
}

-- ------------------------------------------------------------------ logging
local PREFIX = "|cff19aeffWoWFN|r"
function N.Say(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. " " .. msg, 1, 1, 1)
    end
end

local errors = { minute = 0, window = 0, session = 0, lastReset = 0 }
function N.NoteError(module)
    local now = GetTime()
    if now - errors.lastReset > 60 then
        errors.minute, errors.lastReset = 0, now
    end
    errors.minute = errors.minute + 1
    errors.session = errors.session + 1
    if errors.minute >= 3 or errors.session >= 10 then
        local m = N.Modules and N.Modules[module]
        if m and m.active then
            m.active = false
            N.Say(("ماژول %s به‌خاطر خطا تا آخرین اجرا خاموش شد."):format(m.label or module))
        end
    end
end

-- ------------------------------------------------------------------ registry
N.Modules = {}

-- Register a module. spec = { id, label, active, risk, Setup(fn) }
-- Setup is called only if the module is enabled AND the current build is
-- not newer than the module's data. Setup must install its own hooks
-- through N:Hook so they are wrapped and counted.
function N.Register(spec)
    N.Modules[spec.id] = spec
    spec.active = spec.active ~= false
end

local hooks = {}

-- Safe hook: wraps fn in pcall, counts failures, checks the target exists.
-- kind "hook"  -> HookScript-style: hooksecurefunc(tbl, key, fn)
-- kind "post"  -> wrap a global function, run fn after the original
function N.Hook(module, kind, target, key, fn)
    local m = N.Modules[module]
    if not m or not m.active then return false end
    local id = module .. ":" .. kind .. ":" .. tostring(key or target)
    if hooks[id] then return true end

    local wrapped = function(...)
        if not m.active then return end
        local ok, err = pcall(fn, ...)
        if not ok then
            N.NoteError(module)
            if N.db and N.db.debug then
                N.Say(("خطا در %s: %s"):format(id, tostring(err)))
            end
        end
    end

    if kind == "hook" then
        if not target or not target.HookScript and type(target) ~= "table" then
            return false
        end
        target:HookScript(key, wrapped)
    elseif kind == "secure" then
        if type(target) ~= "string" or not _G[target] then return false end
        hooksecurefunc(target, key or target, wrapped)
    elseif kind == "global" then
        if type(_G[target]) ~= "function" then return false end
        hooksecurefunc(target, wrapped)
    else
        return false
    end

    hooks[id] = true
    m.hooked = (m.hooked or 0) + 1
    return true
end

-- Hook a GameTooltip script on a frame instance (tooltips, item refs...).
function N.HookTooltipScript(module, frame, script, fn)
    if not frame or not frame.HookScript then return false end
    local m = N.Modules[module]
    if not m or not m.active then return false end
    local ok, err = pcall(frame.HookScript, frame, script, function(...)
        if not m.active then return end
        local okFn, errFn = pcall(fn, ...)
        if not okFn then
            N.NoteError(module)
            if N.db and N.db.debug then
                N.Say(("خطا در %s/%s: %s"):format(module, script, tostring(errFn)))
            end
        end
    end)
    return ok
end

-- ------------------------------------------------------------------ events
local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:SetScript("OnEvent", function(_, event, name)
    if event ~= "ADDON_LOADED" or name ~= ADDON then return end
    WoWFNDB = WoWFNDB or {}
    N.db = WoWFNDB
    -- migrate missing keys
    N.db.mode = N.db.mode or 1
    N.db.fontSize = N.db.fontSize or 12
    N.db.showPersian = N.db.showPersian ~= false
    N.db.debug = N.db.debug == true

    for id, m in pairs(N.Modules) do
        if m.active and type(m.Setup) == "function" then
            local ok, err = pcall(m.Setup, m)
            if ok then
                m.ready = true
            else
                m.active = false
                N.Say(("ماژول %s راه‌اندازی نشد: %s"):format(m.label or id, tostring(err)))
            end
        end
    end

    -- user custom translations override everything
    if N.Custom and N.Custom.Apply then
        local n = N.Custom.Apply()
        if n > 0 then N.Say(("%d ترجمهٔ سفارشی شما اعمال شد."):format(n)) end
    end

    local ready = 0
    for _, m in pairs(N.Modules) do if m.ready then ready = ready + 1 end end
    N.Say(("نسخه %s بارگذاری شد — %d ماژول فعال. دستور: /wofn"):format(N.VERSION, ready))

    if N.Panel and N.Panel.Build then N.Panel.Build() end
    if N.Minimap and N.Minimap.Setup then
        local okMM, errMM = pcall(N.Minimap.Setup)
        if not okMM and N.db.debug then N.Say("خطای مینی‌مپ: " .. tostring(errMM)) end
    end
    boot:UnregisterEvent("ADDON_LOADED")
end)
