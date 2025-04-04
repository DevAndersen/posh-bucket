param
(
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path))
{
    wsl ranger
}
else
{
    $FullPath = (Resolve-Path $Path)
    $wslPath = wsl -e wslpath "$FullPath"
    wsl -e ranger $wslPath
}
