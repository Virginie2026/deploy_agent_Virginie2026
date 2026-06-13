#!/bin/bash
read -p "Enter project name: " INPUT
PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive"
cleanup (){
tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"
rm -rf "$PROJECT_DIR"
exit 1
}
trap cleanup SIGINT
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
cp attendance_checker.py "$PROJECT_DIR/attendance_checker.py"
cp assets.csv "$PROJECT_DIR/Helpers/assets.csv"
cp config.json "$PROJECT_DIR/Helpers/config.json"
cp reports.log "$PROJECT_DIR/reports/reports.log"
read -p "Update thresholds? (y/n) : " MODIFY
if [[ "$MODIFY" == "y" ]]; then
read -p "Warning threshold (default 75) : " NEW_WARNING
read -p "Failure threshold (default 50): " NEW_FAILURE
sed -i "s/\"warning\": [0-9]*/\"warning\": $NEW_WARNING/" "$PROJECT_DIR/Helpers/config.json"
sed -i "s/\"failure\": [0-9]*/\"failure\": $NEW_FAILURE/" "$PROJECT_DIR/Helpers/config.json"
fi
if python3 --version &>/dev/null; then
echo "Python3 is installed"
else
echo "Python3 is not installed"
fi
echo "Setup complete : $PROJECT_DIR"

