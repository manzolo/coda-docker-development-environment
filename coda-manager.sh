#!/bin/bash

# CODA Docker Manager Script with Dialog Interface
# Author: Assistant
# Description: Interactive manager for CODA Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if dialog is installed
check_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo -e "${RED}Error: 'dialog' is not installed.${NC}"
        echo "Please install it with: sudo apt-get install dialog (Ubuntu/Debian)"
        echo "                     or: sudo yum install dialog (RedHat/CentOS)"
        echo "                     or: brew install dialog (MacOS)"
        exit 1
    fi
}

# Check if docker and docker compose are installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        dialog --msgbox "Docker is not installed. Please install Docker first." 10 50
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null && ! docker compose version &> /dev/null; then
        dialog --msgbox "Docker Compose is not installed. Please install Docker Compose first." 10 50
        exit 1
    fi
}

# Load environment variables
load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    else
        dialog --msgbox ".env file not found. Creating default configuration..." 10 50
        create_default_env
    fi
}

# Create default .env file
create_default_env() {
    cat > .env << 'EOF'
# CODA Configuration
CODA_VERSION=2.25.6

# Container Configuration
CONTAINER_NAME=coda-dev
PROJECT_NAME=coda-project

# Volume Configuration
# Modifica questo path con il percorso assoluto dei tuoi sorgenti
SOURCE_PATH=./src

# Port Configuration (se necessario per future estensioni)
# PORT=8080
EOF
    dialog --msgbox ".env file created with default values." 8 50
}

# Edit configuration
edit_configuration() {
    local temp_file=$(mktemp)
    
    dialog --form "CODA Configuration" 15 60 5 \
        "CODA Version:"     1 1 "$CODA_VERSION"     1 20 30 0 \
        "Container Name:"   2 1 "$CONTAINER_NAME"   2 20 30 0 \
        "Project Name:"     3 1 "$PROJECT_NAME"     3 20 30 0 \
        "Source Path:"      4 1 "$SOURCE_PATH"      4 20 30 0 \
        2> $temp_file
    
    if [ $? -eq 0 ]; then
        local values=($(cat $temp_file))
        
        # Update .env file
        cat > .env << EOF
# CODA Configuration
CODA_VERSION=${values[0]}

# Container Configuration
CONTAINER_NAME=${values[1]}
PROJECT_NAME=${values[2]}

# Volume Configuration
SOURCE_PATH=${values[3]}
EOF
        
        dialog --msgbox "Configuration updated successfully!" 8 40
        load_env
    fi
    
    rm -f $temp_file
}

# Build Docker image
build_image() {
    dialog --infobox "Building CODA Docker image with version $CODA_VERSION..." 5 60
    
    if docker compose build 2>&1 | tee /tmp/build.log; then
        dialog --msgbox "Docker image built successfully!" 8 40
    else
        dialog --textbox /tmp/build.log 20 70
        dialog --msgbox "Build failed! Check the log above." 8 40
    fi
}

# Start container
start_container() {
    dialog --infobox "Starting CODA container..." 5 40
    
    if docker compose up -d 2>&1 | tee /tmp/start.log; then
        dialog --msgbox "Container started successfully!" 8 40
    else
        dialog --textbox /tmp/start.log 20 70
        dialog --msgbox "Failed to start container! Check the log above." 8 40
    fi
}

# Stop container
stop_container() {
    dialog --infobox "Stopping CODA container..." 5 40
    
    if docker compose down 2>&1 | tee /tmp/stop.log; then
        dialog --msgbox "Container stopped successfully!" 8 40
    else
        dialog --textbox /tmp/stop.log 20 70
        dialog --msgbox "Failed to stop container! Check the log above." 8 40
    fi
}

# Enter container shell
enter_shell() {
    clear
    echo -e "${GREEN}Entering CODA container shell...${NC}"
    echo -e "${YELLOW}Type 'exit' to return to the menu${NC}"
    echo ""
    sleep 2
    
    docker compose exec coda /bin/bash || docker exec -it ${CONTAINER_NAME} /bin/bash
}

# View container logs
view_logs() {
    dialog --tailbox <(docker compose logs -f 2>&1) 20 70
}

# Check container status
check_status() {
    local status=$(docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Status}}" | tail -n 1)
    local info="Container Name: $CONTAINER_NAME\n"
    info+="CODA Version: $CODA_VERSION\n"
    info+="Source Path: $SOURCE_PATH\n"
    info+="Status: $status"
    
    if docker ps | grep -q ${CONTAINER_NAME}; then
        # Container is running, try to get CODA version
        local coda_info=$(docker exec ${CONTAINER_NAME} python -c "import coda; print(f'CODA Python: {coda.version()}')" 2>/dev/null || echo "CODA Python: Not available")
        info+="\n$coda_info"
    fi
    
    dialog --msgbox "$info" 12 60
}

# Clean up Docker resources
cleanup() {
    dialog --yesno "This will remove:\n- Stopped containers\n- Unused images\n- Unused volumes\n\nDo you want to continue?" 10 50
    
    if [ $? -eq 0 ]; then
        dialog --infobox "Cleaning up Docker resources..." 5 40
        docker system prune -f --volumes 2>&1 | tee /tmp/cleanup.log
        dialog --textbox /tmp/cleanup.log 20 70
    fi
}

# Initialize source directory
init_source_dir() {
    if [ ! -d "$SOURCE_PATH" ]; then
        dialog --yesno "Source directory '$SOURCE_PATH' doesn't exist.\nDo you want to create it?" 8 50
        if [ $? -eq 0 ]; then
            mkdir -p "$SOURCE_PATH"
            echo "# CODA Project Sources" > "$SOURCE_PATH/README.md"
            dialog --msgbox "Source directory created at: $SOURCE_PATH" 8 50
        fi
    else
        dialog --msgbox "Source directory already exists at: $SOURCE_PATH" 8 50
    fi
}

# Main menu
main_menu() {
    while true; do
        choice=$(dialog --clear \
            --backtitle "CODA Docker Manager" \
            --title "Main Menu" \
            --menu "Choose an option:" 18 60 11 \
            1 "Build Docker Image" \
            2 "Start Container" \
            3 "Stop Container" \
            4 "Enter Container Shell" \
            5 "View Container Logs" \
            6 "Check Container Status" \
            7 "Edit Configuration" \
            8 "Initialize Source Directory" \
            9 "Clean Docker Resources" \
            10 "About" \
            11 "Exit" \
            2>&1 >/dev/tty)
        
        case $choice in
            1) build_image ;;
            2) start_container ;;
            3) stop_container ;;
            4) enter_shell ;;
            5) view_logs ;;
            6) check_status ;;
            7) edit_configuration ;;
            8) init_source_dir ;;
            9) cleanup ;;
            10) dialog --msgbox "CODA Docker Manager v1.0\n\nA tool to manage CODA development environment\nusing Docker containers.\n\nCODA Version: $CODA_VERSION" 12 50 ;;
            11) clear; exit 0 ;;
            *) clear; exit 0 ;;
        esac
    done
}

# Main execution
main() {
    check_dialog
    check_docker
    load_env
    
    # Welcome message
    dialog --msgbox "Welcome to CODA Docker Manager!\n\nThis tool will help you manage your CODA\ndevelopment environment using Docker.\n\nCurrent CODA Version: $CODA_VERSION" 10 50
    
    main_menu
}

# Run main function
main "$@"