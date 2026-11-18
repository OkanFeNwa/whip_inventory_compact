-- WHIP applies a game-native screen blur every time the inventory opens:
-- TriggerScreenblurFadeIn(200) in whip_core/client/inventory.lua:1091.
-- A theme.css cannot undo a game native -- CSS only paints the NUI page, the blur
-- is a post-process on the GAME frame behind it. So this resource cancels it from
-- our side. No whip_core file is touched: removing this client script (and its
-- fxmanifest entry) restores the stock blur immediately.
--
-- WHIP itself uses duration 0 for an instant fade-out (client/pause.lua:395).
-- TRIGGER_SCREENBLUR_FADE_OUT returns a BOOL: a call made while WHIP's 200ms
-- fade-IN is animating can be refused, so we retry for a short window.

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

-- SAME-TICK CANCELLATION (the actual fix for the one-frame flash).
-- WHIP opens the inventory from these two commands. It is our dependency, so it
-- registers its handlers first; ours run right after openUI() in the same input
-- dispatch, i.e. BEFORE the frame is rendered. That removes the flash entirely.
-- Toggling the inventory closed is harmless here: WHIP fades out anyway.
for _, cmd in ipairs({ 'inventory', 'whip_inventory_pad' }) do
    RegisterCommand(cmd, function()
        startSuppression()
        killBlur()
    end, false)
end

-- Server-pushed opens (stash, vehicle, admin inspect, panels).
local OPEN_EVENTS = {
    'whip_core:client:openInventory',
    'whip_core:client:openPlayerInventory',
    'whip_core:client:openPanel',
}
for _, event in ipairs(OPEN_EVENTS) do
    RegisterNetEvent(event, startSuppression)
end

-- Fallback for the remaining LOCAL opens (F1 radial, prompt-driven stashes and
-- gloveboxes) that fire no command we can hook. One cheap native at idle; the
-- cross-resource export runs only while a fade is animating.
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

-- Backstop: WHIP pushes this ~150ms after any screen opens. The guard keeps the
-- pause menu's own blur untouched.
RegisterNetEvent('whip_core:ui:stateChanged', function(e)
    if not e or not e.open then return end
    local whip = exports.whip_core
    local ok, open = pcall(function() return whip:IsInventoryOpen() end)
    if ok and open then startSuppression() end
end)
