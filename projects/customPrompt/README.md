# customPrompt

## Description

A custom prompt function.

## Features

- If current directory is, or is within, $HOME, replace $HOME with "~".
- If current directory is in a git repo, show repo directory name and repo relative path.
- Per-user config (stored in environment variable).
	- ClockEnabled
	- ClockFormat
	- GitIndicator
- Color control
	- #r
		- Resets fore- and background colors
	- #fH
		- Set the currently used background color to H, where H represents a hexadecimal digit.
	- #bH
		- Set the currently used background color to H, where H represents a hexadecimal digit.

## Remarks

- Takes a few seconds the first time it is used, while it sets the config environment variable.
- Currently assumes git is installed, rather than check whether or not it is.
- The color control regex pattern is functional, but needs cleaning up.
