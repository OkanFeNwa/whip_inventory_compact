-- WHIP dims AND blurs the game behind the inventory with TriggerScreenblurFadeIn(200)
-- (whip_core/client/inventory.lua). A theme.css cannot undo a game native, so this small
-- script counters it from OUR resource only, for as long as WHIP's inventory is open.
--
-- No whip_core file is touched: we only READ its public export and call the native.
-- Deleting this file (and its fxmanifest entry) restores the stock blur immediately.

local function killBlur()
    -- 1ms is effectively instant but, unlike 0, is always accepted as a duration.
    TriggerScreenblurFadeOut(1)
end

local whip = exports.whip_core
local function inventoryIsOpen()
    local ok, open = pcall(function()
        return whip:IsInventoryOpen()
    end)
    return ok and open == true
end

-- Fast path for server-pushed opens (stash, vehicle, admin inspect, panels).
-- Our resource starts after whip_core (dependency), so this runs in the same tick
-- as WHIP's FadeIn.
local OPEN_EVENTS = {
    'whip_core:client:openInventory',
    'whip_core:client:openPlayerInventory',
    'whip_core:client:openPanel',
}
for _, event in ipairs(OPEN_EVENTS) do
    RegisterNetEvent(event, function()
        if inventoryIsOpen() then killBlur() end
    end)
end

-- Universal watcher for the LOCAL opens that fire no event: F2, pad, radial,
-- prompt-driven stashes and gloveboxes.
--
-- Idle cost is a single cheap native per frame. The relatively expensive
-- cross-resource export is called ONLY while a blur fade is actually running,
-- so a closed inventory costs practically nothing. Pause-menu blur is left
-- alone because inventoryIsOpen() is false there.
-- 0x7B226C785A52A0A9 = IS_SCREENBLUR_FADE_RUNNING. Called by hash so the
-- watcher also works on artifacts whose Lua declarations omit this native.
local IS_SCREENBLUR_FADE_RUNNING = 0x7B226C785A52A0A9

CreateThread(function()
    while true do
        Wait(0)
        if Citizen.InvokeNative(IS_SCREENBLUR_FADE_RUNNING) and inventoryIsOpen() then
            killBlur()
        end
    end
end)
