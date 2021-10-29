# Commandbox CLI bullet train module

The bullet train CLI can be installed as a Commandbox module to beautify and enhance your interaction with Commandbox in a terminal session. For the installation to work, your Mac or Windows computer must support a 256 colors system interface. While it can be assumed by default on Mac, some workaround may be needed on Windows by downloading "con-emu", a command prompt shell emulation for Windows.

Instructions are detailed at: http://www.forgebox.io/view/commandbox-bullet-train

## Prerequisites

To make sure your computer supports 256 colors, simply run `system-colors` at the commandbox prompt:

```sh
$ box
> system-colors
```

If your system does not support 256 colors on Windows, you need to implement the workaround.

## Installation steps

- install the bullet train module for commandbox
- download and install the required font family on your computer
- set Terminal with the newly installed font
- set the new font for your source code editor's integrated terminal.(We are using VS Code)

### 1. Install the bullet train module

At the Commandbox prompt, run:

```sh
> install commandbox-bullet-train
```

### 2. Download the font

Fonts currently installed on your computer do not support the commandbox bullet train module command line interface. You need a font from the Powerline patched font family for the installation to work.

Download the font from Forgebox.io:

- Go to: forgebox.io/view/commandbox-bullet-train
- Go to Fonts and click the link to Powerline fonts

This will lead you to a GitHub site from where a compatible font of your choice can be downloaded. In our case, we selected and downloaded the "DejaVu sans Mono for Powerline.ttf" font. 

### 3. Install the font on your computer

On Mac, double click the downloaded font file. You'll get a Font book opened as a result. Click install.
On Windows, the process is similar but is not detailed here.

### 4. Set the Terminal font

On Mac: 

- Open "Preferences" from the Terminal app menu
- In the text tab, go to Font > change
- Select the new font family: "DejaVu sans Mono for Powerline" and save
- Reload the commandbox shell and it should display the new prompt interface.

On Windows:

- Follow the instructions found online for "con-emu terminal font installation"

### 5. Set VS Code Terminal integrated font family

- Go to Command palette > Settings
- Search for "Terminal font". This will lead you to Features > Terminal screen
- On that screen, modify the font as: "DejaVu sans Mono for Powerline" and save
- Reload the commandbox shell and it should display the new prompt interface.