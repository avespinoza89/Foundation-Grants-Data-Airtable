# ============================================================================
# AIRTABLE CONNECTION TEST
# ============================================================================
# Quick test to verify API connection and inspect base structure

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("TESTING AIRTABLE API CONNECTION\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Load configuration
cat("Loading configuration...\n")
source("config/config.R")

# Check if API is configured
if (!API_CONFIGURED) {
  stop("ERROR: API credentials not configured. Please check your .env file.")
}

cat(sprintf("\u2713 API Key found (starts with: %s...)\n", substr(AIRTABLE_API_KEY, 1, 10)))
cat(sprintf("\u2713 Base ID: %s\n\n", AIRTABLE_BASE_ID))

# Load required packages
suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
})

# ============================================================================
# TEST 1: Basic API Connection
# ============================================================================

cat("TEST 1: Testing basic API connection\n")
cat(paste(rep("-", 80), collapse=""), "\n")

# Try to access the base metadata
base_url <- sprintf("https://api.airtable.com/v0/meta/bases/%s/tables", AIRTABLE_BASE_ID)

response <- GET(
  base_url,
  add_headers(
    Authorization = sprintf("Bearer %s", AIRTABLE_API_KEY)
  )
)

if (status_code(response) == 200) {
  cat("\u2713 SUCCESS: Connected to Airtable API\n")

  # Parse base structure
  base_data <- content(response, "parsed")

  if (!is.null(base_data$tables)) {
    cat(sprintf("\u2713 Found %d table(s) in your base:\n\n", length(base_data$tables)))

    for (i in seq_along(base_data$tables)) {
      table <- base_data$tables[[i]]
      cat(sprintf("  %d. %s\n", i, table$name))
      cat(sprintf("     ID: %s\n", table$id))
      if (!is.null(table$fields)) {
        cat(sprintf("     Fields: %d\n", length(table$fields)))
      }
      cat("\n")
    }
  }

} else if (status_code(response) == 401) {
  cat("\u2717 FAILED: Unauthorized (401)\n")
  cat("   Your API token may be invalid or missing required scopes.\n")
  cat("   Required scopes: data.records:read, data.records:write, schema.bases:read\n\n")
  cat("   Response:", content(response, "text"), "\n")
  stop("Authentication failed")

} else if (status_code(response) == 403) {
  cat("\u2717 FAILED: Forbidden (403)\n")
  cat("   Your token doesn't have access to this base.\n")
  cat("   Make sure you added this base when creating the token.\n\n")
  cat("   Response:", content(response, "text"), "\n")
  stop("Access denied")

} else if (status_code(response) == 404) {
  cat("\u2717 FAILED: Not Found (404)\n")
  cat("   Base ID may be incorrect.\n")
  cat(sprintf("   Base ID provided: %s\n\n", AIRTABLE_BASE_ID))
  cat("   Response:", content(response, "text"), "\n")
  stop("Base not found")

} else {
  cat(sprintf("\u2717 FAILED: Unexpected error (HTTP %d)\n", status_code(response)))
  cat("   Response:", content(response, "text"), "\n")
  stop(sprintf("API request failed with status %d", status_code(response)))
}

# ============================================================================
# TEST 2: Check for Source Table
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("TEST 2: Looking for source data table\n")
cat(paste(rep("-", 80), collapse=""), "\n")

# Try to read from the configured source table
url <- sprintf("%s/%s?maxRecords=3", API_BASE_URL, URLencode(SOURCE_TABLE_NAME))

response <- GET(url, API_HEADERS)

if (status_code(response) == 200) {
  data <- content(response, "parsed")

  cat(sprintf("\u2713 Found table: '%s'\n", SOURCE_TABLE_NAME))
  cat(sprintf("\u2713 Sample records retrieved: %d\n\n", length(data$records)))

  if (length(data$records) > 0) {
    cat("First record fields:\n")
    fields <- names(data$records[[1]]$fields)
    for (field in fields) {
      cat(sprintf("  - %s\n", field))
    }
    cat("\n")
  }

} else if (status_code(response) == 404) {
  cat(sprintf("\u2717 Table '%s' not found in your base\n\n", SOURCE_TABLE_NAME))
  cat("Available tables in your base:\n")
  if (!is.null(base_data$tables)) {
    for (table in base_data$tables) {
      cat(sprintf("  - %s\n", table$name))
    }
  }
  cat("\nPlease update SOURCE_TABLE_NAME in your .env file to match one of the above.\n")
} else {
  cat(sprintf("\u2717 Error accessing table (HTTP %d)\n", status_code(response)))
  cat("   Response:", content(response, "text"), "\n")
}

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("CONNECTION TEST COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Next Steps:\n")
cat("1. Review the table names listed above\n")
cat("2. Update SOURCE_TABLE_NAME in .env if needed\n")
cat("3. Ensure your source table has the required fields\n")
cat("4. Run the normalization script\n\n")
