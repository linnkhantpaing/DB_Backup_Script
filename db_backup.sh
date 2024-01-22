#!/bin/bash

# MySQL Database Credentials
USER="DB_Username"
PASSWORD="DB_Password"

# Backup Configuration
BACKUP_DIR="path to directory"  # Main backup directory
DAYS_TO_KEEP=180               # Retention period in days (delete backups older than this)
DATE=$(date +%Y-%m-%d)         # Current date

# Log Configuration
LOG_FILE="$BACKUP_DIR/backup_log.txt"

# Google Cloud Storage Configuration
BUCKET_NAME="Google_cloud Bucket Name"
JSON_KEY_FILE="server path to directory/Google_cloud Bucket Name.json"  # Path to your JSON key file

# Connection Process Configuration
START_CONNECTION_COMMAND="command_to_start_connection"
REVOKE_CONNECTION_COMMAND="command_to_revoke_connection"

# Create a subdirectory with the current date
BACKUP_PATH="$BACKUP_DIR/$DATE"
mkdir -p "$BACKUP_PATH"

# Redirect all script output to the log file
exec &> "$LOG_FILE"

# Function to start connection process
start_connection() {
    echo "Starting connection process......."
    eval "$START_CONNECTION_COMMAND"
}

# Function to revoke connection process
revoke_connection() {
    echo "Revoking connection process......."
    eval "$REVOKE_CONNECTION_COMMAND"
}

# Trap signals to ensure connection processes are properly started and revoked
trap 'revoke_connection; exit 1' SIGHUP SIGINT SIGTERM
trap 'revoke_connection; exit 0' EXIT

# Start connection process
start_connection

# Authenticate with Google Cloud using JSON key file
gcloud auth activate-service-account --key-file="$JSON_KEY_FILE"

# Get list of database names
databases=$(mysql -u$USER -p$PASSWORD -e "SHOW DATABASES;" | awk '{if(NR>1)print}' | grep -Ev "(information_schema|performance_schema|mysql|sys)")

# Backup each database
for db in $databases; do
    echo "Backing up database: $db"
    mysqldump -u$USER -p$PASSWORD --databases "$db" > "$BACKUP_PATH/$db.sql"
done

   echo "Start Zipping Database backup file"
# Zip the backup directory
zip -r "$BACKUP_DIR/$DATE.zip" "$BACKUP_PATH"
   echo "##########Successfully finished zipping##########"

# Upload backup zip file to Google Cloud Storage
gsutil -o "GSUtil:state_dir=$HOME/gsutil" cp "$BACKUP_DIR/$DATE.zip" "gs://$BUCKET_NAME/$DATE.zip"
echo "#####Backup and upload to Google Cloud Storage completed successfully#####"

# Remove backups older than specified retention period
#find "$BACKUP_PATH" -type d -mtime +$DAYS_TO_KEEP -exec rm -r {} \;
echo "#######Backup processes completed successfully#######"

# Send email with log file
echo "Database Backup processes are completed. Please check in attached." | mail -s "MySQL Backup Log" -a "$LOG_FILE" Email_Address

echo "#####Backup and email sending completed successfully#####"

