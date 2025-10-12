=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: postgres cheatsheet
Author ....: devesplabs

[-] DESCRIPTION

Some description

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

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: postgres :: reload config
---

# Postgres Reload Config

Any one of these options can be used to reload the postgres config for changes that do not 
require a full restart.

Connect to PostgreSQL and reload configuration
```
psql -c "SELECT pg_reload_conf();"
```

Reload PostgreSQL service (no downtime)
```
sudo systemctl reload postgresql@13-main.service
```

As postgres user
```
pg_ctl reload -D /var/lib/postgresql/13/main
```

Find postgres main process and send SIGHUP
```
sudo pkill -HUP -f "postgres.*main"
```

Notes:
- pg_reload_conf() is the safest and most commonly used method
- No downtime - All these methods reload configuration without restarting PostgreSQL
- pg_hba.conf changes take effect immediately after reload
- postgresql.conf changes - Some settings require a restart, but authentication settings in pg_hba.conf only need a reload

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: postgres :: default data directory
---

## Default Data Directory

```
-> ls -l /var/lib/postgresql/13/main/
total 88
-rw------- 1 postgres postgres    3 Oct 10 14:11 PG_VERSION
drwx------ 7 postgres postgres 4096 Oct 10 15:19 base/
-rw------- 1 postgres postgres   58 Oct 11 00:30 current_logfiles
drwx------ 2 postgres postgres 4096 Oct 10 15:20 global/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_commit_ts/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_dynshmem/
drwx------ 4 postgres postgres 4096 Oct 11 19:49 pg_logical/
drwx------ 4 postgres postgres 4096 Oct 10 14:11 pg_multixact/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_notify/
drwx------ 7 postgres postgres 4096 Oct 10 14:52 pg_replslot/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_serial/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_snapshots/
drwx------ 2 postgres postgres 4096 Oct 10 15:19 pg_stat/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_stat_tmp/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_subtrans/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_tblspc/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_twophase/
drwx------ 3 postgres postgres 4096 Oct 10 20:34 pg_wal/
drwx------ 2 postgres postgres 4096 Oct 10 14:11 pg_xact/
-rw------- 1 postgres postgres   88 Oct 10 14:11 postgresql.auto.conf
-rw------- 1 postgres postgres  130 Oct 10 15:19 postmaster.opts
-rw------- 1 postgres postgres  101 Oct 10 15:19 postmaster.pid
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: postgres :: manage the service
---

## Manage the Postgres Service

Ensure that:
    - Postgresql is running in the primary
    - Postgresql is not running in the standby

FILE: `~/.aliasrc`
```
#
# Local commands
#
alias ltr='ls -latr'
alias ls='ls -C1F'
alias ll='ls -l'
alias la='ls -la'
alias ld='ls -1F'

alias pstart='sudo systemctl start postgresql@13-main.service --no-pager'
alias pstop='sudo systemctl stop postgresql@13-main.service --no-pager'
alias pstatus='sudo systemctl status postgresql@13-main.service --no-pager'
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: replication setup
---

## Replication Setup

Follow the steps in 
```
/Users/afoot/Documents/DATAL3/RESEARCH/project_PSQL/psql_active_research/psql_1_replication_slots.md
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: create replication user
---

Sat 2025Oct11 21:07:13 PDT

## Create replication user

Create the replicator user on the PRIMARY only.

First, login as the postgres user.

Then, create the new user 'replicator' user with password 'abc123'
```
    psql -c "CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'abc123';"
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: replication :: status
---

Sat 2025Oct11 21:07:13 PDT

## Replication Check

Primary.
FILE: `~/bin/replication_check_primary_v1.sh`
```
#!/bin/bash

echo
echo "Replication status on PRIMARY DB server."
echo
psql -x -c "select * from pg_stat_replication;"
echo
```

Standby.
FILE: `~/bin/replication_check_standby_v1.sh`
```
#!/bin/bash

echo
echo "Replication status on SECONDARY DB server."
echo
psql -x -c "select * from pg_stat_wal_receiver;"
echo
```

## Standby :: recoverfy status
Shows false (f) on primary.
Shows true (t) on standby.
```
psql -c "SELECT pg_is_in_recovery();"
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: replication :: slot check
---

Sat 2025Oct11 21:07:13 PDT

## Manage Replication Slots

https://pgpedia.info/p/pg_create_physical_replication_slot.html
See 
- `PSQL Manual '26.2.6.1. Querying and Manipulating Replication Slots'`
- [https://pgpedia.info/p/pg_drop_replication_slot.html]

Syntax: CREATE
```
    psql -c "SELECT * FROM pg_create_physical_replication_slot('sonar_a_slot');"
```
Syntax: DELETE
```
    psql -c "SELECT pg_drop_replication_slot('node2');"
```
Syntax: CHECK
```
    psql -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

    psql -c "SELECT application_name, client_addr, state FROM pg_stat_replication;"
```

**IMPORTANT**
Replication slots only exist on the active primary.
If you failover to a standby, you must create replication slots for new standby

Check WAL sender processes
```
psql -c "SELECT pid, state, sent_lsn, write_lsn FROM pg_stat_replication;"
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: connection test
---

Sat 2025Oct11 21:07:13 PDT

## Connection test

Do a connection test before doing the data transfer from PRIMARY to SECONDARY.

Test one of two ways:
    • Use the sonar postgres user created as part of the ansible role
    • create a temp user and a temp database

Then connect to the PRIMARY from a client.

Syntax:
    /bin/psql -U sonar -h <primary-ip-address>  -d <database>

Connect with the sonar user and DB.
    • User: `replicator`
    • Pass: `abc123`
    • DB: `postgres`
```
-> psql -h 10.233.218.199 -U replicator -d postgres
psql (13.22 (Ubuntu 13.22-1.pgdg22.04+1), server 13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.

postgres=> \q
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: pg_basebackup
---

## Data Transfer :: pg_basebackup

On the STANDBY, perform data transfer

Stop the postgres service before the transfer.

Start a screen session as this may take some time depending on data size.
```
screen -S afdev1
echo $TERM
```

NOTE: 
(1) do not run the script in the background… you need to enter the replicator password
(2) update the SOURCE ip address in the script

Actual example used -- change the ip address for the actual source DB host
Create script: `/postgres/bin/pgbackup-transfer.sh`
```
time /usr/bin/pg_basebackup \
-S sonar_slot_1 \
-h 172.24.1.11 \
-U replicator \
-p 5432 \
-D /db/pg_from_master \
--write-recovery-conf \
--wal-method=stream \
--format=p \
--progress --password --verbose
```

Options used:
  -p, --port=PORT        database server port number
  -U, --username=NAME    connect as specified database user
  -F, --format=p|t       output format (plain (default), tar)
  -P, --progress         show progress information
  -X, --wal-method=none|fetch|stream
  -R, --write-recovery-conf
  -v, --verbose          output verbose messages


### transfer summary 

```
cat /db/pg_from_master/postgresql.auto.conf

cat /db/pg_from_master/backup_label

ls -l /db/pg_from_master/standby.signal
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=PSQL :: config files :: primary, one standby
---

# Config File for PRIMARY and one STANDBY

## PRIMARY
FILE: /etc/postgresql/13/main/postgresql.conf
```
#------------------------------------------------------------------------------
# MODIFIED BY ANSIBLE ROLE TEMPLATE
#------------------------------------------------------------------------------

data_directory  = '/var/lib/postgresql/13/main/'
hba_file  = '/etc/postgresql/13/main/pg_hba.conf'
ident_file  = '/etc/postgresql/13/main/pg_ident.conf'

listen_addresses  = '*'
port  =  '5432'
ssl  = 'False'
datestyle  = 'iso, mdy'
default_text_search_config  = 'pg_catalog.english'

wal_level  = 'replica'
synchronous_commit = 'local'

max_wal_senders = '203'
wal_sender_timeout = '120s'

synchronous_standby_names = '*'

max_replication_slots = '200'

# Autovacuum Settings
autovacuum_max_workers = '6'
autovacuum_vacuum_cost_limit = '1000'

#######################################

```

## STANDBY
FILE: /etc/postgresql/13/main/postgresql.conf
```
#------------------------------------------------------------------------------
# MODIFIED BY ANSIBLE ROLE TEMPLATE
#------------------------------------------------------------------------------

data_directory  = '/var/lib/postgresql/13/main/'
hba_file  = '/etc/postgresql/13/main/pg_hba.conf'
ident_file  = '/etc/postgresql/13/main/pg_ident.conf'

listen_addresses  = '*'
port  =  '5432'
ssl  = 'False'
datestyle  = 'iso, mdy'
default_text_search_config  = 'pg_catalog.english'

wal_level  = 'replica'
synchronous_commit = 'local'

max_wal_senders = '203'
wal_sender_timeout = '120s'

synchronous_standby_names = '*'

hot_standby = on

max_replication_slots = '200'

# Autovacuum Settings - CHG2823480
autovacuum_max_workers = '6'
autovacuum_vacuum_cost_limit = '1000'
```

## All Hosts :: HBA

Modify the ip addresses in the IPv4 section for the current environment.

FILE: `/etc/postgresql/13/main/pg_hba.conf`
```
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             172.24.1.11/32          trust #pgnode1
host    all             all             172.24.1.1/32           trust #pgnode2
host    all             all             172.24.1.2/32           trust #pgnode3
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
=PSQL :: data test
---

Sat 2025Oct11 20:29:07 PDT

##  Data Verification

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

## SQL Files

Crete the file in ~/bin.
Run like this:
```
psql -f <filename>
```

FILE: `tables_test_create.sql`
```
-- Table 1: users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

INSERT INTO users (username, email) VALUES ('testuser', 'testuser@example.com');

-- Table 2: products
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

INSERT INTO products (name, price) VALUES ('Sample Product', 19.99);

-- Table 3: orders
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (user_id, product_id) VALUES (1, 1);
```

FILE: `tables_test_query.sql`
```
--- query tables
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;
```


FILE: `tables_test_drop.sql`
```
-- Drop tables for replication test
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
```

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
