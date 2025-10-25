=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Subject ...: Docker
Author ....: John Doe

[-] DESCRIPTION

Some description

[-] DEPENDENCIES
none

[-] REQUIREMENTS
none

[-] CAVEATS
none

[-] REFERENCE

Docker Compose CLI Reference
[https://docs.docker.com/reference/cli/docker/compose/]

-------------------------------------------------------------------------------
[-] Revision History

Date: Tue 2025Oct14 12:31:03 PDT 
Author: foot
Reason for change: Initial doc

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=ENVIRONMENT :: starting environment
---

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=TOOL :: timeline
---

Tue 2025Oct14 12:31:03 PDT

## Change Timezone

Set PST Time

```
-> sudo ln -s /usr/share/zoneinfo/PST8PDT /etc/localtime
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: start environment
---

Tue 2025Oct14 12:31:03 PDT

## Compose :: Start Environment

Start docker compose environment in detached mode.
```
docker compose up -d
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=COMPOSE :: stop environment
---

Tue 2025Oct14 11:55:12 PDT

## Compose :: Stop or Restart Environment

This is the command to use for a temporary halt.
```
docker compose stop
```

Action: Stops all running containers defined in the docker-compose.yml file.
Result: The containers remain on your system in a "stopped" state. All networks and volumes are preserved.
Use Case: When you want to pause your application for a period and resume it later, without losing any data or configuratio

Restart the environment.
```
docker compose start
```
:::::::::::::::

Feature         docker compose `stop`                            docker compose `down`
------------    ---------------------------------------------    ---------------------------------------------
Containers	    Stops them. They can be restarted later.	    Stops and removes them.

Networks	    Retains them.	                                Removes them.

Volumes	        Retains them (unless they are anonymous).	    Removes them if they were created without an explicit name, 
                                                                and will remove explicitly named volumes if you add the -v flag.

State	        Preserves the state of the environment,         Tears down the entire environment. A new docker compose up will 
                allowing a quick restart with docker compose    build a fresh environment.
                start.	

:::::::::::::::

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=POSTGRES :: manage the service
---

```
sudo systemctl start postgresql@13-main.service --no-pager
sudo systemctl stop postgresql@13-main.service --no-pager
sudo systemctl status postgresql@13-main.service --no-pager
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER :: postgres user and group check
---

## Check for Postgres User and Group

```
getent group postgres
getent passwd postgres
```
If the group or user does not exist, create them with:
```
sudo groupadd -g 112 postgres
sudo useradd -r -u 112 -g postgres postgres
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER :: stop docker compose service
---

## Stop Docker Compose Service

Stop the service
Remove the container
Start the service anew
```
docker compose stop pgnode1;
docker compose rm -f pgnode1;
docker compose up -d pgnode1;
echo
```

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER :: remove containers
---

## Remove Specific Containers
To remove specific containers, use the following command:
```
docker compose rm -f <container_name>
```
Replace `<container_name>` with the name of the container you want to remove.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER :: pull policy
---

`pull_policy:` never option to prevent Docker from trying to pull these local images from an external registry.
This is useful in scenarios where you have local images that you want to use without the overhead of checking a remote registry.


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=DOCKER :: using docker snapshots in docker compose
---

## Using Docker Snapshots

Suppose you created a snapshot of your Docker container using the `docker commit` command. You can then use this snapshot in your Docker Compose file by specifying the image name and tag.

## Example using Snapshot in Compose

I started a compose environment using the following configuration with a custom docker image.
```
  pgnode1:
    image: dockio/u2204-arm64v8:1.0
    pull_policy: never
...    
```
Once I customized the container and took a snapshot, I had the following image available:
```
-> docker images | grep pgnode
dockio/pgnode1-snapshot                             20251007-151621        47386d25ba4e   9 days ago      2.96GB
```
Then I modified the compose file to use that image instead of the one initially used to create the container.
```
  pgnode1:
    # image: ubuntu:22.04
    # image: dockio/u2204-arm64v8:1.0
    image: dockio/pgnode1-snapshot:20251007-151621
    pull_policy: never
...    
```
For the image name, that is using:
- the name of the snapshot
- the timestamp of the snapshot
Here I use `pull_policy: never` to prevent Docker from trying to pull the image from a remote registry, ensuring that it uses the local snapshot instead.

Once the container is up, use a command such as this to check whether a utility is present.
```
 -> docker compose exec pgnode1 bash -c "which traceroute"
/usr/sbin/traceroute
```
That indicates that all the previously installed utilities are present in the container.

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
