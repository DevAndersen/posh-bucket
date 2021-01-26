# poshcat

A PowerShell version of busyloop's [lolcat](https://github.com/busyloop/lolcat/). Makes PowerShell *a bit* more colorful.

Can take input from either pipeline or `Object` parameter, but prioritizes `Object` parameter.

Works if input comes from `Format-Table` or `Format-List`.

`EscapeEndings` parameter can be used to specify which escape sequence ending characters to look out for, when filtering the input for pre-existing formatting. Helps preserve escape code formatting that has already been embedded into the input.

`NoRegex` parameter makes the script simply color every input character, overriding the `EscapeEndings` parameter in the process.
