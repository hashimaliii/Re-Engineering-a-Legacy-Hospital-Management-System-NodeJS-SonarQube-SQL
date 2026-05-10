-- R1: Remove derived columns from billing and replace with a view
ALTER TABLE billing DROP COLUMN tax_amt;
ALTER TABLE billing DROP COLUMN grand_total;
ALTER TABLE billing DROP COLUMN balance;

CREATE OR REPLACE VIEW v_billing_summary AS
SELECT 
    bill_no, pid, svc_cost, tax_pct,
    ROUND(svc_cost * tax_pct / 100, 2) AS tax_amt,
    ROUND(svc_cost + (svc_cost * tax_pct / 100), 2) AS grand_total,
    paid,
    ROUND(svc_cost + (svc_cost * tax_pct / 100) - paid, 2) AS balance
FROM billing;
