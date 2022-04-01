$previous = [System.Collections.ArrayList]::new()

while($true)
{
    $timestamp = [datetime]::Now.ToString("\[HH\:mm\:ss\] ")

    $current = Get-Process | % { "$($_.Id)`t$($_.ProcessName)" }
    
    if ($previous.Count -eq 0)
    {
        Write-Host "`e[32m$timestamp Started`e[m"
    }
    else
    {
        $started = $current | ? { $_ -notin $previous }
        $stopped = $previous | ? { $_ -notin $current }

        $started | % { "`e[32m$timestamp + $_`e[m" }
        $stopped | % { "`e[31m$timestamp - $_`e[m" }
    }

    $previous = $current
    sleep 1
}
