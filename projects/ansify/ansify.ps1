param(

	[Parameter(Mandatory)]
	[String]$Text,
	[Int]$ForegroundColor,
	[Int]$BackgroundColor,
	[Switch]$Underline,
	[Switch]$Invert,
	[Switch]$WithoutResetAtEnd
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$result = $Text
$escape = [Char]0x1B

$colorPattern = "\@\[([B,F])#([0-9,A-f]{3,6})\]"
$htPatterns = @{
	"\@\[R\]"	= "$escape[0m"	# Reset
	"\@\[U\]"	= "$escape[4m"	# Underline
	"\@\[-U\]"	= "$escape[24m"	# Underline off
	"\@\[I\]"	= "$escape[7m"	# Inverse
	"\@\[-I\]"	= "$escape[27m"	# Inverse off
}

#region Parameter modifiers

if ($ForegroundColor)
{
	$fgColor = [System.Drawing.Color]::FromArgb($ForegroundColor)
	$fr = $fgColor.R
	$fg = $fgColor.G
	$fb = $fgColor.B
	$result = "$escape[38;2;$fr;$fg;$($fb)m$result"
}

if ($BackgroundColor)
{
	$bgColor = [System.Drawing.Color]::FromArgb($BackgroundColor)
	$br = $bgColor.R
	$bg = $bgColor.G
	$bb = $bgColor.B
	$result = "$escape[48;2;$br;$bg;$($bb)m$result"
}

if ($Underline)
{
	$result = "$escape[4m$result"
}

if ($Invert)
{
	$result = "$escape[7m$result"
}

#endregion

#region functions

function EmbedSimpleReplace($Pattern, $Replace)
{
	$script:result = [Regex]::Replace($result, $Pattern, $Replace, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function EmbedColor()
{
	$script:result = [Regex]::Replace($result, $colorPattern, {
		$matches = $args[0].Groups.Value
		
		$colorLayer = switch($matches[1].ToUpper())
		{
			"F" {"38"}
			"B" {"48"}
		}
		
		$hexColor = [System.Drawing.Color]::FromArgb("0x" + $matches[2])
		$r = $hexColor.R
		$g = $hexColor.G
		$b = $hexColor.B
		
		return "$escape[$colorLayer;2;$r;$g;$($b)m"
	}, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

#endregion

EmbedColor

foreach ($key in $htPatterns.Keys)
{
	EmbedSimpleReplace -Pattern $key -Replace $htPatterns[$key]
}

if (!$WithoutResetAtEnd)
{
	$result += "$escape[0m"
}

return $result
