# Launches vim.
param
(
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path))
{
    wsl vim
}
else
{
    $FullPath = (Resolve-Path $Path)
    $wslPath = wsl -e wslpath "$FullPath"
    wsl -e vim $wslPath
}
