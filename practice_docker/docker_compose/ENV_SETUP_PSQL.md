
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: crete docker compose environment
Author ....: afoot

[-] DESCRIPTION

Create a DOCKER COMPOSE dev environment.

It takes 1min to start a docker compose environment.
It takes 3mins to configure one container for postgres.
It takes 10mins to have a complete environment with three containers ready to use.

[-] DEPENDENCIES
none

[-] REQUIREMENTS
none

[-] CAVEATS
none

[-] REFERENCE

-------------------------------------------------------------------------------
[-] Revision History

Date: Mon 2023Jan16 13:01:00 PST
Author: foot
Reason for change: refined the scripts to automate the provisioning process

Date: Sat 2023Jan14 12:13:58 PST
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=ENVIRONMENT :: starting environment
---

Mactop.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: start environment
---

# Create Containers

Go to the parent dir of the docker compose file.
Point the compose.yaml link to the file version to use.
```
cd ~/Documents/DATAM1/MyCode/DOCKER/practice_docker/docker_compose/compose_psql-replication

```

Start the environment
```
-> docker compose up -d
```

Check the containers are running
```
-> docker ps
```

Login to a container
```
-> docker exec -it c1 bash
```

Check the shared `/hostdata` host path is mounted
```
[root@server01 /]# df -h /hostdata
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: set up user environment
---

# Root SHELL Environment

Login to a container.
You will be logged in as the root user.
```
->  docker exec -it c1 bash
```

Run the script to copy the DOT env files
```
cd /hostdata/app/initial_sys_config/environment_config
./env_setup.sh
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: customize os
---

# Resources for this Task

The installation scripts are in this directory:
> /hostdata/data/env_config/psql_config
See `APPENDIX A :: psql :: what do I have in there?`

# Install CentOS packages

Tasks:
- installs all centos packages
- copies customized /etc/sudoers and /etc/group file
- sets the timezone to PST
```
/hostdata/app/initial_sys_config/generic_install/install_generic_packages_CentOS8_v2.sh
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: install postgres
---

Sat 2023Jan14 13:42:59 PST

# Run the PSQL installation script as root
- install psql packages
- create `postgres` user system account
- configure the postgres user with SUDO
- create link to /db/pg${VERSION}
- create log directory
- copy files to manage the service
```
/hostdata/app/psql/install/psql_install.sh
```

# Check postgres user environment
Su to the postgres user
```
root# su - postgres
posrgres$ sudo tail /etc/shadow
```

Initialize the DB cluster as the postgres user.
```
postgres$ /usr/pgsql-13/bin/initdb -D /db/pg13
```

Now you can manage the psql service as the postgres user.
```
postgres$ pstart
postgres$ pstatus
postgres$ pstop
```

The Postgres environment is ready to use

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: stop the docker compose environment
---

Sat 2023Jan14 14:33:07 PST

# Stop the environment

You can pause the entire environment and restart at a later time.

Stop the containers with
```
-> docker compose stop
```

This works also.
``` 
$ docker compose down
# To delete all data run:
$ docker compose down -v
```

# Restart the environment

```
-> docker compose start
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
###############################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=APPENDIX A :: psql :: what do I have in there?
---

Sat 2023Jan14 20:48:55 UTC

Go to the directory containing the installation scripts.
```
Fri 2023Jun16 18:07:53 PDT
hist:13 -> ll
total 0
drwxr-xr-x 20 root root 640 Jun 16 15:55 initial_sys_config/
drwxr-xr-x  6 root root 192 Jun 16 16:15 psql
```

What do i have in there?
- A script to install CentOS package: `install_centos_packages.sh`
- A script to install Postgresql v13: `install_psql.sh`
- A directory name `files` with config files for the package installations.
```
-> ll /hostdata/app/initial_sys_config/
total 0
drwxr-xr-x  5 root root 160 Jun 16 15:32 adduser/
drwxr-xr-x  6 root root 192 Jun 16 15:32 ansible_install/
drwxr-xr-x  3 root root  96 Jun 16 15:32 docker_install/
drwxr-xr-x 10 root root 320 Jun 16 15:32 environment_config/
drwxr-xr-x 11 root root 352 Jun 16 15:38 generic_install/
drwxr-xr-x  4 root root 128 Jun 16 15:32 helper_scripts/
drwxr-xr-x 18 root root 576 Jun 16 15:32 java_install/
drwxr-xr-x  5 root root 160 Jun 16 15:32 jenkins_install/
drwxr-xr-x  8 root root 256 Jun 16 15:32 k8s_install/
drwxr-xr-x  3 root root  96 Jun 16 15:32 misc_install/
drwxr-xr-x  4 root root 128 Jun 16 15:32 nginx_install/
drwxr-xr-x  9 root root 288 Jun 16 15:32 ntp_install/
drwxr-xr-x  3 root root  96 Jun 16 15:32 perl_install/
drwxr-xr-x  6 root root 192 Jun 16 15:32 python_install/
drwxr-xr-x  3 root root  96 Jun 16 15:32 ruby_install/

hist:15 -> ll /hostdata/app/psql
total 4
-rw-r--r--  1 root root  14 Jun 16 16:15 README.md
drwxr-xr-x 15 root root 480 Jun 16 16:15 files/
drwxr-xr-x  7 root root 224 Jun 16 16:15 install/

-> ll /hostdata/app/psql/files/
-rw-r--r-- 1 root root   389 Jun 16 16:15 etc_group
-rw-r--r-- 1 root root  4374 Jun 16 16:15 etc_sudoers
-rw-r--r-- 1 root root   353 Jun 16 16:15 master_postgresql.auto.conf
-rw-r--r-- 1 root root   866 Jun 16 16:15 master_postgresql.conf
-rw-r--r-- 1 root root  4760 Jun 16 16:15 pg_hba.conf_ORIG
-rw-r--r-- 1 root root   832 Jun 16 16:15 pg_hba_ALL.conf
-rw-r--r-- 1 root root    88 Jun 16 16:15 postgresql.auto.conf_ORIG
-rw-r--r-- 1 root root 28031 Jun 16 16:15 postgresql.conf_ORIG
-rw-r--r-- 1 root root   111 Jun 16 16:15 psreload.sh
-rw-r--r-- 1 root root   109 Jun 16 16:15 pstart.sh
-rw-r--r-- 1 root root   111 Jun 16 16:15 pstatus.sh
-rw-r--r-- 1 root root   107 Jun 16 16:15 pstop.sh
-rw-r--r-- 1 root root   586 Jun 16 16:15 slave_postgresql.conf

-> ll /hostdata/app/psql/install/
-rwxr-xr-x 1 root root  817 Jun 16 16:15 psql_copy_management_files.sh*
-rwxr-xr-x 1 root root  646 Jun 16 16:15 psql_copy_sudo.sh*
-rwxr-xr-x 1 root root 2199 Jun 16 16:22 psql_install.sh*
-rwxr-xr-x 1 root root  613 Jun 16 16:15 replication_check_primary_v1.sh*
-rwxr-xr-x 1 root root  362 Jun 16 16:15 replication_check_standby_v1.sh*
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=APPENDIX B :: psql :: manage the service
---

# PSQL :: manage the service 
The version number changes depending on on the PSQL version installed

For example, v13 looks like this:

```
/usr/pgsql-13/bin/pg_ctl -D /db/pg13 -l logfile stop
/usr/pgsql-13/bin/pg_ctl -D /db/pg13 -l logfile start
/usr/pgsql-13/bin/pg_ctl -D /db/pg13 -l logfile restart
/usr/pgsql-13/bin/pg_ctl -D /db/pg13 -l logfile reload
/usr/pgsql-13/bin/pg_ctl -D /db/pg13 -l logfile status
```

For example, v11 looks like this:
```
/usr/pgsql-11/bin/pg_ctl -D /db/pg11 -l logfile stop
/usr/pgsql-11/bin/pg_ctl -D /db/pg11 -l logfile start
/usr/pgsql-11/bin/pg_ctl -D /db/pg11 -l logfile restart
/usr/pgsql-11/bin/pg_ctl -D /db/pg11 -l logfile reload
/usr/pgsql-11/bin/pg_ctl -D /db/pg11 -l logfile status
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=OUTPUT A :: stdout :: result of running some command or script at the CLI
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=INFO A :: some informational bit about this subject
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=FILE A :: filename :: relevant contents of config file
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=TROUBLESHOOTING A :: additional pitfalls to look for
---

[-] PROBLEM

[-] SOLUTION

[-] REFERENCE

::
::::::::::::::
::

..............

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
