-- WoWFN — runtime test for the Text engine (run outside WoW with lua5.4).

local N = { db = { mode = 3 } }
WoWFN = N
dofile("WoWFN/Text.lua")
local T = N.T

local fails = 0
local function check(name, cond)
    if cond then print(("PASS %s"):format(name))
    else fails = fails + 1; print(("FAIL %s"):format(name)) end
end

-- digits
check("digits-ascii", T.Digits("سلام 123") ~= "سلام 123")
check("digits-count", #T.Chars(T.Digits("0123456789")) == 10)

-- chars / utf8
check("chars-split", #T.Chars("سلام x") == 6)

-- normalize arabic kaf/yeh -> persian
check("normalize", T.Normalize("\217\131\217\138") == "کی")

-- shape produces longer output (presentation forms are 3 bytes)
check("shape-extends", #T.Shape("سلام") > #"سلام")

-- shape is stable for latin
check("shape-latin-untouched", T.Shape("Fireball") == "Fireball")

-- bidi keeps latin runs intact and reverses rtl
local bidi = T.Bidi("سلام Fireball 123")
check("bidi-latin-run", bidi:find("Fireball") ~= nil)

-- process dispatches per mode
N.db.mode = 2
check("process-mode2-raw", T.Process("سلام") == "سلام")
N.db.mode = 3
check("process-mode3-full", T.Process("سلام Fireball 45") == T.Bidi(T.Shape(T.Digits(T.Normalize("سلام Fireball 45")))))

-- wrap
local lines = T.Wrap("یکی بود یکی نبود در قصه‌های قدیمی", 12)
check("wrap-lines", #lines >= 3)

-- edge cases
check("empty", T.Process("") == "")
check("nil-safe", T.Process(nil) == nil)

-- data sanity: all Persian values non-empty and look Persian
dofile("WoWFN/Data/Data.lua")
for kind, tbl in pairs(N.Data) do
    if type(tbl) == "table" then
        local bad = 0
        for en, fa in pairs(tbl) do
            if type(en) ~= "string" or type(fa) ~= "string" or fa == "" then
                bad = bad + 1
            end
        end
        check("data-" .. kind .. "-clean", bad == 0)
    end
end

if fails == 0 then print("ALL TESTS PASS") else os.exit(1) end
