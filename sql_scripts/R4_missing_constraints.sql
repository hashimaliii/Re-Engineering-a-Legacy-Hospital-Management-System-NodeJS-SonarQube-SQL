-- R4: Fix missing PKs and FKs with data cleanup
ALTER TABLE billing ADD PRIMARY KEY (bill_no);

DELETE FROM billing WHERE pid NOT IN (SELECT pid FROM pat_master);

ALTER TABLE billing 
ADD CONSTRAINT fk_billing_patient 
FOREIGN KEY (pid) REFERENCES pat_master(pid);

ALTER TABLE appointments 
ADD CONSTRAINT fk_appt_doctor 
FOREIGN KEY (doc_id) REFERENCES doctors(doctor_id);
