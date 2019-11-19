# consoleImageRenderer

Renders the specified image file to the console as an RGB image, utilizing ANSI escape sequences.

Width and height can optionally be specified. This is recommended if rendering an image that wouldn't be qualified as being of "icon" size.

Note: Does not handle transparency, having transparency in the image can affect the result.

Note: For Windows Conhost, RGB support via ANSI is only supported on Windows 10, specifically from Insider Build 14931 and on.
