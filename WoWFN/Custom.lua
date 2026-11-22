-- WoWFN — Custom translations: user-added entries stored in SavedVariables
-- and merged over the built-in tables. Managed with /wofn add / list /
-- remove, or the "Custom" section of the panel.
--
-- Schema: N.db.custom = { [kind] = { ["English"] = "فارسی", ... }, ... }
-- Custom entries always win over built-ins (applied after Data + packs).

local N = WoWFN
local C = {}
N.Custom = C

local KINDS = { "spells", "items", "npcs", "quests", "ui", "stats", "classes" }

function C.Table(kind)
    if not N.db then N.db = {} end
    N.db.custom = N.db.custom or {}
    N.db.custom[kind] = N.db.custom[kind] or {}
    return N.db.custom[kind]
end

-- Add or update a custom translation. Returns "added" / "updated".
function C.Add(kind, en, fa)
    if not KINDS[ kind ] and not (kind == "factions" or kind == "professions") then
        return nil, "نوع ناشناخته"
    end
    if type(en) ~= "string" or en == "" or type(fa) ~= "string" or fa == "" then
        return nil, "مقدار خالی"
    end
    local tbl = C.Table(kind)
    local status = tbl[en] and "updated" or "added"
    tbl[en] = fa
    -- apply immediately to the live tables
    if N.Data and N.Data[kind] then N.Data[kind][en] = fa end
    return status
end

-- Remove a custom translation (restores the built-in if one exists).
function C.Remove(kind, en)
    local tbl = C.Table(kind)
    if tbl[en] then
        tbl[en] = nil
        -- re-apply built-in by rebuilding the table from Data packs
        if N.Data and N.Data[kind] and N.Data.RestoreBuiltins then
            N.Data.RestoreBuiltins(kind, en)
        end
        return true
    end
    return false
end

-- Merge all custom entries over built-in data. Called from Core after
-- data packs load.
function C.Apply()
    if not N.db or not N.db.custom then return 0 end
    local n = 0
    for kind, entries in pairs(N.db.custom) do
        if N.Data and N.Data[kind] then
            for en, fa in pairs(entries) do
                N.Data[kind][en] = fa
                n = n + 1
            end
        end
    end
    return n
end

-- Count per kind.
function C.Counts()
    local out = {}
    if not N.db or not N.db.custom then return out end
    for kind, entries in pairs(N.db.custom) do
        local n = 0
        for _ in pairs(entries) do n = n + 1 end
        out[kind] = n
    end
    return out
end

-- List entries of a kind as "en -> fa" strings.
function C.List(kind)
    local tbl = C.Table(kind)
    local out = {}
    for en, fa in pairs(tbl) do
        out[#out + 1] = ("%s -> %s"):format(en, fa)
    end
    table.sort(out)
    return out
end

-- Export all custom entries as a Lua table source (for sharing/backup).
function C.Export()
    if not N.db or not N.db.custom then return "{}" end
    local parts = {}
    for kind, entries in pairs(N.db.custom) do
        local lines = {}
        for en, fa in pairs(entries) do
            lines[#lines + 1] = ('    [%q] = %q,'):format(en, fa)
        end
        parts[#parts + 1] = ("  %s = {\n%s\n  },"):format(kind, table.concat(lines, "\n"))
    end
    return ("{\n%s\n}"):format(table.concat(parts, "\n"))
end
