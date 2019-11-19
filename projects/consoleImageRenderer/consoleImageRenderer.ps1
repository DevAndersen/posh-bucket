[CmdletBinding(DefaultParameterSetName = "Normal")]
param(
	[Parameter(Mandatory, ParameterSetName = "Normal")]
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[String]$Path,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Width,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Height
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$absolutePath = Resolve-Path $Path
$imageFileStream = [System.IO.File]::OpenRead($absolutePath)
$img = [System.Drawing.Image]::FromStream($imageFileStream, $false, $false)

if ($PSCmdlet.ParameterSetName -eq "Resize")
{
	$img = $img.GetThumbnailImage($Width, $Height, $null, [System.IntPtr]::Zero)
}

$escape = [Char]0x1B
$halfCharString = ([Char]0x2580).ToString()

for ($y = 0; $y -lt $img.Height; $y += 2)
{
	for ($x = 0; $x -lt $img.Width; $x++)
	{
		$pixelString = ""
		
		$f = $img.GetPixel($x, $y)
		$pixelString += "$escape[38;2;$($f.R);$($f.G);$($f.b)m"
		
		if ($y -lt $img.Height - 1)
		{
			$b = $img.GetPixel($x, $y + 1)
			$pixelString += "$escape[48;2;$($b.R);$($b.G);$($b.B)m"
		}
		
		$pixelString += $halfCharString
		
		Write-Host $pixelString -NoNewline
	}
	Write-Host
}

$img.Dispose()
$imageFileStream.Dispose()
