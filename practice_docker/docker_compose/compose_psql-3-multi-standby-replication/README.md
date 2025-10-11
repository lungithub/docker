## PostgreSQL and pgAdmin
This example provides a base setup for using [PostgreSQL](https://www.postgresql.org/) and [pgAdmin](https://www.pgadmin.org/).
More details on how to customize the installation and the compose file can be found [here (PostgreSQL)](https://hub.docker.com/_/postgres) and [here (pgAdmin)](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html).

Project structure:
```
.
-> ll
total 72
-rw-r--r--  1 afoot  staff   584 Jul  6 14:54 LICENSE
-rw-r--r--  1 afoot  staff  2385 Jul  6 14:54 README.md
drwxr-xr-x  5 afoot  staff   160 Nov  2 05:52 app/
-rw-r--r--  1 afoot  staff  6884 Nov  2 11:11 compose.yaml
-rw-r--r--  1 afoot  staff  1599 Jul  6 14:54 compose_v1.yaml
-rw-r--r--  1 afoot  staff  1933 Jul  6 14:54 compose_v2.yaml
-rw-r--r--  1 afoot  staff  2433 Jul  6 14:54 compose_v3.yaml
-rw-r--r--  1 afoot  staff  4962 Jul  6 14:54 compose_v4.yaml
drwxr-xr-x  4 afoot  staff   128 Jul  6 14:54 data/
drwxr-xr-x  3 afoot  staff    96 Jul  6 14:54 grafana/
drwxr-xr-x  7 afoot  staff   224 Jul  6 14:54 prometheus/
```

Sample compose stanza.
```
#
# Ansible - Control
#  
  ansiblecontrol:
    # image: arm64v8/ubuntu:22.04
    image: dockio/u2204-arm64v8:1.0
    networks:
      net1:
        priority: 10
        ipv4_address: "172.24.1.18"
      net2:
        priority: 0
      net3:
        priority: 0
    hostname: ansiblecontrol
    container_name: ansiblecontrol
    privileged: true 
    restart: on-failure
    volumes:
      - "./:/hostdata"      
    command: ["sleep", "infinity"]  

```


## Deploy with docker compose

When deploying this setup, the pgAdmin web interface will be available at port 5050 (e.g. http://localhost:5050).  

``` shell
-> cd ~/Documents/DATAL1/MyCode/compose_psql-repmgr-WM-AARCH64-v1
-> docker compose up -d
```

  
## Expected result

Check containers are running:
```
Thu 2023Nov02 11:49:32 PDT
(⎈|uscentral-prod-az-024:ccm2-server)
afoot@local:
~/Documents/DATAL1/MyCode/compose_psql-repmgr-WM-AARCH64-v1
hist:61 -> docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                        NAMES
84eb938932b2   dpage/pgadmin4:latest           "/entrypoint.sh"         35 minutes ago   Up 35 minutes   443/tcp, 0.0.0.0:5050->80/tcp                pgadmin-2
a2bb10e39f73   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                ansiblecontrol
68e8cc302c66   portainer/portainer-ce:alpine   "/portainer -H unix:…"   35 minutes ago   Up 35 minutes   8000/tcp, 9443/tcp, 0.0.0.0:9000->9000/tcp   portainer-2
ae818792cd08   prom/prometheus                 "/bin/prometheus --c…"   35 minutes ago   Up 35 minutes   0.0.0.0:9090->9090/tcp                       prometheus-2
b7791aeb4366   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                pgnode2
cfe6b6d2ae8c   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                ansibleagent2
68d9dee3e265   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                ansibleagent1
ddc998cc93fd   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                witness
cbb1ab7200ad   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                pgnode1
44eee9c5a418   nicolaka/netshoot               "sleep infinity"         35 minutes ago   Up 35 minutes                                                netutils2
a46812638eb4   dockio/u2204-arm64v8:1.0        "sleep infinity"         35 minutes ago   Up 35 minutes                                                pgnode3
3c9948a26c21   grafana/grafana                 "/run.sh"                35 minutes ago   Up 35 minutes   0.0.0.0:3000->3000/tcp                       grafana-2
```

Stop the containers without deleting them or their volumes
``` shell
$ docker compose stop
```
To delete all data run:
```
$ docker compose down -v
```
::::::::::::::

## IP VLAN 

::::::::::::::