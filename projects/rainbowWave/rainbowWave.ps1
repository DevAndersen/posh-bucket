$i = 0
$e = [char]27

function Calc($Offset, $Speed)
{
	$base = ($i / $Speed) + (2 * [Math]::Pi * ($Offset / 3))
	return (([Math]::Sin($base)) + 1) / 2
}

while ($true)
{
	$i++
	$r = [int]((Calc 1 50) * 255)
	$g = [int]((Calc 2 50) * 255)
	$b = [int]((Calc 3 50) * 255)
	$dotSize = 10
	$dot = ([string][char]0x2588) * $dotSize
	$offset = " " * [int]((Calc 1 20) * ([Console]::BufferWidth - $dotSize))
	$colorDot = "$e[38;2;$r;$g;$($b)m$dot$e[0m"
	Write-Host ($offset + $colorDot)
	sleep -Milliseconds 5
}
