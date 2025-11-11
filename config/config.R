# ============================================================================
# CENTRALIZED CONFIGURATION FOR AIRTABLE NORMALIZATION PROJECT
# ============================================================================
# This file provides centralized configuration management
# Source this file at the beginning of your scripts
# ============================================================================

# ============================================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================================

load_environment <- function() {
  # Check for .env file in project root
  env_file <- ".env"

  if (file.exists(env_file)) {
    message("Loading configuration from .env file...")
    readRenviron(env_file)
    return(TRUE)
  } else if (file.exists(".env.example")) {
    warning("No .env file found. Please copy .env.example to .env and configure your credentials.")
    return(FALSE)
  } else {
    warning("No environment configuration found.")
    return(FALSE)
  }
}

# Load environment variables
env_loaded <- load_environment()

# ============================================================================
# AIRTABLE API CONFIGURATION
# ============================================================================

# API Credentials
AIRTABLE_API_KEY <- Sys.getenv("AIRTABLE_API_KEY", unset = "")
AIRTABLE_BASE_ID <- Sys.getenv("AIRTABLE_BASE_ID", unset = "")

# Check if credentials are configured
API_CONFIGURED <- (AIRTABLE_API_KEY != "" && AIRTABLE_BASE_ID != "")

# API Base URL
if (API_CONFIGURED) {
  API_BASE_URL <- sprintf("https://api.airtable.com/v0/%s", AIRTABLE_BASE_ID)
} else {
  API_BASE_URL <- NULL
}

# ============================================================================
# TABLE NAMES
# ============================================================================

# Source table
SOURCE_TABLE_NAME <- Sys.getenv("SOURCE_TABLE_NAME", unset = "Foundation Grants Data")

# Target tables
TARGET_GRANTS_TABLE <- Sys.getenv("TARGET_GRANTS_TABLE", unset = "Grants")
TARGET_REPORTS_TABLE <- Sys.getenv("TARGET_REPORTS_TABLE", unset = "Progress_Reports")
TARGET_VISITS_TABLE <- Sys.getenv("TARGET_VISITS_TABLE", unset = "Site_Visits")

# ============================================================================
# FILE PATHS
# ============================================================================

# Project root directory
PROJECT_ROOT <- getwd()

# Data directories
DATA_INPUT_DIR <- file.path(PROJECT_ROOT, "data", "input")
DATA_OUTPUT_DIR <- file.path(PROJECT_ROOT, "data", "output")

# Default file names
MESSY_DATA_FILE <- file.path(DATA_INPUT_DIR, "MESSY_Grants_Data_Export.xlsx")
NORMALIZED_OUTPUT_FILE <- file.path(DATA_OUTPUT_DIR, "NORMALIZED_Output.xlsx")

# Create directories if they don't exist
if (!dir.exists(DATA_INPUT_DIR)) {
  dir.create(DATA_INPUT_DIR, recursive = TRUE)
}
if (!dir.exists(DATA_OUTPUT_DIR)) {
  dir.create(DATA_OUTPUT_DIR, recursive = TRUE)
}

# ============================================================================
# API SETTINGS
# ============================================================================

# Airtable rate limiting (5 requests per second)
API_RATE_LIMIT_DELAY <- 0.21  # seconds between requests

# API retry settings
MAX_API_RETRIES <- as.numeric(Sys.getenv("MAX_API_RETRIES", unset = "3"))

# Batch sizes (Airtable API limits)
API_BATCH_SIZE_READ <- 100    # Maximum records per GET request
API_BATCH_SIZE_WRITE <- 10    # Maximum records per POST request
API_BATCH_SIZE_DELETE <- 10   # Maximum records per DELETE request

# ============================================================================
# OPERATIONAL SETTINGS
# ============================================================================

# Debug mode
DEBUG_MODE <- Sys.getenv("DEBUG_MODE", unset = "FALSE") == "TRUE"

# Backup before write
BACKUP_BEFORE_WRITE <- Sys.getenv("BACKUP_BEFORE_WRITE", unset = "TRUE") == "TRUE"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

#' Check if all required packages are installed
#' @param packages Character vector of package names
#' @return Logical indicating if all packages are available
check_packages <- function(packages) {
  missing <- packages[!sapply(packages, requireNamespace, quietly = TRUE)]

  if (length(missing) > 0) {
    stop(sprintf(
      "Missing required packages: %s\nInstall them with: install.packages(c('%s'))",
      paste(missing, collapse = ", "),
      paste(missing, collapse = "', '")
    ))
  }

  return(TRUE)
}

#' Print configuration summary
print_config <- function() {
  cat("\n")
  cat(paste(rep("=", 80), collapse=""), "\n")
  cat("CONFIGURATION SUMMARY\n")
  cat(paste(rep("=", 80), collapse=""), "\n\n")

  cat("API Configuration:\n")
  cat(sprintf("  - API Configured: %s\n", ifelse(API_CONFIGURED, "Yes", "No")))
  if (API_CONFIGURED) {
    cat(sprintf("  - Base ID: %s\n", substr(AIRTABLE_BASE_ID, 1, 10), "..."))
  }

  cat("\nTable Names:\n")
  cat(sprintf("  - Source: %s\n", SOURCE_TABLE_NAME))
  cat(sprintf("  - Grants: %s\n", TARGET_GRANTS_TABLE))
  cat(sprintf("  - Reports: %s\n", TARGET_REPORTS_TABLE))
  cat(sprintf("  - Visits: %s\n", TARGET_VISITS_TABLE))

  cat("\nFile Paths:\n")
  cat(sprintf("  - Input: %s\n", DATA_INPUT_DIR))
  cat(sprintf("  - Output: %s\n", DATA_OUTPUT_DIR))

  cat("\nSettings:\n")
  cat(sprintf("  - Debug Mode: %s\n", DEBUG_MODE))
  cat(sprintf("  - Backup Before Write: %s\n", BACKUP_BEFORE_WRITE))
  cat(sprintf("  - Max API Retries: %d\n", MAX_API_RETRIES))

  cat("\n")
  cat(paste(rep("=", 80), collapse=""), "\n\n")
}

# ============================================================================
# PACKAGE REQUIREMENTS
# ============================================================================

REQUIRED_PACKAGES <- c(
  "httr",       # HTTP requests
  "jsonlite",   # JSON parsing
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "openxlsx"    # Excel file handling
)

# ============================================================================
# INITIALIZATION MESSAGE
# ============================================================================

if (interactive()) {
  message("Configuration loaded successfully")
  if (!API_CONFIGURED) {
    message("NOTE: Running in demo mode (no API credentials configured)")
  }
}

# ============================================================================
# EXPORT CONFIGURATION
# ============================================================================

# Return a list of all configuration values
get_config <- function() {
  list(
    # API
    api_key = AIRTABLE_API_KEY,
    base_id = AIRTABLE_BASE_ID,
    api_configured = API_CONFIGURED,
    api_base_url = API_BASE_URL,

    # Tables
    source_table = SOURCE_TABLE_NAME,
    grants_table = TARGET_GRANTS_TABLE,
    reports_table = TARGET_REPORTS_TABLE,
    visits_table = TARGET_VISITS_TABLE,

    # Paths
    data_input_dir = DATA_INPUT_DIR,
    data_output_dir = DATA_OUTPUT_DIR,
    messy_data_file = MESSY_DATA_FILE,
    normalized_output_file = NORMALIZED_OUTPUT_FILE,

    # Settings
    debug_mode = DEBUG_MODE,
    backup_before_write = BACKUP_BEFORE_WRITE,
    max_retries = MAX_API_RETRIES,
    rate_limit_delay = API_RATE_LIMIT_DELAY,

    # Packages
    required_packages = REQUIRED_PACKAGES
  )
}
