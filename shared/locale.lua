-- ============================================
-- Lingue — lo stesso schema di whip_clothingwheel
-- ============================================
-- Config.Locale sceglie il blocco in Config.Locales. Se una chiave manca si
-- prova en, poi it, infine si restituisce la chiave stessa (mai una stringa
-- vuota). I segnaposto sono quelli di string.format (%s, %d, ...).

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

--- Testo localizzato. `key` usa la notazione con punti, per esempio 'accessory.phone'.
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

--- Lingua effettiva: quella configurata se esiste, altrimenti en, altrimenti it.
function InventorySkin.activeLocale()
    if localeTable(Config.Locale) then return tostring(Config.Locale) end
    if localeTable('en') then return 'en' end
    return 'it'
end

--- Nome display della lingua attiva (per i log).
function InventorySkin.localeName()
    return InventorySkin.locale('meta.name')
end

--- Escaping minimo per una stringa CSS tra virgolette singole.
function InventorySkin.cssString(value)
    local s = tostring(value)
    s = s:gsub('\r', '')
    s = s:gsub('\\', '\\\\')  -- escape existing backslashes FIRST
    s = s:gsub('\n', '\\a ') -- CSS escape for a line feed
    s = s:gsub("'", "\\'")
    return s
end
