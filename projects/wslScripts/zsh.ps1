# Launches ZSH.
param
(
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path))
{
    wsl zsh
}
else
{
    $FullPath = (Resolve-Path $Path)
    $wslPath = wsl -e wslpath "$FullPath"
    wsl -e zsh $wslPath
}
