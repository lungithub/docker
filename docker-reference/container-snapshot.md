# Container Snapshot Management Guide

This guide provides instructions for creating and restoring snapshots of your PostgreSQL cluster containers.

## Current Container Status

### Running Containers (dockio/u2204-arm64v8:1.0)
- **ansiblecontrol** - Ansible control node
- **ansibleagent1** - Ansible agent node 1  
- **ansibleagent2** - Ansible agent node 2
- **pgnode1** - PostgreSQL primary/secondary node 1
- **pgnode2** - PostgreSQL primary/secondary node 2
- **pgnode3** - PostgreSQL primary/secondary node 3
- **witness** - PostgreSQL witness node for repmgr

## Method 1: Create Container Images (Recommended)

This method creates new Docker images from your running containers, preserving their current state.

### Create Snapshots

```bash
# Create snapshots of all PostgreSQL cluster containers
docker commit ansiblecontrol dockio/ansiblecontrol-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit ansibleagent1 dockio/ansibleagent1-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit ansibleagent2 dockio/ansibleagent2-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit pgnode1 dockio/pgnode1-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit pgnode2 dockio/pgnode2-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit pgnode3 dockio/pgnode3-snapshot:$(date +%Y%m%d-%H%M%S)
docker commit witness dockio/witness-snapshot:$(date +%Y%m%d-%H%M%S)
```

### Batch Script for All Containers

```
#!/bin/bash
# Create snapshots for all dockio containers

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CONTAINERS=("ansiblecontrol" "ansibleagent1" "ansibleagent2" "pgnode1" "pgnode2" "pgnode3" "witness")

echo "Creating container snapshots with timestamp: $TIMESTAMP"

for container in "${CONTAINERS[@]}"; do
    echo "Creating snapshot for $container..."
    docker commit $container dockio/${container}-snapshot:$TIMESTAMP
    if [ $? -eq 0 ]; then
        echo "✓ Successfully created dockio/${container}-snapshot:$TIMESTAMP"
    else
        echo "✗ Failed to create snapshot for $container"
    fi
done

echo "Snapshot creation completed!"
echo "List of created snapshots:"
docker images | grep snapshot
```

### View Created Snapshots

```bash
# List all snapshot images
docker images | grep snapshot

# List snapshots with specific pattern
docker images | grep "dockio.*snapshot"
```

## Method 2: Export/Import Containers

This method exports containers to tar files for backup and portability.

### Export Containers

```bash
# Create snapshots directory
mkdir -p ./container-snapshots/$(date +%Y%m%d-%H%M%S)
cd ./container-snapshots/$(date +%Y%m%d-%H%M%S)

# Export each container
docker export ansiblecontrol > ansiblecontrol-snapshot.tar
docker export ansibleagent1 > ansibleagent1-snapshot.tar
docker export ansibleagent2 > ansibleagent2-snapshot.tar
docker export pgnode1 > pgnode1-snapshot.tar
docker export pgnode2 > pgnode2-snapshot.tar
docker export pgnode3 > pgnode3-snapshot.tar
docker export witness > witness-snapshot.tar

# Compress exports (optional)
gzip *.tar
```

### Batch Export Script

```
#!/bin/bash
# Export all containers to tar files

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_DIR="./container-snapshots/$TIMESTAMP"
CONTAINERS=("ansiblecontrol" "ansibleagent1" "ansibleagent2" "pgnode1" "pgnode2" "pgnode3" "witness")

echo "Creating snapshot directory: $SNAPSHOT_DIR"
mkdir -p "$SNAPSHOT_DIR"
cd "$SNAPSHOT_DIR"

for container in "${CONTAINERS[@]}"; do
    echo "Exporting $container..."
    docker export $container > ${container}-snapshot.tar
    if [ $? -eq 0 ]; then
        echo "✓ Successfully exported $container to ${container}-snapshot.tar"
        gzip ${container}-snapshot.tar
        echo "✓ Compressed to ${container}-snapshot.tar.gz"
    else
        echo "✗ Failed to export $container"
    fi
done

echo "Export completed! Files saved in: $SNAPSHOT_DIR"
ls -lh *.gz
```

## Restoring from Snapshots

### Method 1: Restore from Committed Images

```bash
# Stop current containers
docker-compose down

# Remove current containers (optional, if you want clean restore)
docker rm ansiblecontrol ansibleagent1 ansibleagent2 pgnode1 pgnode2 pgnode3 witness

# Run containers from snapshot images
# Replace TIMESTAMP with your actual snapshot timestamp
TIMESTAMP="20231007-143000"  # Example timestamp

docker run -d --name ansiblecontrol dockio/ansiblecontrol-snapshot:$TIMESTAMP
docker run -d --name ansibleagent1 dockio/ansibleagent1-snapshot:$TIMESTAMP
docker run -d --name ansibleagent2 dockio/ansibleagent2-snapshot:$TIMESTAMP
docker run -d --name pgnode1 dockio/pgnode1-snapshot:$TIMESTAMP
docker run -d --name pgnode2 dockio/pgnode2-snapshot:$TIMESTAMP
docker run -d --name pgnode3 dockio/pgnode3-snapshot:$TIMESTAMP
docker run -d --name witness dockio/witness-snapshot:$TIMESTAMP
```

### Method 2: Restore from Exported Tar Files

```bash
# Import tar files as new images
# Replace TIMESTAMP with your actual snapshot timestamp
TIMESTAMP="20231007-143000"  # Example timestamp
SNAPSHOT_DIR="./container-snapshots/$TIMESTAMP"

cd "$SNAPSHOT_DIR"

# Import each container
docker import ansiblecontrol-snapshot.tar.gz dockio/ansiblecontrol-restored:$TIMESTAMP
docker import ansibleagent1-snapshot.tar.gz dockio/ansibleagent1-restored:$TIMESTAMP
docker import ansibleagent2-snapshot.tar.gz dockio/ansibleagent2-restored:$TIMESTAMP
docker import pgnode1-snapshot.tar.gz dockio/pgnode1-restored:$TIMESTAMP
docker import pgnode2-snapshot.tar.gz dockio/pgnode2-restored:$TIMESTAMP
docker import pgnode3-snapshot.tar.gz dockio/pgnode3-restored:$TIMESTAMP
docker import witness-snapshot.tar.gz dockio/witness-restored:$TIMESTAMP

# Run containers from imported images
docker run -d --name ansiblecontrol dockio/ansiblecontrol-restored:$TIMESTAMP
docker run -d --name ansibleagent1 dockio/ansibleagent1-restored:$TIMESTAMP
docker run -d --name ansibleagent2 dockio/ansibleagent2-restored:$TIMESTAMP
docker run -d --name pgnode1 dockio/pgnode1-restored:$TIMESTAMP
docker run -d --name pgnode2 dockio/pgnode2-restored:$TIMESTAMP
docker run -d --name pgnode3 dockio/pgnode3-restored:$TIMESTAMP
docker run -d --name witness dockio/witness-restored:$TIMESTAMP
```

## Docker Compose Integration

### Update Compose File for Snapshots

You can modify your `compose.yaml` to use snapshot images:

```yaml
# Example modification for compose.yaml
services:
  pgnode1:
    image: dockio/pgnode1-snapshot:20231007-143000  # Use snapshot image
    # ... rest of configuration
  
  pgnode2:
    image: dockio/pgnode2-snapshot:20231007-143000  # Use snapshot image
    # ... rest of configuration
```

## Best Practices

### 1. Regular Snapshots
- Create snapshots before major changes
- Use timestamps for versioning
- Keep multiple snapshots for different states

### 2. Naming Convention
```bash
# Recommended naming pattern
dockio/[container-name]-snapshot:[YYYYMMDD-HHMMSS]
dockio/[container-name]-snapshot:[version-tag]
```

### 3. Storage Management

::: Code Generated by Copilot [2f4a8b1c-7d3e-4a2f-9c5b-8e1f2a3b4c5d]. This comment will be removed automatically after the file is saved :::

#### Filesystem Storage Locations

**Docker Images (Method 1 - docker commit):**
- **macOS**: `/Users/[username]/Library/Containers/com.docker.docker/Data/vms/0/data/docker/image/`
- **Linux**: `/var/lib/docker/image/overlay2/imagedb/content/sha256/`
- **Windows**: `C:\ProgramData\Docker\image\windowsfilter\imagedb\content\sha256\`

**Exported Files (Method 2 - docker export):**
- Stored in the directory you specify (e.g., `./container-snapshots/[timestamp]/`)
- Default location: Current working directory where you run the export command

```bash
# Check Docker root directory
docker info | grep "Docker Root Dir"

# Check total Docker storage usage
docker system df

# Check individual image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep snapshot

# Monitor disk usage for snapshots
du -sh ~/Library/Containers/com.docker.docker/Data/vms/0/data/docker/  # macOS
du -sh /var/lib/docker/  # Linux
```

#### Storage Cleanup Commands

```bash
# Clean up old snapshots
docker images | grep snapshot | grep "weeks ago" | awk '{print $3}' | xargs docker rmi

# Remove snapshots older than 30 days
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}\t{{.ID}}" | grep snapshot | awk '$3 < (systime() - 30*24*3600) {print $4}' | xargs docker rmi

# Clean up unused Docker data (including stopped containers, unused networks, images, and build cache)
docker system prune -a

# Remove only dangling images
docker image prune
```

### 4. Documentation
- Keep a log of when snapshots were created
- Document the state/purpose of each snapshot
- Note any special configurations

## Quick Commands Reference

```bash
# Create snapshot of specific container
docker commit [container-name] dockio/[container-name]-snapshot:$(date +%Y%m%d-%H%M%S)

# List all snapshots
docker images | grep snapshot

# Remove specific snapshot
docker rmi dockio/[container-name]-snapshot:[tag]

# Export container to file
docker export [container-name] > [container-name]-snapshot.tar

# Import from file
docker import [container-name]-snapshot.tar dockio/[container-name]-restored:[tag]
```

## Troubleshooting

### Common Issues

1. **Container not found**: Ensure container names are correct
2. **Permission denied**: Run with appropriate Docker permissions
3. **Disk space**: Monitor available disk space for large snapshots
4. **Network issues**: Snapshots preserve container state but may need network reconfiguration

### Verification

```bash
# Verify snapshot was created successfully
docker inspect dockio/[container-name]-snapshot:[tag]

# Check snapshot size
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep snapshot

# Test restored container
docker run --rm -it dockio/[container-name]-snapshot:[tag] /bin/bash
```

---

**Note**: This guide assumes your PostgreSQL cluster containers contain important state data. 
Always test the restore process in a non-production environment first.
