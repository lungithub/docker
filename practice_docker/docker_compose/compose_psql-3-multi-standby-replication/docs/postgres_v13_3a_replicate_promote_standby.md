=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: EMERGENCY FAILOVER - promote standby due to primary unavailability
Author ....: devesplabs

[-] DESCRIPTION

## PREMISE

Consider this scenario:

- primary (pgnode1)
- standby1 (pgnode2) using sonar_slot_1
- standby2 (pgnode3) using sonar_slot_2

I want to promote standby1 (pgnode3) from the standby configuration.

I want to start simulating PRIMARY(pgnode1) unavailability by stopping the 
postggres service.

On PRIMARY(pgnode1).
```
sudo systemctl stop postgresql@13-main.service --no-pager
```

What configuration changes are needed on the new primary (pgnode2)? 
What configuration changes are needed on the new standby (pgnode3)?

What configuration changes are needed on the old primary (pgnode1) once it comes back online?
How do we rejoin it?

[-] DEPENDENCIES
none

[-] REQUIREMENTS


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

Sat 2025Oct11 22:16:47 PDT

Worked on first doc draft.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#########################      SCENARIO SUMMARY      ###########################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: remove standby :: outline
---

Sat 2025Oct11 22:16:47 PDT

**EMERGENCY FAILOVER SCENARIO**

In this scenario we assume the following:
- the primary database WAS running on pgnode1 (now crashed/unavailable)
- one standby database is running on pgnode2, using replication slot sonar_slot_1
- one standby database is running on pgnode3, using replication slot sonar_slot_2

**EMERGENCY CONDITION**: The primary database (pgnode1) is no longer available due to:
- Hardware failure
- Network failure  
- PostgreSQL crash
- Operating system crash
- Any other unplanned outage

This document outlines the steps to promote a standby database (pgnode2) to become the new primary during an emergency failover situation.

**Key Differences from Planned Failover**:
- No coordination with applications needed (they're already failing)
- No risk of split-brain (primary is dead)
- Focus on speed of recovery
- Simplified process since old primary cannot interfere

**What Happens During Emergency Promotion?**
- The selected standby server (pgnode2) will be promoted to primary
- Replication slots on the old primary (pgnode1) are already invalidated (server is down)
- Applications currently failing to connect will need to be reconfigured to point to the new primary
- The remaining standby (pgnode3) will be reconfigured to replicate from the new primary
- **No split-brain risk** since the old primary cannot accept connections

**Recovery Goals**:
- **RTO (Recovery Time Objective)**: 5-15 minutes typical
- **RPO (Recovery Point Objective)**: Minimal data loss (last replicated transaction)

**Prerequisites for Emergency Failover**:
- At least one standby is healthy and up-to-date
- Network connectivity between standbys is working
- Administrative access to standby servers

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#########################      REMOVE STANDBY      #############################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: remove standby :: outline
---

Sat 2025Oct11 22:16:47 PDT

## PROMOTE STANDBY

First, let's discuss what to do with pgnode2 to become the new primary

### Phase 1: Prepare for Promotion

#### Step 1: Verify Current Replication Status
On pgnode2 (standby to be promoted):
```bash
# Check if still in recovery mode
psql -c "SELECT pg_is_in_recovery();"

# Check last received LSN
psql -c "SELECT * FROM pg_stat_wal_receiver;"

# Check replication lag
psql -c "SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() 
                     THEN 0 
                     ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) 
                END AS lag_seconds;"
```

#### Step 2: Verify Primary is Unavailable (Emergency Failover)
**SCENARIO**: This document covers **Emergency Failover** where the primary (pgnode1) is crashed/unavailable.

Since the primary is already down:
- Applications cannot connect to the primary (connections will fail)
- No risk of split-brain scenarios
- No need to stop applications manually
- Proceed immediately to promotion

Verify the primary is truly unavailable:
```bash
# Test connection to primary from pgnode2
psql -h 172.24.1.11 -U postgres -c "SELECT 1;" 2>/dev/null || echo "Primary is unreachable - proceeding with failover"

# Check if primary process is dead (if you have shell access to pgnode1)
# ssh pgnode1 "sudo systemctl status postgresql@13-main.service" || echo "Primary service is down"
```

**Note**: Applications will automatically fail when trying to connect to the dead primary. This step simply confirms the emergency condition exists.

### Phase 2: Execute Emergency Promotion

#### Step 3: Promote pgnode2 to Primary (URGENT)
On pgnode2:
```bash
# EMERGENCY PROMOTION - This is the critical step
sudo -u postgres pg_ctl promote -D /var/lib/postgresql/13/main

# Monitor the promotion process
tail -f /var/log/postgresql/postgresql-*.log &
```

**Expected output**: You should see log messages about promotion starting and completing.

#### Step 4: Verify Promotion Success (URGENT)
```bash
# CRITICAL CHECK: Should return 'false' indicating it's no longer in recovery
psql -c "SELECT pg_is_in_recovery();"

# Verify standby.signal file is gone (confirms promotion)
ls -la /var/lib/postgresql/13/main/standby.signal 2>/dev/null || echo "standby.signal removed - promotion successful"

# Test that PostgreSQL accepts write operations
psql -c "CREATE TABLE emergency_promotion_test (promoted_at timestamp default now()); INSERT INTO emergency_promotion_test DEFAULT VALUES; SELECT * FROM emergency_promotion_test;"
```

**At this point, pgnode2 is now the PRIMARY and can accept application connections.**

### Phase 3: Essential Configuration (for Immediate Operation)

#### Step 5: Verify Essential Settings are Active
On pgnode2, check current configuration (these should already be set from when it was a standby):
```bash
# Check critical replication settings
psql -c "SHOW wal_level;"           # Should be 'replica' or higher
psql -c "SHOW max_wal_senders;"     # Should be > 0
psql -c "SHOW max_replication_slots;" # Should be > 0

# If any are incorrect, update postgresql.conf and reload:
# echo "wal_level = replica" >> /etc/postgresql/13/main/postgresql.conf
# echo "max_wal_senders = 3" >> /etc/postgresql/13/main/postgresql.conf
# psql -c "SELECT pg_reload_conf();"
```

#### Step 6: Verify Authentication is Ready
Check that `/etc/postgresql/13/main/pg_hba.conf` allows connections:
```bash
# Verify replication and client access lines exist
grep -E "(replication.*replicator|all.*all.*172.24.1)" /etc/postgresql/13/main/pg_hba.conf

# If missing, add these lines and reload:
# echo "host replication replicator 172.24.1.0/24 trust" >> /etc/postgresql/13/main/pg_hba.conf
# echo "host all all 172.24.1.0/24 trust" >> /etc/postgresql/13/main/pg_hba.conf
# psql -c "SELECT pg_reload_conf();"
```

**EMERGENCY MILESTONE**: pgnode2 is now ready to accept application traffic.

### Phase 4: Restore Replication (for Redundancy)

#### Step 7: Create Replication Slot for pgnode3
See `=TROUBLESHOOTING A :: reuse slot names`.

On pgnode2 (new primary):
```bash
# Create replication slot for remaining standby using SAME name as before
# (pgnode1's slots are gone, so we can reuse the names)
psql -c "SELECT * FROM pg_create_physical_replication_slot('sonar_slot_3');"

# Verify slot creation
psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```

**Note**: We can reuse the original slot name `sonar_slot_3` because:
- All replication slots on the old primary (pgnode1) are gone
- The new primary (pgnode2) starts with no slots after promotion
- This maintains your existing naming convention

### Phase 5: Reconfigure Remaining Standby (Restore Redundancy)

#### Step 8: Update pgnode3 to Point to New Primary
On pgnode3, use `ALTER SYSTEM` commands to update the replication configuration:
```bash
# Update connection info to point to pgnode2 (new primary)
psql -c "ALTER SYSTEM SET primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.12 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=standby3';"

# Update the replication slot name
psql -c "ALTER SYSTEM SET primary_slot_name = 'sonar_slot_3';"

# Verify the changes were applied
cat /var/lib/postgresql/13/main/postgresql.auto.conf
```

**Important Notes**:
- Changed host from `172.24.1.11` (old primary) to `172.24.1.12` (new primary)
- Updated `application_name` to `standby3` to identify this standby clearly
- Using original slot name `sonar_slot_3` for consistency
- **Never edit `postgresql.auto.conf` manually** - always use `ALTER SYSTEM`
```

#### Step 9: Restart pgnode3 Replication
```bash
# Restart PostgreSQL service on pgnode3 to connect to new primary
sudo systemctl restart postgresql@13-main.service --no-pager
```

### Phase 6: Critical Verification (Ensure System Stability)

#### Step 10: Verify New Replication Setup
On pgnode2 (new primary):
```bash
# Check replication status - should show pgnode3 connecting
psql -x -c "SELECT application_name, client_addr, state, sync_state FROM pg_stat_replication;"

# Verify replication slots - should show sonar_slot_3 as active
psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```

On pgnode3 (standby):
```bash
# Verify it's receiving from new primary
psql -x -c "SELECT sender_host, sender_port, status FROM pg_stat_wal_receiver;"

# Confirm still in recovery mode
psql -c "SELECT pg_is_in_recovery();"  # Should return 'true'
```

#### Step 11: Test Data Replication (Critical Test)
On pgnode2 (new primary):
```bash
# Create test data to verify replication is working
psql -c "CREATE TABLE emergency_replication_test (id serial, test_time timestamp default now(), message text default 'Emergency failover successful');"
psql -c "INSERT INTO emergency_replication_test (message) VALUES ('Replication test after emergency promotion');"
psql -c "SELECT * FROM emergency_replication_test;"
```

On pgnode3 (standby):
```bash
# Verify data appears (should appear within seconds)
sleep 5
psql -c "SELECT * FROM emergency_replication_test;"
```

### Phase 7: Application Recovery (Restore Service)

#### Step 12: Update Application Connection Strings (URGENT)
**This step restores service to users:**

1. **Update application configuration** to point to new primary:
   - Old primary: `172.24.1.11:5432` (pgnode1 - DEAD)
   - New primary: `172.24.1.12:5432` (pgnode2 - ACTIVE)

2. **Restart applications** to pick up new connection strings

3. **Update monitoring systems** to monitor pgnode2 as primary

4. **Update backup scripts** to backup from pgnode2

5. **Update DNS records** if using DNS-based connection routing

#### Step 13: Verify Application Connectivity
```bash
# Test application can connect and write to new primary
psql -h 172.24.1.12 -U your_app_user -d your_app_db -c "SELECT current_timestamp, 'Emergency failover complete' as status;"
```

**EMERGENCY RECOVERY COMPLETE**: Applications should now be operational.

### Phase 7: Handle Old Primary When Available

#### Step 14: When pgnode1 Comes Back Online
See separate section: "REJOIN OLD PRIMARY AS STANDBY"

### Summary of Emergency Failover:
- **pgnode1**: Dead/unavailable (original primary)
- **pgnode2**: Promoted from standby to primary (new master)
- **pgnode3**: Reconfigured to replicate from pgnode2 instead of pgnode1
- **Applications**: Must be reconfigured to connect to pgnode2

### Emergency Failover Timeline:
- **Detection**: 1-3 minutes (monitoring alerts)
- **Promotion**: 30 seconds - 2 minutes
- **Reconfiguration**: 5-10 minutes
- **Application recovery**: 5-15 minutes (depends on application restart time)
- **Total RTO**: 10-30 minutes typical

### Post-Failover Actions:
1. **Immediate**: Verify applications are connecting to new primary
2. **Short-term**: Monitor replication lag and performance
3. **Medium-term**: Plan for pgnode1 recovery/replacement
4. **Long-term**: Review what caused the original failure

---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
############################################################################MARK
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=APPENDIX A :: Primary Failover Scenarios
---

#### Primary Failover Scenarios

The Real Requirement: The critical requirement is preventing <split-brain> scenarios where both the old primary and new primary accept writes simultaneously. This doesn't necessarily mean "no connections" - it means "no write transactions."

Two Different Scenarios:

1. Emergency Failover (Primary is crashed/unavailable):
    - The primary CAN'T accept connections because it's down
    - This requirement is automatically satisfied
    - No action needed on the primary
2. Planned Failover (Primary is still running):
    - You MUST prevent the primary from accepting writes
    - Options include:
        - Stopping applications that write to it
        - Setting the primary to read-only mode
        - Blocking connections via firewall/network
        - Gracefully shutting down the primary
        - 
- Key Points:
    - Read connections to the old primary are generally acceptable
    - Write connections are what cause the split-brain problem
    - The goal is data consistency, not necessarily zero connections
    - The method depends on whether the primary is accessible or not

If the primary (pgnode1) is **completely unavailable** (crashed, network failure, etc.):
- This step is automatically satisfied - the primary cannot accept connections
- Skip to Step 3 immediately

If the primary (pgnode1) is **still accessible** (planned maintenance, controlled failover):
- Stop application connections to prevent split-brain scenarios
- **Go to every server that connects to the primary and stop the application there**
- Ensure no new transactions are being written
- Optionally, put the primary in read-only mode:
  ```bash
  # On pgnode1 (if accessible)
  psql -c "ALTER SYSTEM SET default_transaction_read_only = on;"
  psql -c "SELECT pg_reload_conf();"
  ```

**CRITICAL**: During promotion, you must prevent the old primary from accepting writes to avoid data inconsistency and split-brain scenarios. The methods depend on whether the primary is accessible:

- **Primary Unavailable** (crash/network failure): Problem is already solved
- **Primary Available** (planned failover): Must actively prevent new connections/writes

**Split-Brain Prevention**: The key is ensuring only ONE server can accept writes at any time. This is why stopping applications or making the old primary read-only is crucial for planned failovers.


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
=TROUBLESHOOTING A :: reuse slot names
---

[-] PROBLEM

Question regarding "#### Step 7: Create Replication Slot for pgnode3".

In the primary I have these slots.
```
-> psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
  slot_name   | slot_type | active
--------------+-----------+--------
 sonar_slot_2 | physical  | t
 sonar_slot_3 | physical  | f
 sonar_slot_1 | physical  | t
 sonar_slot_5 | physical  | f
 sonar_slot_4 | physical  | f
```

[-] RESEARCH


[-] SOLUTION

**Answer**: Yes, you can reuse the same slot names. You don't need to create `sonar_slot_3_new` - you can simply create `sonar_slot_3` on the new primary (pgnode2).

**Why this works**:
1. **Slots are server-specific**: When pgnode1 (old primary) died, ALL its replication slots died with it
2. **Clean slate**: pgnode2 (new primary) starts with NO replication slots after promotion  
3. **Name independence**: Slot names on the new primary are completely independent from the old primary
4. **Consistency benefit**: Using the same names maintains your existing naming convention

**Recommended Approach**:
```sql
-- On pgnode2 (new primary), create slots with original names:
SELECT * FROM pg_create_physical_replication_slot('sonar_slot_3');

-- On pgnode3, use the original slot name:
primary_slot_name = 'sonar_slot_3'
```

**Benefits of Reusing Names**:
- **Consistency** with your existing naming convention
- **Simpler configuration** (less confusing than `_new` suffixes)
- **Documentation clarity** (matches your original setup)
- **Operational simplicity** (same names = same monitoring/scripts)

**Only Use New Names If**:
- You have specific organizational reasons
- You want to distinguish "before/after failover" in monitoring
- Your operational procedures require it

**Bottom line**: The `_new` suffix was unnecessary complexity. Use your original slot names for simplicity and consistency!


[-] REFERENCE

::
::::::::::::::
::

..............


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
