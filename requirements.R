# ============================================================================
# PACKAGE DEPENDENCIES FOR AIRTABLE NORMALIZATION PROJECT
# ============================================================================
# This script installs all required R packages for the project
#
# Usage:
#   source("requirements.R")
#   # or
#   Rscript requirements.R
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("AIRTABLE NORMALIZATION - PACKAGE INSTALLATION\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# ============================================================================
# REQUIRED PACKAGES
# ============================================================================

required_packages <- c(
  "httr",       # HTTP requests to Airtable API
  "jsonlite",   # JSON parsing for API responses
  "dplyr",      # Data manipulation and transformation
  "tidyr",      # Data tidying operations
  "openxlsx"    # Reading/writing Excel files
)

# ============================================================================
# OPTIONAL PACKAGES (for enhanced functionality)
# ============================================================================

optional_packages <- c(
  "lubridate",  # Date/time manipulation
  "stringr",    # String manipulation
  "purrr",      # Functional programming tools
  "readr",      # Fast CSV reading/writing
  "here"        # Project-relative paths
)

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

#' Install packages if not already installed
#' @param packages Character vector of package names
#' @param optional Logical indicating if packages are optional
install_if_missing <- function(packages, optional = FALSE) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat(sprintf("Installing %s package: %s\n",
                  ifelse(optional, "optional", "required"), pkg))

      tryCatch({
        install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org/")
        cat(sprintf("  \u2713 %s installed successfully\n", pkg))
      }, error = function(e) {
        if (optional) {
          warning(sprintf("  \u2717 Failed to install optional package %s: %s", pkg, e$message))
        } else {
          stop(sprintf("  \u2717 Failed to install required package %s: %s", pkg, e$message))
        }
      })
    } else {
      cat(sprintf("  \u2713 %s already installed\n", pkg))
    }
  }
}

#' Check package versions and print summary
check_packages <- function(packages) {
  cat("\nInstalled Package Versions:\n")
  cat(paste(rep("-", 80), collapse=""), "\n")

  for (pkg in packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      version <- as.character(packageVersion(pkg))
      cat(sprintf("  %s: %s\n", pkg, version))
    } else {
      cat(sprintf("  %s: NOT INSTALLED\n", pkg))
    }
  }
  cat("\n")
}

# ============================================================================
# MAIN INSTALLATION PROCESS
# ============================================================================

cat("STEP 1: Installing Required Packages\n")
cat(paste(rep("-", 80), collapse=""), "\n")
install_if_missing(required_packages, optional = FALSE)

cat("\n")
cat("STEP 2: Installing Optional Packages\n")
cat(paste(rep("-", 80), collapse=""), "\n")
cat("Note: Optional packages provide enhanced functionality but are not required\n\n")
install_if_missing(optional_packages, optional = TRUE)

# ============================================================================
# VERIFICATION
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("PACKAGE INSTALLATION COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Check all packages
all_packages <- c(required_packages, optional_packages)
check_packages(all_packages)

# Verify required packages
cat("Verifying Required Packages:\n")
cat(paste(rep("-", 80), collapse=""), "\n")

all_installed <- TRUE
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("  \u2717 MISSING: %s\n", pkg))
    all_installed <- FALSE
  } else {
    cat(sprintf("  \u2713 OK: %s\n", pkg))
  }
}

cat("\n")

if (all_installed) {
  cat("\u2713 SUCCESS: All required packages are installed!\n")
  cat("\nYou can now run the normalization scripts:\n")
  cat("  1. Generate sample data: Rscript scripts/generate_sample_data.R\n")
  cat("  2. Normalize data: Rscript scripts/normalize_airtable_data.R\n\n")
} else {
  cat("\u2717 ERROR: Some required packages failed to install\n")
  cat("Please install them manually using: install.packages(c(...))\n\n")
}

cat(paste(rep("=", 80), collapse=""), "\n\n")

# ============================================================================
# R VERSION CHECK
# ============================================================================

cat("R Environment Information:\n")
cat(paste(rep("-", 80), collapse=""), "\n")
cat(sprintf("  R Version: %s\n", R.version.string))
cat(sprintf("  Platform: %s\n", R.version$platform))
cat(sprintf("  OS: %s\n", R.version$os))
cat("\n")

# Check R version
r_version <- as.numeric(paste(R.version$major, R.version$minor, sep = "."))
if (r_version < 4.0) {
  warning("This project is designed for R version 4.0 or higher. Some features may not work correctly.")
} else {
  cat("\u2713 R version is compatible\n\n")
}

cat(paste(rep("=", 80), collapse=""), "\n\n")
