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

Q: why does git status shows .DS_Store even after adding it to the .gitignore?

```
Sat 2025Jun21 14:50:17 PDT 
orion@devesp  git(main)
~/Documents/DATAM2/learning/MyConfig/initial_sys_config 
hist:501 -> gs
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .DS_Store
        deleted:    chrony_install/install_chrony_Ubuntu_U2004.sh
        modified:   docker_install/install_docker_U2204.sh
        modified:   java_install/install_openjdk17_U2204.sh
        modified:   misc_install/install_rvm_U22.04.sh

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        chrony_install/install_chrony_Ubuntu_U2204.sh
```

If git status still shows .DS_Store after you’ve added it to your .gitignore, it’s likely because .DS_Store was already tracked by git before you updated .gitignore. The .gitignore file only prevents new files from being tracked; it does not affect files that are already in the repository.

```
git rm --cached .DS_Store
git add .gitignore
git commit -m "Stop tracking .DS_Store and update .gitignore
```

This will remove .DS_Store from the repository (but not from your local filesystem) and ensure it’s ignored in the future.

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
=COMPOSE :: systemd entry point
---

Sat 2025Jun21 14:21:26 PDT

I was not able to use `systemctl` to manage services.
Here I explain how to fix that to make it work.

## SystemD on Containers

Initial i had this config. 
But `systemctl` commands were not working.
```yaml
  devops-u1:
    image: dockio/u2204-devesp:1.0
    networks:
      custom-network:
        priority: 10
        ipv4_address: "172.30.1.11"      
    hostname: devops-u1
    container_name: devops-u1
    privileged: true
    restart: on-failure
    volumes:
      - "./:/hostdata" 
      - "/Users/orion/Documents/DATAM1/MyCode:/MyCode"     
      - "/Users/orion/Documents/DATAM2/learning/MyConfig:/MyConfig"
    command: ["sleep", "infinity"]      
```

I was getting this error.
```
-> systemctl status ssh
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
```

This error occurs because your container is not running with systemd as PID 1, so commands like systemctl will not work. In your compose.yaml, you are using:
```
command: ["sleep", "infinity"]
```
or
```
entrypoint: ["/usr/sbin/init"]
command: ["sleep", "infinity"]
```

But systemctl only works if systemd is PID 1 (the main process in the container). Here’s how to fix it:

Solution:
Remove the command: ["sleep", "infinity"] line from your RHEL-based containers (e.g., devops-r1, devops-r2).
Make sure the entrypoint is set to ["/usr/sbin/init"] (which starts systemd as PID 1).

Why:
If you specify both entrypoint and command, Docker will run /usr/sbin/init sleep infinity, which is not what you want.
You want /usr/sbin/init to be PID 1, so systemd manages the container.
What to do:

Remove the command line from `compose.yaml`.

I replaced the `command` line with the `entrypoint` line.
This works if the OS images supports it. And it does.

This configuration enables `systemd` on Ubuntu2204.

```yaml
  devops-u1:
    image: dockio/u2204-devesp:1.0
    networks:
      custom-network:
        priority: 10
        ipv4_address: "172.30.1.11"      
    hostname: devops-u1
    container_name: devops-u1
    privileged: true
    restart: on-failure
    volumes:
      - "./:/hostdata" 
      - "/Users/orion/Documents/DATAM1/MyCode:/MyCode"     
      - "/Users/orion/Documents/DATAM2/learning/MyConfig:/MyConfig"
    entrypoint: ["/sbin/init"]
```

You can use `systemctl` to manage services.

```bash
Sat 2025Jun21 14:21:26 PDT
orion@devesp  git(main)
~/Documents/DATAM1/MyCode/DOCKER_CODE/practice_docker/docker_compose/compose_allpurpose
hist:528 -> docker exec -it devops-u1  bash

Sat 2025Jun21 21:21:31 UTC
root@devops-u1
/
hist:13 -> systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-06-21 21:19:40 UTC; 2min 3s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 50 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 54 (sshd)
      Tasks: 1 (limit: 19648)
     Memory: 1.7M
        CPU: 20ms
     CGroup: /system.slice/ssh.service
             └─54 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Jun 21 21:19:40 devops-u1 systemd[1]: Starting OpenBSD Secure Shell server...
Jun 21 21:19:40 devops-u1 sshd[54]: Server listening on 0.0.0.0 port 22.
Jun 21 21:19:40 devops-u1 sshd[54]: Server listening on :: port 22.
Jun 21 21:19:40 devops-u1 systemd[1]: Started OpenBSD Secure Shell server
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

In the ubuntu container, I'm getting this, why?
```
Sat 2025Jun21 21:23:29 UTC
root@devops-u1
st:14 -> grafana-cicd | logger=context userId=0 orgId=0 uname= t=2025-06-21T21:24:08.01873784Z level=info msg="Request Completed" method=GET path=/api/live/ws status=401 remote_addr=192.168.65.1 time_ms=0 duration=459.514µs size=27 referer= handler=/api/live/ws
grafana-cicd | logger=context userId=0 orgId=0 uname= t=2025-06-21T21:25:08.028898078Z level=info msg="Request Completed" method=GET path=/api/live/ws status=401 remote_addr=192.168.65.1 time_ms=0 duration=343.007µs size=27 referer= handler=/api/live/ws
```

[-] SOLUTION

The log message you are seeing from the Grafana container:
```
logger=context userId=0 orgId=0 uname= ...
```

means that an unauthenticated (not logged in) request was made to the Grafana live websocket API endpoint (/api/live/ws), and Grafana returned a 401 Unauthorized response.

Why does this happen?

This is normal if a browser or some client tries to connect to Grafana's live features (like dashboards with live updates) without being logged in.
It does not indicate a problem with your Ubuntu container or your Docker Compose setup.
It is just an informational log from Grafana, not an error in your Ubuntu container.

What should you do?

If you are not experiencing issues using Grafana, you can ignore these log entries.
If you want to avoid them, make sure you are logged in to Grafana in your browser when accessing dashboards that use live features.

Summary:
This is a normal log from Grafana indicating an unauthenticated request. It is not a problem with your Ubuntu container or Docker Compose environment.

[-] REFERENCE

::
::::::::::::::
::

..............

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

