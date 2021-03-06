# consoleImageRenderer

![Bliss, now in the console!](./githubAssets/example.png)

## Description

Renders the specified image file to the console as a 24-bit RGB image, utilizing ANSI escape sequences for coloring, and the upper half block character for pixels.

The image path can be local ("C:\...") or a URL (the URL must start with "HTTP(S)://").

By default (parameterless), the image will be rendered at a 1:1 scale of the actual image size. If the image is larger than the console buffer, the rendering will look "torn".

Alternatively, the script can be called with a specified height and width, or set to a fill mode which will try to make the image fill the console buffer.

The result of the script can be saved to a file or variable, which can be written to the console at later times (simply ).

## Remarks

- This script does not take transparency into consideration. Transparent pixels will be rendered according to their RGB values.
- For the Windows console (conhost), 24-bit RGB support via ANSI is only supported on Windows 10, specifically from Insider Build 14931 and on.
