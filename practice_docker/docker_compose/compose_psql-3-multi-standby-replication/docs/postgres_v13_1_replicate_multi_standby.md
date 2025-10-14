=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: Docker
Author ....: John Doe

[-] DESCRIPTION

## Add new standby

1. Create a new replication slot on the primary node (pgnode1) for the new standby (pgnode3).
2. Create a new subscription on the standby node (pgnode3) to connect to the primary node (pgnode1) using the new replication slot.
3. Apply the necessary configuration changes on both nodes to allow for the new standby to be recognized and properly replicate data.
4. Start the replication process on the new standby node (pgnode3) and monitor the replication status.
5. Verify that the new standby node (pgnode3) is receiving and applying changes from the primary node (pgnode1) as expected.
6. On pgnode3 the data is replicated.
7. Monitor the replication lag and performance on both nodes to ensure optimal operation.
8. Document the replication setup and any changes made during the process.
9. Test failover and switchover procedures to ensure they work as expected.
10. Monitor the replication status and performance on the new standby node (pgnode3) to ensure it is functioning correctly.
11. Perform regular maintenance and updates on the new standby node (pgnode3) to keep it in sync with the primary node (pgnode1).
12. Implement a backup strategy for the new standby node (pgnode3) to ensure data durability and recoverability.
13. Test the failover process to ensure the new standby node (pgnode3) can take over in case of a primary node (pgnode1) failure.
14. Document the entire replication setup and any changes made during the process.
15. Review and update the replication strategy as needed to accommodate changes in the environment or workload.
16. Conduct regular testing of the replication setup to ensure it continues to meet business requirements.
17. Stay informed about new PostgreSQL features and best practices for replication to continuously improve the setup.
18. Evaluate the need for additional standby nodes or changes to the existing architecture based on workload and performance metrics.
19. Plan for regular reviews and updates to the replication strategy to ensure it remains effective and aligned with business goals.
20. Establish a process for documenting and communicating changes to the replication setup to all relevant stakeholders.
21. Continuously monitor the replication setup for any issues or areas for improvement.

[-] DEPENDENCIES
none

[-] REQUIREMENTS
none

[-] CAVEATS
none

[-] REFERENCE

-------------------------------------------------------------------------------
[-] Revision History

Date: Sat 2018Dec08 13:23:12 PST
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=ENVIRONMENT :: starting environment
---

# Compute Environment

I have a docker compose environment running on Ubuntu22.04.

Location: 
```
~/Documents/DATAL4/MyCode/compose-psql-AARCH64
```

The environment consists of four containers
1. pgnode1: the primary db server
2. pgnode2 and pgnode3: the standby db servers
3. witness: a suitable container for setting up repmgr (not done in this exercise)

# Postgres version

In this exercise we use <Postgresql-13>.

# Data Directory

We use the default data directory
```
/var/lib/postgresql/13/main
```

# Configuration Files

We use the default configuration files
```
/etc/postgresql/13/main/
```

# Logs Location

```
-> ls -ld /var/log/postgres
drwxr-xr-x 2 postgres postgres 8192 Jan  6 00:00 /var/log/postgres
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TOOL :: timeline
---

Fri 2025Oct10 16:04:01 PDT 

Set up multi-standby replication.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: pre-flight checks :: pgnode1 <-> pgnode2
---

Fri 2025Oct10 16:03:44 PDT

# REPLICATOIN STATUS :: before adding second standby

This is a snapshot what things look like with the following:
- one PRIMARY: `pgnode1`
- one STANDBY: `pgnode2`

## PRIMARY :: pgnode1

Primary node information

Replication slots.
Note that only one slot shows as active with `t`.
```
Fri 2025Oct10 16:04:17 PDT
postgres@pgnode1
~
hist:72 -> psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
  slot_name   | slot_type | active
--------------+-----------+--------
 sonar_slot_2 | physical  | f
 sonar_slot_3 | physical  | f
 sonar_slot_1 | physical  | t
 sonar_slot_5 | physical  | f
 sonar_slot_4 | physical  | f
(5 rows)
```

Replication status on PRIMARY DB server.
Only one record shown indicating there is only one standby.
```
Fri 2025Oct10 16:03:44 PDT 
postgres@pgnode1  
~ 
hist:72 -> ~/bin/replication_check_primary_v1.sh

Replication status on PRIMARY DB server.

-[ RECORD 1 ]----+------------------------------
pid              | 33271
usesysid         | 16386
usename          | replicator
application_name | 13/main
client_addr      | 172.24.1.1
client_hostname  | 
client_port      | 59572
backend_start    | 2025-10-10 15:31:14.00785-07
backend_xmin     | 
state            | streaming
sent_lsn         | 0/5000148
write_lsn        | 0/5000148
flush_lsn        | 0/5000148
replay_lsn       | 0/5000148
write_lag        | 
flush_lag        | 
replay_lag       | 
sync_priority    | 1
sync_state       | sync
reply_time       | 2025-10-10 16:04:16.772786-07
```

## STANDBY 1 :: pgnode2

Replication status on SECONDARY DB server.

```
Fri 2025Oct10 16:04:01 PDT 
postgres@pgnode2 
~ 
hist:79 -> ~/bin/replication_check_standby_v1.sh

Replication status on SECONDARY DB server.

-[ RECORD 1 ]---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 28772
status                | streaming
receive_start_lsn     | 0/5000000
receive_start_tli     | 1
written_lsn           | 0/5000148
flushed_lsn           | 0/5000000
received_tli          | 1
last_msg_send_time    | 2025-10-10 16:04:16.773082-07
last_msg_receipt_time | 2025-10-10 16:04:16.773239-07
latest_end_lsn        | 0/5000148
latest_end_time       | 2025-10-10 15:31:14.008534-07
slot_name             | sonar_slot_1
sender_host           | 172.24.1.11
sender_port           | 5432
conninfo              | user=replicator password=******** channel_binding=prefer dbname=replication host=172.24.1.11 port=5432 fallback_application_name=13/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

## Check replication data

Here we verify that data is in sync between the existing primary and standby.

On the PRIMARY DB server, run the following command to check the replication data:
```
Fri 2025Oct10 16:27:51 PDT
postgres@pgnode1
~
hist:98 -> psql -f ~/bin/sql/tables_test_query.sql
 id | username |        email
----+----------+----------------------
  1 | testuser | testuser@example.com
(1 row)

 id |      name      | price
----+----------------+-------
  1 | Sample Product | 19.99
(1 row)

 id | user_id | product_id |         order_date
----+---------+------------+----------------------------
  1 |       1 |          1 | 2025-10-10 14:59:52.740296
(1 row)
```

On pgnode2 the data is replicated.
```
Fri 2025Oct10 16:27:26 PDT
postgres@pgnode2
~/bin/sql
hist:87 -> psql -f ~/bin/sql/tables_test_query.sql
 id | username |        email
----+----------+----------------------
  1 | testuser | testuser@example.com
(1 row)

 id |      name      | price
----+----------------+-------
  1 | Sample Product | 19.99
(1 row)

 id | user_id | product_id |         order_date
----+---------+------------+----------------------------
  1 |       1 |          1 | 2025-10-10 14:59:52.740296
(1 row)

```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#########################      ADD FIRST STANDBY      #########################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: Add First Standby :: detailed steps
---

## Steps to Add First Standby :: pgnode2

This shows the steps to setup replication on the FIRST STANDBY using `sonar_slot_1 `.

### Data Transfer Steps

1. Primary: the data directory is `/var/lib/postgresql/13/main`
2. Standby: create the data destination directory `/var/lib/postgresql/pg_from_master`
3. Standby: do the data transfer using `pg_basebackup` to destination `/var/lib/postgresql/pg_from_master`
4. Standby: rename the original data directory to `/var/lib/postgresql/13/main` to `/var/lib/postgresql/13/main_ORIG`
5. Standby: move the transferred data `/var/lib/postgresql/pg_from_master` to `/var/lib/postgresql/13/main`
6. Standby: start the postgres service
7. Primary and standby: check replication status


### STANDBY :: Rename the Original Data Directory
On the STANDBY, create the destination dir for the pg_basebackup transfer.
This is done on the postgres DATA directory, wherever that is.
The default data dir is done here.
```
mv /var/lib/postgresql/13/main /var/lib/postgresql/13/main_ORIG
```

### STANDBY :: Create The Data Destination Directory
create the data destination directory
```
cd /var/lib/postgresql
mkdir pg_from_master;
chmod 700 pg_from_master;
ls -ld pg_from_master;
```

### STANDBY :: Do the Data Transfer

On the STANDBY, run pg_basebackup to transfer the dta from the PRIMARY.

user: `replicator`
pass: `abc123`

```
time /usr/bin/pg_basebackup \
-S sonar_slot_1 \
-h 172.24.1.11 \
-U replicator \
-p 5432 \
-D /var/lib/postgresql/pg_from_master \
--write-recovery-conf \
--wal-method=stream \
--format=p \
--progress --password --verbose
```

### STANDBY :: Move the Transferred Data
```
mv /var/lib/postgresql/pg_from_master /var/lib/postgresql/13/main
```

### STANDBY :: Start the postgres Service
```
sudo systemctl start postgresql@13-main.service --no-pager
```

### PRIMARY :: Replication Slot Status

```
Fri 2025Oct10 19:36:00 PDT
postgres@pgnode1
/etc/postgresql/13/main
hist:100 -> psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
  slot_name   | slot_type | active
--------------+-----------+--------
 sonar_slot_2 | physical  | f
 sonar_slot_3 | physical  | f
 sonar_slot_1 | physical  | t
 sonar_slot_5 | physical  | f
 sonar_slot_4 | physical  | f
(5 rows)
```

### PRIMARY :: Replication Status

Take note of the entries in `client_addr`.

```
Fri 2025Oct10 19:59:54 PDT
postgres@pgnode1
/etc/postgresql/13/main
hist:98 -> ~/bin/replication_check_primary_v1.sh

Replication status on PRIMARY DB server.

-[ RECORD 1 ]----+------------------------------
pid              | 35119
usesysid         | 16386
usename          | replicator
application_name | 13/main
client_addr      | 172.24.1.1
client_hostname  |
client_port      | 35982
backend_start    | 2025-10-10 19:02:29.07298-07
backend_xmin     |
state            | streaming
sent_lsn         | 0/5000148
write_lsn        | 0/5000148
flush_lsn        | 0/5000148
replay_lsn       | 0/5000148
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 1
sync_state       | sync
reply_time       | 2025-10-10 20:02:32.099414-07
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#########################      ADD SECOND STANDBY      #########################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: Add Second Standby :: outline
---


2025Oct10 19:28:23 PDT

## Steps to Add Second Standby :: pgnode3 (outline)

This shows the steps to setup replication on the SECOND STANDBY using an available slot.
- standby to add: `pgnode3`
- slot to use: `sonar_slot_2 `.

### 1. Prepare pgnode3 Environment
- Install PostgreSQL 13 on pgnode3 (same as you did for pgnode1 and pgnode2)
- Create the data directory structure
- Ensure network connectivity between pgnode1 and pgnode3

Stop the service on pgnodd3.

```bash
sudo systemctl stop postgresql@13-main.service --no-pager
```

### 2. PRIMARY :: Update Primary Configuration (if needed)
On pgnode1, verify your `postgresql.conf` has the settings to accomodate an additional standby.
```bash
max_wal_senders = 3  # Should support multiple standbys
max_replication_slots = 10  # You already have this
```

### 3. STDANDBY :: Data Transfer from pgnode1 to pgnode3

For the new standby, use the same `pg_basebackup` method, but specify `sonar_slot_2`.
Run pg_basebackup to transfer the data.
```bash
time /usr/bin/pg_basebackup \
-S sonar_slot_2 \
-h 172.24.1.11 \
-U replicator \
-p 5432 \
-D /var/lib/postgresql/pg_from_master \
--write-recovery-conf \
--wal-method=stream \
--format=p \
--progress --password --verbose
```

Verify the data was transferred.
The contents should look as seen here.
```
-> ls -l pg_from_master
```

### 4. STDANDBY :: Verify pgnode3 Recovery Settings
The `--write-recovery-conf` flag will automatically create the recovery configuration, but ensure it points to `sonar_slot_2`.

Check the recovery file. 
Note the `primary_slot_name` setting should be `sonar_slot_2`.
```
-> cat pg_from_master/postgresql.auto.conf
```

Check the backup label file.
```
-> cat pg_from_master/backup_label
```

### 5. STDANDBY :: Move the data
Move the new data to the expected, final destination.
Do CP or RM depending on space availability.
```
mv /var/lib/postgresql/pg_from_master /var/lib/postgresql/13/main
```

### 6. STDANDBY :: start the service
Start the postgres service.
```
sudo systemctl start postgresql@13-main.service --no-pager
```

### 7. PRIMARY :: Check Replication Slots
After setup, the replication slots should show like this:
```
 -> psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```

### 8. PRIMARY :: Check Replication Status
After setup, there should be two records showing, one for each standby.
```
-> ~/bin/replication_check_primary_v1.sh
```

Replication check Standby-1 (pgnode2)
```
 ~/bin/replication_check_standby_v1.sh
```

Replication check Standby-2 (pgnode3)
```
~/bin/replication_check_standby_v1.sh
```

### 9. PRIMARY + STANDBY :: data verification
PRIMARY: Run this SQL scripts to CRUD some data.
```
psql -f ~/bin/sql/tables_test_create.sql
psql -f ~/bin/sql/tables_test_drop.sql
```
PRIMARY and STNDBYS: run this SQL script to query the data.
```
psql -f ~/bin/sql/tables_test_query.sql
```
The data should be identical on all hosts.

## Benefits of Multi-Standby Configuration

1. Load Distribution: Read queries can be distributed across multiple standbys
2. High Availability: Multiple failover targets
3. Geographic Distribution: If nodes are in different locations
4. Maintenance Flexibility: Can take one standby offline without losing redundancy

## Potential Considerations

- Network Bandwidth: More standbys = more WAL streaming traffic from primary
- Monitoring: Need to monitor multiple replication streams
- Failover Complexity: More nodes to consider in failover scenarios

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: Add Second Standby :: detailed steps
---

Fri 2025Oct10 19:28:23 PDT

## Steps to Add Second Standby :: pgnode3 (detailed steps)

This shows the steps to setup replication on the SECOND STANDBY using an available slot.
- standby to add: `pgnode3`
- slot to use: `sonar_slot_2 `.

### 1. Prepare pgnode3 Environment
- Install PostgreSQL 13 on pgnode3 (same as you did for pgnode1 and pgnode2)
- Create the data directory structure
- Ensure network connectivity between pgnode1 and pgnode3

Stop the service on pgnodd3.

```bash
sudo systemctl stop postgresql@13-main.service --no-pager
```

### 2. PRIMARY :: Update Primary Configuration (if needed)
On pgnode1, verify your `postgresql.conf` has the settings to accomodate an additional standby.
```bash
max_wal_senders = 3  # Should support multiple standbys
max_replication_slots = 10  # You already have this
```
The above means that with `max_wal_senders` set to 3, we can have up to that number of hosts in the DB cluster.
- one primary: pgnode1
- first standby: pgnode2
- second standby: pgnode3

### 3. STDANDBY :: Data Transfer from pgnode1 to pgnode3
When we added the first standby, pgnode2, we used `sonar_slot_1`.
For the new standby, use the same `pg_basebackup` method, but specify `sonar_slot_2`.

Rename the original default location.
We will replace this main directory with the data we transfer from the primary.
```bash
mv /var/lib/postgresql/13/main /var/lib/postgresql/13/main_ORIG;
```

Prepare the destination directory.
```bash
cd /var/lib/postgresql;
mkdir pg_from_master;
chmod 700 pg_from_master;
ls -ld pg_from_master;
```

Run pg_basebackup to transfer the data.
- user: `replicator`
- pass: `abc123`
```bash
time /usr/bin/pg_basebackup \
-S sonar_slot_2 \
-h 172.24.1.11 \
-U replicator \
-p 5432 \
-D /var/lib/postgresql/pg_from_master \
--write-recovery-conf \
--wal-method=stream \
--format=p \
--progress --password --verbose
```

Verify the data was transferred.
The contents should look as seen here.
```
Fri 2025Oct10 20:04:47 PDT
postgres@pgnode3
~
hist:55 -> ls -l pg_from_master
total 260
-rw------- 1 postgres postgres      3 Oct 10 20:04 PG_VERSION
-rw------- 1 postgres postgres    224 Oct 10 20:04 backup_label
-rw------- 1 postgres postgres 178329 Oct 10 20:04 backup_manifest
drwx------ 6 postgres postgres   4096 Oct 10 20:04 base/
-rw------- 1 postgres postgres     58 Oct 10 20:04 current_logfiles
drwx------ 2 postgres postgres   4096 Oct 10 20:04 global/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_commit_ts/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_dynshmem/
drwx------ 4 postgres postgres   4096 Oct 10 20:04 pg_logical/
drwx------ 4 postgres postgres   4096 Oct 10 20:04 pg_multixact/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_notify/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_replslot/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_serial/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_snapshots/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_stat/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_stat_tmp/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_subtrans/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_tblspc/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_twophase/
drwx------ 3 postgres postgres   4096 Oct 10 20:04 pg_wal/
drwx------ 2 postgres postgres   4096 Oct 10 20:04 pg_xact/
-rw------- 1 postgres postgres    363 Oct 10 20:04 postgresql.auto.conf
-rw------- 1 postgres postgres      0 Oct 10 20:04 standby.signal
```

### 4. STDANDBY :: Verify pgnode3 Recovery Settings
The `--write-recovery-conf` flag will automatically create the recovery configuration, but ensure it points to `sonar_slot_2`.

Check the recovery file. 
Note the `primary_slot_name` setting should be `sonar_slot_2`.
```
Fri 2025Oct10 20:06:06 PDT
postgres@pgnode3
~
hist:57 -> cat pg_from_master/postgresql.auto.conf
# Do not edit this file manually!
# It will be overwritten by the ALTER SYSTEM command.
primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
primary_slot_name = 'sonar_slot_2'
```

Check the backup label file.
```
Fri 2025Oct10 20:05:56 PDT
postgres@pgnode3
~
hist:56 -> cat pg_from_master/backup_label
START WAL LOCATION: 0/6000028 (file 000000010000000000000006)
CHECKPOINT LOCATION: 0/6000060
BACKUP METHOD: streamed
BACKUP FROM: master
START TIME: 2025-10-10 20:04:46 PDT
LABEL: pg_basebackup base backup
START TIMELINE: 1
```

### 5. STDANDBY :: Move the data
Move the new data to the expected, final destination.
Do CP or RM depending on space availability.
```
mv /var/lib/postgresql/pg_from_master /var/lib/postgresql/13/main

Or,

cp -r /var/lib/postgresql/pg_from_master /var/lib/postgresql/13/main

-> du -sh /var/lib/postgresql/pg_from_master /var/lib/postgresql/13/main
48M	/var/lib/postgresql/pg_from_master
48M	/var/lib/postgresql/13/main
```

### 6. STDANDBY :: start the service
Start the postgres service.
```
sudo systemctl start postgresql@13-main.service --no-pager
```

### 7. PRIMARY :: Check Replication Slots

After setup, the replication slots should show like this:
```
 -> psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
  slot_name   | slot_type | active
--------------+-----------+--------
 sonar_slot_2 | physical  | t #pgnode2
 sonar_slot_3 | physical  | f
 sonar_slot_1 | physical  | t #pgnode1
 sonar_slot_5 | physical  | f
 sonar_slot_4 | physical  | f
(5 rows)
```

### 8. PRIMARY :: Check Replication Status

After setup, there should be two records showing, one for each standby.
Sync state:
- standby1: sync
- standby2: potential... why?
```
-> ~/bin/replication_check_primary_v1.sh

Replication status on PRIMARY DB server.

-[ RECORD 1 ]----+------------------------------
pid              | 35119
usesysid         | 16386
usename          | replicator
application_name | 13/main
client_addr      | 172.24.1.1
client_hostname  |
client_port      | 35982
backend_start    | 2025-10-10 19:02:29.07298-07
backend_xmin     |
state            | streaming
sent_lsn         | 0/7000148
write_lsn        | 0/7000148
flush_lsn        | 0/7000148
replay_lsn       | 0/7000148
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 1
sync_state       | sync
reply_time       | 2025-10-10 20:22:52.613109-07
-[ RECORD 2 ]----+------------------------------
pid              | 35433
usesysid         | 16386
usename          | replicator
application_name | 13/main
client_addr      | 172.24.1.2
client_hostname  |
client_port      | 52280
backend_start    | 2025-10-10 20:21:42.703597-07
backend_xmin     |
state            | streaming
sent_lsn         | 0/7000148
write_lsn        | 0/7000148
flush_lsn        | 0/7000148
replay_lsn       | 0/7000148
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 1
sync_state       | potential
reply_time       | 2025-10-10 20:22:52.814967-07
```

Replication check Standby-1 (pgnode2)

```
Fri 2025Oct10 20:20:50 PDT
postgres@pgnode2
~
hist:94 -> ~/bin/replication_check_standby_v1.sh

Replication status on SECONDARY DB server.

-[ RECORD 1 ]---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 29921
status                | streaming
receive_start_lsn     | 0/5000000
receive_start_tli     | 1
written_lsn           | 0/7000148
flushed_lsn           | 0/7000148
received_tli          | 1
last_msg_send_time    | 2025-10-10 20:25:22.773434-07
last_msg_receipt_time | 2025-10-10 20:25:22.773518-07
latest_end_lsn        | 0/7000148
latest_end_time       | 2025-10-10 20:09:51.859322-07
slot_name             | sonar_slot_1
sender_host           | 172.24.1.11
sender_port           | 5432
conninfo              | user=replicator password=******** channel_binding=prefer dbname=replication host=172.24.1.11 port=5432 fallback_application_name=13/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

Replication check Standby-2 (pgnode3)

```
Fri 2025Oct10 20:23:12 PDT
postgres@pgnode3
~/13/main
hist:79 -> ~/bin/replication_check_standby_v1.sh

Replication status on SECONDARY DB server.

-[ RECORD 1 ]---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 29754
status                | streaming
receive_start_lsn     | 0/7000000
receive_start_tli     | 1
written_lsn           | 0/7000148
flushed_lsn           | 0/7000148
received_tli          | 1
last_msg_send_time    | 2025-10-10 20:25:12.901456-07
last_msg_receipt_time | 2025-10-10 20:25:12.901523-07
latest_end_lsn        | 0/7000148
latest_end_time       | 2025-10-10 20:21:42.704435-07
slot_name             | sonar_slot_2
sender_host           | 172.24.1.11
sender_port           | 5432
conninfo              | user=replicator password=******** channel_binding=prefer dbname=replication host=172.24.1.11 port=5432 fallback_application_name=13/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any

```

### 9. PRIMARY + STANDBY :: data verification
PRIMARY: Run this SQL scripts to CRUD some data.
```
psql -f ~/bin/sql/tables_test_create.sql
psql -f ~/bin/sql/tables_test_drop.sql
```
PRIMARY and STNDBYS: run this SQL script to query the data.
```
psql -f ~/bin/sql/tables_test_query.sql
```
The data should be identical on all hosts.


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
################################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=APPENDIX A :: aaa
---


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=OUTPUT A :: stdout :: result of running some command or script at the CLI
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=INFO A :: some informational bit about this subject
---
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=FILE A :: /etc/postgresql/13/main/pg_hba.conf
---

Fri 2025Oct10 19:26:05 PDT

## HBA Config

This config allows the following among the nodes:
- db replication
- user connections from standbys to primary -- `IPv4 local connections`

(!) this is a wide open config for testing purposes only and not suitable for production

FILE: `/etc/postgresql/13/main/pg_hba.conf`
```
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             172.24.1.1/32           trust
host    all             all             172.24.1.2/32           trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
##local   replication     all                                     peer
##host    replication     all             127.0.0.1/32            trust
##host    replication     all             ::1/128                 trust

# Replication
local	replication	all                                    trust
host	replication	replicator	127.0.0.1/32		trust
host	replication	all		::1/128			trust
host	replication	replicator	0.0.0.0/0		trust

```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TROUBLESHOOTING A :: set application_name
---

[-] PROBLEM

Update the STANDBY to have the `application_name` in the connections settings.
Update: `/var/lib/postgresql/13/main/postgresql.auto.conf`


[-] RESEARCH

My PRIMARY DB has ip address `172.24.1.11` and the user is `replicator` 
In the PRIMARY DB server I have this in the postgresql.conf `synchronous_standby_names = '*'`
If I have this on standby1 `primary_conninfo = 'host=172.24.1.11 port=5432 user=replicator application_name=standby1' `
and this on standby2 `primary_conninfo = 'host=172.24.1.11 port=5432 user=replicator application_name=standby2' `
will that work? do I need to restart the STANDBY DBs and the PRIMARY DB?

[-] SOLUTION

It is a problem to try and put primary_conninfo and primary_slot_name into a single ALTER SYSTEM command because ALTER SYSTEM is designed to set one parameter at a time. primary_conninfo and primary_slot_name are two separate and distinct server configuration parameters in PostgreSQL

Each ALTER SYSTEM command will update `/var/lib/postgresql/13/main/postgresql.auto.conf`


## STANDBY - ALTER connection settings

:: standby1

```sql
-- Connect to the standby database instance and run these commands
-- Step 1: Set the primary_conninfo with the application_name
ALTER SYSTEM SET primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=standby1';

-- Step 2: Set the primary_slot_name
ALTER SYSTEM SET primary_slot_name = 'sonar_slot_1';

-- Step 3: Restart the standby instance to apply both changes
-- (This step is done from your operating system's command line, not psql)
-- pg_ctl restart -D /var/lib/postgresql/13/main
```
Stop/start this DB Standby.

:: standby2

```sql
-- Connect to the standby database instance and run these commands
-- Step 1: Set the primary_conninfo with the application_name
ALTER SYSTEM SET primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=standby2';

-- Step 2: Set the primary_slot_name
ALTER SYSTEM SET primary_slot_name = 'sonar_slot_2';

-- Step 3: Restart the standby instance to apply both changes
-- (This step is done from your operating system's command line, not psql)
-- pg_ctl restart -D /var/lib/postgresql/13/main
```
Stop/start this DB Standby.

standby1 - before
```
primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
primary_slot_name = 'sonar_slot_1'
```

standby1 - ater
```
primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=standby1'
primary_slot_name = 'sonar_slot_1'
```

standby2 - before
```
primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
primary_slot_name = 'sonar_slot_2'
```

standby2 - after
```
primary_conninfo = 'user=replicator password=abc123 channel_binding=prefer host=172.24.1.11 port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=standby1'
primary_slot_name = 'sonar_slot_2'
```

### PRIMARY - update postgresql.conf

I'm choosing "ANY 1".
Using "ANY 2" seems risky if a standby goes down.
```
##synchronous_standby_names = '*'
##synchronous_standby_names = 'ANY 2 (standby1, standby2)'
synchronous_standby_names = 'ANY 1 (standby1, standby2)'
```


## ALL - replication state

:: PRIMARY

```
Fri 2025Oct10 22:12:27 PDT
postgres@pgnode1
~/bin/sql
hist:113 -> ~/bin/replication_check_primary_v1.sh

Replication status on PRIMARY DB server.

-[ RECORD 1 ]----+------------------------------
pid              | 35801
usesysid         | 16386
usename          | replicator
application_name | standby1
client_addr      | 172.24.1.1
client_hostname  |
client_port      | 47200
backend_start    | 2025-10-10 21:35:06.327972-07
backend_xmin     |
state            | streaming
sent_lsn         | 0/702F4C0
write_lsn        | 0/702F4C0
flush_lsn        | 0/702F4C0
replay_lsn       | 0/702F4C0
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 1
sync_state       | quorum
reply_time       | 2025-10-10 22:19:05.612107-07
-[ RECORD 2 ]----+------------------------------
pid              | 35802
usesysid         | 16386
usename          | replicator
application_name | standby2
client_addr      | 172.24.1.2
client_hostname  |
client_port      | 49090
backend_start    | 2025-10-10 21:35:15.175904-07
backend_xmin     |
state            | streaming
sent_lsn         | 0/702F4C0
write_lsn        | 0/702F4C0
flush_lsn        | 0/702F4C0
replay_lsn       | 0/702F4C0
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 1
sync_state       | quorum
reply_time       | 2025-10-10 22:19:05.591798-07
```

:: STANDBY

Each standby shows the corresponding `application_name`.
Their LSB matches the PRIMARY: `0/702F4C0`

```
Fri 2025Oct10 22:20:20 PDT
postgres@pgnode2
~/bin/sql
hist:111 -> ~/bin/replication_check_standby_v1.sh

Replication status on SECONDARY DB server.

-[ RECORD 1 ]---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 30201
status                | streaming
receive_start_lsn     | 0/7000000
receive_start_tli     | 1
written_lsn           | 0/702F4C0
flushed_lsn           | 0/702F4C0
received_tli          | 1
last_msg_send_time    | 2025-10-10 22:20:05.634677-07
last_msg_receipt_time | 2025-10-10 22:20:05.63474-07
latest_end_lsn        | 0/702F4C0
latest_end_time       | 2025-10-10 22:05:04.871592-07
slot_name             | sonar_slot_1
sender_host           | 172.24.1.11
sender_port           | 5432
conninfo              | user=replicator password=******** channel_binding=prefer dbname=replication host=172.24.1.11 port=5432 application_name=standby1 fallback_application_name=13/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

```
Fri 2025Oct10 22:20:15 PDT
postgres@pgnode3
~/bin/sql
hist:102 -> ~/bin/replication_check_standby_v1.sh

Replication status on SECONDARY DB server.

-[ RECORD 1 ]---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 30041
status                | streaming
receive_start_lsn     | 0/7000000
receive_start_tli     | 1
written_lsn           | 0/702F4C0
flushed_lsn           | 0/702F4C0
received_tli          | 1
last_msg_send_time    | 2025-10-10 22:20:05.632808-07
last_msg_receipt_time | 2025-10-10 22:20:05.632938-07
latest_end_lsn        | 0/702F4C0
latest_end_time       | 2025-10-10 22:05:04.871576-07
slot_name             | sonar_slot_2
sender_host           | 172.24.1.11
sender_port           | 5432
conninfo              | user=replicator password=******** channel_binding=prefer dbname=replication host=172.24.1.11 port=5432 application_name=standby2 fallback_application_name=13/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

[-] REFERENCE


Google AI chat:
[https://www.google.com/search?q=For+this%2C+synchronous_standby_names+%3D+%27standby1%2C+standby2%27%2C+is+standby1+a+hostname+or+ip+address%2C+other%3F&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQIRiPAjIHCAIQIRiPAjIHCAMQIRiPAtIBCjIxODIxajBqMTWoAgiwAgHxBY307Bd4ouRq&sourceid=chrome&ie=UTF-8&udm=50&fbs=AIIjpHxU7SXXniUZfeShr2fp4giZud1z6kQpMfoEdCJxnpm_3W-pLdZZVzNY_L9_ftx08kxElMEpo90JBBY0TEXYKcN_lPATbVTMCnYfcHh7XdvGafSOvPSd3fidQPWr76qIT3UaGfj_2sRKINePkrsUa2Zmr3be064LWdVjznIbFo3ci9y1twO3ldT3BLxvCdpeg95EDVPBCcy9m_e1Y3-kNb3KqMhuew&ved=2ahUKEwjf5NiCnpuQAxW-kmoFHdVeNlUQ0NsOegQIFRAA&aep=10&ntc=1&mtid=o9PpaNTXKZ64qtsP9puPkQ4&mstk=AUtExfDv7zbUSwdWu7m8Up1BnPHGwHTJefTETPidGtaQEZ78p8Ntw3rBZ8987UX0PmaCaFnh43Yz6FZI9XbSG9X76O4TOPPxJDZt-tzgVqV8sBtuGkhbiR-Lf27nCKQAeRvvpWH01wXK0S-ChprDcGmG5WaZoiGx93F4C5MYBqIvYHW62Z532-XKjKOqozGlgW86E6ZsqLy5fxUcg9x1ZwLcOvNo4DUKGt7_atMzwIbSTdP5mHQ_aTEzsP9r22gleHgJu1oPJtLh22aiCJHiAlCLUhm5xcMEHMDISTPf-kbnTvKdJ3rF2FmE3p7iKHlHczecZ2BAPTCfp4lBgA&csuir=1]

[https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-SYNCHRONOUS-STANDBY-NAMES]

Streaming replication failover
[https://www.postgresql.fastware.com/postgresql-insider-str-rep-ope#:~:text=By%20doing%20the%20above%2C%20the,be%20met%20when%20running%20pg_rewind:]

11.3. Managing Multiple-Standby Servers
[https://www.interdb.jp/pg/pgsql11/03.html]

::
::::::::::::::
::

..............


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
