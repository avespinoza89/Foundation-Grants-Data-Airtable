# ============================================================================
# SAMPLE DATA GENERATOR FOR AIRTABLE NORMALIZATION DEMO
# ============================================================================
# Purpose: Generate realistic messy grant data to demonstrate database
#          normalization benefits
#
# This script creates a denormalized (messy) dataset that combines:
# - Grant information (repeated for every report/visit)
# - Progress reports
# - Site visits
# All in a single table with lots of empty cells and redundancy
#
# Author: Civil Justice Data Team
# Date: November 2025
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("GENERATING SAMPLE MESSY GRANT DATA\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Load required libraries
cat("Loading required packages...\n")
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(openxlsx)
})

cat("\u2713 Packages loaded successfully\n\n")

# Set seed for reproducibility
set.seed(42)

# ============================================================================
# CONFIGURATION
# ============================================================================

# Number of grants to generate
NUM_GRANTS <- 15

# Date range for grants
GRANT_START_YEAR <- 2023
GRANT_END_YEAR <- 2025

# ============================================================================
# REFERENCE DATA
# ============================================================================

# Sample organizations
organizations <- c(
  "Legal Aid Society of Metro City",
  "Community Justice Center",
  "Equal Rights Advocacy Group",
  "Family Law Services Coalition",
  "Housing Justice Project",
  "Immigration Legal Services",
  "Youth Justice Initiative",
  "Elder Law Center",
  "Disability Rights Foundation",
  "Consumer Protection Legal Aid",
  "Environmental Justice Alliance",
  "Workers' Rights Legal Clinic",
  "Domestic Violence Legal Support",
  "Veterans Legal Assistance",
  "Civil Liberties Defense Fund"
)

# Focus areas
focus_areas <- c(
  "Housing Rights",
  "Immigration Law",
  "Family Law",
  "Consumer Protection",
  "Employment Law",
  "Disability Rights",
  "Education Rights",
  "Healthcare Access"
)

# Program officers
program_officers <- c(
  "Sarah Johnson",
  "Michael Chen",
  "Jennifer Martinez",
  "David Thompson",
  "Lisa Anderson"
)

# Grant statuses
grant_statuses <- c("Active", "Active", "Active", "Completed", "In Review")

# Report types
report_types <- c("Quarterly", "Mid-Year", "Annual", "Final")

# Visit types
visit_types <- c("Site Visit", "Virtual Check-in", "Program Review")

# Sample activities descriptions
activities_templates <- c(
  "Provided legal consultations to %d clients. Conducted %d workshops on tenant rights. Successfully represented clients in %d cases.",
  "Offered pro bono services to %d low-income families. Held community outreach events reaching %d individuals. Filed %d legal motions.",
  "Assisted %d clients with legal documentation. Provided %d hours of free legal advice. Achieved positive outcomes in %d cases.",
  "Conducted intake interviews with %d new clients. Delivered %d educational seminars. Represented clients in %d court proceedings.",
  "Served %d individuals through direct legal services. Coordinated with %d partner organizations. Successfully resolved %d legal matters."
)

# Sample challenges
challenges_templates <- c(
  "Limited staff capacity during peak demand periods. Increased complexity of cases requiring specialized expertise.",
  "Difficulty reaching rural communities. Translation services needed for non-English speakers.",
  "High client no-show rate for appointments. Funding constraints limiting service hours.",
  "Increased demand for services exceeding capacity. Staff turnover requiring additional training.",
  "Technology barriers preventing virtual service delivery. Documentation requirements creating administrative burden."
)

# Sample observations
observations_templates <- c(
  "Program demonstrates strong community engagement. Staff show high level of expertise and commitment. Office facilities are well-maintained and accessible.",
  "Client satisfaction appears high based on testimonials. Strong partnerships with local organizations. Need for expanded service hours noted.",
  "Impressive case outcomes and client success stories. Effective use of technology for service delivery. Staff could benefit from additional training.",
  "Well-organized case management system in place. Good record-keeping and documentation. Opportunities for increased community outreach.",
  "Strong alignment with grant objectives. Efficient use of funding resources. Potential for program expansion identified."
)

# ============================================================================
# GENERATE BASE GRANT DATA
# ============================================================================

cat("Generating grant records...\n")

grants_base <- data.frame(
  Grant_ID = sprintf("GR-%d-%04d", GRANT_START_YEAR, 1:NUM_GRANTS),
  Organization_Name = sample(organizations, NUM_GRANTS, replace = FALSE),
  Grant_Amount = sample(c(50000, 75000, 100000, 150000, 200000, 250000),
                        NUM_GRANTS, replace = TRUE),
  Grant_Start_Date = as.Date(sprintf("%d-%02d-01",
                                     GRANT_START_YEAR,
                                     sample(1:12, NUM_GRANTS, replace = TRUE))),
  Program_Officer = sample(program_officers, NUM_GRANTS, replace = TRUE),
  Focus_Area = sample(focus_areas, NUM_GRANTS, replace = TRUE),
  Grant_Status = sample(grant_statuses, NUM_GRANTS, replace = TRUE),
  stringsAsFactors = FALSE
)

# Calculate grant end dates (typically 12-24 months)
grants_base$Grant_End_Date <- grants_base$Grant_Start_Date +
  sample(365:730, NUM_GRANTS, replace = TRUE)

cat(sprintf("\u2713 Generated %d grant records\n", NUM_GRANTS))

# ============================================================================
# GENERATE PROGRESS REPORTS
# ============================================================================

cat("Generating progress reports...\n")

# Each grant gets 2-4 progress reports
reports_list <- list()

for (i in 1:nrow(grants_base)) {
  num_reports <- sample(2:4, 1)
  grant_duration <- as.numeric(grants_base$Grant_End_Date[i] -
                                grants_base$Grant_Start_Date[i])

  for (j in 1:num_reports) {
    # Space out reports evenly across grant period
    report_date <- grants_base$Grant_Start_Date[i] +
      (grant_duration / (num_reports + 1)) * j

    # Generate realistic metrics
    clients_served <- sample(20:200, 1)
    workshops <- sample(2:15, 1)
    cases <- sample(5:50, 1)

    report <- data.frame(
      Grant_ID = grants_base$Grant_ID[i],
      Organization_Name = grants_base$Organization_Name[i],
      Grant_Amount = grants_base$Grant_Amount[i],
      Grant_Start_Date = grants_base$Grant_Start_Date[i],
      Grant_End_Date = grants_base$Grant_End_Date[i],
      Program_Officer = grants_base$Program_Officer[i],
      Focus_Area = grants_base$Focus_Area[i],
      Grant_Status = grants_base$Grant_Status[i],

      # Report-specific fields
      Report_Date = report_date,
      Reporting_Period = sprintf("Q%d %d", ((j-1) %% 4) + 1,
                                 as.numeric(format(report_date, "%Y"))),
      Report_Type = sample(report_types, 1),
      Clients_Served = clients_served,
      Activities_Description = sprintf(sample(activities_templates, 1),
                                       clients_served, workshops, cases),
      Challenges_Faced = sample(challenges_templates, 1),
      Budget_Status = sample(c("On Track", "Under Budget", "Over Budget"),
                            1, prob = c(0.6, 0.3, 0.1)),

      # Empty site visit fields
      Site_Visit_Date = as.Date(NA),
      Visit_Type = NA,
      Visitor_Name = NA,
      Visit_Purpose = NA,
      Observations = NA,
      Follow_Up_Required = NA,
      Follow_Up_Notes = NA,

      stringsAsFactors = FALSE
    )

    reports_list[[length(reports_list) + 1]] <- report
  }
}

reports_data <- bind_rows(reports_list)
cat(sprintf("\u2713 Generated %d progress report records\n", nrow(reports_data)))

# ============================================================================
# GENERATE SITE VISITS
# ============================================================================

cat("Generating site visit records...\n")

# Each grant gets 1-2 site visits
visits_list <- list()

for (i in 1:nrow(grants_base)) {
  num_visits <- sample(1:2, 1)
  grant_duration <- as.numeric(grants_base$Grant_End_Date[i] -
                               grants_base$Grant_Start_Date[i])

  for (j in 1:num_visits) {
    # Space out visits across grant period
    visit_date <- grants_base$Grant_Start_Date[i] +
      sample(30:(grant_duration - 30), 1)

    visit <- data.frame(
      Grant_ID = grants_base$Grant_ID[i],
      Organization_Name = grants_base$Organization_Name[i],
      Grant_Amount = grants_base$Grant_Amount[i],
      Grant_Start_Date = grants_base$Grant_Start_Date[i],
      Grant_End_Date = grants_base$Grant_End_Date[i],
      Program_Officer = grants_base$Program_Officer[i],
      Focus_Area = grants_base$Focus_Area[i],
      Grant_Status = grants_base$Grant_Status[i],

      # Empty report fields
      Report_Date = as.Date(NA),
      Reporting_Period = NA,
      Report_Type = NA,
      Clients_Served = NA,
      Activities_Description = NA,
      Challenges_Faced = NA,
      Budget_Status = NA,

      # Site visit-specific fields
      Site_Visit_Date = visit_date,
      Visit_Type = sample(visit_types, 1),
      Visitor_Name = sample(program_officers, 1),
      Visit_Purpose = sample(c(
        "Annual program review",
        "Mid-term evaluation",
        "Technical assistance visit",
        "Compliance check",
        "Partnership development"
      ), 1),
      Observations = sample(observations_templates, 1),
      Follow_Up_Required = sample(c("Yes", "No"), 1, prob = c(0.3, 0.7)),
      Follow_Up_Notes = ifelse(
        sample(c(TRUE, FALSE), 1, prob = c(0.3, 0.7)),
        sample(c(
          "Schedule follow-up training session",
          "Provide additional resources on best practices",
          "Connect with peer organization for collaboration",
          "Review budget allocation in next quarter",
          "No immediate follow-up needed"
        ), 1),
        NA
      ),

      stringsAsFactors = FALSE
    )

    visits_list[[length(visits_list) + 1]] <- visit
  }
}

visits_data <- bind_rows(visits_list)
cat(sprintf("\u2713 Generated %d site visit records\n", nrow(visits_data)))

# ============================================================================
# COMBINE INTO MESSY DENORMALIZED TABLE
# ============================================================================

cat("\nCombining into messy denormalized structure...\n")

# Combine reports and visits
messy_data <- bind_rows(reports_data, visits_data)

# Sort by Grant_ID and date
messy_data <- messy_data %>%
  arrange(Grant_ID,
          coalesce(Report_Date, Site_Visit_Date))

cat(sprintf("\u2713 Created messy table with %d total rows\n", nrow(messy_data)))

# ============================================================================
# CALCULATE AND DISPLAY STATISTICS
# ============================================================================

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("MESSY DATA STRUCTURE ANALYSIS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("PROBLEMS DEMONSTRATED:\n\n")

# Calculate redundancy
unique_grants <- n_distinct(messy_data$Grant_ID)
total_rows <- nrow(messy_data)
redundancy_pct <- (1 - unique_grants/total_rows) * 100

cat(sprintf("1. DATA REDUNDANCY:\n"))
cat(sprintf("   - %d unique grants repeated across %d rows\n",
            unique_grants, total_rows))
cat(sprintf("   - %.1f%% of data is redundant grant information\n",
            redundancy_pct))
cat(sprintf("   - Grant info duplicated an average of %.1f times\n\n",
            total_rows / unique_grants))

# Calculate empty cells
total_cells <- nrow(messy_data) * ncol(messy_data)
empty_cells <- sum(is.na(messy_data))
empty_pct <- (empty_cells / total_cells) * 100

cat(sprintf("2. SPARSE DATA (EMPTY CELLS):\n"))
cat(sprintf("   - %d total cells in table\n", total_cells))
cat(sprintf("   - %d empty/NA cells\n", empty_cells))
cat(sprintf("   - %.1f%% of table is empty\n\n", empty_pct))

cat("3. UPDATE ANOMALIES:\n")
cat("   - Changing a grant amount requires updating multiple rows\n")
cat("   - Risk of inconsistent data if updates miss some rows\n")
cat("   - Example: Grant GR-2023-0001 appears in multiple rows\n\n")

cat("4. INSERT ANOMALIES:\n")
cat("   - Cannot add a new grant without also adding a report or visit\n")
cat("   - Must wait for activity before recording grant award\n\n")

cat("5. DELETE ANOMALIES:\n")
cat("   - Deleting the last report/visit for a grant deletes grant info\n")
cat("   - Risk of losing grant data unintentionally\n\n")

# ============================================================================
# SAVE TO EXCEL FILE
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("SAVING OUTPUT\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Create Excel workbook
wb <- createWorkbook()

# Add messy data sheet
addWorksheet(wb, "Messy Combined Data")
writeData(wb, "Messy Combined Data", messy_data)

# Format the worksheet
setColWidths(wb, "Messy Combined Data", cols = 1:ncol(messy_data), widths = "auto")

# Add a summary sheet
summary_data <- data.frame(
  Metric = c(
    "Total Rows",
    "Total Columns",
    "Unique Grants",
    "Total Reports",
    "Total Visits",
    "Data Redundancy",
    "Empty Cells",
    "Average Reports per Grant",
    "Average Visits per Grant"
  ),
  Value = c(
    nrow(messy_data),
    ncol(messy_data),
    unique_grants,
    sum(!is.na(messy_data$Report_Date)),
    sum(!is.na(messy_data$Site_Visit_Date)),
    sprintf("%.1f%%", redundancy_pct),
    sprintf("%.1f%%", empty_pct),
    sprintf("%.1f", sum(!is.na(messy_data$Report_Date)) / unique_grants),
    sprintf("%.1f", sum(!is.na(messy_data$Site_Visit_Date)) / unique_grants)
  )
)

addWorksheet(wb, "Summary Statistics")
writeData(wb, "Summary Statistics", summary_data)
setColWidths(wb, "Summary Statistics", cols = 1:2, widths = "auto")

# Save file
output_file <- "data/input/MESSY_Grants_Data_Export.xlsx"
saveWorkbook(wb, output_file, overwrite = TRUE)

cat(sprintf("\u2713 Saved messy data to: %s\n\n", output_file))

# ============================================================================
# FINAL SUMMARY
# ============================================================================

cat(paste(rep("=", 80), collapse=""), "\n")
cat("SAMPLE DATA GENERATION COMPLETE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("FILES CREATED:\n")
cat(sprintf("  - %s\n", output_file))
cat("\nCONTENTS:\n")
cat(sprintf("  - %d grants\n", unique_grants))
cat(sprintf("  - %d progress reports\n", sum(!is.na(messy_data$Report_Date))))
cat(sprintf("  - %d site visits\n", sum(!is.na(messy_data$Site_Visit_Date))))
cat(sprintf("  - %d total rows (demonstrating redundancy)\n\n", nrow(messy_data)))

cat("NEXT STEPS:\n")
cat("  1. Review the messy data in Excel\n")
cat("  2. Run scripts/normalize_airtable_data.R to normalize it\n")
cat("  3. Compare the before/after structure\n\n")

cat(paste(rep("=", 80), collapse=""), "\n\n")
