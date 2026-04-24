# Scripts for Creating 2025-2026 Open School Checklist

This directory contains scripts to create recurring processes for the "Open School Checklist" workflow for the 2025-2026 school year.

## Scripts

### `create_2025_2026_osc_items.rb`

This script creates 2025-2026 Open School Checklist items by finding existing workflow instances and initializing them using the `Workflow::InitializeWorkflowJob`.

**Usage:**

```bash
rails runner scripts/create_2025_2026_osc_items.rb
```

**Features:**

- Finds the "Open School Checklist" workflow definition
- Iterates through existing workflow instances
- Uses background jobs to initialize each workflow instance
- Leverages the existing `Workflow::Initialize` service for proper workflow creation

## What This Script Does

1. **Find the Workflow Definition**: Locates the "Open School Checklist" workflow definition in the database
2. **Process Existing Instances**: Iterates through all existing workflow instances
3. **Background Job Processing**: Queues `Workflow::InitializeWorkflowJob` for each instance to handle the initialization asynchronously
4. **Proper Workflow Creation**: Uses the established workflow initialization service for consistent behavior

## Safety Features

- **Uses Existing Service**: Leverages the proven `Workflow::Initialize` service
- **Background Processing**: Handles initialization asynchronously to avoid blocking
- **Idempotent**: The underlying service prevents duplicate creation
- **Error Handling**: Built-in error handling from the workflow initialization service

## Prerequisites

- The "Open School Checklist" workflow definition must exist in the database
- The workflow should have processes marked as recurring with `due_months` specified
- The `DateCalculator` should be properly configured for 2025-2026

## Troubleshooting

If you encounter errors:

1. **Workflow not found**: Ensure the workflow definition exists with the exact title "Open School Checklist"
2. **Permission errors**: Make sure you have the necessary database permissions
3. **Job queue issues**: Check that your background job processor is running

## Running in Production

⚠️ **Warning**: This script creates new database records. Always test in a development/staging environment first.

For production use:

1. Test thoroughly in staging
2. Backup the database before running
3. Run during low-traffic periods
4. Monitor the job queue for any failed jobs
5. Check the logs for any initialization errors

## How to run for 2026-2027 School Year
1. Update places in code where school year is hardcoded to 2025-2026
2. Commit code changes to main branch
3. Open PR to merge main to dev. Merge in.
4. Open PR to merge dev to staging. Merge in.
5. Open PR to merge staging to production. Merge in.
6. Deploy code to production via Render (make sure to do both api and worker)
7. SSH into the production server via Render
8. Via rails console, run the script

