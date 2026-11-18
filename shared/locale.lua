-- ============================================
-- Languages — same scheme as whip_clothingwheel
-- ============================================
-- Config.Locale selects the block in Config.Locales. If a key is missing, en is
-- tried first, then it, and finally the key itself is returned (never an empty
-- string). Placeholders are string.format's (%s, %d, ...).

InventorySkin = InventorySkin or {}

local function localeTable(lang)
    if type(Config.Locales) ~= 'table' then return nil end
    return Config.Locales[lang or Config.Locale]
end

local function localePath(tbl, key)
    if type(tbl) ~= 'table' then return nil end
    for part in tostring(key):gmatch('[^%.]+') do
        tbl = tbl[part]
        if type(tbl) ~= 'table' and type(tbl) ~= 'string' then return nil end
    end
    return tbl
end

--- Localized text. `key` uses dot notation, for example 'accessory.phone'.
function InventorySkin.locale(key, ...)
    local current = localeTable(Config.Locale)
    local value = localePath(current, key)
    if value == nil then
        local fallback = localeTable('en') or localeTable('it')
        value = localePath(fallback, key)
    end
    if value == nil then
        local italian = localeTable('it')
        value = localePath(italian, key)
    end
    if type(value) ~= 'string' then return tostring(key) end
    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, value, ...)
        if ok then return formatted end
    end
    return value
end

--- Effective language: the configured one if it exists, otherwise en, otherwise it.
function InventorySkin.activeLocale()
    if localeTable(Config.Locale) then return tostring(Config.Locale) end
    if localeTable('en') then return 'en' end
    return 'it'
end

--- Display name of the active language (for logs).
function InventorySkin.localeName()
    return InventorySkin.locale('meta.name')
end

--- Minimal escaping for a CSS string wrapped in single quotes.
function InventorySkin.cssString(value)
    local s = tostring(value)
    s = s:gsub('\r', '')
    s = s:gsub('\\', '\\\\')  -- escape existing backslashes FIRST
    s = s:gsub('\n', '\\a ') -- CSS escape for a line feed
    s = s:gsub("'", "\\'")
    return s
end
