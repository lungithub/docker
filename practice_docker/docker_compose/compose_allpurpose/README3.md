# Docker Compose All-Purpose Environment: Technical Overview & FAQ

## Overview

This project provides a comprehensive Docker Compose environment for DevOps, CI/CD, monitoring, and analytics. It includes Ubuntu and RHEL development containers, Jenkins, Splunk, Prometheus, Grafana, and more. The setup is designed for local development and experimentation, with a focus on service interconnectivity, metrics collection, and ease of access from the Docker host (macOS).

---

## Services & Networking

- **Custom Docker Network**: All services are attached to `custom-network` with static IPs for predictable service discovery.
- **Service Containers**:
  - **Ubuntu Agents** (`devops-u1`, `devops-u2`, `devops-u3`):
    - Based on `dockio/u2204-devesp:2.0`.
    - Run with `privileged: true` and `entrypoint: ["/sbin/init"]` to enable `systemd` and support `systemctl`.
    - Expose Node Exporter on port 9100 (see below for port mapping details).
    - Nginx (if installed) is mapped to host ports 81 (HTTP), 444 (HTTPS), and 8081 (alternative HTTP).
  - **RHEL Agents** (`devops-r1`, `devops-r2`):
    - Based on `dockio/rhel9-devesp:1.0`.
    - Use `command: ["sleep", "infinity"]` (systemd not enabled by default).
    - Node Exporter mapped to unique host ports.
  - **Jenkins, Splunk, Prometheus, Grafana**: Standard images with persistent volumes and custom configuration.

---

## Port Mapping: Host vs. Container

- **Syntax**: `"HOST_PORT:CONTAINER_PORT"`
- **Example**: `- "9101:9100"` means:
  - `9101` is the port on your Mac (host)
  - `9100` is the port inside the container
- **Why?**: This allows you to access services running inside containers from your host at `localhost:HOST_PORT`.
- **Nginx Example** (in `devops-u1`):
  - `- "81:80"` → http://localhost:81
  - `- "444:443"` → https://localhost:444
  - `- "8081:8080"` → http://localhost:8081

---

## Node Exporter & Metrics Access

- **Multiple Containers, Same Endpoint**: Each container runs Node Exporter on port 9100 internally.
- **Host Access**: Map each container's 9100 to a unique host port (e.g., 9101, 9102, 9103, ...).
  - Example:
    - `devops-u1`: `- "9101:9100"` → http://localhost:9101/metrics
    - `devops-u2`: `- "9102:9100"` → http://localhost:9102/metrics
    - `devops-u3`: `- "9103:9100"` → http://localhost:9103/metrics
- **Internal Compose Network**: Services can always reach each other at `http://<service_name>:9100/metrics` (e.g., `http://devops-u1:9100/metrics`). No port conflict occurs internally.
- **macOS Note**: You cannot use the container's internal IP from the host; always use the mapped host port.

---

## Prometheus & Grafana Integration

- **Prometheus**:
  - Scrapes metrics from all exporters using service names and port 9100.
  - Example scrape config:
    ```yaml
    scrape_configs:
      - job_name: 'node_exporters'
        static_configs:
          - targets: ['devops-u1:9100', 'devops-u2:9100', 'devops-u3:9100', 'devops-r1:9100', 'devops-r2:9100']
    ```
- **Grafana**:
  - Uses a provisioned datasource (`grafana/datasource.yml`) pointing to Prometheus at `http://prometheus-cicd:9090`.
  - Accessible at http://localhost:3000 (default admin:admin, password: grafana).

---

## Systemd & systemctl in Ubuntu Containers

- **Problem**: `systemctl` fails if systemd is not PID 1 (e.g., when using `command: ["sleep", "infinity"]`).
- **Solution**: Use `entrypoint: ["/sbin/init"]` and remove the `command` line. This starts systemd as PID 1, enabling `systemctl`.
- **RHEL Note**: RHEL containers use `command: ["sleep", "infinity"]` by default, so `systemctl` will not work unless you change the entrypoint.

---

## FAQ & Troubleshooting

### Q: How do I access Node Exporter metrics from my Mac?
A: Use the mapped host port, e.g., `http://localhost:9101/metrics` for `devops-u1`.

### Q: Can I use the container's internal IP from my Mac?
A: No, on macOS you must use the mapped host port. Internal IPs are only accessible from other containers.

### Q: How does Prometheus scrape metrics from all containers?
A: It uses the Docker Compose service names and port 9100 (e.g., `devops-u1:9100`).

### Q: What happens if multiple containers map the same container port to the same host port?
A: Only one mapping will work; you must use unique host ports for each container.

### Q: How do I restart a specific container?
A: Use the service name: `docker compose restart devops-u1`

### Q: How do I reload the compose config after changes?
A: Run `docker compose up -d` to apply changes. There is no hot-reload.

### Q: How do I enable systemd and systemctl in Ubuntu containers?
A: Use `entrypoint: ["/sbin/init"]` and remove any `command` line.

---

## Example Service Block (devops-u1)
```yaml
  devops-u1:
    image: dockio/u2204-devesp:2.0
    networks:
      custom-network:
        priority: 10
        ipv4_address: "172.30.1.11"
    hostname: devops-u1
    container_name: devops-u1
    privileged: true
    restart: on-failure
    ports:
      - "9101:9100" # Node Exporter
      - "81:80"     # nginx HTTP
      - "444:443"   # nginx HTTPS
      - "8081:8080" # nginx alt HTTP
    volumes:
      - "./:/hostdata"
      - "/Users/orion/Documents/DATAM1/MyCode:/MyCode"
      - "/Users/orion/Documents/DATAM2/learning/MyConfig:/MyConfig"
    entrypoint: ["/sbin/init"]
```

---

## References
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Prometheus Docker Guide](https://prometheus.io/docs/prometheus/latest/installation/)
- [Grafana Docker Guide](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)
- [Systemd in Docker](https://docs.docker.com/engine/examples/systemd/)

---

_Last updated: 2025-06-21_
