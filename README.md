# Airtable Database Normalization Project

A comprehensive R-based solution for extracting, normalizing, and restructuring foundation grant data from Airtable. This project demonstrates best practices in database normalization, data quality validation, and API integration.

## Overview

This project transforms messy, denormalized grant data (where grant information is repeated across multiple rows) into a properly normalized database structure with three distinct tables:

1. **Grants Table** - Core grant information (stored once)
2. **Progress Reports Table** - Linked to grants via Grant_ID
3. **Site Visits Table** - Linked to grants via Grant_ID

### The Problem

Many organizations store data in a single table where:
- Grant information is duplicated across every progress report and site visit row
- 70-80% of data is redundant
- Updates must be made in multiple places (update anomalies)
- Deleting the last report can delete grant information (delete anomalies)
- Cannot add a grant without also adding a report or visit (insert anomalies)

### The Solution

This project provides automated scripts to:
1. Extract messy data from Airtable (or local Excel files)
2. Normalize it into properly structured tables
3. Validate data integrity and referential constraints
4. Write normalized data back to Airtable
5. Reduce data redundancy by 70-80%

## Key Features

- **Complete ETL Pipeline**: Extract, Transform, Load workflow for Airtable data
- **Data Quality Validation**: Checks for referential integrity, primary key uniqueness, and completeness
- **Flexible Configuration**: Environment-based configuration for different environments
- **Demo Mode**: Works with local Excel files when Airtable API is not configured
- **Comprehensive Documentation**: Setup guides, API documentation, and inline code comments
- **Production Ready**: Rate limiting, error handling, and batch processing built-in

## Project Structure

```
Foundation-Grants-Data-Airtable/
├── README.md                           # This file
├── requirements.R                      # Package dependency installer
├── .env.example                        # Environment variable template
├── .gitignore                          # Git ignore rules
│
├── config/
│   └── config.R                        # Centralized configuration
│
├── scripts/
│   ├── generate_sample_data.R          # Generate demo messy data
│   └── normalize_airtable_data.R       # Main normalization script
│
├── data/
│   ├── input/                          # Source data files
│   │   └── MESSY_Grants_Data_Export.xlsx
│   └── output/                         # Normalized output files
│       └── NORMALIZED_Output.xlsx
│
└── docs/
    ├── SETUP_GUIDE.md                  # Detailed setup instructions
    └── AIRTABLE_SETUP.md               # Airtable-specific configuration
```

## Quick Start

### Prerequisites

- R version 4.0 or higher
- RStudio (recommended but not required)
- Airtable account with API access (optional for demo mode)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Foundation-Grants-Data-Airtable.git
   cd Foundation-Grants-Data-Airtable
   ```

2. **Install required R packages**
   ```r
   source("requirements.R")
   ```

3. **Configure environment variables** (optional for demo mode)
   ```bash
   cp .env.example .env
   # Edit .env with your Airtable credentials
   ```

### Demo Mode (No Airtable Account Required)

1. **Generate sample messy data**
   ```r
   Rscript scripts/generate_sample_data.R
   ```
   This creates `data/input/MESSY_Grants_Data_Export.xlsx` with realistic sample data.

2. **Run normalization**
   ```r
   Rscript scripts/normalize_airtable_data.R
   ```
   This creates `data/output/NORMALIZED_Output.xlsx` with three normalized tables.

### Production Mode (With Airtable)

1. **Set up Airtable** (see [AIRTABLE_SETUP.md](docs/AIRTABLE_SETUP.md))
   - Create a new base or use existing one
   - Create source table with messy data
   - Create three target tables for normalized data
   - Generate API key

2. **Configure credentials**
   ```bash
   # Edit .env file with your actual credentials
   AIRTABLE_API_KEY=your_api_key_here
   AIRTABLE_BASE_ID=your_base_id_here
   ```

3. **Run normalization**
   ```r
   Rscript scripts/normalize_airtable_data.R
   ```

## Usage Examples

### Generate Sample Data

```r
# Generate 15 grants with reports and visits
source("scripts/generate_sample_data.R")

# Output:
# - data/input/MESSY_Grants_Data_Export.xlsx
# - Summary statistics and data quality analysis
```

### Normalize Existing Data

```r
# Normalize data from Airtable or local file
source("scripts/normalize_airtable_data.R")

# The script will:
# 1. Extract data from source
# 2. Create three normalized tables
# 3. Validate data integrity
# 4. Write to Airtable or local Excel file
# 5. Generate summary report
```

### Using Configuration

```r
# Load centralized configuration
source("config/config.R")

# Print configuration summary
print_config()

# Access configuration values
config <- get_config()
print(config$api_configured)
```

## Data Model

### Before Normalization (Messy Structure)

Single table with 50+ rows containing:
- Grant info repeated in every row
- Many empty cells (70-80% sparse)
- Mixed entity types (grants, reports, visits)

### After Normalization

**Grants Table** (15 rows)
```
Grant_ID | Organization_Name | Grant_Amount | Grant_Start_Date | ...
---------|-------------------|--------------|------------------|----
GR-2023-0001 | Legal Aid Society | 150000 | 2023-01-15 | ...
```

**Progress_Reports Table** (40 rows)
```
Report_ID | Grant_ID | Report_Date | Clients_Served | ...
----------|----------|-------------|----------------|----
RPT-2023-0001-0001 | GR-2023-0001 | 2023-04-15 | 125 | ...
```

**Site_Visits Table** (20 rows)
```
Visit_ID | Grant_ID | Site_Visit_Date | Visitor_Name | ...
---------|----------|-----------------|--------------|----
VST-2023-0001-0001 | GR-2023-0001 | 2023-06-10 | Sarah Johnson | ...
```

## Benefits of Normalization

1. **Eliminate Redundancy**: Grant data stored once instead of 50+ times
2. **Data Integrity**: Single source of truth for each grant
3. **Easier Updates**: Change grant amount in one place
4. **Better Queries**: Efficient filtering and aggregation
5. **Scalability**: Add thousands of reports without data duplication
6. **Referential Integrity**: All reports and visits link to valid grants

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Required for Airtable integration
AIRTABLE_API_KEY=your_api_key_here
AIRTABLE_BASE_ID=your_base_id_here

# Table names (customize as needed)
SOURCE_TABLE_NAME=raw-grants-data
TARGET_GRANTS_TABLE=Grants
TARGET_REPORTS_TABLE=Progress_Reports
TARGET_VISITS_TABLE=Site_Visits

# Optional settings
DEBUG_MODE=FALSE
BACKUP_BEFORE_WRITE=TRUE
MAX_API_RETRIES=3
```

### Centralized Configuration

All configuration is managed in `config/config.R`:

```r
source("config/config.R")

# Configuration is automatically loaded
# Access via:
# - Direct variables: AIRTABLE_API_KEY, TARGET_GRANTS_TABLE, etc.
# - Config list: get_config()
```

## Data Validation

The normalization script includes comprehensive validation:

### 1. Referential Integrity
- All Progress Reports link to valid Grants
- All Site Visits link to valid Grants
- No orphaned records

### 2. Primary Key Uniqueness
- Each Grant has unique Grant_ID
- Each Report has unique Report_ID
- Each Visit has unique Visit_ID

### 3. Data Completeness
- % of grants with organization names
- % of reports with activity descriptions
- % of visits with observations

## API Integration

### Airtable API Features

- **Rate Limiting**: Respects 5 requests/second limit
- **Pagination**: Handles large datasets automatically
- **Batch Processing**: Writes in batches of 10 records
- **Error Handling**: Graceful failure with descriptive messages

### API Usage Examples

```r
# Extract from Airtable
data <- extract_from_airtable("raw-grants-data")

# Write to Airtable
write_to_airtable(grants_df, "Grants")

# Delete records (use with caution!)
delete_all_records("Old_Table")
```

## Troubleshooting

### Common Issues

1. **"API Error: 401"** - Invalid API key
   - Check your `AIRTABLE_API_KEY` in `.env`
   - Generate new key at https://airtable.com/create/tokens

2. **"Table not found"** - Table name mismatch
   - Verify table names in Airtable match `.env` settings
   - Check for extra spaces in table names

3. **"Package not found"** - Missing dependencies
   - Run `source("requirements.R")` to install packages

4. **Rate limit errors** - Too many API requests
   - Script includes rate limiting (0.21s between requests)
   - Wait a few minutes and retry
   
5. **Unknown field name** - Variable name (e.g. column name or field name) not found in new table
  - New table being created may include the variable in R but may be missing in Airtable
  - Refer to Airtable table, manage fields, and manually create missing field

### Getting Help

- See [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed installation
- See [AIRTABLE_SETUP.md](docs/AIRTABLE_SETUP.md) for API configuration
- Check inline code comments in scripts
- Review Airtable API docs: https://airtable.com/developers/web/api/introduction

## Performance

- **Small datasets** (< 100 grants): ~30 seconds
- **Medium datasets** (100-1000 grants): 2-5 minutes
- **Large datasets** (1000+ grants): 10-30 minutes

Performance depends on:
- Number of records
- Network speed (for Airtable API)
- API rate limiting
- Computer specifications

## Best Practices

1. **Backup Before Operations**
   - Always backup Airtable base before running scripts
   - Enable `BACKUP_BEFORE_WRITE=TRUE` in `.env`

2. **Test with Sample Data First**
   - Use `generate_sample_data.R` to test workflow
   - Validate output before processing real data

3. **Incremental Updates**
   - For ongoing use, modify scripts for incremental updates
   - Track last sync timestamp
   - Update only changed records

4. **Security**
   - Never commit `.env` file to version control
   - Use environment variables for credentials
   - Rotate API keys regularly

5. **Data Quality**
   - Review validation results
   - Investigate any failed integrity checks
   - Clean source data before normalization

## Contributing

This project was created for a philanthropic foundation as part of an effort to streamline their data management and strategic grantmaking process. The data found in this repository has been deidentified and all organizational and individual names are fictitious to ensure confidentiality. The repository was duplicated for an RFP response demonstrating database normalization expertise.

## License

[Specify license here]

## Contact

For questions or support:
- **Author**: Plot + Learn
- **Date**: November 2025
- **Purpose**: Database Normalization Demonstration

## Acknowledgments

- Built with R and the tidyverse
- Airtable API documentation
- Database normalization theory (3NF)

---

**Note**: This project demonstrates professional data engineering practices including:
- Database normalization (3rd Normal Form)
- ETL pipeline development
- API integration
- Data quality validation
- Production-ready code with error handling
- Comprehensive documentation
