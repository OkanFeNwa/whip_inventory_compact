-- WHIP applies a game-native screen blur every time the inventory opens:
-- TriggerScreenblurFadeIn(200) in whip_core/client/inventory.lua:1091.
-- A theme.css cannot undo a game native, so this resource cancels it from OUR
-- side only. No whip_core file is touched: removing this client script (and its
-- fxmanifest entry) restores the stock blur immediately.
--
-- WHIP itself uses duration 0 for an instant fade-out (client/pause.lua:395).
-- TRIGGER_SCREENBLUR_FADE_OUT returns a BOOL: a call made while WHIP's 200ms
-- fade-IN is animating can be refused. Calling it once at the start of the fade
-- is therefore not enough. We hold a short suppression window and retry every
-- frame, so at least one call lands after the FadeIn has finished.
--
-- IS_SCREENBLUR_FADE_RUNNING becomes false once the fade is over -- but by then
-- the blur is fully applied. That is why the window must outlive the fade.

local SUPPRESS_MS = 450   -- WHIP's fade is 200ms; generous headroom.
local IS_SCREENBLUR_FADE_RUNNING = 0x7B226C785A52A0A9

local suppressUntil = 0

local function killBlur()
    TriggerScreenblurFadeOut(0)
end

local function startSuppression()
    local now = GetGameTimer()
    -- Never shorten a window that is already running.
    if now < suppressUntil then return end
    suppressUntil = now + SUPPRESS_MS
end

-- Server-pushed opens (stash, vehicle, admin inspect, panels). Fast path:
-- starts the window in the same tick instead of waiting for the watcher.
local OPEN_EVENTS = {
    'whip_core:client:openInventory',
    'whip_core:client:openPlayerInventory',
    'whip_core:client:openPanel',
}
for _, event in ipairs(OPEN_EVENTS) do
    RegisterNetEvent(event, startSuppression)
end

-- F2, the pad, the F1 radial and prompt-driven stashes/gloveboxes are all LOCAL
-- and fire no net event. A single cheap native is all this thread does at idle;
-- the cross-resource export is called ONLY while a fade is animating.
CreateThread(function()
    while true do
        Wait(0)
        local now = GetGameTimer()
        if now < suppressUntil then
            killBlur()
        elseif Citizen.InvokeNative(IS_SCREENBLUR_FADE_RUNNING) then
            local whip = exports.whip_core
            local ok, open = pcall(function() return whip:IsInventoryOpen() end)
            if ok and open then
                startSuppression()
                killBlur()
            end
        end
    end
end)

-- Backstop. WHIP pushes this ~150ms after any screen opens; if the fade check
-- missed an open, this catches it. The guard keeps the pause menu's own blur
-- untouched.
RegisterNetEvent('whip_core:ui:stateChanged', function(e)
    if not e or not e.open then return end
    local whip = exports.whip_core
    local ok, open = pcall(function() return whip:IsInventoryOpen() end)
    if ok and open then startSuppression() end
end)
