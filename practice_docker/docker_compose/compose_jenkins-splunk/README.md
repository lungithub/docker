=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: Jenkins - Splunk
Author ....: afoot

[-] DESCRIPTION

Docker compose jenkins, splunk.

[-] DEPENDENCIES
none

[-] REQUIREMENTS
none

[-] CAVEATS
none

[-] REFERENCE

## Project Location
> /Users/orion/Documents/DATAM2/EDUCATION/RESEARCH/project_Jenkins/jenkins_installation/jenkins_install_docker_compose

## Jenkins

=JENKINS :: WebUI Access

## Splunk

=SPLUNK :: WebUI Access

-------------------------------------------------------------------------------
[-] Revision History

Date: Mon 2023Aug21 19:09:04 PDT
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=ENVIRONMENT :: starting environment
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=JENKINS :: docker compose :: spin up envionment
---

## Jenkins 

Project structure:
```
Mon 2023Aug21 18:35:01 PDT
orion@devesp  git(main)
~/Documents/DATAM1/MyCode/DOCKER/practice_docker/docker_compose/compose_jenkins
hist:482 -> ll
total 40
-rw-r--r--   1 orion  staff  1110 Jun 26 18:51 README.md
drwxr-xr-x   4 orion  staff   128 Jun 16 15:34 app/
-rw-r--r--   1 orion  staff  6835 Aug 21 18:35 compose-jenkins-splunk_v1.yaml
-rw-r--r--   1 orion  staff  6835 Aug 21 18:35 compose.yaml
drwxr-xr-x   5 orion  staff   160 Jun 16 15:34 data/
drwxr-xr-x   3 orion  staff    96 Mar 11 18:39 grafana/
drwxr-xr-x  38 orion  staff  1216 Aug 21 18:33 jenkins_configuration/
drwxr-xr-x   7 orion  staff   224 Mar 11 18:39 prometheus/
```

## Configuration

## Deploy with docker compose
When deploying this setup, the pgAdmin web interface will be available at port 5050 (e.g. http://localhost:5050).  

```
$ docker compose up -d
```

## Stop and restart the environment

Stop the env.
```
-> docker compose stop
```
Restart
```
-> docker compose sart
```

Bring down the env.
```
-> docker compose down
```
Bring down the env and delete all data
```
-> docker compose down -v
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=JENKINS :: WebUI Access
---

## Jenkins instance

  http://localhost:8080

## Users - Jenkins

user: admin
  pass: aaaaaa
user: devadmin
  pass: aaaaaa  
user: devuser
  pass: aaaaaa
  Token name: jenkins-token1
  Token value: 118a940141447b4bb840812e404d54b682

## Users - Splunk

user: admin
  pass: abc12345

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=SPLUNK :: WebUI Access
---

[http://localhost:8000/]

user: admin
pass: abc12345

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
###############################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=APPENDIX A :: container :: extra data on some task
---

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

