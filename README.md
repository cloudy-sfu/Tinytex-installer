# Tinytex installer
Install Tinytex by Yihui Xie without RStudio in Windows

![](https://shields.io/badge/dependencies-PowerShell_7-navy)
![](https://shields.io/badge/OS-Windows_≥_10-skyblue)

## Introduction

[Tinytex](https://github.com/rstudio/tinytex) is a light-weighted TeX Live distribution by Yihui Xie.

It is cross-platform, while requiring R language to install.

This program can install Tinytex in Windows without R language. It has `tlmgr` command, but doesn't have the function about testing compiling LaTeX documents or automatically install missing packages.

## Usage

### Install

Run the following command in PowerShell.

```powershell
.\install.ps1
```

### Uninstall

Run the following command in PowerShell.

```powershell
.\uninstall.ps1
```

### Dependencies list

To analyze the document and list used TeX Live packages, run the following command with arguments in PowerShell.

```powershell
.\list_packages.ps1
```

Arguments:

| Argument      | Required? | Description                                                  |
| ------------- | --------- | ------------------------------------------------------------ |
| Position 1    | Yes       | File path of the document to analyze.                        |
| `-OutputPath` | No        | File path to output used TeX Live packages. Default: `requirements.txt` |

### Duplicate reference

To check duplicate bibtex reference, run the following command with arguments in PowerShell.

```
.\check_duplicate_bibtex.ps1
```

Arguments:

| Argument    | Required? | Description                                                  |
| ----------- | --------- | ------------------------------------------------------------ |
| `-Filename` | No        | File path of bibtex file (usually `*.bib`). Default: `ref.bib`. |

