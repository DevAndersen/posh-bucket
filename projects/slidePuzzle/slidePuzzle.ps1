[CmdletBinding()]
param(
   [int]$Width = 5,
   [int]$Height = 5,
   [int]$ShuffleCount = 1000,
   [bool]$UseColors = $true
)

$charLineH = [char]0x2500
$charLineV = [char]0x2502
$charLineX = [char]0x253C

$charTTop = [char]0x252C
$charTBottom = [char]0x2534
$charTLeft = [char]0x251C
$charTRight = [char]0x2524

$charCTL = [char]0x250C
$charCTR = [char]0x2510
$charCBL = [char]0x2514
$charCBR = [char]0x2518

$lineClosedPart = (0..4 | % { $charLineH }) -join ""

$lineOpen = (0..($Width - 1) | % { "     " }) -join $charLineV
$lineClosed = (0..($Width - 1) | % { $lineClosedPart }) -join $charLineX
$lineTop = (0..($Width - 1) | % { (0..4 | % { $charLineH }) -join "" }) -join $charTTop
$lineBottom = (0..($Width - 1) | % { (0..4 | % { $charLineH }) -join "" }) -join $charTBottom

$currentX = $Width - 1
$currentY = $Height - 1

$validX = 0..($Width - 1)
$validY = 0..($Height - 1)

[int[,]]$grid = [int[,]]::new($Width, $Height)
[int[,]]$solvedGrid = [int[,]]::new($Width, $Height)

$cursorStartX = [console]::CursorLeft
$cursorStartY = [console]::CursorTop

function FillGrid($InputGrid)
{
	for ($y = 0; $y -lt $Height; $y++)
	{	
		for ($x = 0; $x -lt $Width; $x++)
		{
			if (($x -ne $Width - 1) -or ($y -ne $Height - 1))
			{
				$InputGrid[$x, $y] = ($y * $Width) + $x + 1
			}
		}
	}
}

function PrintLines()
{
	[console]::SetCursorPosition($cursorStartX, $cursorStartY)
	Write-Host $charCTL$lineTop$charCTR -ForegroundColor DarkGray
	for ($i = 0; $i -lt (3 * $Height) + ($Height - 1); $i++)
	{
		if ($i % 4 -eq 3)
		{
			Write-Host $charTLeft$lineClosed$charTRight -ForegroundColor DarkGray
		}
		else
		{
			Write-Host $charLineV$lineOpen$charLineV -ForegroundColor DarkGray
		}
	}
	Write-Host $charCBL$lineBottom$charCBR -ForegroundColor DarkGray
}

function PrintGrid()
{
	[console]::SetCursorPosition($cursorStartX, $cursorStartY)
	for ($y = 0; $y -lt $Height; $y++)
	{	
		for ($x = 0; $x -lt $Width; $x++)
		{
			$number = $grid[$x, $y]
			
			[console]::SetCursorPosition($cursorStartX + $x * 6 + 3, $cursorStartY + $y * 4 + 2)
			if ($grid[$x, $y] -ne 0)
			{
				if ($UseColors)
				{
					if ($grid[$x, $y] -eq ($y * $Width) + $x + 1)
					{
						$foreground = "Green"
					}
					else
					{
						$foreground = "Red"
					}
				}
				else
				{
					$foreground = "Gray"
				}
				Write-Host $number.ToString().PadRight(2, " ") -ForegroundColor $foreground
			}
			else
			{
				Write-Host "  "
			}
		}
	}
}

function GetInput()
{
	$input = [console]::ReadKey($true).Key
	
	if ($input -eq [consolekey]::UpArrow)
	{
		return 0,-1
	}
	elseif ($input -eq [consolekey]::DownArrow)
	{
		return 0,1
	}
	elseif ($input -eq [consolekey]::LeftArrow)
	{
		return -1,0
	}
	elseif ($input -eq [consolekey]::RightArrow)
	{
		return 1,0
	}
	else
	{
		return 0,0
	}
}

function MoveTile($MoveX, $MoveY)
{
	$newX = $currentX + $MoveX
	$newY = $currentY + $MoveY
	
	$isMoveXValid = (($MoveX -ne 0) -and ($validX -contains $newX))
	$isMoveYValid = (($MoveY -ne 0) -and ($validY -contains $newY))
	$isMoveValid = $isMoveXValid -or $isMoveYValid
	
	
	if ($isMoveValid)
	{
		$script:moves++
		
		$tmp = $grid[$currentX, $currentY]
		$grid[$currentX, $currentY] = $grid[$newX, $newY]
		$grid[$newX, $newY] = $tmp
		
		$script:currentX = $newX
		$script:currentY = $newY
	}
}

function IsGridSolved()
{
	for ($y = 0; $y -lt $Height; $y++)
	{	
		for ($x = 0; $x -lt $Width; $x++)
		{
			if ($grid[$x, $y] -ne $solvedGrid[$x, $y])
			{
				return $false
			}
		}
	}
	return $true
}

function ShuffleGrid()
{
	$validMoves = ((0,1),(0,-1),(1,0),(-1,0))
	
	0..$ShuffleCount | % {
		$move = Get-Random $validMoves
		MoveTile -MoveX $move[0] -MoveY $move[1]
	}
}

[console]::CursorVisible = $false

FillGrid -InputGrid $grid
FillGrid -InputGrid $solvedGrid

ShuffleGrid

PrintLines
PrintGrid

$moves = 0
$timer = [System.Diagnostics.Stopwatch]::new()
$timer.Start()

while (!(IsGridSolved))
{
	$input = GetInput
	MoveTile -MoveX $input[0] -MoveY $input[1]
	PrintGrid
}

$timer.Stop()

Write-Host "`r`n`r`n`r`n"
Write-Host "Congratulations, puzzle solved!" -ForegroundColor Green
Write-Host "Time:  $($timer.Elapsed.ToString("hh\:mm\:ss\:fff"))"
Write-Host "Moves: $moves"

[console]::CursorVisible = $true
