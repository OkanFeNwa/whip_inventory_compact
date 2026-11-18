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

local function inventoryIsOpen()
    local ok, open = pcall(function()
        return exports.whip_core:IsInventoryOpen()
    end)
    return ok and open == true
end

-- Server-pushed opens (stash, vehicle, admin inspect, panels). Our resource starts
-- after whip_core (dependency), so this runs in the same tick as WHIP's FadeIn.
local OPEN_EVENTS = {
    'whip_core:client:openInventory',
    'whip_core:client:openPlayerInventory',
    'whip_core:client:openPanel',
}
for _, event in ipairs(OPEN_EVENTS) do
    RegisterNetEvent(event, killBlur)
end

-- The common F2 open is LOCAL (inventoryKey -> Inventory.openUI) and never fires
-- a net event. WHIP sets invOpen BEFORE TriggerScreenblurFadeIn, so polling every
-- frame lets us cancel the fade in the same frame it starts.
--
-- Do NOT idle at 40ms here: that gap was the residual one-frame blur flash.
CreateThread(function()
    while true do
        Wait(0)
        if inventoryIsOpen() then
            killBlur()
        end
    end
end)
