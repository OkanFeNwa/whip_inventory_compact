-- Apply this skin server-wide without touching whip_core/config.lua or server.cfg.
-- Stopping this resource unwinds the override automatically (the registry is owned
-- by this resource), so the stock look comes back on its own.
--
-- The skin only has CSS, so the Lua locale from config.lua is compiled into a
-- tiny `locales/active.css` at start. theme.css imports that file; changing
-- Config.Locale and restarting is therefore enough to switch every label.

local RESOURCE = GetCurrentResourceName()

local function writeActiveLocaleCss()
    local root = GetResourcePath(RESOURCE) or ('resources/[custom]/' .. RESOURCE)
    local path = ('%s/locales/active.css'):format(root)
    local q = InventorySkin.cssString

    local css = table.concat({
        '/* Generated from config.lua by server.lua. Do not edit by hand.',
        '   Change Config.Locale and `restart whip_inventory_compact` instead. */',
        ':root {',
        ('    --skin-label-phone: \'%s\';'):format(q(InventorySkin.locale('accessory.phone'))),
        ('    --skin-label-cash: \'%s\';'):format(q(InventorySkin.locale('accessory.cash'))),
        ('    --skin-label-key1: \'%s\';'):format(q(InventorySkin.locale('accessory.key1'))),
        ('    --skin-label-key2: \'%s\';'):format(q(InventorySkin.locale('accessory.key2'))),
        ('    --skin-label-key3: \'%s\';'):format(q(InventorySkin.locale('accessory.key3'))),
        '}',
        '',
    }, '\n')

    local fh, err = io.open(path, 'w')
    if not fh then
        print(('[whip_inventory_compact] ' .. InventorySkin.locale('console.localeWriteFailed')):format(tostring(path), tostring(err)))
        return false
    end

    fh:write(css)
    fh:close()
    print(('[whip_inventory_compact] ' .. InventorySkin.locale('console.localeActive')):format(
        InventorySkin.activeLocale(), InventorySkin.localeName()))
    return true
end

writeActiveLocaleCss()

Whip.register(function()
    local ok, why = Whip.core:SetActiveTheme(RESOURCE)
    if not ok then
        print(('[whip_inventory_compact] ' .. InventorySkin.locale('console.themeFailed')):format(tostring(why)))
    end
end)
