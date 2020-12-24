if ($PSVersionTable.PSVersion.Major -ge 7)
{
	Write-Host "
     `e[93m_\/_
      /\
      `e[32m/\
     /  \
     /`e[33m~~`e[32m\`e[31m`e[5mo`e[25m
    `e[32m/`e[34m`e[5mo`e[25m   `e[32m\
   /`e[33m~~`e[93m*`e[33m~~~`e[32m\
  `e[95m`e[5mo`e[25m`e[32m/     `e[96m`e[5mo`e[25m`e[32m\
  /`e[33m~~~~~~~~`e[32m\
 /`e[32m__`e[93m*`e[32m_______`e[32m\
      `e[33m||
    `e[37m\`e[33m====`e[37m/
     \__/`e[0m
"
}
else
{
	# Older versions of PowerShell don't have the neat "`e" shortcut for [char]27.
	Write-Host "
     $([char]27)[93m_\/_
      /\
      $([char]27)[32m/\
     /  \
     /$([char]27)[33m~~$([char]27)[32m\$([char]27)[31m$([char]27)[5mo$([char]27)[25m
    $([char]27)[32m/$([char]27)[34m$([char]27)[5mo$([char]27)[25m   $([char]27)[32m\
   /$([char]27)[33m~~$([char]27)[93m*$([char]27)[33m~~~$([char]27)[32m\
  $([char]27)[95m$([char]27)[5mo$([char]27)[25m$([char]27)[32m/     $([char]27)[96m$([char]27)[5mo$([char]27)[25m$([char]27)[32m\
  /$([char]27)[33m~~~~~~~~$([char]27)[32m\
 /$([char]27)[32m__$([char]27)[93m*$([char]27)[32m_______$([char]27)[32m\
      $([char]27)[33m||
    $([char]27)[37m\$([char]27)[33m====$([char]27)[37m/
     \__/$([char]27)[0m
"
}
