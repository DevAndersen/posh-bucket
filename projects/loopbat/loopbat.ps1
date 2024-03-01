# A wrapper around bat (https://github.com/sharkdp/bat), which wraps bats $Path every $Interval seconds.
# This script cleanly clears the console and then writes the bat output in one go, in order to avoid blinking text in the console

param
(
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [double]$Interval = 1
)

while ($true)
{
    $text = "`e[H"
    $text += " " * ([System.Console]::WindowWidth * [System.Console]::WindowHeight)
    $text += "`e[H"
    bat $Path --style plain -f | Out-String | Tee-Object -Variable bat | Out-Null
    $text += $bat
    $text
    [System.Console]::CursorVisible = $false
    sleep $Interval
}
