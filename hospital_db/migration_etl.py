import csv
import subprocess
from datetime import datetime
import re
import os

# Docker MySQL execution helper
def run_sql(sql):
    cmd = ["docker", "exec", "-i", "hospital_db", "mysql", "-u", "root", "-proot", "hospital"]
    # We use -e for single statements, or pipe for script
    process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate(input=sql)
    if process.returncode != 0:
        print(f"SQL Error: {stderr}")
    return stdout

VALID_STATUSES = {'P', 'C', 'X', 'H', 'R'}

def parse_appt_date(raw):
    # T1: 'DD/MM/YYYY HH:MM' --> 'YYYY-MM-DD HH:MM:SS'
    try:
        dt = datetime.strptime(raw.strip(), '%d/%m/%Y %H:%M')
        return dt.strftime('%Y-%m-%d %H:%M:%S')
    except Exception as e:
        print(f"Error parsing date {raw}: {e}")
        return None

def split_room(raw):
    # T2: 'Room 3 Block B' --> (3, 'Block B')
    try:
        match_room = re.search(r'Room (\d+)', raw)
        match_block = re.search(r'Block ([A-Z])', raw)
        
        room_no = int(match_room.group(1)) if match_room else 0
        block_name = f"Block {match_block.group(1)}" if match_block else "Unknown"
        return room_no, block_name
    except Exception as e:
        return 0, "Unknown"

def migrate(csv_path):
    print(f"Starting migration from {csv_path}...")
    skipped = []
    processed = 0
    
    with open(csv_path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # T4: validate status; skip and log unknown codes
            if row['status'] not in VALID_STATUSES:
                print(f"Skipping appt {row['appt_id']}: Invalid status {row['status']}")
                skipped.append(row['appt_id'])
                continue
            
            # T1: Parse date
            appt_dt = parse_appt_date(row['appt_date'])
            if not appt_dt:
                skipped.append(row['appt_id'])
                continue
                
            # T2: Split room
            room_no, block = split_room(row['room'])
            
            # T3: patient_nm, patient_ph, doc_name omitted from INSERT
            # Prepare SQL statements
            # We use INSERT IGNORE for patients and doctors
            p_name = row['patient_nm'].replace("'", "''")
            doc_name = row['doc_name'].replace("'", "''")
            block_esc = block.replace("'", "''")
            
            sql = f"""
            INSERT IGNORE INTO patients (patient_id, p_name) VALUES ({row['patient_id']}, '{p_name}');
            INSERT IGNORE INTO doctors (doctor_id, full_name) VALUES ({row['doc_id']}, '{doc_name}');
            INSERT INTO appointments (appt_id, patient_id, doc_id, appt_datetime, status, fee, discount, room_number, building_block) 
            VALUES ({row['appt_id']}, {row['patient_id']}, {row['doc_id']}, '{appt_dt}', '{row['status']}', 
                   {row['fee']}, {row['discount']}, {room_no}, '{block_esc}');
            """
            
            run_sql(sql)
            processed += 1

    print(f"\nMigration Complete.")
    print(f"Rows successfully processed: {processed}")
    print(f"Rows skipped: {len(skipped)}")
    if skipped:
        print(f"Skipped IDs: {skipped}")

if __name__ == "__main__":
    migrate('legacy_data.csv')
