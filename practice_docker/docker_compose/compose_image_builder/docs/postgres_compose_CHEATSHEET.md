=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: postgres docker cheatsheet
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

Date: Mon 2025Oct20 10:48:07 PDT 
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=ENVIRONMENT :: starting environment
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TOOL :: timeline
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER  :: compose :: install postgres
---

## Install Postgres

Update the `PG_VERSION` var in the install script before running.

```
cd /hostdata/app/psql/psql-ubuntu2204/install-postgres;
./install_psql_U2204_v1-movedir.sh
echo;
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER  :: compose :: recreate a service
---

Mon 2025Oct20 10:48:07 PDT

## Recreate Container

Docker Compose commands to recreate the pgnode1 container:

Stop the pgnode1 service:
```
docker compose stop pgnode1
```
Remove the pgnode1 container:
```
docker compose rm -f pgnode1
```
Start the pgnode1 service again:
```
docker compose up -d pgnode1
```
Alternative single command:
```
docker compose up -d --force-recreate pgnode1
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