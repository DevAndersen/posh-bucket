# consoleImageRenderer

## Description

Renders the specified image file to the console as a 24-bit RGB image, utilizing ANSI escape sequences for coloring, and the upper half block character for pixels.

By default (parameterless), the image will be rendered at a 1:1 scale of the actual image size. If the image is larger than the console buffer, the rendering will look "torn".

Alternatively, the script can be called with a specified height and width, or set to a fill mode which will try to make the image fill the console buffer.

## Remarks

- This script does not take transparency into consideration. Transparent pixels will be rendered according to their RGB values.
- For the Windows console (conhost), 24-bit RGB support via ANSI is only supported on Windows 10, specifically from Insider Build 14931 and on.
