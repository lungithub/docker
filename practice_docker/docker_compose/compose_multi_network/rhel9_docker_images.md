
Thu 2023Jun08 20:10:22 PDT

https://developers.redhat.com/blog/2020/03/24/red-hat-universal-base-images-for-docker-users#introducing_red_hat_universal_base_images


do a search for all UBI base images on the Red Hat Container Registry:
https://catalog.redhat.com/

RHEL 9
```
Thu 2023Jun08 20:09:40 PDT
orion@devesp
~/Documents/DATAM1/MyCode/DOCKER_RESOURCES
hist:487 -> docker search registry.access.redhat.com/ubi | grep ubi9
ubi9/go-toolset           rhcc_registry.access.redhat.com_ubi9/go-tool…   0
ubi9-beta/ubi             Provides the latest release of Red Hat Unive…   0
ubi9-beta/ubi-minimal     Provides the latest release of the Minimal R…   0
ubi9/ubi-init             rhcc_registry.access.redhat.com_ubi9/ubi-init   0
ubi9-init                 rhcc_registry.access.redhat.com_ubi9-init       0
ubi9-micro                rhcc_registry.access.redhat.com_ubi9-micro      0
ubi9/ubi                  rhcc_registry.access.redhat.com_ubi9/ubi        0
ubi9                      rhcc_registry.access.redhat.com_ubi9            0
ubi9-beta/ubi-init        Provides the latest release of the Red Hat U…   0
ubi9-beta/ubi-micro       Provides the latest release of Micro Univers…   0
ubi9/ubi-minimal          rhcc_registry.access.redhat.com_ubi9/ubi-min…   0
ubi9/ubi-micro            rhcc_registry.access.redhat.com_ubi9/ubi-mic…   0
ubi9-minimal              rhcc_registry.access.redhat.com_ubi9-minimal    0
ubi9-beta/toolbox         Toolbox containerized shell image based in U…   0
ubi9/toolbox              rhcc_registry.access.redhat.com_ubi9/toolbox    0
ubi9/openjdk-11-runtime   rhcc_registry.access.redhat.com_ubi9/openjdk…   0
ubi9/openjdk-17-runtime   rhcc_registry.access.redhat.com_ubi9/openjdk…   0
```

RHEL 8
```
Thu 2023Jun08 20:09:55 PDT
orion@devesp
~/Documents/DATAM1/MyCode/DOCKER_RESOURCES
hist:488 -> docker search registry.access.redhat.com/ubi | grep ubi8
ubi8/go-toolset           Platform for building and running Go 1.11.5 …   0
ubi8/openjdk-8-runtime    OpenJDK 1.8 runtime-only image on Red Hat Un…   0
ubi8/openjdk-11-runtime   OpenJDK 11 runtime-only image on Red Hat Uni…   0
ubi8/openjdk-17-runtime   OpenJDK 17 runtime-only image on Red Hat Uni…   0
ubi8/ubi                  Provides the latest release of the Red Hat U…   0
ubi8                      The Universal Base Image is designed and eng…   0
ubi8/ubi-minimal          Provides the latest release of the Minimal R…   0
ubi8/ubi-init             Provides the latest release of the Red Hat U…   0
ubi8-init                 The Universal Base Image Init is designed to…   0
ubi8-micro                Provides the latest release of Micro Univers…   0
ubi8-minimal              The Universal Base Image Minimal is a stripp…   0
ubi8/ubi-micro            Provides the latest release of Micro Univers…   0
ubi8/php-72               Platform for building and running PHP 7.2 ap…   0
ubi8/s2i-core             Base image which allows using of source-to-i…   0
```

Now, start a UBI test container running an interactive shell:
```
$ docker run -it --name test registry.access.redhat.com/ubi8/ubi:8.1 bash

Thu 2023Jun08 20:20:18 PDT
orion@devesp
~/Documents/DATAM1/MyCode/DOCKER_RESOURCES
hist:495 -> docker run -it --name test registry.access.redhat.com/ubi9
[root@e8a75797ae3a /]#

```
Inside the test container, list its preconfigured Yum repositories:
```
[root@de1d73d88418 /]# yum repolist
```
You can also search for individual packages available from these repositories. The following example searches for Nginx web server packages:
```
[root@de1d73d88418 /]# yum search nginx
```

Installed a package, but could not start the service with SYSTEMD
```
[root@e8a75797ae3a /]# yum install openssh-server

[root@e8a75797ae3a /]# systemctl status openssh
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
```

https://superuser.com/questions/774291/centos-6-5-bash-service-command-not-found
To have /sbin/service again run `yum reinstall initscripts`. 

https://linuxhandbook.com/system-has-not-been-booted-with-systemd/

Systemd command 	Sysvinit command
```
systemctl start service_name 	service service_name start
systemctl stop service_name 	service service_name stop
systemctl restart service_name 	service service_name restart
systemctl status service_name 	service service_name status
systemctl enable service_name 	chkconfig service_name on
systemctl disable service_name 	chkconfig service_name off
```

Need to install `initscripts-service`
Need to register with RedHat to install.
```
[root@e8a75797ae3a sbin]# yum whatprovides service
Updating Subscription Management repositories.
Unable to read consumer identity
Subscription Manager is operating in container mode.

This system is not registered with an entitlement server. You can use subscription-manager to register.

Last metadata expiration check: 0:07:54 ago on Fri Jun  9 03:20:59 2023.
initscripts-service-10.11.5-1.el9.noarch : Support for service command
Repo        : ubi-9-baseos-rpms
Matched from:
Filename    : /usr/sbin/service
Provide    : /sbin/service

[root@e8a75797ae3a /]# yum reinstall initscripts
Updating Subscription Management repositories.
Unable to read consumer identity
Subscription Manager is operating in container mode.

This system is not registered with an entitlement server. You can use subscription-manager to register.

Last metadata expiration check: 0:04:36 ago on Fri Jun  9 03:20:59 2023.
Package initscripts available, but not installed.
No match for argument: initscripts

[root@e8a75797ae3a sbin]# which subscription-manager
/usr/sbin/subscription-manager

```