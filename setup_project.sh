#!/bin/bash
read -p "Enter project name: " INPUT
PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive"
cleanup (){
echo ""
echo "Ctrl+C detected. Creating archive..."
tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"
echo "Archive created : ${ARCHIVE_NAME}.tar.gz"
rm -rf "$PROJECT_DIR"
echo "Incomplete folder deleted : $PROJECT_DIR"
exit 1
}
trap cleanup SIGINT
if [ -d "$PROJECT_DIR" ]; then
read -p "Folder already exists. Replace it? (y/n) : " OVERWRITE
if [ "$OVERWRITE" == "y" ]; then
rm -rf "$PROJECT_DIR"
else
echo "Cancelled."
exit 0
fi
fi
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
cat << 'EOF' > "$PROJECT_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
cat << 'EOF' > "$PROJECT_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
cat << 'EOF' > "$PROJECT_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
touch "$PROJECT_DIR/reports/reports.log"
read -p "Update thresholds? (y/n) : " MODIFY
if [[ "$MODIFY" == "y" ]]; then
while true; do
read -p "Warning threshold (default 75) : " NEW_WARNING
if [[ "$NEW_WARNING" =~ ^[0-9]+$ ]]; then
break
else
echo "Invalid input. Please enter a number."
fi
done
while true; do
read -p "Failure threshold (default 50) : " NEW_FAILURE
if [[ "$NEW_FAILURE" =~ ^[0-9]+$ ]]; then
break
else
echo "Invalid input. Please enter a number."
fi
done
sed -i "s/\"warning\": [0-9]*/\"warning\": $NEW_WARNING/" "$PROJECT_DIR/Helpers/config.json"
sed -i "s/\"failure\": [0-9]*/\"failure\": $NEW_FAILURE/" "$PROJECT_DIR/Helpers/config.json"
echo "Warning threshold set to : $NEW_WARNING%"
echo "Failure threshold set to : $NEW_FAILURE%"
fi
if python3 --version &>/dev/null; then
echo "Python3 is installed: $(python3 --version)"
else
echo "Python3 is not installed"
fi
echo "Checking project structure..."
for FILE in "$PROJECT_DIR/attendance_checker.py" "$PROJECT_DIR/Helpers/assets.csv" "$PROJECT_DIR/Helpers/config.json" "$PROJECT_DIR/reports/reports.log"; do
if [ -e "$FILE" ]; then
echo "OK : $FILE"
else
echo "MISSING : $FILE"
fi
done
echo "Setup complete : $PROJECT_DIR"
