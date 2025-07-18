# MySQL Automated Backup to Google Cloud Storage

This script automates the backup of MySQL databases and uploads the compressed backup to **Google Cloud Storage (GCS)**. It also sends a log email and cleans up old backups based on a retention policy.
## 📊 Large-Scale Database Support

This script supports backing up **100+ MySQL databases**. To improve performance and reliability:

- Uses a loop to individually dump each database.
- Skips system databases like `information_schema`, `performance_schema`, etc.
- For high-performance environments:
  - Consider **parallel dumping** (requires high CPU/disk I/O).
  - Use `--single-transaction` to minimize locking (InnoDB only).
- Output is individually stored per database to aid in debugging or restoring specific databases.
- Each database's backup status is logged for traceability.

> 💡 Note: Make sure your storage volume has enough space before running the script. Compressed `.zip` files help reduce total storage usage.

## 📌 Features

- Dumps all MySQL databases except system ones (`mysql`, `sys`, etc.)
- Compresses the backup
- Uploads to Google Cloud Storage
- Retains backups for a defined number of days
- Sends a backup status log via email
- Custom connection logic (start/revoke hooks)

## 🛠️ Requirements

- `bash` (Linux/Unix-based system)
- MySQL client tools (`mysql`, `mysqldump`)
- `gcloud` CLI installed and configured
- `gsutil` CLI (comes with `gcloud`)
- A GCP Service Account with `Storage Object Admin` role
- Mail command-line utility (`mail`, `mailx`, etc.)
- Permissions to execute the script and access GCS

## 🔐 Google Cloud Setup

1. Create a service account in your GCP project.
2. Grant it the `Storage Object Admin` role.
3. Generate a **JSON key** for the account.
4. Download the JSON key and save it to the server.
5. Make sure your GCS bucket exists and is accessible by the service account.

## 🧾 Script Configuration

Edit the script variables:

```bash
USER="your_mysql_username"
PASSWORD="your_mysql_password"
BACKUP_DIR="/absolute/path/to/backup/directory"
DAYS_TO_KEEP=180

BUCKET_NAME="your_gcs_bucket_name"
JSON_KEY_FILE="/absolute/path/to/your-key-file.json"

START_CONNECTION_COMMAND="command_to_start_connection"
REVOKE_CONNECTION_COMMAND="command_to_revoke_connection"

EMAIL="you@example.com"
