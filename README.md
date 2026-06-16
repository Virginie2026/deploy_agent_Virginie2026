# deploy_agent_Virginie2026

## Project Description

This project is a bash script that automates the setup of a workspace
for a Student Attendance Tracker application. Instead of manually
creating folders, copying files, and editing configuration values one
by one, the script setup_project.sh does all of this automatically
in a few seconds.

This follows the principle of Infrastructure as Code (IaC):
- Reproducibility: every time the script runs, it creates the exact
  same folder structure.
- Efficiency: a setup that would take several minutes by hand is done
  in seconds.
- Reliability: removes human errors like typos in folder names or
  forgetting to copy a file.
## How the script works

### 1. Asking for a project name
The script uses the `read` command to ask the user for an identifier.
This value is stored in a variable called INPUT, and is used to build
the name of the main folder: attendance_tracker_${INPUT}.

Example: if I type "v1", the script creates a folder called
attendance_tracker_v1.

### 2. Checking if the folder already exists
Before creating anything, the script checks with
"if [ -d "$PROJECT_DIR" ]" whether a folder with that name already
exists. If it does, the script asks the user if they want to replace
it. If the user says no, the script stops safely without deleting or
overwriting anything by accident.

### 3. Creating the folder structure
Using "mkdir -p", the script creates:
- the main project folder: attendance_tracker_{input}/
- a subfolder called Helpers/
- a subfolder called reports/

### 4. Generating the source files
Instead of copying pre-existing files, the script generates the
required files directly using "cat << 'EOF' > filename" blocks.
This writes the content for each file straight into the script,
so the repository only needs setup_project.sh and README.md to work:
- config.json and assets.csv are generated inside Helpers/
- attendance_checker.py is generated in the main project folder
- reports.log is created empty with "touch" (it gets filled when
  attendance_checker.py is run)
### 5. Updating thresholds with sed
The script asks the user if they want to change the attendance
thresholds (warning and failure). If the user types "y", the script
asks for new values using "read".

Before using these values, the script checks that they are valid
numbers using a while loop and a regular expression
(^[0-9]+$). If the input is not a number, the script asks again
until a valid number is entered.

Once the values are validated, the script uses "sed -i" to perform
an in-place edit of config.json, replacing the old threshold values
(75 and 50) with the new ones, without needing to open the file
manually.

### 6. Handling Ctrl+C with a signal trap
The script defines a function called cleanup(), which:
1. Creates a compressed archive (.tar.gz) of the current project
   folder using "tar -czf"
2. Deletes the incomplete project folder using "rm -rf"

This function is connected to the SIGINT signal (Ctrl+C) using
"trap cleanup SIGINT". This means that if the user interrupts the
script at any point with Ctrl+C, the script will not leave a half-
finished folder behind. Instead, it saves whatever was created so far
into an archive and cleans up the workspace automatically.

### 7. Health check at the end
Before finishing, the script performs two checks:
- It runs "python3 --version" to verify that Python 3 is installed
  on the system, and prints a success or warning message.
- It loops through each required file (attendance_checker.py,
  assets.csv, config.json, reports.log) and prints "OK" if the file
  exists or "MISSING" if it doesn't, confirming that the folder
  structure matches what was required.
## How to Run the Script

1. Make the script executable:
   chmod +x setup_project.sh

2. Run it:
   ./setup_project.sh

3. Follow the prompts:
   - Enter a project name (example: v1)
   - If a folder with that name already exists, choose whether to
     replace it (y/n)
   - Choose whether to update the attendance thresholds (y/n)
   - If yes, enter new numeric values for warning and failure
   - The script will then create the project, copy the files, update
     config.json if needed, check for python3, and verify the final
     folder structure
## How to Trigger the Archive Feature (Ctrl+C)

1. Run the script:
   ./setup_project.sh

2. Enter a project name when prompted

3. At any point before the script finishes, press Ctrl+C

What happens:
- The script catches the SIGINT signal
- It creates an archive named attendance_tracker_{input}_archive.tar.gz
  containing whatever files/folders were created so far
- It deletes the incomplete attendance_tracker_{input}/ folder
- The workspace is left clean, with no half-finished folders

I tested this by running the script, entering a project name, and
pressing Ctrl+C right after the folder structure was created but
before the configuration step finished. The archive was created
successfully and the incomplete folder was removed.
## Final Project Structure

attendance_tracker_{input}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
## Generated Source Files

- attendance_checker.py: Python script that reads config.json and
  assets.csv, calculates each student's attendance percentage, and
  writes warning/urgent alerts to reports.log if the percentage is
  below the configured thresholds.

- assets.csv: list of students with their email, name, number of
  sessions attended, and number of absences.

- config.json: contains the warning and failure thresholds (default
  75% and 50%), the run mode (live or dry run), and the total number
  of sessions.

- reports.log: example of a generated report showing alerts for
  students below the thresholds.
## Requirements
- bash
- python3
## Video Demonstration

The full project demonstration is available here:

https://drive.google.com/file/d/16RxGkK4aN5ZPnSUBBPAW9VdqtkJzFXxO/view?usp=drive_link

