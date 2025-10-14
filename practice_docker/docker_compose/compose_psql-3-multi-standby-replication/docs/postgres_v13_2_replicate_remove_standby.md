=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: remote standby from replication
Author ....: devesplabs

[-] DESCRIPTION

In this scenario we assume the following:
- the primary database is running on pgnode1
- one standby database is running on pgnode2, using replication slot sonar_slot_1
- one standby database is running on pgnode3, using replication slot sonar_slot_2

At some point in time, we want to remove one of the standby databases from the replication setup, perhaps
due to maintenance or reconfiguration.

This document will outline the steps to remove a standby database from the replication setup.

[-] DEPENDENCIES
none

[-] REQUIREMENTS
none

[-] CAVEATS
none

[-] REFERENCE

-------------------------------------------------------------------------------
[-] Revision History

Date: Sat 2025Oct11 20:07:38 PDT
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=ENVIRONMENT :: starting environment
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TOOL :: timeline
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: replication setup
---

## Replication Setup

Follow the steps in 
```
~/DATAL3/RESEARCH/project_PSQL/psql_active_research/psql_1_replication_slots.md
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#########################      REMOVE STANDBY      #############################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: remove standby :: outline
---

Sat 2025Oct11 20:07:38 PDT

## REMOVE STANDBY

Consider this scenario:

primary (pgnode1)
--> standby1 (pgnode2) using sonar_slot_1
--> standby2 (pgnode3) using sonar_slot_2

I want to remove standby2 (pgnode3) from the standby configuration.

### Step-by-Step Removal Process

#### 1. Stop the Standby Server (pgnode3)

**NO DOWNTIME ON PRIMARY** - This only affects pgnode3
On pgnode3.
```
sudo systemctl stop postgresql@13-main.service --no-pager3
```

#### 2. Verify Replication Status on Primary

Check that pgnode3 is no longer streaming.

On primary (pgnode1) check active replication connections
```
psql -c "SELECT application_name, client_addr, state FROM pg_stat_replication;"
```
Check replication slots separately
```
psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```
You should only see pgnode2 active in pg_stat_replication, and sonar_slot_1 should still be active in pg_replication_slots.

#### 3. Drop the Replication Slot on Primary

**NO DOWNTIME ON PRIMARY** - Safe operation while primary is running
On pgnode1.
```
psql -c "SELECT pg_drop_replication_slot('sonar_slot_2');"
```

#### 4. Verify Slot Removal

On pgnode1.
```
psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```
sonar_slot_2 should no longer appear in the list.

#### 5. Clean Up pgnode3 (Optional)

If completely decommissioning pgnode3:
```
# On pgnode3 - Remove PostgreSQL data
sudo rm -rf /var/lib/postgresql/13/main
sudo rm -rf /var/lib/postgresql/pg_from_master

# Or convert to standalone database
# Remove standby.signal file to make it a regular database
rm /var/lib/postgresql/13/main/standby.signal
```

### Important Notes

**NO PRIMARY DOWNTIME REQUIRED**
- The primary (pgnode1) continues serving clients normally
- pgnode2 replication remains unaffected
- Only pgnode3 experiences downtime during its shutdown

**Safe Order of Operations**
1. Stop standby first (prevents connection errors)
2. Drop replication slot second (cleans up WAL retention)
3. Clean up standby files last (optional)

**What Happens to WAL Files**
- Once slot is dropped, WAL files for that slot are no longer retained
- This frees up disk space on the primary
- No impact on other replication slots

### Verification Commands

After removal, verify the setup:
```sql
# Check remaining replication slots
psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

# Check active replication connections
psql -c "SELECT application_name, client_addr, state FROM pg_stat_replication;"

# Check WAL sender processes
psql -c "SELECT pid, state, sent_lsn, write_lsn FROM pg_stat_replication;"
```

Expected result: Only sonar_slot_1 and pgnode2 should remain active.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
############################################################################MARK
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=APPENDIX A :: container :: extra data on some task
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=OUTPUT A :: stdout :: result of running some command or script at the CLI
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=INFO A :: some informational bit about this subject
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=FILE A :: filename :: relevant contents of config file
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TROUBLESHOOTING A :: additional pitfalls to look for
---

[-] PROBLEM


[-] RESEARCH


[-] SOLUTION


[-] REFERENCE

::
::::::::::::::
::

..............


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
