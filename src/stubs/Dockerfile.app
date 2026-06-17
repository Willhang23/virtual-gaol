# ==============================================================================
# Phase 1: Base & Compatibility Setup
# ==============================================================================
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install core utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Create a non-privileged user for runtime execution
RUN useradd -m -s /bin/bash vgaol-app

# Set up the shared workspace mount point
WORKDIR /app

# ==============================================================================
# Phase 2: Developer Dependency Injection (Customizable Section)
# ==============================================================================
# Append your persistent package installations here
# ==============================================================================

# ==============================================================================
# Phase 3: Development Runtime Configuration
# ==============================================================================
# Hardcode the entrypoint script directly into the container filesystem
RUN echo '#!/bin/bash\n\
set -e\n\
if [ -d "/app" ]; then\n\
    chown -R vgaol-app:vgaol-app /app\n\
fi\n\
exec su -c "$@" vgaol-app' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Start as root to allow entrypoint.sh to fix permissions, 
# it will drop to vgaol-app automatically before executing your app.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
