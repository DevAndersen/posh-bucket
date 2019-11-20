# variableFileInterpreter

Reads the content of files, one .txt and one .json, and replace PowerShell-styled variables ($varName) with the value of an actual PowerShell variable of the same name.

Note: Script scope is being used for variable declaration in the script, because the interpretation occurs in a different scope from the variable declaration.

Note: The $jsonContentSafe variable ensures double quotes (") will be understood correctly.
