# GenAI Sandbox Docker Container

A ready-to-use Docker container for running AI tools like Claude Code, Gemini CLI, and more. The container comes pre-configured with essential development tools and environment managers.

## Project Structure

```
genai-sandbox/
├── Dockerfile           # Container definition
├── docker-compose.yml   # Docker compose configuration
├── platform.pkg         # Ubuntu apt packages (one per line)
├── brew.pkg            # Homebrew packages (one per line)
├── quick-start.sh      # Container management script
└── README.md           # This file
```

## Features

- **Base**: Ubuntu 24.04 LTS
- **Shell**: Zsh with Oh My Zsh
- **Development Tools**:
  - NVM (Node Version Manager) - Pre-installed with latest LTS Node.js
  - pyenv (Python Version Manager)
  - SDKMAN (Java/JVM Version Manager)
  - Homebrew (Package Manager)
- **Essential Tools**: git, curl, wget, neovim
- **Non-root User**: aiuser (with sudo access)
- **Volume Mounting**: `~/workspace/genai/` (host) → `/home/aiuser/workspace/` (container)

## Quick Start

### First Time Setup

1. Build the image:
```bash
./quick-start.sh build
```

2. Start the container:
```bash
./quick-start.sh start
```

3. Access the shell:
```bash
./quick-start.sh shell
```

### Available Commands

The `quick-start.sh` script provides the following commands:

| Command | Description |
|---------|-------------|
| `build` | Build the Docker image |
| `start` | Start the container |
| `stop` | Stop the container |
| `restart` | Restart the container |
| `status` | Check container status |
| `shell` | Open a shell in the container |
| `logs` | View container logs |
| `rebuild` | Rebuild and restart the container |

### Example Usage

```bash
# Build the image
./quick-start.sh build

# Start the container
./quick-start.sh start

# Check status
./quick-start.sh status

# Open shell
./quick-start.sh shell

# Stop container
./quick-start.sh stop
```

## Inside the Container

Once you're inside the container, you can install and use various AI tools:

### Installing Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### Installing Gemini CLI

```bash
pip install google-generativeai
```

### Using Node.js (via NVM)

```bash
# List installed versions
nvm list

# Install a specific version
nvm install 20

# Use a specific version
nvm use 20
```

### Using Python (via pyenv)

```bash
# List available versions
pyenv install --list

# Install a specific version
pyenv install 3.12.0

# Set global version
pyenv global 3.12.0
```

### Using Java (via SDKMAN)

```bash
# List available Java versions
sdk list java

# Install a specific version
sdk install java 21.0.1-tem

# Use a specific version
sdk use java 21.0.1-tem
```

### Using Homebrew

```bash
# Update Homebrew
brew update

# Search for packages
brew search <package-name>

# Install packages
brew install gh
brew install fzf

# List installed packages
brew list

# Upgrade packages
brew upgrade

# Uninstall packages
brew uninstall <package-name>
```

## Volume Mounting

The container automatically mounts your local `~/workspace/genai/` directory to `/home/aiuser/workspace/` inside the container. Any files you create or modify in the container will be persisted on your host machine.

## Container Details

- **Container Name**: genai-sandbox
- **Image Name**: genai-sandbox:latest
- **User**: aiuser (non-root with sudo access)
- **Default Shell**: /bin/zsh
- **Working Directory**: /home/aiuser/workspace

## Troubleshooting

### Container won't start

1. Check if Docker is running:
```bash
docker ps
```

2. Check container logs:
```bash
./quick-start.sh logs
```

### Need to rebuild after changes

```bash
./quick-start.sh rebuild
```

### Reset everything

```bash
./quick-start.sh stop
docker-compose down
docker rmi genai-sandbox:latest
./quick-start.sh build
./quick-start.sh start
```

## Package Management

This container uses externalized package configuration files for easy customization:

### platform.pkg
Contains Ubuntu apt packages to be installed. Add one package per line, comments start with `#`.

```bash
# Example: Add a new apt package
echo "ripgrep" >> platform.pkg
./quick-start.sh rebuild
```

### brew.pkg
Contains Homebrew packages to be installed. Add one package per line, comments start with `#`.

```bash
# Example: Add a new brew package
echo "bat" >> brew.pkg
./quick-start.sh rebuild
```

**Note**: After modifying either package file, you must rebuild the container for changes to take effect.

## Customization

### Adding More Tools

1. For Ubuntu packages available via apt, add them to `platform.pkg`
2. For cross-platform tools or newer versions, add them to `brew.pkg`
3. Rebuild the container:

```bash
./quick-start.sh rebuild
```

### Changing the Volume Mount

Edit `docker-compose.yml` and modify the volumes section:

```yaml
volumes:
  - /your/host/path:/home/aiuser/workspace
```

## Security Note

The container runs with a non-root user (`aiuser`) that has sudo access without password. This is convenient for development but should not be used in production environments.
