param(
	[String]$Text,
	[Switch]$WithoutResetAtEnd
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$result = $Text
$escape = [Char]0x1B

$htPatterns = @{
	"\@\[R\]"	= "$escape[0m"	# Reset
	"\@\[U\]"	= "$escape[4m"	# Underline
	"\@\[-U\]"	= "$escape[24m"	# Underline off
	"\@\[I\]"	= "$escape[7m"	# Inverse
	"\@\[-I\]"	= "$escape[27m"	# Inverse off
}

$colorPattern = "\@\[([B,F])#([0-9,A-f]{3,6})\]"

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
		
		$color = [System.Drawing.Color]::FromArgb("0x" + $matches[2])
		$r = $color.R
		$g = $color.G
		$b = $color.B
		
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
