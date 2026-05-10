# Software Re-Engineering Final Project
**Project:** Legacy Hospital Management System Re-Engineering

This repository contains the full re-engineering pipeline for a legacy hospital system, including code smell analysis of JUnit 4 and a normalized database migration.

## Repository Structure
- `junit4/`: The target Java project used for parts B, C, and D.
- `hospital_db/`: Database refactoring and migration logic.
  - `init_db.sql`: The normalized schema and view definitions.
  - `migration_etl.py`: Python script to migrate legacy CSV data.
  - `legacy_data.csv`: Sample legacy data used for migration.
  - `prisma/`: Prisma schema and configurations.
- `sql_scripts/`: Individual SQL refactoring scripts (R1-R5).
- `SRE-Report.md`: Final project report with screenshots and analysis.

## Setup Instructions

### 1. Start Infrastructure (Docker)
Ensure Docker Desktop is running, then start the SonarQube and MySQL containers:
```powershell
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
docker run -d --name hospital_db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=hospital mysql:8.0
```

### 2. Run Code Analysis (SonarQube)
Navigate to the `junit4` folder and run the scanner:
```powershell
cd junit4
..\sonar-scanner-5.0.1.3006-windows\bin\sonar-scanner.bat -Dsonar.login=admin -Dsonar.password=admin123
```
View results at `http://localhost:9000/dashboard?id=junit4`.

### 3. Load Normalized Schema
Load the refactored database schema into MySQL:
```powershell
Get-Content hospital_db\init_db.sql | docker exec -i hospital_db mysql -u root -proot
```

### 4. Execute Data Migration
Run the Python ETL script to migrate legacy appointment records:
```powershell
cd hospital_db
python migration_etl.py
```

### 5. Validate Migration
Run the validation queries:
```powershell
docker exec -i hospital_db mysql -u root -proot hospital -e "SELECT COUNT(*) FROM appointments; SELECT DISTINCT status FROM appointments;"
```
