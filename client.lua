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

-- WHIP opens its UI from these net events. Our resource starts AFTER whip_core
-- (dependency), so our handler is registered later and runs in the SAME TICK,
-- right after WHIP's FadeIn. The blur never gets a visible frame.
local OPEN_EVENTS = {
    'whip_core:client:openInventory',
    'whip_core:client:openPlayerInventory',
    'whip_core:client:openPanel',
}
for _, event in ipairs(OPEN_EVENTS) do
    RegisterNetEvent(event, killBlur)
end

-- Local opens (F2 from cache, radial, pad) never come through a net event.
-- Poll every frame while open to catch those too; 40ms is plenty when closed.
CreateThread(function()
    local interval = 40

    while true do
        Wait(interval)

        local open = inventoryIsOpen()
        interval = open and 0 or 40

        if open then
            killBlur()
        end
    end
end)
