[CmdletBinding()]
param(
	[Parameter()]
	[Int]$TickRate = 50,
	
	[Parameter()]
	[Int]$Rarity = 10,
	
	[Parameter()]
	[Int]$Amount = 10,
	
	[Parameter()]
	[Int]$MinSpeed = 1,
	
	[Parameter()]
	[Int]$MaxSpeed = 3,
	
	[Parameter()]
	[Char]$SnowChar = "."
)

clear
[Console]::CursorVisible = $false
$flakes = New-Object System.Collections.ArrayList

function AddNewFlake()
{
	$flakes.Add([PSCustomObject]@{
		X = Get-Random -Maximum ([Console]::WindowWidth)
		Y = 0
		Fall = Get-Random -Minimum $MinSpeed -Maximum $MaxSpeed
		Melted = $false
	}) | Out-Null
}

function MoveFlake($Flake)
{
	$Flake.Y += $Flake.Fall
	if ($Flake.Y -ge ([Console]::WindowHeight) - 1)
	{
		$Flake.Melted = $true
	}
	
	if ($Flake.X -le 0)
	{
		$xMin = 0
	}
	else
	{
		$xMin = -1
	}
	
	if ($Flake.X -ge ([Console]::WindowWidth - 1))
	{
		$xMax = 0
	}
	else
	{
		$xMax = 2
	}
	
	$Flake.X += (Get-Random -Minimum $xMin -Maximum $xMax)
}

function RenderFlake($Flake, $Char)
{
	if (!$Flake.Melted)
	{
		[Console]::SetCursorPosition($Flake.X, $Flake.Y)
		Write-Host $Char -NoNewline
	}
}

while($true)
{
	sleep -Milliseconds $TickRate
	
	0..$Amount | % {
		if ((Get-Random -Maximum $Rarity) -eq 0)
		{
			AddNewFlake
		}
	}
	
	$flakes | ? { !($_.Melted) } | % {
		RenderFlake -Flake $_ -Char " "
		MoveFlake -Flake $_
		RenderFlake -Flake $_ -Char $SnowChar
	}
}
