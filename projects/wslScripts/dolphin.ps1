# Launches KDE's Dolphin file manager.
param
(
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path))
{
    wsl dolphin
}
else
{
    $FullPath = (Resolve-Path $Path)
    $wslPath = wsl -e wslpath "$FullPath"
    wsl -e dolphin $wslPath
}
