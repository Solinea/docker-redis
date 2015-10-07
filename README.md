solinea/redis
---

Redis running on a minimal Debian base image.

`solinea/redis` is a Docker image based on `solinea/debian`.

# Usage

Create a Dockerfile with the following content:

    FROM solinea/redis

# Volumes

Volume         | Description
---------------|--------------
/etc/redis     | Configuration
/var/lib/redis | Data