-- Normalized Schema for HealthBridge Hospital
CREATE DATABASE IF NOT EXISTS hospital;
USE hospital;

-- Refactoring R2 & R3
CREATE TABLE IF NOT EXISTS appt_status_ref (
    status_code CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

INSERT IGNORE INTO appt_status_ref VALUES 
('P','Pending'), ('C','Completed'), ('X','Cancelled'), 
('H','On Hold'), ('R','Rescheduled');

CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    speciality VARCHAR(255),
    contact_no VARCHAR(255),
    join_date DATE,
    salary_monthly FLOAT,
    dept_id INT,
    is_active CHAR(1)
);

CREATE TABLE IF NOT EXISTS patients (
    patient_id INT PRIMARY KEY,
    p_name VARCHAR(255) NOT NULL,
    dob DATE,
    sex CHAR(1),
    addr1 VARCHAR(255),
    addr2 VARCHAR(255),
    city VARCHAR(255),
    reg_doc_id INT,
    total_visits INT DEFAULT 0,
    last_bill FLOAT,
    notes TEXT,
    FOREIGN KEY (reg_doc_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE IF NOT EXISTS appointments (
    appt_id INT PRIMARY KEY,
    patient_id INT,
    doc_id INT,
    appt_datetime DATETIME,
    status CHAR(1),
    fee FLOAT,
    discount FLOAT,
    room_number INT,
    building_block VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doc_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (status) REFERENCES appt_status_ref(status_code)
);

CREATE TABLE IF NOT EXISTS billing (
    bill_no VARCHAR(50) PRIMARY KEY,
    pid INT,
    svc_cost FLOAT,
    tax_pct FLOAT,
    paid FLOAT,
    created VARCHAR(50),
    created_by VARCHAR(255),
    FOREIGN KEY (pid) REFERENCES patients(patient_id)
);

-- Refactoring R1
CREATE OR REPLACE VIEW v_billing_summary AS
SELECT 
    bill_no, 
    pid, 
    svc_cost, 
    tax_pct,
    ROUND(svc_cost * tax_pct / 100, 2) AS tax_amt,
    ROUND(svc_cost + (svc_cost * tax_pct / 100), 2) AS grand_total,
    paid,
    ROUND(svc_cost + (svc_cost * tax_pct / 100) - paid, 2) AS balance
FROM billing;
