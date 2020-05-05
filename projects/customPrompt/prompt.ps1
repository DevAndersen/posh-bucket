function Prompt()
{
	$envVarName = "PWSH_PROMPT_CONFIG"
	if (![System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User))
	{
		$defaultPromptConfig = [pscustomobject]@{
			ClockEnabled = $true
			ClockFormat = "HH:mm:ss"
			GitIndicator = "$([char]0xb6)"
		}
		
		Write-Host "User environment variable '$envVarName' not found - initializing with default values..." -ForegroundColor Yellow
		[System.Environment]::SetEnvironmentVariable($envVarName, ($defaultPromptConfig | ConvertTo-Json -Compress), [System.EnvironmentVariableTarget]::User)
	}
	
	$promptConfig = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User) | ConvertFrom-Json
	
	#region Functions
	function InGitRepo()
	{
		return (git rev-parse --is-inside-work-tree 2> $null) -eq $true
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

	function GetHomeRelativePath()
	{
		return $pwd.Path.Substring($HOME.Length)
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
	}
	
	function AddColorsToPath($Path)
	{
		$Path = $Path.Replace([string][System.IO.Path]::DirectorySeparatorChar, "#f8$([System.IO.Path]::DirectorySeparatorChar)#f7")
		return $Path
	}
	
	#endregion
	
	$config = [System.Environment]::GetEnvironmentVariable("PWSH_PROMPT_CONFIG", [System.EnvironmentVariableTarget]::User) | ConvertFrom-Json
	$promptText = ""
	$promptPath = ""
	
	if ($config.ClockEnabled)
	{
		$promptText += "#f2[#fa$([datetime]::Now.ToString("$($promptConfig.ClockFormat)"))#f2] "
	}
	
	if (InGitRepo)
	{
		$gitRelativePath = GetGitRelativePath
		$promptText += "#f6$($promptConfig.GitIndicator) #fb$(GetGitRepoName)"
		
		if ($gitRelativePath.Length -ne 0)
		{
			$gitRelativePath = " $gitRelativePath"
		}
		
		$promptPath = $gitRelativePath
	}
	elseif (InHome)
	{
		$promptPath = "#fb~$(GetHomeRelativePath)"
	}
	else
	{
		$promptPath = $PWD.Path
	}
	
	$coloredPath = AddColorsToPath -Path $promptPath
	
	WriteWithColor -ColorString "$promptText#f7$coloredPath#ff>#r"
	return " "
}
