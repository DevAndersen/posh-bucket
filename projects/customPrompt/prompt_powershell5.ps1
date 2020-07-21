#requires -Version 5

function Save-PromptOptions()
{
	$promptOptionsFilePath = [System.IO.Path]::GetDirectoryName($PROFILE),"promptOptions.json" -join [System.IO.Path]::DirectorySeparatorChar
	$PromptOptions | ConvertTo-Json | Out-File $promptOptionsFilePath -Encoding utf8
}

function Load-PromptOptions()
{
	$promptOptionsFilePath = [System.IO.Path]::GetDirectoryName($PROFILE),"promptOptions.json" -join [System.IO.Path]::DirectorySeparatorChar
	$promptOptionsContent = gc $promptOptionsFilePath -Encoding utf8
	
	if ($promptOptionsContent)
	{
		try
		{
			$global:PromptOptions = $promptOptionsContent | ConvertFrom-Json
		}
		catch
		{
			Write-Host "Prompt options file appears to have been corrupted - resetting to default state..." -ForegroundColor Red
			Reset-PromptOptions
		}
	}
}

function Reset-PromptOptions([switch]$SkipSaving)
{
	$global:PromptOptions = [pscustomobject]@{
		General = [pscustomobject]@{												# =General=
			PathStyle = "&f7"														# Styling for the parts of the path (directories).
			PathSeparatorStyle = '"&f8$([System.IO.Path]::DirectorySeparatorChar)"'	# Styling for the path separator ('/' or '\').
			DriveStyle = '&f7$1:'													# Styling for the current Windows drive. '$1' means drive root, for example 'C'.
			Order = "prefix,clock,identity,git,path,suffix"							# The order of the individual parts of the prompt text.
		}
		RelativeHome = [pscustomobject]@{											# =Relative Home= | Replaces $HOME with a custom string, shortening the prompt text.
			Enabled = $true															# Enable/Disable relative home.
			RelativeHomeStyle = "&fb~"												# Default style replaces $HOME with '~', similarly to what is seen in many *NIX shells.
		}
		Prefix = [pscustomobject]@{													# =Prefix= | Generic text that makes up the left-most part of the prompt text.
			Enabled = $false														# Enable/Disable prefix.
			Text = "&f7PS "															# Default emulates that of the standard prompt function.
		}
		Clock = [pscustomobject]@{													# =Clock= | Displays the time the prompt function was called. Useful for tracking when the last command completed.
			Enabled = $true															# Enable/Disable clock.
			Format = "&\f2[&\f\aHH&\f\2:&\f\amm&\f\2:&\f\ass&\f2] "					# Clock format. Defaults to "HH:mm:ss" (24-hour clock). Remember to escape with '\'. 
		}
		Identity = [pscustomobject]@{												# =Identity= | Displays the identity of the current user.
			Enabled = $false														# Enable/Disable identity.
			Text = '"&f6[&fe$(GetHostName)&f6\&fe$(GetUsername)&f6] "'				# Format and styling of the identity string.
		}
		Git = [pscustomobject]@{													# =Git= | Displays basic information about the current Git repository.
			Enabled = $true															# Makes paths in git repos relative.
			GitIndicator = "&f6git "												# Indicator that the current directory is within a git repo.
			EnableWindowsTerminalGitIndicator = $true								# Enable/Disable testing for Windows Terminal. Disabling this can increase the speed of the prompt function a bit.
			WindowsTerminalGitIndicator = "`u{1F531} "								# Indicator that the current directory is within a git repo. Will be used if Windows Terminal is detected, supports emoji.
			RepoNameStyle = "&fb"													# Styling for the repo name.
		}
		Suffix = [pscustomobject]@{													# =Prompt Suffix= | The last part of the prompt; '>' in the standard prompt function.
			NormalUser = "&ff>"														# Prompt suffix for normal users.
			PrivilegedUser = "&fc>"													# Prompt suffix for privileged users (administrator role).
		}
	}
	
	if (!$SkipSaving)
	{
		Save-PromptOptions
	}
}

function Prompt()
{
	[console]::CursorVisible = $false
	if (!$global:PromptOptions)
	{
		Load-PromptOptions
	}
	
	if ($PromptOptions -eq $null)
	{
		Write-Host "Prompt options file not found - initializing with default state..." -ForegroundColor Yellow
		Reset-PromptOptions
	}
	
	#region Functions
	
	# Useful to check for emojis support.
	function IsWindowsTerminal($Process)
	{
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
		$ErrorActionPreference = "Ignore"
		if ((Get-Command git 2> $null) -ne $null)
		{
			$inGitRepo = (git rev-parse --is-inside-work-tree 2> $null)
			if ($inGitRepo)
			{
				return $PWD.Path.StartsWith((GetGitRoot)) # Ensures going from a git repo to, for example, "HKLM:\", doesn't return true.
			}
		}
		return $false
	}
	
	function GetGitRoot()
	{
		$ErrorActionPreference = "Ignore"
		return (git rev-parse --show-toplevel).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
	}
	
	function GetGitRelativePath()
	{
		$ErrorActionPreference = "Ignore"
		$gitRelativePath = [regex]::Match($pwd.Path, "^($([regex]::Escape((GetGitRoot))))($([regex]::Escape([System.IO.Path]::DirectorySeparatorChar))?)(.*)").Groups[3].Value
		return "$(if ($gitRelativePath.Length -eq 0) {''} else {' '})$gitRelativePath"
	}
	
	function GetGitRepoName()
	{
		$ErrorActionPreference = "Ignore"
		return (GetGitRoot).Split([System.IO.Path]::DirectorySeparatorChar)[-1]
	}
	
	function InHome()
	{
		return $pwd.Path.StartsWith($HOME)
	}
	
	function IsPrivileged()
	{
		$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
		$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
		return $principal.IsInRole($adminRole)
	}
	
	function GetHostName()
	{
		return $env:COMPUTERNAME
	}
	
	function GetUsername()
	{
		return $env:USERNAME
	}
	
	function EmbedColors($EncodedString)
	{
		$matches = [regex]::Matches($EncodedString, "&(r)|&(([fb])([0-f]))|((?:.|\n)+?)(?=&|$)", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
		$encodedStrings = foreach ($match in $matches)
		{
			$resetGroup  = $match.Groups[1]
			$changeGroup = $match.Groups[2]
			$depthGroup  = $match.Groups[3]
			$colorGroup  = $match.Groups[4]
			$textGroup   = $match.Groups[$match.Groups.Count - 1]
			
			if ($resetGroup.Success)
			{
				"$([char]0x1B)[0m"
			}
			elseif ($changeGroup.Success)
			{
				$colorIndex = [System.Convert]::ToInt32($colorGroup.Value, 16)
				
				# Table for shifting between .NET- and ANSI color codes.
				$colorIndex = switch ($colorIndex)
				{
                    0  { 0 }
                    4  { 1 }
                    2  { 2 }
                    6  { 3 }
                    1  { 4 }
                    5  { 5 }
                    3  { 6 }
                    7  { 7 }
                    8  { 8 }
                    12 { 9 }
                    10 { 10 }
                    14 { 11 }
                    9  { 12 }
                    13 { 13 }
                    11 { 14 }
                    15 { 15 }
				}
				
				$colorIndex = if ($colorIndex -gt 7) {$colorIndex + 52} else {$colorIndex}
				
				switch ($depthGroup.Value)
				{
					"f" { $colorIndex += 30 }
					"b" { $colorIndex += 40 }
				}
				"$([char]0x1B)[$($colorIndex)m"
			}
			elseif ($textGroup.Success)
			{
				$textGroup.Value
			}
		}
		
		return ($encodedStrings -join "")
	}
	
	function GetHomeRelativePath()
	{
		return $pwd.Path.Substring($HOME.Length)
	}
	
	function BuildPromptTextArray()
	{
		foreach ($word in @($PromptOptions.General.Order -split ","))
		{
			switch ($word.ToLower())
			{
				"prefix" { (WritePrefix) }
				"clock" { (WriteClock) }
				"identity" { (WriteIdentity) }
				"git" { (WriteGit) }
				"path" { (WritePath) }
				"suffix" { (WriteSuffix) }
			}
		}
	}
	
	#region Write functions
	
	function WritePrefix()
	{
		if ($PromptOptions.Prefix.Enabled)
		{
			return $PromptOptions.Prefix.Text
		}
		else
		{
			return ""
		}
	}
	
	function WriteClock()
	{
		if ($PromptOptions.Clock.Enabled)
		{
			return [datetime]::Now.ToString($PromptOptions.Clock.Format)
		}
		else
		{
			return ""
		}
	}
	
	function WriteIdentity()
	{
		if ($PromptOptions.Identity.Enabled)
		{
			return (iex $PromptOptions.Identity.Text)
		}
		else
		{
			return ""
		}
	}
	
	function WriteGit()
	{
		if ($PromptOptions.Git.Enabled -and (InGitRepo))
		{
			$gitIndicatorString = if ($PromptOptions.Git.EnableWindowsTerminalGitIndicator -and (IsWindowsTerminal -Process (Get-Process -Id $PID)))
			{
				$PromptOptions.Git.WindowsTerminalGitIndicator
			}
			else
			{
				$PromptOptions.Git.GitIndicator
			}
			return "$gitIndicatorString$($PromptOptions.Git.RepoNameStyle)$(GetGitRepoName)"
		}
		return ""
	}
	
	function WritePath()
	{
		if ($PromptOptions.Git.Enabled -and (InGitRepo))
		{
			$path = GetGitRelativePath
		}
		elseif ($PromptOptions.RelativeHome.Enabled -and (InHome))
		{
			$path = "$($PromptOptions.RelativeHome.RelativeHomeStyle)&r$(GetHomeRelativePath)"
		}
		else
		{
			$path = $PWD.Path
		}
		$path = $path -replace "(^.+):", $PromptOptions.General.DriveStyle # Applies styling for the current drive.
		$path = $path -replace "$([regex]::Escape([System.IO.Path]::DirectorySeparatorChar))$", "" # Removes unnecessary directory separator char at end of path.
		$path = $path.Replace([string][System.IO.Path]::DirectorySeparatorChar, "$(iex $PromptOptions.General.PathSeparatorStyle)$($PromptOptions.General.PathStyle)") # Styles the current path.
		return "$($PromptOptions.General.PathStyle)$path"
	}
	
	function WriteSuffix()
	{
		if((IsPrivileged))
		{
			return $PromptOptions.Suffix.PrivilegedUser
		}
		else
		{
			return $PromptOptions.Suffix.NormalUser
		}
	}
	
	#endregion
	
	#endregion
	
	# Temporarily changes the output encoding to support emoji.
	$savedEncoding = [console]::OutputEncoding
	[console]::OutputEncoding = [System.Text.Encoding]::UTF8
	
	$promptText = ((BuildPromptTextArray) | ? { ![string]::IsNullOrEmpty($_) }) -join "&r"
	[console]::Write((EmbedColors -EncodedString "$promptText&r"))
	[console]::OutputEncoding = $savedEncoding # Change the output encoding back to its original value.
	[console]::CursorVisible = $true
	return " "
}
