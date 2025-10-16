#!/bin/bash

# GenAI Sandbox Container Management Script
# Usage: ./quick-start.sh [build|start|stop|restart|status|shell|logs]

set -e

CONTAINER_NAME="genai-sandbox"
IMAGE_NAME="genai-sandbox:1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect docker compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}GenAI Sandbox Container Management${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     - Build the Docker image"
    echo "  start     - Start the container"
    echo "  stop      - Stop the container"
    echo "  restart   - Restart the container"
    echo "  status    - Check container status"
    echo "  shell     - Open a shell in the container"
    echo "  logs      - View container logs"
    echo "  rebuild   - Rebuild and restart the container"
    echo ""
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Error: docker-compose is not installed${NC}"
        exit 1
    fi

    if ! docker ps &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        exit 1
    fi
}

build_image() {
    echo -e "${BLUE}Building GenAI Sandbox image...${NC}"
    cd "$SCRIPT_DIR"
    $COMPOSE_CMD build
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build completed successfully${NC}"
    else
        echo -e "${RED}Build failed${NC}"
        exit 1
    fi
}

start_container() {
    echo -e "${BLUE}Starting GenAI Sandbox container...${NC}"
    cd "$SCRIPT_DIR"

    # Check if container exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        # Container exists, just start it
        $COMPOSE_CMD start
    else
        # Container doesn't exist, create and start
        $COMPOSE_CMD up -d
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container started successfully${NC}"
        echo -e "${YELLOW}Run './quick-start.sh shell' to access the container${NC}"
    else
        echo -e "${RED}Failed to start container${NC}"
        exit 1
    fi
}

stop_container() {
    echo -e "${BLUE}Stopping GenAI Sandbox container...${NC}"
    cd "$SCRIPT_DIR"
    $COMPOSE_CMD stop
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container stopped successfully${NC}"
    else
        echo -e "${RED}Failed to stop container${NC}"
        exit 1
    fi
}

restart_container() {
    echo -e "${BLUE}Restarting GenAI Sandbox container...${NC}"
    cd "$SCRIPT_DIR"
    $COMPOSE_CMD restart
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container restarted successfully${NC}"
    else
        echo -e "${RED}Failed to restart container${NC}"
        exit 1
    fi
}

check_status() {
    echo -e "${BLUE}GenAI Sandbox Status:${NC}"
    echo ""

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}Status: Running${NC}"
        echo ""
        docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    elif docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${YELLOW}Status: Stopped${NC}"
        echo ""
        docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}"
    else
        echo -e "${RED}Status: Not created${NC}"
        echo -e "${YELLOW}Run './quick-start.sh build' and then './quick-start.sh start'${NC}"
    fi
}

open_shell() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}Error: Container is not running${NC}"
        echo -e "${YELLOW}Run './quick-start.sh start' first${NC}"
        exit 1
    fi

    echo -e "${BLUE}Opening shell in GenAI Sandbox...${NC}"
    docker exec -it "$CONTAINER_NAME" /bin/zsh
}

view_logs() {
    cd "$SCRIPT_DIR"
    echo -e "${BLUE}Viewing container logs (Press Ctrl+C to exit)...${NC}"
    $COMPOSE_CMD logs -f
}

rebuild_container() {
    echo -e "${BLUE}Rebuilding GenAI Sandbox...${NC}"

    # Stop container if it's running (ignore errors if not running)
    cd "$SCRIPT_DIR"
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${BLUE}Stopping existing container...${NC}"
        docker-compose stop
    fi

    build_image
    start_container
}

# Main script logic
check_docker

case "$1" in
    build)
        build_image
        ;;
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    status)
        check_status
        ;;
    shell)
        open_shell
        ;;
    logs)
        view_logs
        ;;
    rebuild)
        rebuild_container
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
