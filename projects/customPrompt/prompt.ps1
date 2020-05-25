#requires -Version 7

function Save-PromptOptions()
{
	[System.Environment]::SetEnvironmentVariable("PWSH_PROMPT_OPTIONS", ($PromptOptions | ConvertTo-Json -Compress), [System.EnvironmentVariableTarget]::User)
}

function Prompt()
{
	$global:PromptOptions ??= [System.Environment]::GetEnvironmentVariable("PWSH_PROMPT_OPTIONS", [System.EnvironmentVariableTarget]::User) | ConvertFrom-Json
	
	if ($PromptOptions -eq $null)
	{
		Write-Host "User environment variable 'PWSH_PROMPT_OPTIONS' not found - initializing with default values..." -ForegroundColor Yellow
		$global:PromptOptions = [pscustomobject]@{
			General = [pscustomobject]@{
				RelativeHomePath = $true		# Replaces $HOME with '~'.
				PathStyle = "#f7"				# Styling for path.
				PathSeparatorStyle = "#f8"		# Styling for path separator.
				DriveStyle = '$1$2'				# Styling for the current drive. Use single quotes. $1 = drive root, $2 = drive separator.
				HomeStyle = "#fb"				# Styling for the current drive. Use single quotes. $1 = drive root, $2 = drive separator.
				EndingTest = "#ff>#r"			# The ending of the prompt.
			}
			Clock = [pscustomobject]@{
				Enabled = $true
				Format = "#\f\aHH#\f\2:#\f\amm#\f\2:#\f\ass"	# Remember to escape with '\'.
				BorderLeft = "#f2["
				BorderRight = "#f2]#r "	
			}
			Identity = [pscustomobject]@{
				Enabled = $false
				IdentityString = '"#fe$($env:USERNAME)#f6@#fe$($env:COMPUTERNAME)#r "'
			}
			Git = [pscustomobject]@{
				Enabled = $true																					# Makes paths in git repos relative.
				GitIndicator = '(IsWindowsTerminal -Process (Get-Process -Id $PID)) ? "`u{1F531}" : "#f6git#r"'	# Indicator that the current directory is within a git repo. Uses fallback text if not run in Windows Terminal.
				RepoNameStyle = "#fb"																			# Styling for the repo name.
			}
		}
		Save-PromptOptions
	}

	#region Functions
	
	# Useful to check for emojis support.
	function IsWindowsTerminal($Process)
	{
		if (!$IsWindows)
		{
			return false
		}
		
		if ($Process -ne $null)
		{
			if ($Process.Parent.Name -eq "WindowsTerminal")
			{
				return $true
			}
			return IsWindowsTerminal -Proce $Process.Parent
		}
		return $false
	}
	
	function InGitRepo()
	{
		$inGitRepo = (git rev-parse --is-inside-work-tree 2> $null)
		if ($inGitRepo)
		{
			return $PWD.Path.StartsWith((GetGitRoot)) # Ensures going from a git repo to, for example, "HKLM:\", doesn't return true.
		}
		return $false
	}
	
	function GetGitRoot()
	{
		return (git rev-parse --show-toplevel).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
	}
	
	function GetGitRelativePath()
	{
		return [regex]::Match($pwd.Path, "^($([regex]::Escape((GetGitRoot))))($([regex]::Escape([System.IO.Path]::DirectorySeparatorChar))?)(.*)").Groups[3].Value
	}
	
	function GetGitRepoName()
	{
		return (GetGitRoot).Split([System.IO.Path]::DirectorySeparatorChar)[-1]
	}
	
	function InHome()
	{
		return $pwd.Path.StartsWith($HOME)
	}
	
	function WriteWithColor($ColorString)
	{
		$matches = [regex]::Matches($ColorString, "(#r)|#(([BF])([0-9A-F]))|((?:(?!(?:#r)|#(?:(?:[BF])(?:[0-9A-F]))).)+)", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
		$global:rawinput = $ColorString
		foreach ($match in $matches)
		{
			$resetGroup = $match.Groups[1]
			$changeGroup = $match.Groups[2]
			$depthGroup = $match.Groups[3]
			$colorGroup = $match.Groups[4]
			$textGroup = $match.Groups[5]
			
			if ($resetGroup.Success)
			{
				[console]::ResetColor()
			}
			elseif ($changeGroup.Success)
			{
				$color = [System.ConsoleColor][System.Convert]::ToInt32($colorGroup.Value, 16)
				
				switch ($depthGroup.Value)
				{
					"f" { [Console]::ForegroundColor = $color }
					"b" { [Console]::BackgroundColor = $color }
				}
			}
			elseif ($textGroup.Success)
			{
				[System.Console]::Write($textGroup.Value)
			}
		}
		[console]::ResetColor()
	}
	
	function GetHomeRelativePath()
	{
		return $pwd.Path.Substring($HOME.Length)
	}
	
	function WriteClock()
	{
		$clockTimestamp = [datetime]::Now.ToString($PromptOptions.Clock.Format)
		return [System.Text.StringBuilder]::new().Append($PromptOptions.Clock.BorderLeft).Append($clockTimestamp).Append($PromptOptions.Clock.BorderRight).ToString()
	}
	
	function WriteGit()
	{
		return "$(iex $PromptOptions.Git.GitIndicator) $($PromptOptions.Git.RepoNameStyle)$(GetGitRepoName) "
	}
	
	function WritePath()
	{
		$path = ""
		if ($PromptOptions.Git.Enabled -and (InGitRepo))
		{
			$path = GetGitRelativePath
		}
		elseif ($PromptOptions.General.RelativeHomePath -and (InHome))
		{
			$path = "$($PromptOptions.General.HomeStyle)~$(GetHomeRelativePath)"
		}
		else
		{
			$path = $PWD.Path
		}
		$path = $path -replace "(^.+)(:)",$PromptOptions.General.DriveStyle # Applies styling for the current drive.
		$path = $path -replace "$([regex]::Escape([System.IO.Path]::DirectorySeparatorChar))$","" # Removes unnecessary directory separator char at end of path.
		$path = $path.Replace([string][System.IO.Path]::DirectorySeparatorChar, "$($PromptOptions.General.PathSeparatorStyle)$([System.IO.Path]::DirectorySeparatorChar)$($PromptOptions.General.PathStyle)") # Styles the current path.
		return "$($PromptOptions.General.PathStyle)$path"
	}
	
	#endregion
	
	# Temporarily changes the output encoding to support emoji.
	$savedEncoding = [console]::OutputEncoding
	[console]::OutputEncoding = [System.Text.Encoding]::UTF8
	
	$promptText = ((
		($PromptOptions.Clock.Enabled ? (WriteClock) : ""),
		($PromptOptions.Identity.Enabled ? (iex $PromptOptions.Identity.IdentityString) : ""),
		(($PromptOptions.Git.Enabled -and (InGitRepo)) ? (WriteGit) : ""),
		(WritePath),
		$PromptOptions.General.EndingTest
	) | ? { ![string]::IsNullOrEmpty($_) }) -join ""
	
	WriteWithColor -ColorString $promptText
	[console]::OutputEncoding = $savedEncoding # Change the output encoding back to its original value.
	return " "
}
