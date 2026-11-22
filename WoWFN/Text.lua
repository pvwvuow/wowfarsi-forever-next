-- WoWFN — Text engine: Persian shaping, bidi reordering, digits, wrapping.
--
-- The WoW 1.15.x client does not shape Arabic-script text. Depending on the
-- display mode we either reshape only (mode 1 — the client's own bidi pass
-- handles ordering), pass through raw (mode 2), or do everything ourselves
-- (mode 3: shape + reorder + wrap). All functions are pure string -> string.
--
-- Presentation forms are derived from codepoints (Unicode Arabic
-- Presentation Forms-B, U+FE70..U+FEFC), encoded to UTF-8 at load time.

local N = WoWFN
local T = {}
N.T = T

local FA_DIGITS = { "\219\176", "\219\177", "\219\178", "\219\179", "\219\180",
                    "\219\181", "\219\182", "\219\183", "\219\184", "\219\185" }

-- UTF-8 encode a codepoint (Lua 5.1 compatible).
local function utf8char(cp)
    if cp < 0x80 then
        return string.char(cp)
    elseif cp < 0x800 then
        return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + cp % 0x40)
    elseif cp < 0x10000 then
        return string.char(0xE0 + math.floor(cp / 0x1000),
                           0x80 + math.floor(cp / 0x40) % 0x40,
                           0x80 + cp % 0x40)
    end
    return string.char(0xF0 + math.floor(cp / 0x40000),
                       0x80 + math.floor(cp / 0x1000) % 0x40,
                       0x80 + math.floor(cp / 0x40) % 0x40,
                       0x80 + cp % 0x40)
end

-- Split a UTF-8 string into characters.
function T.Chars(s)
    local out, i = {}, 1
    while i <= #s do
        local b = s:byte(i)
        local len = 1
        if b >= 0xF0 then len = 4 elseif b >= 0xE0 then len = 3
        elseif b >= 0xC0 then len = 2 end
        if i + len - 1 > #s then len = 1 end
        out[#out + 1] = s:sub(i, i + len - 1)
        i = i + len
    end
    return out
end

-- base codepoint -> { isolated, final, initial, medial } codepoints
local FORMS_CP = {
    [0x0628] = { 0xFE8D, 0xFE8E, 0xFE8F, 0xFE90 }, -- ب
    [0x067E] = { 0xFB56, 0xFB57, 0xFB58, 0xFB59 }, -- پ
    [0x062A] = { 0xFE95, 0xFE96, 0xFE97, 0xFE98 }, -- ت
    [0x062B] = { 0xFE99, 0xFE9A, 0xFE9B, 0xFE9C }, -- ث
    [0x062C] = { 0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0 }, -- ج
    [0x0686] = { 0xFB7A, 0xFB7B, 0xFB7C, 0xFB7D }, -- چ
    [0x062D] = { 0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4 }, -- ح
    [0x062E] = { 0xFEA5, 0xFEA6, 0xFEA7, 0xFEA8 }, -- خ
    [0x062F] = { 0xFEA9, 0xFEAA },                 -- د
    [0x0630] = { 0xFEAB, 0xFEAC },                 -- ذ
    [0x0631] = { 0xFEAD, 0xFEAE },                 -- ر
    [0x0632] = { 0xFEAF, 0xFEB0 },                 -- ز
    [0x0698] = { 0xFB8A, 0xFB8B },                 -- ژ
    [0x0633] = { 0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4 }, -- س
    [0x0634] = { 0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8 }, -- ش
    [0x0635] = { 0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC }, -- ص
    [0x0636] = { 0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0 }, -- ض
    [0x0637] = { 0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4 }, -- ط
    [0x0638] = { 0xFEC5, 0xFEC6, 0xFEC7, 0xFEC8 }, -- ظ
    [0x0639] = { 0xFEC9, 0xFECA, 0xFECB, 0xFECC }, -- ع
    [0x063A] = { 0xFECD, 0xFECE, 0xFECF, 0xFED0 }, -- غ
    [0x0641] = { 0xFED1, 0xFED2, 0xFED3, 0xFED4 }, -- ف
    [0x0642] = { 0xFED5, 0xFED6, 0xFED7, 0xFED8 }, -- ق
    [0x06A9] = { 0xFB8E, 0xFB8F, 0xFB90, 0xFB91 }, -- ک
    [0x06AF] = { 0xFB92, 0xFB93, 0xFB94, 0xFB95 }, -- گ
    [0x0644] = { 0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0 }, -- ل
    [0x0645] = { 0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4 }, -- م
    [0x0646] = { 0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8 }, -- ن
    [0x0648] = { 0xFEED, 0xFEEE },                 -- و
    [0x0647] = { 0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC }, -- ه
    [0x064A] = { 0xFEF1, 0xFEF2, 0xFEF3, 0xFEF4 }, -- ی
    [0x06CC] = { 0xFBFC, 0xFBFD, 0xFBFE, 0xFBFF }, -- ی (farsi yeh)
    [0x0626] = { 0xFE8B, 0xFE8C, 0xFE89, 0xFE8A }, -- ئ
    [0x0621] = { 0xFE80 },                         -- ء
    [0x0622] = { 0xFE81, 0xFE82 },                 -- آ
    [0x0623] = { 0xFE83, 0xFE84 },                 -- أ
    [0x0625] = { 0xFE87, 0xFE88 },                 -- إ
    [0x0629] = { 0xFE93, 0xFE94 },                 -- ة
}

-- decode first UTF-8 char of a string to a codepoint
local function utf8code(ch)
    local b = ch:byte(1)
    if not b then return nil end
    if b < 0x80 then return b end
    if b >= 0xF0 then
        return (b - 0xF0) * 0x40000 + (ch:byte(2) - 0x80) * 0x1000
             + (ch:byte(3) - 0x80) * 0x40 + (ch:byte(4) - 0x80)
    elseif b >= 0xE0 then
        return (b - 0xE0) * 0x1000 + (ch:byte(2) - 0x80) * 0x40
             + (ch:byte(3) - 0x80)
    elseif b >= 0xC0 then
        return (b - 0xC0) * 0x40 + (ch:byte(2) - 0x80)
    end
    return b
end

local FORMS = {}       -- char -> { iso, fin, ini, med } (strings)
local JOINS_NEXT = {}  -- char -> true if it connects to the next letter
for cp, forms in pairs(FORMS_CP) do
    local ch = utf8char(cp)
    FORMS[ch] = {
        utf8char(forms[1]),
        utf8char(forms[2] or forms[1]),
        utf8char(forms[3] or forms[1]),
        utf8char(forms[4] or forms[2] or forms[1]),
    }
    -- letters that have an initial form connect to the following letter
    JOINS_NEXT[ch] = forms[3] ~= nil
end

function T.HasPersian(s)
    if type(s) ~= "string" then return false end
    for _, ch in ipairs(T.Chars(s)) do
        local cp = utf8code(ch)
        if cp and ((cp >= 0x0600 and cp <= 0x06FF) or (cp >= 0xFB50 and cp <= 0xFEFF)) then
            return true
        end
    end
    return false
end

-- ASCII digits -> Persian digits.
function T.Digits(s)
    if type(s) ~= "string" then return s end
    return (s:gsub("%d", function(d) return FA_DIGITS[tonumber(d) + 1] end))
end

-- Normalize Arabic ye/kaf to Persian forms.
function T.Normalize(s)
    if type(s) ~= "string" then return s end
    s = s:gsub(utf8char(0x0643), utf8char(0x06A9)) -- arabic kaf -> ک
    s = s:gsub(utf8char(0x064A), utf8char(0x06CC)) -- arabic yeh -> ی
    return s
end

-- Pick contextual presentation forms for every Arabic letter.
function T.Shape(s)
    if type(s) ~= "string" then return s end
    local chars = T.Chars(s)
    local out = {}
    local n = #chars
    for i = 1, n do
        local ch = chars[i]
        local f = FORMS[ch]
        if not f then
            out[i] = ch
        else
            local prevJoin = i > 1 and JOINS_NEXT[chars[i - 1]] == true
            local nextIsLetter = i < n and FORMS[chars[i + 1]] ~= nil
            if prevJoin and nextIsLetter and f[4] then
                out[i] = f[4]
            elseif prevJoin and f[2] then
                out[i] = f[2]
            elseif nextIsLetter and f[3] then
                out[i] = f[3]
            else
                out[i] = f[1]
            end
        end
    end
    return table.concat(out)
end

-- Reverse the character order of a run (manual bidi, mode 3).
function T.ReverseRun(s)
    local chars = T.Chars(s)
    local out = {}
    for i = #chars, 1, -1 do out[#out + 1] = chars[i] end
    return table.concat(out)
end

-- Manual bidi: split into LTR runs (latin words/numbers) and RTL runs,
-- then lay runs out right-to-left; LTR runs keep their internal order.
function T.Bidi(s)
    if type(s) ~= "string" or s == "" then return s end
    local runs, isLtr = {}, {}
    local i, n = 1, #s
    while i <= n do
        local ltr = s:match("^[%w]+", i) or s:match("^[][!\"%%&'()*+,./:;<=>?@\\^_`{|}~-]+", i)
        if ltr then
            runs[#runs + 1], isLtr[#runs + 1] = ltr, true
            i = i + #ltr
        else
            -- one RTL token = a single character that is not the start of
            -- an LTR run; joining consecutive RTL chars happens implicitly
            -- because runs are laid out in reverse anyway
            local ch = T.Chars(s:sub(i, i))[1] or s:sub(i, i)
            runs[#runs + 1], isLtr[#runs + 1] = ch, false
            i = i + #ch
        end
    end
    local out = {}
    for idx = #runs, 1, -1 do
        if isLtr[idx] then
            out[#out + 1] = runs[idx]
        else
            out[#out + 1] = T.ReverseRun(runs[idx])
        end
    end
    return table.concat(out)
end

-- Entry point: process one line according to the saved display mode.
function T.Process(s)
    if type(s) ~= "string" or s == "" then return s end
    local mode = (N.db and N.db.mode) or 1
    if mode == 2 then
        return s
    elseif mode == 3 then
        return T.Bidi(T.Shape(T.Digits(T.Normalize(s))))
    else
        return T.Shape(T.Digits(T.Normalize(s)))
    end
end

-- Word-wrap Persian text to roughly `width` characters per line.
function T.Wrap(s, width)
    width = width or 40
    local lines, cur = {}, ""
    for w in s:gmatch("%S+") do
        if cur ~= "" and #cur + #w + 1 > width then
            lines[#lines + 1] = cur
            cur = w
        else
            cur = (cur == "") and w or (cur .. " " .. w)
        end
    end
    if cur ~= "" then lines[#lines + 1] = cur end
    return lines
end
