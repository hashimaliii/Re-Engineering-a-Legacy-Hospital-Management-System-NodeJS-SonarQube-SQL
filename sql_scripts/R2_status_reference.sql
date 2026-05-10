-- R2: Replace CHAR(1) status codes with a reference table
CREATE TABLE IF NOT EXISTS appt_status_ref (
    status_code CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

INSERT IGNORE INTO appt_status_ref VALUES 
('P','Pending'), ('C','Completed'), ('X','Cancelled'), 
('H','On Hold'), ('R','Rescheduled');

ALTER TABLE appointments 
ADD CONSTRAINT fk_appt_status 
FOREIGN KEY (status) REFERENCES appt_status_ref(status_code);
