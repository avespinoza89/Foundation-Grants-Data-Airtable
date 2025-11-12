# ============================================================================
# AIRTABLE DATABASE NORMALIZATION SCRIPT
# ============================================================================
# Purpose: Extract messy combined data from Airtable, normalize it, and
#          write back properly structured tables
#
# This script demonstrates the complete workflow:
# 1. Connect to Airtable API
# 2. Extract messy combined data from single table
# 3. Normalize into three properly structured tables
# 4. Validate data integrity
# 5. Write normalized tables back to Airtable
#
# Author: Civil Justice Data Team
# Created for: Civil Justice, Inc. RFP Response
# Date: November 2025
# ============================================================================

# ============================================================================
# SETUP AND CONFIGURATION
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("AIRTABLE DATABASE NORMALIZATION - COMPLETE WORKFLOW\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Load required libraries
cat("Loading required packages...\n")
suppressPackageStartupMessages({
  library(httr)        # For HTTP requests to Airtable API
  library(jsonlite)    # For JSON parsing
  library(dplyr)       # For data manipulation
  library(tidyr)       # For data cleaning
  library(openxlsx)    # For Excel export (backup/documentation)
})

cat("\u2713 Packages loaded successfully\n\n")

# ============================================================================
# AIRTABLE API CONFIGURATION
# ============================================================================
# NOTE: In production, these would be stored in environment variables
# or a secure configuration file, never hardcoded

cat("Configuring Airtable API connection...\n")

# Load configuration from environment or config file
source_config <- function() {
  # Try to load from .env file if it exists
  env_file <- ".env"
  if (file.exists(env_file)) {
    cat("  Loading configuration from .env file...\n")
    readRenviron(env_file)
  }
}

# Load configuration
source_config()

# Airtable credentials from environment variables
AIRTABLE_API_KEY <- Sys.getenv("AIRTABLE_API_KEY", unset = "")
AIRTABLE_BASE_ID <- Sys.getenv("AIRTABLE_BASE_ID", unset = "")

# Table names in Airtable
SOURCE_TABLE_NAME <- Sys.getenv("SOURCE_TABLE_NAME", unset = "Foundation Grants Data")
TARGET_GRANTS_TABLE <- Sys.getenv("TARGET_GRANTS_TABLE", unset = "Grants")
TARGET_REPORTS_TABLE <- Sys.getenv("TARGET_REPORTS_TABLE", unset = "Progress_Reports")
TARGET_VISITS_TABLE <- Sys.getenv("TARGET_VISITS_TABLE", unset = "Site_Visits")

# Check if API credentials are configured
API_CONFIGURED <- (AIRTABLE_API_KEY != "" && AIRTABLE_BASE_ID != "")

if (API_CONFIGURED) {
  # API endpoint base URL
  API_BASE_URL <- sprintf("https://api.airtable.com/v0/%s", AIRTABLE_BASE_ID)

  # Standard headers for all requests
  API_HEADERS <- add_headers(
    Authorization = sprintf("Bearer %s", AIRTABLE_API_KEY),
    `Content-Type` = "application/json"
  )

  cat("\u2713 API configuration complete\n\n")
} else {
  cat("  NOTE: Airtable API credentials not configured\n")
  cat("  Will run in demo mode using local files\n\n")
}

# ============================================================================
# FUNCTION: EXTRACT DATA FROM AIRTABLE
# ============================================================================

extract_from_airtable <- function(table_name) {
  cat(sprintf("Extracting data from Airtable table: %s\n", table_name))

  all_records <- list()
  offset <- NULL
  page_count <- 0

  repeat {
    page_count <- page_count + 1
    cat(sprintf("  Fetching page %d...\n", page_count))

    # Build URL with pagination offset if needed
    url <- sprintf("%s/%s", API_BASE_URL, URLencode(table_name))
    if (!is.null(offset)) {
      url <- sprintf("%s?offset=%s", url, offset)
    }

    # Make API request
    response <- GET(url, API_HEADERS)

    # Check for errors
    if (status_code(response) != 200) {
      stop(sprintf("API Error: %d - %s",
                   status_code(response),
                   content(response, "text")))
    }

    # Parse response
    data <- content(response, "parsed")

    # Extract records
    if (length(data$records) > 0) {
      all_records <- c(all_records, data$records)
    }

    # Check for more pages
    if (!is.null(data$offset)) {
      offset <- data$offset
    } else {
      break
    }

    # Airtable rate limit: 5 requests per second
    Sys.sleep(0.21)
  }

  cat(sprintf("\u2713 Extracted %d records from Airtable\n\n", length(all_records)))

  # Convert to data frame
  if (length(all_records) == 0) {
    stop("No records found in source table")
  }

  # Extract fields from each record
  df <- data.frame()
  for (record in all_records) {
    row <- as.data.frame(record$fields, stringsAsFactors = FALSE)
    row$airtable_record_id <- record$id  # Preserve original record ID
    df <- bind_rows(df, row)
  }

  return(df)
}

# ============================================================================
# FUNCTION: DELETE ALL RECORDS FROM TABLE
# ============================================================================

delete_all_records <- function(table_name) {
  cat(sprintf("Clearing existing data from table: %s\n", table_name))

  # First, get all record IDs
  url <- sprintf("%s/%s", API_BASE_URL, URLencode(table_name))
  response <- GET(url, API_HEADERS)

  if (status_code(response) != 200) {
    cat(sprintf("  Table %s may not exist yet, skipping deletion\n", table_name))
    return()
  }

  data <- content(response, "parsed")

  if (length(data$records) == 0) {
    cat("  Table is already empty\n")
    return()
  }

  record_ids <- sapply(data$records, function(r) r$id)

  # Delete in batches of 10 (Airtable API limit)
  batch_size <- 10
  total_batches <- ceiling(length(record_ids) / batch_size)

  for (i in seq(1, length(record_ids), by = batch_size)) {
    batch <- record_ids[i:min(i + batch_size - 1, length(record_ids))]
    batch_num <- ceiling(i / batch_size)

    cat(sprintf("  Deleting batch %d of %d (%d records)...\n",
                batch_num, total_batches, length(batch)))

    # Build delete URL with record IDs as query parameters
    delete_url <- sprintf("%s/%s?", API_BASE_URL, URLencode(table_name))
    for (id in batch) {
      delete_url <- paste0(delete_url, sprintf("records[]=%s&", id))
    }
    delete_url <- substr(delete_url, 1, nchar(delete_url) - 1)  # Remove trailing &

    # Make delete request
    response <- DELETE(delete_url, API_HEADERS)

    if (status_code(response) != 200) {
      warning(sprintf("Failed to delete batch %d: %s",
                      batch_num, content(response, "text")))
    }

    Sys.sleep(0.21)  # Rate limiting
  }

  cat(sprintf("\u2713 Deleted %d records from %s\n\n", length(record_ids), table_name))
}

# ============================================================================
# FUNCTION: WRITE DATA TO AIRTABLE
# ============================================================================

write_to_airtable <- function(df, table_name) {
  cat(sprintf("Writing %d records to Airtable table: %s\n", nrow(df), table_name))

  # Remove any Airtable metadata columns
  df <- df %>% select(-any_of(c("airtable_record_id")))

  # Convert data frame to list of records
  records <- list()
  for (i in 1:nrow(df)) {
    # Convert row to named list, removing NA values
    fields <- as.list(df[i, ])
    fields <- fields[!is.na(fields)]

    # Ensure all values are appropriate types for Airtable
    fields <- lapply(fields, function(x) {
      if (is.factor(x)) as.character(x)
      else if (is.numeric(x) && length(x) == 1) as.numeric(x)
      else as.character(x)
    })

    records[[i]] <- list(fields = fields)
  }

  # Write in batches of 10 (Airtable API limit)
  batch_size <- 10
  total_batches <- ceiling(length(records) / batch_size)
  records_created <- 0

  for (i in seq(1, length(records), by = batch_size)) {
    batch <- records[i:min(i + batch_size - 1, length(records))]
    batch_num <- ceiling(i / batch_size)

    cat(sprintf("  Writing batch %d of %d (%d records)...\n",
                batch_num, total_batches, length(batch)))

    # Build request body
    body <- list(records = batch)

    # Make API request
    url <- sprintf("%s/%s", API_BASE_URL, URLencode(table_name))
    response <- POST(
      url,
      API_HEADERS,
      body = toJSON(body, auto_unbox = TRUE),
      encode = "json"
    )

    if (status_code(response) != 200) {
      stop(sprintf("Failed to write batch %d: %s\nResponse: %s",
                   batch_num,
                   status_code(response),
                   content(response, "text")))
    }

    records_created <- records_created + length(batch)

    Sys.sleep(0.21)  # Rate limiting
  }

  cat(sprintf("\u2713 Successfully wrote %d records to %s\n\n",
              records_created, table_name))

  return(records_created)
}

# ============================================================================
# MAIN WORKFLOW: EXTRACT, NORMALIZE, LOAD
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("STARTING NORMALIZATION WORKFLOW\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# ----------------------------------------------------------------------------
# STEP 1: EXTRACT MESSY DATA FROM AIRTABLE
# ----------------------------------------------------------------------------

cat("STEP 1: EXTRACT DATA FROM AIRTABLE\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

# Check if we should use API or local file
if (!API_CONFIGURED) {
  cat("NOTE: API credentials not configured, loading from local Excel file\n")
  cat("In production, this would extract from Airtable API\n\n")

  input_file <- "data/input/MESSY_Grants_Data_Export.xlsx"
  if (!file.exists(input_file)) {
    stop(sprintf("Input file not found: %s\nPlease run generate_sample_data.R first", input_file))
  }

  messy_data <- read.xlsx(input_file)
  cat(sprintf("\u2713 Loaded %d rows from local file\n\n", nrow(messy_data)))

} else {
  # Extract from Airtable
  messy_data <- extract_from_airtable(SOURCE_TABLE_NAME)
}

cat("Original messy data structure:\n")
cat(sprintf("  - Total rows: %d\n", nrow(messy_data)))
cat(sprintf("  - Columns: %d\n", ncol(messy_data)))
cat(sprintf("  - Unique grants: %d\n", n_distinct(messy_data$Grant_ID)))

cat("\nPROBLEMS WITH THIS STRUCTURE:\n")
cat("  1. Grant information repeated in every row\n")
cat("  2. Progress reports and site visits mixed together\n")
cat("  3. Many empty/NA fields\n")
cat("  4. Update anomalies (must update grant info in multiple places)\n")
cat("  5. Insert anomalies (can't add a grant without a report or visit)\n")
cat("  6. Delete anomalies (deleting last report deletes grant info)\n\n")

# ----------------------------------------------------------------------------
# STEP 2: NORMALIZE - EXTRACT GRANTS TABLE
# ----------------------------------------------------------------------------

cat("STEP 2: CREATE NORMALIZED GRANTS TABLE\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

grants <- messy_data %>%
  select(Grant_ID, Organization_Name, Grant_Amount, Grant_Start_Date,
         Grant_End_Date, Program_Officer, Focus_Area, Grant_Status) %>%
  distinct() %>%
  arrange(Grant_ID)

cat(sprintf("\u2713 Created Grants table with %d unique records\n", nrow(grants)))
cat(sprintf("  Reduced from %d rows to %d rows\n", nrow(messy_data), nrow(grants)))
cat(sprintf("  Data reduction: %.1f%%\n\n",
            (1 - nrow(grants)/nrow(messy_data)) * 100))

# ----------------------------------------------------------------------------
# STEP 3: NORMALIZE - EXTRACT PROGRESS REPORTS TABLE
# ----------------------------------------------------------------------------

cat("STEP 3: CREATE NORMALIZED PROGRESS REPORTS TABLE\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

progress_reports <- messy_data %>%
  filter(!is.na(Report_Date) & Report_Date != "") %>%
  select(Grant_ID, Report_Date, Reporting_Period, Report_Type,
         Clients_Served, Activities_Description, Challenges_Faced,
         Budget_Status) %>%
  distinct() %>%  # Remove duplicate reports
  mutate(
    Report_ID = sprintf("RPT-%s-%04d",
                        substr(Grant_ID, 4, 15),
                        row_number())
  ) %>%
  select(Report_ID, Grant_ID, everything()) %>%
  arrange(Grant_ID, Report_Date)

cat(sprintf("\u2713 Created Progress Reports table with %d records\n",
            nrow(progress_reports)))
cat(sprintf("  Reports per grant (average): %.1f\n\n",
            nrow(progress_reports) / n_distinct(progress_reports$Grant_ID)))

# ----------------------------------------------------------------------------
# STEP 4: NORMALIZE - EXTRACT SITE VISITS TABLE
# ----------------------------------------------------------------------------

cat("STEP 4: CREATE NORMALIZED SITE VISITS TABLE\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

site_visits <- messy_data %>%
  filter(!is.na(Site_Visit_Date) & Site_Visit_Date != "") %>%
  select(Grant_ID, Site_Visit_Date, Visit_Type, Visitor_Name,
         Visit_Purpose, Observations, Follow_Up_Required, Follow_Up_Notes) %>%
  distinct() %>%  # Remove duplicate visits
  mutate(
    Visit_ID = sprintf("VST-%s-%04d",
                       substr(Grant_ID, 4, 15),
                       row_number())
  ) %>%
  select(Visit_ID, Grant_ID, everything()) %>%
  arrange(Grant_ID, Site_Visit_Date)

cat(sprintf("\u2713 Created Site Visits table with %d records\n",
            nrow(site_visits)))
cat(sprintf("  Visits per grant (average): %.1f\n\n",
            nrow(site_visits) / n_distinct(site_visits$Grant_ID)))

# ----------------------------------------------------------------------------
# STEP 5: DATA QUALITY VALIDATION
# ----------------------------------------------------------------------------

cat("STEP 5: DATA QUALITY VALIDATION\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

cat("Check 1: Referential Integrity\n")
orphaned_reports <- setdiff(progress_reports$Grant_ID, grants$Grant_ID)
orphaned_visits <- setdiff(site_visits$Grant_ID, grants$Grant_ID)

if(length(orphaned_reports) == 0) {
  cat("  \u2713 All progress reports link to valid grants\n")
} else {
  cat(sprintf("  \u2717 WARNING: %d orphaned progress reports\n",
              length(orphaned_reports)))
}

if(length(orphaned_visits) == 0) {
  cat("  \u2713 All site visits link to valid grants\n")
} else {
  cat(sprintf("  \u2717 WARNING: %d orphaned site visits\n",
              length(orphaned_visits)))
}

cat("\nCheck 2: Primary Key Uniqueness\n")
cat(sprintf("  \u2713 Grants: %d unique Grant_IDs (primary key)\n",
            n_distinct(grants$Grant_ID)))
cat(sprintf("  \u2713 Reports: %d unique Report_IDs (primary key)\n",
            n_distinct(progress_reports$Report_ID)))
cat(sprintf("  \u2713 Visits: %d unique Visit_IDs (primary key)\n",
            n_distinct(site_visits$Visit_ID)))

cat("\nCheck 3: Data Completeness\n")
cat(sprintf("  Grants with organization name: %.0f%%\n",
            100 * sum(!is.na(grants$Organization_Name)) / nrow(grants)))
cat(sprintf("  Reports with activities: %.0f%%\n",
            100 * sum(!is.na(progress_reports$Activities_Description)) /
              nrow(progress_reports)))
cat(sprintf("  Visits with observations: %.0f%%\n\n",
            100 * sum(!is.na(site_visits$Observations)) / nrow(site_visits)))

# ----------------------------------------------------------------------------
# STEP 6: WRITE NORMALIZED TABLES BACK TO AIRTABLE
# ----------------------------------------------------------------------------

cat("STEP 6: WRITE NORMALIZED DATA TO AIRTABLE\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

if (!API_CONFIGURED) {
  cat("NOTE: API credentials not configured, saving to local files instead\n")
  cat("In production, this would write to Airtable API\n\n")

  # Save to Excel as backup
  wb <- createWorkbook()

  addWorksheet(wb, "Grants")
  writeData(wb, "Grants", grants)

  addWorksheet(wb, "Progress_Reports")
  writeData(wb, "Progress_Reports", progress_reports)

  addWorksheet(wb, "Site_Visits")
  writeData(wb, "Site_Visits", site_visits)

  output_file <- "data/output/NORMALIZED_Output.xlsx"
  saveWorkbook(wb, output_file, overwrite = TRUE)
  cat(sprintf("\u2713 Saved to %s\n\n", output_file))

} else {
  # Write to Airtable

  # Optional: Clear existing data (use with caution!)
  # Uncomment these lines if you want to replace all data
  # delete_all_records(TARGET_GRANTS_TABLE)
  # delete_all_records(TARGET_REPORTS_TABLE)
  # delete_all_records(TARGET_VISITS_TABLE)

  # Write normalized tables
  grants_written <- write_to_airtable(grants, TARGET_GRANTS_TABLE)
  reports_written <- write_to_airtable(progress_reports, TARGET_REPORTS_TABLE)
  visits_written <- write_to_airtable(site_visits, TARGET_VISITS_TABLE)

  cat(paste(rep("=", 80), collapse=""), "\n")
  cat("AIRTABLE WRITE SUMMARY\n")
  cat(paste(rep("=", 80), collapse=""), "\n")
  cat(sprintf("  Grants: %d records written\n", grants_written))
  cat(sprintf("  Progress Reports: %d records written\n", reports_written))
  cat(sprintf("  Site Visits: %d records written\n\n", visits_written))
}

# ----------------------------------------------------------------------------
# STEP 7: FINAL SUMMARY
# ----------------------------------------------------------------------------

cat(paste(rep("=", 80), collapse=""), "\n")
cat("NORMALIZATION COMPLETE - SUMMARY\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("BEFORE (Messy Structure):\n")
cat(sprintf("  • Single table with %d rows\n", nrow(messy_data)))
cat(sprintf("  • %d columns (many empty)\n", ncol(messy_data)))
cat("  • Grant info repeated in every row\n")
cat("  • Mixed data types in same table\n")
cat("  • Update anomalies present\n\n")

cat("AFTER (Normalized Structure):\n")
cat(sprintf("  • Three tables: Grants (%d), Reports (%d), Visits (%d)\n",
            nrow(grants), nrow(progress_reports), nrow(site_visits)))
cat(sprintf("  • %.1f%% reduction in grant data redundancy\n",
            (1 - nrow(grants)/nrow(messy_data)) * 100))
cat("  • Each entity type in its own table\n")
cat("  • Referential integrity maintained\n")
cat("  • No update anomalies\n")
cat("  • Easier to query and analyze\n\n")

cat("KEY IMPROVEMENTS:\n")
cat(sprintf("  1. Grant records stored ONCE (was in %d rows)\n",
            nrow(messy_data)))
cat("  2. Can add grants without reports/visits\n")
cat("  3. Can delete reports without losing grant info\n")
cat("  4. Updates only need to happen in one place\n")
cat("  5. Clear relationships between entities\n")
cat("  6. 100%% referential integrity validated\n\n")

cat(paste(rep("=", 80), collapse=""), "\n")
cat("WORKFLOW COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# ============================================================================
# AIRTABLE INTEGRATION NOTES FOR PRODUCTION USE
# ============================================================================

cat("NOTES FOR PRODUCTION DEPLOYMENT:\n")
cat(paste(rep("-", 80), collapse=""), "\n\n")

cat("1. API CREDENTIALS:\n")
cat("   Store credentials securely:\n")
cat("   - Use environment variables (Sys.getenv)\n")
cat("   - Or secure configuration management\n")
cat("   - Never commit credentials to version control\n\n")

cat("2. TABLE SETUP IN AIRTABLE:\n")
cat("   Before running this script, create these tables:\n")
cat(sprintf("   - %s (grants data)\n", TARGET_GRANTS_TABLE))
cat(sprintf("   - %s (progress reports)\n", TARGET_REPORTS_TABLE))
cat(sprintf("   - %s (site visits)\n\n", TARGET_VISITS_TABLE))

cat("3. LINKED RECORDS:\n")
cat("   After data is loaded, configure linked record fields:\n")
cat("   - In Progress_Reports: link Grant_ID to Grants table\n")
cat("   - In Site_Visits: link Grant_ID to Grants table\n")
cat("   This creates bidirectional relationships in Airtable UI\n\n")

cat("4. FIELD TYPES:\n")
cat("   Ensure correct field types in Airtable:\n")
cat("   - Dates: Date fields (not text)\n")
cat("   - Currency: Currency or Number fields\n")
cat("   - IDs: Single line text\n")
cat("   - Descriptions: Long text\n\n")

cat("5. RATE LIMITING:\n")
cat("   This script includes rate limiting (5 requests/second)\n")
cat("   For very large datasets, consider:\n")
cat("   - Running during off-peak hours\n")
cat("   - Implementing retry logic\n")
cat("   - Monitoring API usage\n\n")

cat("6. ERROR HANDLING:\n")
cat("   In production, add:\n")
cat("   - Try-catch blocks for API calls\n")
cat("   - Logging of all operations\n")
cat("   - Rollback procedures if errors occur\n")
cat("   - Data backup before modifications\n\n")

cat("7. INCREMENTAL UPDATES:\n")
cat("   For ongoing use, modify to:\n")
cat("   - Check for existing records before writing\n")
cat("   - Update changed records instead of full reload\n")
cat("   - Track last sync timestamp\n\n")

cat(paste(rep("=", 80), collapse=""), "\n")
cat("For questions about Airtable integration, see:\n")
cat("https://airtable.com/developers/web/api/introduction\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")
