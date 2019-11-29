#region Parameters

[CmdletBinding(DefaultParameterSetName = "Normal")]
param(
	[Parameter(Mandatory, ParameterSetName = "Normal")]
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Parameter(Mandatory, ParameterSetName = "FillMode")]
	[String]$Path,
	
	[Parameter(Mandatory, ParameterSetName = "FillMode")]
	[ValidateSet("Stretch", "ProportionalWidth", "ProportionalHeight")]
	[String]$FillMode,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Width,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Height
)

#endregion

#region Functions

function RenderImage([System.Drawing.Image]$Image)
{
	$escape = [Char]0x1B
	$halfCharString = ([Char]0x2580).ToString()

	[Console]::CursorVisible = $false
	for ($y = 0; $y -lt $Image.Height; $y += 2)
	{
		$pixelString = ""
		for ($x = 0; $x -lt $Image.Width; $x++)
		{
			$f = $Image.GetPixel($x, $y)
			$pixelString += "$escape[38;2;$($f.R);$($f.G);$($f.b)m"
			
			if ($y -lt $Image.Height - 1)
			{
				$b = $Image.GetPixel($x, $y + 1)
				$pixelString += "$escape[48;2;$($b.R);$($b.G);$($b.B)m"
			}
			
			$pixelString += $halfCharString
		}
		Write-Host $pixelString
	}
	[Console]::CursorVisible = $true
}

function ResizeImage([System.Drawing.Image]$Image, $NewWidth, $NewHeight)
{
	return $img.GetThumbnailImage($NewWidth, $NewHeight, $null, [IntPtr]::Zero)
}

#endregion

#region Main flow

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$absolutePath = Resolve-Path $Path
$imageFileStream = [System.IO.File]::OpenRead($absolutePath)
$img = [System.Drawing.Image]::FromStream($imageFileStream, $false, $false)

switch ($PSCmdlet.ParameterSetName)
{
	"Resize"
	{
		$img = ResizeImage -Image $img -NewWidth $Width -NewHeight $Height
	}
	"FillMode"
	{
		switch ($FillMode)
		{
			"Stretch"
			{
				$w = [Console]::WindowWidth
				$h = [Console]::WindowHeight * 2
			}
			"ProportionalWidth"
			{
				$w = [Console]::WindowWidth
				$h = ($img.Height / $img.Width) * [Console]::WindowWidth
			}
			"ProportionalHeight"
			{
				$w = ($img.Height / $img.Width) * [Console]::WindowHeight * 2
				$h = [Console]::WindowHeight * 2
			}
		}
		
		$img = ResizeImage -Image $img -NewWidth $w -NewHeight $h
	}
}

RenderImage -Image $img 

$img.Dispose()
$imageFileStream.Dispose()

#endregion
