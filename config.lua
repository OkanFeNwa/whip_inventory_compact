-- =============================================================================
-- Skin language.
--
-- Change ONLY this line: it, en, es, fr, de. Then run
-- `restart whip_inventory_compact`: server.lua rewrites locales/active.css and the
-- theme reloads the labels. Fallback is en, then it, then the key itself.
-- =============================================================================

Config = Config or {}
Config.Locale = 'it'

Config.Locales = {
    it = {
        meta = { name = 'Italiano' },
        accessory = {
            phone = 'Telefono',
            cash = 'Contanti',
            key1 = 'Chiave 1',
            key2 = 'Chiave 2',
            key3 = 'Chiave 3',
        },
        console = {
            themeFailed = 'Impossibile applicare il tema: %s',
            localeWriteFailed = 'Impossibile scrivere locales/active.css (%s): %s',
            localeActive = 'Lingua attiva: %s (%s)',
        },
    },

    en = {
        meta = { name = 'English' },
        accessory = {
            phone = 'Phone',
            cash = 'Cash',
            key1 = 'Key 1',
            key2 = 'Key 2',
            key3 = 'Key 3',
        },
        console = {
            themeFailed = 'Could not apply the theme: %s',
            localeWriteFailed = 'Could not write locales/active.css (%s): %s',
            localeActive = 'Active language: %s (%s)',
        },
    },

    es = {
        meta = { name = 'Español' },
        accessory = {
            phone = 'Teléfono',
            cash = 'Efectivo',
            key1 = 'Llave 1',
            key2 = 'Llave 2',
            key3 = 'Llave 3',
        },
        console = {
            themeFailed = 'No se pudo aplicar el tema: %s',
            localeWriteFailed = 'No se pudo escribir locales/active.css (%s): %s',
            localeActive = 'Idioma activo: %s (%s)',
        },
    },

    fr = {
        meta = { name = 'Français' },
        accessory = {
            phone = 'Téléphone',
            cash = 'Argent',
            key1 = 'Clé 1',
            key2 = 'Clé 2',
            key3 = 'Clé 3',
        },
        console = {
            themeFailed = 'Impossible d’appliquer le thème : %s',
            localeWriteFailed = 'Impossible d’écrire locales/active.css (%s) : %s',
            localeActive = 'Langue active : %s (%s)',
        },
    },

    de = {
        meta = { name = 'Deutsch' },
        accessory = {
            phone = 'Telefon',
            cash = 'Bargeld',
            key1 = 'Schlüssel 1',
            key2 = 'Schlüssel 2',
            key3 = 'Schlüssel 3',
        },
        console = {
            themeFailed = 'Theme konnte nicht angewendet werden: %s',
            localeWriteFailed = 'locales/active.css konnte nicht geschrieben werden (%s): %s',
            localeActive = 'Aktive Sprache: %s (%s)',
        },
    },
}
