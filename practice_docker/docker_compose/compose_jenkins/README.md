## Jenkins 

Project structure:
```
Mon 2023Jun26 18:47:24 PDT
orion@devesp  git(main)
~/Documents/DATAM1/MyCode/DOCKER/practice_docker/docker_compose/compose_jenkins
hist:423 ->  ll
-rw-r--r--   1 orion  staff  2486 Mar 11 18:39 README.md
drwxr-xr-x   4 orion  staff   128 Jun 16 15:34 app/
-rw-r--r--   1 orion  staff  1868 Jun 26 18:42 compose.yaml
drwxr-xr-x   5 orion  staff   160 Jun 16 15:34 data/
drwxr-xr-x   3 orion  staff    96 Mar 11 18:39 grafana/
-rw-r--r--   1 orion  staff  2247 Mar 27 21:15 jenkins_compose_v1.yaml
drwxr-xr-x  39 orion  staff  1248 Jun 26 18:46 jenkins_configuration/
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
````
-> docker compose down -v
```
