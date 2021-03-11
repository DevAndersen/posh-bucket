param(
	[Object[]]$Object,
	[String]$EscapeEndings = "bcdhm",
	[Int]$ColorSpeed = 10,
	[Switch]$NoRegex
)

$e = [char]27
$regexPattern = "`e\[.+?[$EscapeEndings]|."

$inputString = if ($Object)
{
	$Object | Out-String
}
else
{
	$input | Out-String
}

function Rainbowify($Index, $Offset, $Speed)
{
	$base = ($Index / $Speed) + (2 * [Math]::Pi * ($Offset / 3))
	return (([Math]::Sin($base)) + 1) / 2
}

$lines = $inputString -split "`n"
for ($i = 0; $i -lt $lines.Length; $i++)
{
	$line = $lines[$i]
	$outLine = ""
	
	$shifts = if ($NoRegex)
	{
		$line.ToCharArray()
	}
	else
	{
		[regex]::Matches($line, $regexPattern).Groups.Value
	}
	
	for ($j = 0; $j -lt $shifts.Length; $j++)
	{
		$char = $shifts[$j]
		$index = $i + $j
		$r = [int]((Rainbowify -Index $index -Offset 1 -Speed $ColorSpeed) * 255)
		$g = [int]((Rainbowify -Index $index -Offset 2 -Speed $ColorSpeed) * 255)
		$b = [int]((Rainbowify -Index $index -Offset 3 -Speed $ColorSpeed) * 255)
		$outLine += "$e[38;2;$r;$g;$($b)m$char$e[0m"
	}
	$outLine
}
