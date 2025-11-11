# Airtable Setup Guide

This guide provides detailed instructions for setting up Airtable to work with the database normalization scripts.

## Table of Contents

1. [Airtable Account Setup](#airtable-account-setup)
2. [Creating Your Base](#creating-your-base)
3. [Table Structure](#table-structure)
4. [API Configuration](#api-configuration)
5. [Field Type Configuration](#field-type-configuration)
6. [Linked Records Setup](#linked-records-setup)
7. [Testing the Connection](#testing-the-connection)
8. [Security Best Practices](#security-best-practices)

---

## Airtable Account Setup

### 1. Create an Airtable Account

1. Visit https://airtable.com
2. Click "Sign up for free"
3. Choose a plan:
   - **Free**: Up to 1,200 records per base (suitable for testing)
   - **Plus**: 5,000 records per base
   - **Pro**: 50,000 records per base
   - **Enterprise**: Unlimited records

4. Verify your email address
5. Complete the onboarding wizard

### 2. Understand Airtable Terminology

- **Base**: A database (equivalent to an Excel workbook)
- **Table**: A collection of records (like a spreadsheet tab)
- **Field**: A column in a table
- **Record**: A row in a table
- **View**: A filtered/sorted display of records

---

## Creating Your Base

### Option 1: Create New Base from Scratch

1. **Log in to Airtable**
   - Go to https://airtable.com
   - Click "Sign in"

2. **Create Base**
   - Click "+ Add a base" or "Create a base"
   - Choose "Start from scratch"
   - Name it: "Foundation Grants Data" (or your preferred name)
   - Choose an icon and color (optional)

3. **Note Your Base ID**
   - Open your base
   - Look at the URL: `https://airtable.com/[BASE_ID]/...`
   - Copy the BASE_ID (starts with "app")
   - Save it for later configuration

### Option 2: Use Existing Base

If you already have grant data in Airtable:

1. Open your existing base
2. Note the BASE_ID from the URL
3. Ensure you have a table with messy/denormalized data
4. Create three new tables for normalized output (see below)

---

## Table Structure

You need to create **FOUR** tables in your Airtable base:

### 1. Source Table: "Foundation Grants Data"

This table contains your messy, denormalized data.

**Required Fields** (as single-line text unless specified):

| Field Name | Type | Description |
|------------|------|-------------|
| Grant_ID | Single line text | Unique grant identifier |
| Organization_Name | Single line text | Grantee organization name |
| Grant_Amount | Currency | Grant amount in dollars |
| Grant_Start_Date | Date | Grant start date |
| Grant_End_Date | Date | Grant end date |
| Program_Officer | Single line text | Assigned program officer |
| Focus_Area | Single select | Grant focus area |
| Grant_Status | Single select | Active, Completed, etc. |
| Report_Date | Date | Progress report date (may be empty) |
| Reporting_Period | Single line text | Q1 2023, etc. (may be empty) |
| Report_Type | Single select | Quarterly, Annual, etc. |
| Clients_Served | Number | Number of clients (may be empty) |
| Activities_Description | Long text | Description of activities |
| Challenges_Faced | Long text | Challenges encountered |
| Budget_Status | Single select | On Track, Over Budget, etc. |
| Site_Visit_Date | Date | Visit date (may be empty) |
| Visit_Type | Single select | Site Visit, Virtual, etc. |
| Visitor_Name | Single line text | Name of visitor |
| Visit_Purpose | Long text | Purpose of visit |
| Observations | Long text | Observations from visit |
| Follow_Up_Required | Checkbox | Yes/No for follow-up |
| Follow_Up_Notes | Long text | Follow-up action items |

**To Create These Fields:**

1. Click on the table
2. Click "+" to add a new field
3. Choose the appropriate field type
4. Name the field exactly as shown above
5. Repeat for all fields

### 2. Target Table: "Grants"

This will store normalized grant data.

**Required Fields:**

| Field Name | Type | Description |
|------------|------|-------------|
| Grant_ID | Single line text | Primary key |
| Organization_Name | Single line text | Grantee name |
| Grant_Amount | Currency | Grant amount |
| Grant_Start_Date | Date | Start date |
| Grant_End_Date | Date | End date |
| Program_Officer | Single line text | Program officer |
| Focus_Area | Single select | Focus area |
| Grant_Status | Single select | Status |

**To Create This Table:**

1. Click "Add or import" → "Create empty table"
2. Name it "Grants"
3. Add fields as listed above
4. Delete the default "Name" field if not needed

### 3. Target Table: "Progress_Reports"

This will store progress report data.

**Required Fields:**

| Field Name | Type | Description |
|------------|------|-------------|
| Report_ID | Single line text | Primary key |
| Grant_ID | Single line text | Foreign key to Grants |
| Report_Date | Date | Report date |
| Reporting_Period | Single line text | Reporting period |
| Report_Type | Single select | Report type |
| Clients_Served | Number | Clients served |
| Activities_Description | Long text | Activities |
| Challenges_Faced | Long text | Challenges |
| Budget_Status | Single select | Budget status |

### 4. Target Table: "Site_Visits"

This will store site visit data.

**Required Fields:**

| Field Name | Type | Description |
|------------|------|-------------|
| Visit_ID | Single line text | Primary key |
| Grant_ID | Single line text | Foreign key to Grants |
| Site_Visit_Date | Date | Visit date |
| Visit_Type | Single select | Visit type |
| Visitor_Name | Single line text | Visitor name |
| Visit_Purpose | Long text | Purpose |
| Observations | Long text | Observations |
| Follow_Up_Required | Checkbox | Follow-up needed |
| Follow_Up_Notes | Long text | Follow-up notes |

---

## API Configuration

### 1. Generate Personal Access Token

Airtable uses Personal Access Tokens (PAT) for API authentication.

**Steps:**

1. **Navigate to Account Settings**
   - Click your profile icon (top right)
   - Select "Account"
   - Or visit: https://airtable.com/create/tokens

2. **Create New Token**
   - Click "Generate new token" or "Create new token"
   - Name it: "Foundation Grants Normalization"
   - Set description: "API access for R normalization scripts"

3. **Add Scopes**

   Select these scopes (permissions):
   - `data.records:read` - Read records from tables
   - `data.records:write` - Create/update records
   - `schema.bases:read` - Read base schema

4. **Add Access to Specific Base**
   - Under "Access", click "Add a base"
   - Select your "Foundation Grants Data" base
   - This restricts the token to only this base (recommended)

5. **Create Token**
   - Click "Create token"
   - **IMPORTANT**: Copy the token immediately
   - You won't be able to see it again!
   - It will look like: `patXxXxXxXxXxXxXxXx.xxxxxxxxxxxxxxxxxxxxxx`

6. **Store Token Securely**
   ```bash
   # Save to .env file
   echo "AIRTABLE_API_KEY=patXxXxXxXxXxXxXxXx.xxxxxxxxxxxxxxxxxxxxxx" >> .env
   ```

### 2. Configure Base ID

1. **Find Base ID**
   - Open your Airtable base
   - Look at the URL: `https://airtable.com/[BASE_ID]/...`
   - Copy the BASE_ID (e.g., `appXxXxXxXxXxXxXx`)

2. **Add to Configuration**
   ```bash
   # Add to .env file
   echo "AIRTABLE_BASE_ID=appXxXxXxXxXxXxXx" >> .env
   ```

### 3. Complete .env File

Your `.env` file should look like this:

```bash
# Airtable API Configuration
AIRTABLE_API_KEY=patXxXxXxXxXxXxXxXx.xxxxxxxxxxxxxxxxxxxxxx
AIRTABLE_BASE_ID=appXxXxXxXxXxXxXx

# Table Names (must match exactly!)
SOURCE_TABLE_NAME=Foundation Grants Data
TARGET_GRANTS_TABLE=Grants
TARGET_REPORTS_TABLE=Progress_Reports
TARGET_VISITS_TABLE=Site_Visits

# Optional Settings
DEBUG_MODE=FALSE
BACKUP_BEFORE_WRITE=TRUE
MAX_API_RETRIES=3
```

---

## Field Type Configuration

### Recommended Field Types

For optimal performance and data integrity:

#### Text Fields
- **Single line text**: Short text (< 100 characters)
  - Grant_ID, Organization_Name, Program_Officer, etc.

- **Long text**: Multi-line text, descriptions
  - Activities_Description, Challenges_Faced, Observations, etc.

#### Numeric Fields
- **Number**: Integer or decimal
  - Clients_Served (integer, no decimals)

- **Currency**: Monetary values
  - Grant_Amount (USD, 2 decimals)

#### Date Fields
- **Date**: Date only (no time)
  - Grant_Start_Date, Grant_End_Date, Report_Date, Site_Visit_Date

#### Selection Fields
- **Single select**: One option from dropdown
  - Focus_Area, Grant_Status, Report_Type, Visit_Type, Budget_Status

- **Multiple select**: Multiple options (not used in this project)

#### Boolean Fields
- **Checkbox**: Yes/No
  - Follow_Up_Required

### Creating Field Types in Airtable

1. Click field header dropdown (▼)
2. Select "Customize field type"
3. Choose appropriate type
4. Configure options (for Single select fields)
5. Click "Save"

### Single Select Options

Configure these options for single select fields:

**Focus_Area:**
- Housing Rights
- Immigration Law
- Family Law
- Consumer Protection
- Employment Law
- Disability Rights
- Education Rights
- Healthcare Access

**Grant_Status:**
- Active
- Completed
- In Review
- On Hold
- Cancelled

**Report_Type:**
- Quarterly
- Mid-Year
- Annual
- Final

**Visit_Type:**
- Site Visit
- Virtual Check-in
- Program Review

**Budget_Status:**
- On Track
- Under Budget
- Over Budget

---

## Linked Records Setup

After running the normalization script, enhance your Airtable base with linked records:

### 1. Link Progress_Reports to Grants

1. **Open Progress_Reports table**
2. **Add new field** (click "+")
3. **Choose "Link to another record"**
4. **Select "Grants" table**
5. **Name field**: "Grant" (or keep "Grants")
6. **Configure**:
   - ✓ Allow linking to multiple records: NO
   - ✓ Limit record selection to a view: (optional)
7. **Click "Create field"**

8. **Manually link records** (one-time setup):
   - Click in a cell in the new "Grant" column
   - Search for matching Grant_ID
   - Select the corresponding grant
   - Repeat for all reports

   OR use the existing Grant_ID text field for reference

### 2. Link Site_Visits to Grants

Follow the same process:

1. Add "Link to another record" field in Site_Visits table
2. Link to Grants table
3. Manually link each visit to its grant

### 3. Create Rollup Fields

In the **Grants** table, add summary fields:

**Total Reports Count:**
1. Add new field → Rollup
2. Choose linked field: (Progress_Reports link field)
3. Rollup field: Record ID (any field)
4. Aggregation: COUNT()

**Total Visits Count:**
1. Add new field → Rollup
2. Choose linked field: (Site_Visits link field)
3. Rollup field: Record ID
4. Aggregation: COUNT()

**Total Clients Served:**
1. Add new field → Rollup
2. Choose linked field: (Progress_Reports link field)
3. Rollup field: Clients_Served
4. Aggregation: SUM()

---

## Testing the Connection

### Test Script

Create a test R script to verify your API connection:

```r
# test_airtable_connection.R

# Load configuration
source("config/config.R")

# Check if API is configured
if (!API_CONFIGURED) {
  stop("API credentials not configured. Please check your .env file.")
}

# Test API connection
library(httr)

# Make a simple API request
url <- sprintf("%s/%s?maxRecords=1", API_BASE_URL, URLencode(SOURCE_TABLE_NAME))

response <- GET(url, API_HEADERS)

# Check response
if (status_code(response) == 200) {
  cat("✓ SUCCESS: Connected to Airtable API\n")
  cat(sprintf("✓ Base ID: %s\n", AIRTABLE_BASE_ID))
  cat(sprintf("✓ Table: %s\n", SOURCE_TABLE_NAME))

  data <- content(response, "parsed")
  cat(sprintf("✓ Records found: %d\n", length(data$records)))

} else {
  cat("✗ FAILED: API connection error\n")
  cat(sprintf("Status code: %d\n", status_code(response)))
  cat(sprintf("Error: %s\n", content(response, "text")))
}
```

### Run Test

```r
source("test_airtable_connection.R")
```

Expected output:
```
✓ SUCCESS: Connected to Airtable API
✓ Base ID: appXxXxXxXxXxXxXx
✓ Table: Foundation Grants Data
✓ Records found: 1
```

### Common Connection Errors

| Error Code | Meaning | Solution |
|------------|---------|----------|
| 401 | Unauthorized | Check API key in .env |
| 403 | Forbidden | Verify token has correct scopes |
| 404 | Not Found | Check Base ID and table name |
| 429 | Rate Limited | Wait and retry (script handles this) |
| 503 | Service Unavailable | Airtable is down, try later |

---

## Security Best Practices

### 1. Protect Your API Token

✅ **DO:**
- Store in .env file (gitignored)
- Use environment variables
- Rotate tokens regularly (every 90 days)
- Create token with minimal scopes
- Restrict token to specific bases

❌ **DON'T:**
- Commit to Git
- Share in email or chat
- Use in client-side code
- Give full account access
- Reuse across projects

### 2. Token Rotation

Every 90 days:

1. Generate new token
2. Update .env file
3. Test connection
4. Revoke old token

### 3. Access Control

- Use Airtable workspace permissions
- Limit collaborator access
- Review audit logs regularly
- Enable 2FA on Airtable account

### 4. Data Backup

Before running scripts:

1. **Export base to CSV**
   - Click base menu (▼) → "Data" → "Download CSV"
   - Save with timestamp

2. **Use Airtable snapshots**
   - Enterprise plan feature
   - Automatic daily backups

3. **Enable backup in scripts**
   ```bash
   # In .env
   BACKUP_BEFORE_WRITE=TRUE
   ```

---

## Troubleshooting

### Issue: "Invalid authentication token"

**Causes:**
- Token copied incorrectly
- Token revoked or expired
- Wrong token type (not Personal Access Token)

**Solutions:**
1. Regenerate token at https://airtable.com/create/tokens
2. Copy entire token (starts with "pat")
3. Update .env file
4. Restart R session

### Issue: "Table not found"

**Causes:**
- Table name mismatch
- Extra spaces in table name
- Table in different base

**Solutions:**
1. Check exact table name in Airtable
2. Update SOURCE_TABLE_NAME in .env
3. Verify BASE_ID is correct

### Issue: "Field type mismatch"

**Causes:**
- Field is different type than expected
- Missing field
- Field renamed

**Solutions:**
1. Verify all fields exist in table
2. Check field types match specifications
3. Check field names are exact (case-sensitive)

### Issue: "Rate limit exceeded"

**Causes:**
- Too many API requests
- Running multiple scripts simultaneously

**Solutions:**
1. Wait 30 seconds and retry
2. Script includes rate limiting (0.21s between requests)
3. Reduce batch size in config

---

## Next Steps

After completing Airtable setup:

1. ✅ Verify all four tables exist
2. ✅ Verify API token works (run test script)
3. ✅ Configure .env file
4. ✅ Load sample data into source table (optional)
5. ✅ Run normalization script
6. ✅ Review output in target tables
7. ✅ Set up linked records
8. ✅ Create views and filters

---

## Additional Resources

- **Airtable API Documentation**: https://airtable.com/developers/web/api/introduction
- **Personal Access Tokens**: https://airtable.com/developers/web/guides/personal-access-tokens
- **Rate Limits**: https://airtable.com/developers/web/api/rate-limits
- **Field Types**: https://support.airtable.com/docs/field-types-overview

---

**Last Updated**: November 2025
**For Questions**: See main [README.md](../README.md)
