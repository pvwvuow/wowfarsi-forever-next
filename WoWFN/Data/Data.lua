-- WoWFN — Translation data registry.
--
-- Lookup tables keyed by the exact English string the client shows.
-- Schema: WoWFN_Data = { spells, items, npcs, quests, ui, classes }
-- Values are Persian strings. Data packs from wowfarsi.ir merge into these
-- tables at load time (WoWFN_ExtraData, if present, is merged the same way).

local N = WoWFN
local D = {
    classes = {
        ["Warrior"] = "جنگاور", ["Paladin"] = "دلاور", ["Hunter"] = "شکارچی",
        ["Rogue"] = "سارق", ["Priest"] = "کاهن", ["Shaman"] = "جادوانگار",
        ["Mage"] = "جادومغ", ["Warlock"] = "احضارگر", ["Monk"] = "راهب",
        ["Druid"] = "درودی", ["Death Knight"] = "شوالیهٔ مرگ",
        ["Demon Hunter"] = "شکارچی شیطان", ["Evoker"] = "احضارگر اژدها",
        ["Warrior (Arms)"] = "جنگاور (سلاح)", ["Warrior (Fury)"] = "جنگاور (خشم)",
        ["Warrior (Protection)"] = "جنگاور (سنگربانی)",
        ["Paladin (Holy)"] = "دلاور (مقدس)", ["Paladin (Protection)"] = "دلاور (سنگربانی)",
        ["Paladin (Retribution)"] = "دلاور (کیفر)",
        ["Hunter (Beast Mastery)"] = "شکارچی (تسلط بر وحوش)",
        ["Hunter (Marksmanship)"] = "شکارچی (تیراندازی)",
        ["Hunter (Survival)"] = "شکارچی (بقا)",
        ["Rogue (Assassination)"] = "سارق (ترور)", ["Rogue (Outlaw)"] = "سارق (یاغی)",
        ["Rogue (Subtlety)"] = "سارق (زیاده‌گویی)",
        ["Priest (Discipline)"] = "کاهن (طریقت)", ["Priest (Holy)"] = "کاهن (مقدس)",
        ["Priest (Shadow)"] = "کاهن (سایه)",
        ["Shaman (Elemental)"] = "جادوانگار (بنیادی)", ["Shaman (Enhancement)"] = "جادوانگار (تقویت)",
        ["Shaman (Restoration)"] = "جادوانگار (بازسازی)",
        ["Mage (Arcane)"] = "جادومغ (شعبده)", ["Mage (Fire)"] = "جادومغ (آتش)",
        ["Mage (Frost)"] = "جادومغ (یخ)",
        ["Warlock (Affliction)"] = "احضارگر (رنج)", ["Warlock (Demonology)"] = "احضارگر (شیطان‌شناسی)",
        ["Warlock (Destruction)"] = "احضارگر (نابودی)",
        ["Druid (Balance)"] = "درودی (تعادل)", ["Druid (Feral)"] = "درودی (وحشی)",
        ["Druid (Guardian)"] = "درودی (نگهبان)", ["Druid (Restoration)"] = "درودی (بازسازی)",
        ["Death Knight (Blood)"] = "شوالیهٔ مرگ (خون)",
        ["Death Knight (Frost)"] = "شوالیهٔ مرگ (یخ)",
        ["Death Knight (Unholy)"] = "شوالیهٔ مرگ (نامقدس)",
        ["Monk (Brewmaster)"] = "راهب (شراب‌ساز)", ["Monk (Mistweaver)"] = "راهب (بافندهٔ مه)",
        ["Monk (Windwalker)"] = "راهب (بادپیما)",
        ["Demon Hunter (Havoc)"] = "شکارچی شیطان (هلاکت)",
        ["Demon Hunter (Vengeance)"] = "شکارچی شیطان (انتقام)",
    },
    stats = {
        ["Strength"] = "قدرت", ["Agility"] = "چابکی", ["Intellect"] = "هوش",
        ["Stamina"] = "بنیه", ["Spirit"] = "روح", ["Crit Chance"] = "شانس ضربهٔ بحرانی",
        ["Haste"] = "شتاب", ["Mastery"] = "تسلط", ["Versatility"] = "انعطاف‌پذیری",
        ["Attack Power"] = "قدرت حمله", ["Spell Power"] = "قدرت جادو",
        ["Armor"] = "زره", ["Health"] = "جان", ["Mana"] = "مانا",
        ["Energy"] = "انرژی", ["Rage"] = "خشم", ["Focus"] = "تمرکز",
        ["Runic Power"] = "قدرت رونی",
    },
    ui = {
        ["Quest Log"] = "دفتر مأموریت", ["Character"] = "شخصیت", ["Talents"] = "استعدادها",
        ["Spellbook"] = "کتاب جادو", ["Bags"] = "کیف‌ها", ["Map"] = "نقشه",
        ["Dungeon"] = "سیاهچال", ["Raid"] = "حملهٔ دسته‌جمعی", ["Group"] = "گروه",
        ["Guild"] = "انجمن", ["Trade"] = "دادوستد", ["Mail"] = "نامه",
        ["Accept"] = "پذیرفتن", ["Decline"] = "رد کردن", ["Cancel"] = "لغو",
        ["Complete"] = "تکمیل", ["Continue"] = "ادامه", ["Close"] = "بستن",
        ["Level"] = "سطح", ["Requires Level"] = "سطح لازم", ["Item Level"] = "سطح آیتم",
        ["Bind on Equip"] = "پس از پوشیدن مألف می‌شود", ["Bind on Pick-up"] = "با برداشتن مألف می‌شود",
        ["Unique"] = "یگانه", ["Durability"] = "پایداری", ["Sell Price"] = "قیمت فروش",
    },
    spells = {
        ["Fireball"] = "گوی آتش", ["Frostbolt"] = "تیر یخ", ["Arcane Missiles"] = "موادّ شعبده",
        ["Polymorph"] = "دگردیسی", ["Counterspell"] = "شکنندهٔ جادو", ["Blink"] = "پلک",
        ["Ice Block"] = "تختهٔ یخ", ["Evocation"] = "احضار حافظه",
        ["Flash Heal"] = "شفادهی برق‌آسا", ["Greater Heal"] = "شفادهی بزرگ",
        ["Renew"] = "نوزایی", ["Power Word: Shield"] = "کلام قدرت: سپر",
        ["Power Word: Fortitude"] = "کلام قدرت: استواری", ["Shadow Word: Pain"] = "کلام سایه: درد",
        ["Mind Blast"] = "انفجار ذهن", ["Holy Smite"] = "کولهٔ مقدس",
        ["Resurrection"] = "رستاخیز", ["Levitate"] = "شناوری",
        ["Charge"] = "حملهٔ برق‌آسا", ["Heroic Strike"] = "ضربهٔ قهرمانانه",
        ["Whirlwind"] = "گردباد", ["Execute"] = "اعدام", ["Victory Rush"] = "هجوم پیروزی",
        ["Mortal Strike"] = "ضربهٔ مرگبار", ["Slam"] = "کوبش", ["Shield Slam"] = "کوبش سپر",
        ["Thunder Clap"] = "غریو رعد", ["Battle Shout"] = "فریاد نبرد", ["Taunt"] = "تحریک",
        ["Sinister Strike"] = "ضربهٔ شوم", ["Eviscerate"] = "درآوردن روده",
        ["Sap"] = "خواب مصنوعی", ["Stealth"] = "نهفتگی", ["Vanish"] = "محو شدن",
        ["Slice and Dice"] = "پاره‌پاره کردن", ["Backstab"] = "خنجر از پشت",
        ["Sprint"] = "یورش", ["Cheap Shot"] = "ضربهٔ ناجوانمردانه", ["Kidney Shot"] = "ضربهٔ کلیوی",
        ["Aimed Shot"] = "شلیک هدفمند", ["Steady Shot"] = "شلیک پیوسته",
        ["Multi-Shot"] = "شلیک چندگانه", ["Hunter's Mark"] = "نشان شکارچی",
        ["Aspect of the Hawk"] = "هیئت شاهین", ["Feign Death"] = "نمایش مرگ",
        ["Concussive Shot"] = "شلیک مغشوش‌کننده", ["Disengage"] = "عقب‌نشینی",
        ["Serpent Sting"] = "گزش مار", ["Kill Command"] = "فرمان کشتار",
        ["Holy Light"] = "نور مقدس", ["Flash of Light"] = "برق نور",
        ["Divine Shield"] = "سپر الهی", ["Divine Protection"] = "حمایت الهی",
        ["Blessing of Might"] = "برکت توان", ["Blessing of Wisdom"] = "برکت خرد",
        ["Judgement"] = "داوری", ["Consecration"] = "تقدیس", ["Hammer of Justice"] = "پتک عدالت",
        ["Lay on Hands"] = "دست گذاشتن", ["Retribution Aura"] = "هالهٔ کیفر",
        ["Devotion Aura"] = "هالهٔ اخلاص",
        ["Lightning Bolt"] = "آذرخش", ["Chain Lightning"] = "آذرخش زنجیره‌ای",
        ["Earth Shock"] = "لرزش زمین", ["Flame Shock"] = "لرزش شعله",
        ["Healing Wave"] = "موج شفا", ["Lesser Healing Wave"] = "موج شفای کوچک",
        ["Healing Stream Totem"] = "توتِم جوی شفا", ["Grounding Totem"] = "توتِم زمین‌گیر",
        ["Spirit Wolf"] = "گرگ روح", ["Windfury Weapon"] = "سلاح خشم باد",
        ["Rockbiter Weapon"] = "سلاح سنگ‌گاز",
        ["Immolate"] = "سوزاندن", ["Corruption"] = "تباهی", ["Curse of Weakness"] = "نفرین ناتوانی",
        ["Drain Life"] = "مکیدن جان", ["Shadow Bolt"] = "تیر سایه", ["Fear"] = "هراس",
        ["Summon Imp"] = "احضار دیوچه", ["Summon Voidwalker"] = "احضار پویه‌گر خلأ",
        ["Soul Fire"] = "آتش جان", ["Health Funnel"] = "قیف جان", ["Life Tap"] = "ضربهٔ حیات",
        ["Demon Skin"] = "پوست دیو", ["Curse of the Elements"] = "نفرین عناصر",
        ["Moonfire"] = "آتش ماه", ["Starfire"] = "آتش ستاره", ["Wrath"] = "خشم",
        ["Entangling Roots"] = "ریشه‌های درگیر", ["Rejuvenation"] = "جوان‌سازی",
        ["Healing Touch"] = "لمس شفا", ["Regrowth"] = "بازرویی", ["Mark of the Wild"] = "نشان وحش",
        ["Thorns"] = "خارها", ["Bear Form"] = "شکل خرس", ["Cat Form"] = "شکل گربه",
        ["Travel Form"] = "شکل سفر", ["Aquatic Form"] = "شکل آبی",
        ["Death Grip"] = "چنگال مرگ", ["Icy Touch"] = "لمس یخی", ["Plague Strike"] = "ضربهٔ طاعون",
        ["Obliterate"] = "نابودسازی", ["Frost Strike"] = "ضربهٔ یخی", ["Death Coil"] = "مارپیچ مرگ",
    },
    items = {},
    npcs = {},
    quests = {},
}

N.Data = D
N.DATA_SCHEMA = 1

-- Merge a data pack (from a /shared file or release bundle) into D.
function N.MergeData(pack)
    if type(pack) ~= "table" then return 0 end
    local added = 0
    for kind, entries in pairs(pack) do
        if type(D[kind]) == "table" and type(entries) == "table" then
            for en, fa in pairs(entries) do
                if type(fa) == "string" and fa ~= "" and D[kind][en] == nil then
                    D[kind][en] = fa
                    added = added + 1
                end
            end
        end
    end
    return added
end

-- Global lookup helper used by all modules: kind + english string -> fa.
function N.Lookup(kind, en)
    if type(en) ~= "string" or en == "" then return nil end
    local fa = D[kind] and D[kind][en]
    return fa
end

-- Count of loaded translations, for the panel and the greeting.
function N.Counts()
    local c = {}
    for kind, tbl in pairs(D) do
        local n = 0
        for _ in pairs(tbl) do n = n + 1 end
        c[kind] = n
    end
    return c
end
