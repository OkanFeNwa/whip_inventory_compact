<#
.SYNOPSIS
  Re-applies the one-line whip_core patch that disables the native inventory blur.

.DESCRIPTION
  whip_inventory_compact is a CSS-only skin. CSS cannot undo TriggerScreenblurFadeIn:
  that native blurs the GAME frame behind the NUI page. The patch comments out the
  call in whip_core/client/inventory.lua, leaving the pause menu blur untouched.

  A whip_core update overwrites the line, so run this script again after every
  core update. It is idempotent, backs up the original file once, and preserves
  UTF-8 without BOM.

.EXAMPLE
  .\scripts\apply-blur-patch.ps1

.EXAMPLE
  .\scripts\apply-blur-patch.ps1 -Status

.EXAMPLE
  .\scripts\apply-blur-patch.ps1 -Restore

.EXAMPLE
  .\scripts\apply-blur-patch.ps1 -CorePath 'E:\fxserver\resources\[core]\whip_core'
#>
[CmdletBinding()]
param(
    [string] $CorePath,
    [switch] $Restore,
    [switch] $Status
)

$ErrorActionPreference = 'Stop'

$marker       = '[whip_inventory_compact blur patch]'
$needle       = 'TriggerScreenblurFadeIn(200)'
$backupSuffix = '.whip_inventory_compact.bak'

function Find-InventoryFile {
    $dir = $PSScriptRoot
    for ($i = 0; $i -lt 8; $i++) {
        foreach ($rel in @(
            'whip_core\client\inventory.lua',
            '[core]\whip_core\client\inventory.lua',
            'resources\[core]\whip_core\client\inventory.lua'
        )) {
            $candidate = Join-Path $dir $rel
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
        $parent = Split-Path -Parent $dir
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

if ($CorePath) {
    if (Test-Path -LiteralPath $CorePath -PathType Container) {
        $file = Join-Path $CorePath 'client\inventory.lua'
    } else {
        $file = $CorePath
    }
} else {
    $file = Find-InventoryFile
}

if (-not $file -or -not (Test-Path -LiteralPath $file)) {
    throw "Cannot find whip_core/client/inventory.lua. Pass -CorePath '<path to whip_core>'."
}

$text    = [System.IO.File]::ReadAllText($file)
$patched = $text.Contains($marker)
$backup  = $file + $backupSuffix

if ($Status) {
    Write-Host ('File   : ' + $file)
    Write-Host ('State  : ' + $(if ($patched) { 'PATCHED - inventory blur disabled' } else { 'ORIGINAL - inventory blur active' }))
    Write-Host ('Backup : ' + $(if (Test-Path -LiteralPath $backup) { $backup } else { 'none' }))
    return
}

if ($Restore) {
    if (-not $patched) {
        Write-Host 'Already original; nothing to restore.'
        return
    }
    if (-not (Test-Path -LiteralPath $backup)) {
        throw "No backup at $backup. Restore manually by uncommenting the TriggerScreenblurFadeIn(200) line."
    }
    Copy-Item -LiteralPath $backup -Destination $file -Force
    Write-Host ('Restored the original file from ' + $backup)
    Write-Host 'Restart the core:  restart whip_core'
    return
}

if ($patched) {
    Write-Host 'Already patched; nothing to do.'
    return
}

$regex = '(?m)^(?<indent>[ \t]*)' + [regex]::Escape($needle) + '[ \t]*(?=\r?$)'
$ms = [regex]::Matches($text, $regex)
if ($ms.Count -ne 1) {
    throw "Expected exactly one uncommented '$needle' line in $file, found $($ms.Count). Refusing to patch."
}

if (-not (Test-Path -LiteralPath $backup)) {
    [System.IO.File]::Copy($file, $backup)
    Write-Host ('Backup saved: ' + $backup)
}

$nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

$newText = [regex]::Replace($text, $regex, {
    param($m)
    $i = $m.Groups['indent'].Value
    return (
        $i + '-- ' + $marker + ' native inventory blur disabled; pause blur untouched.' + $nl +
        $i + '-- Re-apply after a whip_core update with scripts/apply-blur-patch.ps1' + $nl +
        $i + '-- ' + $needle
    )
})

[System.IO.File]::WriteAllText($file, $newText, (New-Object System.Text.UTF8Encoding($false)))
Write-Host 'Patched whip_core/client/inventory.lua'
Write-Host 'Restart the core:  restart whip_core'
