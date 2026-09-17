# Tinytex installer
Install Tinytex by Yihui Xie without RStudio in Windows

![](https://shields.io/badge/dependencies-PowerShell_7-navy)
![](https://shields.io/badge/OS-Windows_≥_10-skyblue)

[Tinytex](https://github.com/rstudio/tinytex) is a light-weighted TeX Live distribution by Yihui Xie.

It is cross-platform, while requiring R language to install.

This program can install Tinytex in Windows without R language. It has `tlmgr` command, but doesn't have the function about testing compiling LaTeX documents or automatically install missing packages.

## Usage

To install, run the following command in PowerShell.

```powershell
.\install.ps1
```

To uninstall, run the following command in PowerShell.

```powershell
.\uninstall.ps1
```

