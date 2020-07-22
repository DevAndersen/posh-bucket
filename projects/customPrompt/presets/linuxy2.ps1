Reset-PromptOptions -SkipSaving

$PromptOptions.General.PathStyle = "&f7"
$PromptOptions.General.DriveStyle = '&f7$1:'
$PromptOptions.Prefix.Enabled = $true
$PromptOptions.Prefix.Text = "&f8["
$PromptOptions.Clock.Enabled = $false
$PromptOptions.Identity.Enabled = $true
$PromptOptions.Identity.Text = '"&fa$(GetUsername)@$(GetHostName) "'
$PromptOptions.Git.GitIndicator = ""
$PromptOptions.Suffix.NormalUser = "&f8]&ff$"
$PromptOptions.Suffix.PrivilegedUser = "&f7]&ff#"

Write-Host "Reminder: If you want these changes to persist, use the command 'Save-PromptOptions'." -ForegroundColor Green
