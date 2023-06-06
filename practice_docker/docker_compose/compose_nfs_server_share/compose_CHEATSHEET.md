
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

# Start specific container 

https://stackoverflow.com/questions/30233105/docker-compose-up-for-only-certain-containers

If you have several services in a compose file, use this command to start
just one of them -- one specific container.
```
-> docker compose up -d centos79-1
```

Use a compose file
```
-> docker compose --file compose_v3b_U2004.yaml up -d
-> docker compose --file compose_v3b_U2004.yaml down -v
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
###############################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=APPENDIX A :: compose help
---
 
```
-> docker compose --help

Usage:  docker compose [OPTIONS] COMMAND

Docker Compose

Options:
      --ansi string                Control when to print ANSI control characters ("never"|"always"|"auto") (default "auto")
      --compatibility              Run compose in backward compatibility mode
      --env-file string            Specify an alternate environment file.
  -f, --file stringArray           Compose configuration files
      --parallel int               Control max parallelism, -1 for unlimited (default -1)
      --profile stringArray        Specify a profile to enable
      --project-directory string   Specify an alternate working directory
                                   (default: the path of the, first specified, Compose file)
  -p, --project-name string        Project name

Commands:
  build       Build or rebuild services
  convert     Converts the compose file to platform's canonical format
  cp          Copy files/folders between a service container and the local filesystem
  create      Creates containers for a service.
  down        Stop and remove containers, networks
  events      Receive real time events from containers.
  exec        Execute a command in a running container.
  images      List images used by the created containers
  kill        Force stop service containers.
  logs        View output from containers
  ls          List running compose projects
  pause       Pause services
  port        Print the public port for a port binding.
  ps          List containers
  pull        Pull service images
  push        Push service images
  restart     Restart service containers
  rm          Removes stopped service containers
  run         Run a one-off command on a service.
  start       Start services
  stop        Stop services
  top         Display the running processes
  unpause     Unpause services
  up          Create and start containers
  version     Show the Docker Compose version information

Run 'docker compose COMMAND --help' for more information on a command.
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
=APPENDIX B :: psql :: manage the service
---

hist:473 -> docker exec -it c1 bash
[root@centos79-1 /]# yum whatprovides service
initscripts-9.49.53-1.el7.x86_64 : The inittab file and the /etc/init.d scripts
Repo        : base
Matched from:
Filename    : /sbin/service

[root@centos79-1 /]#  yum install initscripts-9.49.53-1.el7.x86_64
Dependencies Resolved
================================================================================================================================
 Package                                 Arch                    Version                            Repository             Size
================================================================================================================================
Installing:
 initscripts                             x86_64                  9.49.53-1.el7                      base                  440 k
Installing for dependencies:
 iproute                                 x86_64                  4.11.0-30.el7                      base                  805 k
 iptables                                x86_64                  1.4.21-35.el7                      base                  432 k
 libmnl                                  x86_64                  1.0.3-7.el7                        base                   23 k
 libnetfilter_conntrack                  x86_64                  1.0.6-1.el7_3                      base                   55 k
 libnfnetlink                            x86_64                  1.0.1-4.el7                        base                   26 k
 sysvinit-tools                          x86_64                  2.88-14.dsf.el7                    base                   63 k

Transaction Summary
================================================================================================================================
Install  1 Package (+6 Dependent packages)

Total download size: 1.8 M
Installed size: 5.1 M
Is this ok [y/d/N]:

[root@centos79-1 /]# service sshd status
Redirecting to /bin/systemctl status sshd.service
Failed to get D-Bus connection: No such file or directory


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


