-- R3: Standardise column names to snake_case in doctors table
ALTER TABLE doctors RENAME COLUMN DoctorID TO doctor_id;
ALTER TABLE doctors RENAME COLUMN FullName TO full_name;
ALTER TABLE doctors RENAME COLUMN Speciality TO speciality;
ALTER TABLE doctors RENAME COLUMN ContactNo TO contact_no;
ALTER TABLE doctors RENAME COLUMN JoinDt TO join_date;
ALTER TABLE doctors RENAME COLUMN Salary TO salary_monthly;
ALTER TABLE doctors RENAME COLUMN isActive TO is_active;
