# base64Invoke

Three simple scripts that, together, can encode, and later decode and execute, PowerShell script code as a base-64 encoded string.

Example:

    > $encodedScript = EncodeB64 -String 'Get-Verb -Verb Get | select Verb,Description'
    
    > $encodedScript
    R2V0LVZlcmIgLVZlcmIgR2V0IHwgc2VsZWN0IFZlcmIsRGVzY3JpcHRpb24=
    
    > DecodeB64 -Base64String $encodedScript
    Get-Verb -Verb Get | select Verb,Description
    
    > InvokeB64 -Base64String $encodedScript
    
    Verb Description
    ---- -----------
    Get  Specifies an action that retrieves a resource

If you dare, try the following:

`InvokeB64 -Base64String "V3JpdGUtSG9zdCAiSGVsbG8gd29ybGQhIiAtRm9yZWdyb3VuZENvbG9yIEdyZWVu"`
