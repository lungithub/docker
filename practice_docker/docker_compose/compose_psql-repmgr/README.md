## PostgreSQL and pgAdmin
This example provides a base setup for using [PostgreSQL](https://www.postgresql.org/) and [pgAdmin](https://www.pgadmin.org/).
More details on how to customize the installation and the compose file can be found [here (PostgreSQL)](https://hub.docker.com/_/postgres) and [here (pgAdmin)](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html).

Project structure:
```
.
├── .env
├── compose.yaml
└── README.md


version: "2.13.0"

services:

#
# PRIMARY - CentOS8
#  
  centos8-1:
    image: centos:8.4.2105
    hostname: centos8-11
    container_name: c811
    privileged: true
    entrypoint: ["/usr/sbin/init"]
    restart: on-failure
    volumes:
      - "./:/hostdata"      
    command: ["sleep", "infinity"]      

#
# SECONDARY - CentOS8
#  
  centos8-2:
    image: centos:8.4.2105
    hostname: centos8-12
    container_name: c812
    privileged: true
    entrypoint: ["/usr/sbin/init"]    
    restart: on-failure
    volumes:
      - "./:/hostdata"    
    command: ["sleep", "infinity"] 

#
# THIRD - CentOS8
#  
  centos8-3:
    image: centos:8.4.2105
    hostname: centos8-13
    container_name: c813
    privileged: true
    entrypoint: ["/usr/sbin/init"]    
    restart: on-failure
    volumes:
      - "./:/hostdata"    
    command: ["sleep", "infinity"] 

```


## Deploy with docker compose
When deploying this setup, the pgAdmin web interface will be available at port 5050 (e.g. http://localhost:5050).  

``` shell
$ docker compose up
```

  
## Expected result

Check containers are running:
```
$ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED             STATUS                 PORTS                                                                                  NAMES
849c5f48f784   postgres:latest                 "docker-entrypoint.s…"   9 minutes ago       Up 9 minutes           0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                              postgres
d3cde3b455ee   dpage/pgadmin4:latest           "/entrypoint.sh"         9 minutes ago       Up 9 minutes           443/tcp, 0.0.0.0:5050->80/tcp, :::5050->80/tcp                                         pgadmin
```

Stop the containers with
``` shell
$ docker compose down
# To delete all data run:
$ docker compose down -v
```
::::::::::::::

## IP VLAN 

::::::::::::::