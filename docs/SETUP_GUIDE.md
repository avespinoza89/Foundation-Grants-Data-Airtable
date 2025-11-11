# Complete Setup Guide

This guide provides step-by-step instructions for setting up the Airtable Database Normalization project on your local machine.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installing R and RStudio](#installing-r-and-rstudio)
3. [Project Installation](#project-installation)
4. [Package Installation](#package-installation)
5. [Configuration](#configuration)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum Requirements

- **Operating System**: Windows 10+, macOS 10.13+, or Linux (Ubuntu 18.04+)
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 500MB for R, RStudio, and packages
- **Internet Connection**: Required for package installation and Airtable API access

### Software Requirements

- **R**: Version 4.0.0 or higher
- **RStudio**: Latest stable version (recommended but optional)
- **Git**: For cloning the repository

---

## Installing R and RStudio

### Windows

1. **Download R**
   - Visit https://cran.r-project.org/bin/windows/base/
   - Download the latest R installer (e.g., `R-4.3.2-win.exe`)
   - Run the installer with default settings
   - Click through the installation wizard

2. **Download RStudio**
   - Visit https://posit.co/download/rstudio-desktop/
   - Download RStudio Desktop (Free version)
   - Run the installer with default settings

3. **Verify Installation**
   ```cmd
   # Open Command Prompt and type:
   R --version
   ```

### macOS

1. **Download R**
   - Visit https://cran.r-project.org/bin/macosx/
   - Download the appropriate .pkg file for your macOS version
   - Open the downloaded .pkg file
   - Follow the installation wizard

2. **Download RStudio**
   - Visit https://posit.co/download/rstudio-desktop/
   - Download RStudio Desktop for macOS
   - Open the .dmg file and drag RStudio to Applications

3. **Verify Installation**
   ```bash
   # Open Terminal and type:
   R --version
   ```

### Linux (Ubuntu/Debian)

1. **Install R**
   ```bash
   # Update package list
   sudo apt update

   # Install R
   sudo apt install r-base r-base-dev

   # Verify installation
   R --version
   ```

2. **Install RStudio**
   ```bash
   # Download RStudio (check website for latest version)
   wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.12.0-369-amd64.deb

   # Install
   sudo dpkg -i rstudio-*.deb
   sudo apt-get install -f  # Fix dependencies if needed
   ```

3. **Install System Dependencies** (required for some R packages)
   ```bash
   sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev
   ```

---

## Project Installation

### Method 1: Clone from Git (Recommended)

```bash
# Navigate to your projects directory
cd ~/Projects  # or your preferred location

# Clone the repository
git clone https://github.com/yourusername/Foundation-Grants-Data-Airtable.git

# Navigate into project directory
cd Foundation-Grants-Data-Airtable
```

### Method 2: Download ZIP

1. Visit the repository on GitHub
2. Click "Code" → "Download ZIP"
3. Extract the ZIP file to your projects directory
4. Rename folder to `Foundation-Grants-Data-Airtable`

### Verify Project Structure

```bash
# List project contents
ls -la

# You should see:
# - README.md
# - requirements.R
# - .env.example
# - .gitignore
# - config/
# - scripts/
# - data/
# - docs/
```

---

## Package Installation

### Automatic Installation (Recommended)

1. **Open RStudio**
   - File → Open Project
   - Navigate to `Foundation-Grants-Data-Airtable` directory
   - Click "Open"

2. **Run Package Installer**
   ```r
   # In RStudio Console, run:
   source("requirements.R")
   ```

3. **Wait for Installation**
   - The script will install all required packages
   - This may take 5-10 minutes
   - You'll see progress messages for each package

### Manual Installation

If automatic installation fails, install packages individually:

```r
# Install CRAN packages
install.packages("httr")
install.packages("jsonlite")
install.packages("dplyr")
install.packages("tidyr")
install.packages("openxlsx")

# Optional packages
install.packages("lubridate")
install.packages("stringr")
install.packages("purrr")
install.packages("readr")
install.packages("here")

# Verify installations
library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(openxlsx)
```

### Troubleshooting Package Installation

#### Windows

If you get compilation errors:

1. Install Rtools:
   - Download from https://cran.r-project.org/bin/windows/Rtools/
   - Install with default settings
   - Restart RStudio

#### macOS

If you get compilation errors:

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Install Homebrew (if not installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

#### Linux

If packages fail to install:

```bash
# Install additional system libraries
sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev
sudo apt install libfontconfig1-dev libharfbuzz-dev libfribidi-dev
sudo apt install libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev

# Then retry package installation in R
```

---

## Configuration

### Environment Variables Setup

1. **Copy Template File**
   ```bash
   cp .env.example .env
   ```

2. **Edit Configuration**
   - Open `.env` in a text editor
   - Fill in your Airtable credentials (see [AIRTABLE_SETUP.md](AIRTABLE_SETUP.md))

   Example `.env` file:
   ```bash
   # Airtable API Credentials
   AIRTABLE_API_KEY=patXxXxXxXxXxXxXxXx.xxxxxxxxxxxxxxxxxxxxxx
   AIRTABLE_BASE_ID=appXxXxXxXxXxXxXx

   # Table Names
   SOURCE_TABLE_NAME=Foundation Grants Data
   TARGET_GRANTS_TABLE=Grants
   TARGET_REPORTS_TABLE=Progress_Reports
   TARGET_VISITS_TABLE=Site_Visits

   # Settings
   DEBUG_MODE=FALSE
   BACKUP_BEFORE_WRITE=TRUE
   MAX_API_RETRIES=3
   ```

3. **Protect Credentials**
   ```bash
   # Ensure .env is not tracked by git
   git status  # Should not show .env in changes

   # If it shows up, add to .gitignore (already done)
   ```

### Demo Mode Setup (No Airtable Required)

If you just want to test the scripts without Airtable:

1. **Skip `.env` configuration** - Leave credentials empty

2. **Generate sample data**
   ```r
   Rscript scripts/generate_sample_data.R
   ```

3. **Scripts will automatically use local files** instead of Airtable API

---

## Verification

### Test R Installation

```r
# In R console:
R.version
```

Expected output: R version 4.x.x or higher

### Test Package Installation

```r
# Check all required packages
required_packages <- c("httr", "jsonlite", "dplyr", "tidyr", "openxlsx")

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("✓ %s is installed\n", pkg))
  } else {
    cat(sprintf("✗ %s is NOT installed\n", pkg))
  }
}
```

### Test Configuration Loading

```r
# Load configuration
source("config/config.R")

# Print configuration summary
print_config()
```

Expected output:
```
================================================================================
CONFIGURATION SUMMARY
================================================================================

API Configuration:
  - API Configured: Yes  # or No if in demo mode

Table Names:
  - Source: Foundation Grants Data
  - Grants: Grants
  - Reports: Progress_Reports
  - Visits: Site_Visits

...
```

### Test Sample Data Generation

```r
# Generate sample data
source("scripts/generate_sample_data.R")

# Check output
file.exists("data/input/MESSY_Grants_Data_Export.xlsx")
# Should return: TRUE
```

### Test Normalization Script

```r
# Run normalization (in demo mode)
source("scripts/normalize_airtable_data.R")

# Check output
file.exists("data/output/NORMALIZED_Output.xlsx")
# Should return: TRUE
```

---

## Troubleshooting

### Common Issues

#### 1. "R is not recognized as an internal or external command" (Windows)

**Solution**: Add R to system PATH
1. Find R installation directory (usually `C:\Program Files\R\R-4.x.x\bin`)
2. Right-click "This PC" → Properties → Advanced system settings
3. Environment Variables → System Variables → Path → Edit
4. Add R bin directory
5. Restart Command Prompt

#### 2. "Permission denied" when installing packages (macOS/Linux)

**Solution**: Don't use sudo with R
```r
# Instead of sudo, set a user library:
.libPaths(c("~/R/library", .libPaths()))
dir.create("~/R/library", recursive = TRUE)
install.packages("package_name")
```

#### 3. "Unable to load shared library" (Linux)

**Solution**: Install system dependencies
```bash
sudo apt update
sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev
```

#### 4. "Cannot open file '.env': No such file or directory"

**Solution**: Create .env from template
```bash
cp .env.example .env
# Then edit .env with your credentials
```

#### 5. RStudio won't start (macOS)

**Solution**:
```bash
# Reset RStudio preferences
rm -rf ~/.rstudio-desktop
```

#### 6. Package installation hangs

**Solution**:
```r
# Try installing from a different CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages("package_name")

# Or specify a specific mirror
options(repos = c(CRAN = "https://cran.rstudio.com"))
```

#### 7. "Error in loadNamespace" after package installation

**Solution**:
```r
# Remove and reinstall the problematic package
remove.packages("package_name")
install.packages("package_name", dependencies = TRUE)
```

### Getting Additional Help

1. **Check Documentation**
   - [README.md](../README.md) - Main project documentation
   - [AIRTABLE_SETUP.md](AIRTABLE_SETUP.md) - Airtable-specific setup

2. **R Help Resources**
   - R Documentation: `?function_name` in R console
   - RStudio Community: https://community.rstudio.com/
   - Stack Overflow: https://stackoverflow.com/questions/tagged/r

3. **Package Documentation**
   ```r
   # View package documentation
   help(package = "dplyr")
   vignette(package = "dplyr")
   ```

4. **Project Issues**
   - Check for existing issues on GitHub
   - Create new issue with:
     - R version (`R.version`)
     - Operating system
     - Error message
     - Steps to reproduce

---

## Next Steps

After completing setup:

1. **For Demo Mode**:
   - Run `Rscript scripts/generate_sample_data.R`
   - Run `Rscript scripts/normalize_airtable_data.R`
   - Review output in `data/output/NORMALIZED_Output.xlsx`

2. **For Production Mode**:
   - Complete [AIRTABLE_SETUP.md](AIRTABLE_SETUP.md)
   - Configure `.env` with real credentials
   - Test with small dataset first
   - Run normalization on production data

3. **Learn More**:
   - Read inline code comments in scripts
   - Review Airtable API documentation
   - Understand database normalization principles

---

## Appendix: Command Reference

### Useful R Commands

```r
# Check working directory
getwd()

# List files
list.files()

# Check package version
packageVersion("dplyr")

# Update all packages
update.packages(ask = FALSE)

# Clear workspace
rm(list = ls())

# Clear console (RStudio)
cat("\014")
```

### Useful Shell Commands

```bash
# Check R version
R --version

# Run R script from command line
Rscript script.R

# Check git status
git status

# View file contents
cat .env.example

# Find R installation directory
which R  # macOS/Linux
where R  # Windows
```

---

**Last Updated**: November 2025
**For Questions**: See [README.md](../README.md) contact section
