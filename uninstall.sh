#!/bin/bash
# XShot Enhanced Uninstallation Script v2.0
# Cross-Platform Screenshot Tool Remover

# Enhanced Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
NC='\033[0m' # No Color

# Background Colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'

# Unicode symbols
CHECKMARK="✓"
CROSSMARK="✗"
ARROW="➤"
STAR="★"
TRASH="🗑️"
GEAR="⚙️"
PACKAGE="📦"
FOLDER="📁"
WARNING="⚠️"
QUESTION="❓"
SPARKLES="✨"
FIRE="🔥"
BOOM="💥"
CLEAN="🧹"

# Terminal width detection
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

# Function to print centered text
print_center() {
    local text="$1"
    local color="$2"
    local padding=$(( (TERM_WIDTH - ${#text}) / 2 ))
    printf "%*s" $padding ""
    echo -e "${color}${text}${NC}"
}

# Function to print a separator line
print_separator() {
    local char="${1:-═}"
    local color="${2:-$CYAN}"
    printf "${color}"
    printf "%*s\n" $TERM_WIDTH "" | tr ' ' "$char"
    printf "${NC}"
}

# Function to print a box
print_box() {
    local text="$1"
    local color="${2:-$BLUE}"
    local box_width=$((${#text} + 4))
    local padding=$(( (TERM_WIDTH - box_width) / 2 ))
    
    printf "%*s" $padding ""
    echo -e "${color}╔$(printf "%*s" $((${#text} + 2)) "" | tr ' ' '═')╗${NC}"
    printf "%*s" $padding ""
    echo -e "${color}║ ${WHITE}${text}${color} ║${NC}"
    printf "%*s" $padding ""
    echo -e "${color}╚$(printf "%*s" $((${#text} + 2)) "" | tr ' ' '═')╝${NC}"
}

# Function to print status with icon
print_status() {
    local status="$1"
    local message="$2"
    local color="$3"
    
    case "$status" in
        "success") echo -e "${GREEN}${CHECKMARK} ${message}${NC}" ;;
        "error") echo -e "${RED}${CROSSMARK} ${message}${NC}" ;;
        "info") echo -e "${BLUE}${ARROW} ${message}${NC}" ;;
        "warning") echo -e "${YELLOW}${WARNING} ${message}${NC}" ;;
        "process") echo -e "${PURPLE}${GEAR} ${message}${NC}" ;;
        "remove") echo -e "${RED}${TRASH} ${message}${NC}" ;;
        "clean") echo -e "${CYAN}${CLEAN} ${message}${NC}" ;;
        "question") echo -e "${YELLOW}${QUESTION} ${message}${NC}" ;;
        *) echo -e "${color}${message}${NC}" ;;
    esac
}

# Function to create animated loading
show_loading() {
    local message="$1"
    local duration="${2:-2}"
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    for ((i=0; i<duration*10; i++)); do
        local char="${spinner:$((i % ${#spinner})):1}"
        printf "\r${RED}${char} ${message}${NC}"
        sleep 0.1
    done
    printf "\r${GREEN}${CHECKMARK} ${message} - Done!${NC}\n"
}

# Function to print progress bar
print_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${RED}${message} ["
    printf "%*s" $filled "" | tr ' ' '█'
    printf "%*s" $empty "" | tr ' ' '░'
    printf "] ${percentage}%%${NC}"
    
    if [ "$current" -eq "$total" ]; then
        printf "\n"
    fi
}

# Enhanced header
show_header() {
    clear
    print_separator "═" "$RED"
    echo
    print_center "${BOLD}${WHITE}${BG_RED}   XSHOT UNINSTALLER   ${NC}" ""
    echo
    print_center "${RED}${FIRE}${FIRE}${FIRE} Complete System Removal Tool ${FIRE}${FIRE}${FIRE}" ""
    echo
    print_separator "═" "$RED"
    echo
    print_center "${DIM}${WHITE}Enhanced Uninstallation Script v2.0${NC}" ""
    echo
    print_separator "─" "$DIM"
    echo
}

# Function to detect OS with enhanced accuracy
detect_os() {
    local os_name=""
    local os_version=""
    local os_arch=""
    
    # Get architecture
    os_arch=$(uname -m 2>/dev/null || echo "unknown")
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for Termux first
        if [ -d "/data/data/com.termux" ]; then
            os_name="termux"
            os_version=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
        # Check for Android (non-Termux)
        elif [ -f "/system/build.prop" ]; then
            os_name="android"
            os_version=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
        # Check for WSL
        elif grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
            os_name="wsl"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_version="$VERSION_ID (WSL: $NAME)"
            fi
        # Regular Linux distributions
        elif [ -f /etc/os-release ]; then
            . /etc/os-release
            os_name="$ID"
            os_version="$VERSION_ID"
            
            # Handle special cases
            case "$ID" in
                "ubuntu") 
                    if grep -q "Pop" /etc/os-release 2>/dev/null; then
                        os_name="pop"
                    fi
                    ;;
                "linuxmint") os_name="mint" ;;
                "elementary") os_name="elementary" ;;
                "manjaro") os_name="manjaro" ;;
                "endeavouros") os_name="endeavour" ;;
                "garuda") os_name="garuda" ;;
                "zorin") os_name="zorin" ;;
            esac
        # Fallback for older systems
        elif [ -f /etc/redhat-release ]; then
            os_name="rhel"
            os_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)
        elif [ -f /etc/debian_version ]; then
            os_name="debian"
            os_version=$(cat /etc/debian_version)
        elif [ -f /etc/arch-release ]; then
            os_name="arch"
            os_version="rolling"
        else
            os_name="linux"
            os_version="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macos"
        os_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        
        # Detect macOS codename
        local major_version=$(echo "$os_version" | cut -d. -f1)
        case "$major_version" in
            "14") os_version="$os_version (Sonoma)" ;;
            "13") os_version="$os_version (Ventura)" ;;
            "12") os_version="$os_version (Monterey)" ;;
            "11") os_version="$os_version (Big Sur)" ;;
            "10") os_version="$os_version (Catalina/Mojave/High Sierra)" ;;
        esac
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        os_name="cygwin"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "msys" ]]; then
        os_name="msys2"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "win32" ]] || [[ "$OS" == "Windows_NT" ]]; then
        os_name="windows"
        if command -v wmic >/dev/null 2>&1; then
            os_version=$(wmic os get Version /value 2>/dev/null | grep "Version=" | cut -d= -f2 | tr -d '\r')
        elif command -v powershell >/dev/null 2>&1; then
            os_version=$(powershell -Command "[System.Environment]::OSVersion.Version.ToString()" 2>/dev/null)
        else
            os_version="unknown"
        fi
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        os_name="freebsd"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "openbsd"* ]]; then
        os_name="openbsd"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "netbsd"* ]]; then
        os_name="netbsd"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "dragonfly"* ]]; then
        os_name="dragonfly"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "solaris"* ]]; then
        os_name="solaris"
        os_version=$(uname -r 2>/dev/null || echo "unknown")
    else
        os_name="unknown"
        os_version="unknown"
    fi
    
    echo "${os_name}|${os_version}|${os_arch}"
}

# Enhanced system info display
show_system_info() {
    local os_info=$(detect_os)
    local os_name=$(echo "$os_info" | cut -d'|' -f1)
    local os_version=$(echo "$os_info" | cut -d'|' -f2)
    local os_arch=$(echo "$os_info" | cut -d'|' -f3)
    
    print_box "SYSTEM INFORMATION" "$BLUE"
    echo
    
    local os_icon=""
    case "$os_name" in
        "ubuntu") os_icon="🟠" ;;
        "debian") os_icon="🔴" ;;
        "mint"|"linuxmint") os_icon="🟢" ;;
        "pop") os_icon="🟡" ;;
        "elementary") os_icon="⚪" ;;
        "fedora") os_icon="🔵" ;;
        "centos"|"rhel"|"rocky"|"almalinux") os_icon="🟣" ;;
        "arch") os_icon="🔷" ;;
        "manjaro") os_icon="🟢" ;;
        "endeavour") os_icon="🟣" ;;
        "garuda") os_icon="🦅" ;;
        "opensuse"|"sles") os_icon="🦎" ;;
        "alpine") os_icon="🏔️" ;;
        "macos") os_icon="🍎" ;;
        "windows") os_icon="🪟" ;;
        "wsl") os_icon="🐧🪟" ;;
        "termux") os_icon="📱" ;;
        "android") os_icon="🤖" ;;
        "freebsd") os_icon="😈" ;;
        "openbsd") os_icon="🐡" ;;
        "netbsd") os_icon="🚩" ;;
        "cygwin") os_icon="🔄" ;;
        "msys2") os_icon="⚙️" ;;
        *) os_icon="💻" ;;
    esac
    
    echo -e "  ${CYAN}${os_icon} Operating System:${NC} ${WHITE}${os_name^} ${os_version}${NC}"
    echo -e "  ${PURPLE}🏗️  Architecture:${NC} ${WHITE}${os_arch}${NC}"
    echo -e "  ${GREEN}🐍 Python Command:${NC} ${WHITE}${PYTHON_CMD}${NC}"
    echo -e "  ${YELLOW}📋 Pip Command:${NC} ${WHITE}${PIP_CMD}${NC}"
    
    if [ "$IS_ROOT" = true ]; then
        echo -e "  ${RED}👑 Running as:${NC} ${WHITE}Root${NC}"
    else
        echo -e "  ${GREEN}👤 Running as:${NC} ${WHITE}User${NC}"
    fi
    
    echo
    print_separator "─" "$DIM"
    echo
    
    # Store for later use
    OS="$os_name"
    OS_VERSION="$os_version"
    OS_ARCH="$os_arch"
}

# Function to scan for XShot installations
scan_installations() {
    print_box "SCANNING FOR XSHOT INSTALLATIONS" "$YELLOW"
    echo
    
    local found_items=()
    
    # Check for Python package
    if $PIP_CMD show xshot >/dev/null 2>&1; then
        found_items+=("Python package (pip)")
        print_status "info" "Found: XShot Python package"
    fi
    
    # Check for executables
    local bin_locations=("$HOME/.local/bin/xshot" "/usr/local/bin/xshot" "$PREFIX/bin/xshot")
    for bin_path in "${bin_locations[@]}"; do
        if [ -f "$bin_path" ]; then
            found_items+=("Executable: $bin_path")
            print_status "info" "Found: Executable at $bin_path"
        fi
    done
    
    # Check for installation directory
    if [ -d "$HOME/.xshot" ]; then
        local dir_size=$(du -sh "$HOME/.xshot" 2>/dev/null | cut -f1)
        found_items+=("Installation directory: $HOME/.xshot ($dir_size)")
        print_status "info" "Found: Installation directory ($dir_size)"
    fi
    
    # Check for config directory
    if [ -d "$HOME/.config/xshot" ]; then
        local config_size=$(du -sh "$HOME/.config/xshot" 2>/dev/null | cut -f1)
        found_items+=("Configuration directory: $HOME/.config/xshot ($config_size)")
        print_status "info" "Found: Configuration directory ($config_size)"
    fi
    
    # Check for shell PATH modifications
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ] && grep -q "xshot\|\.local/bin" "$config" 2>/dev/null; then
            found_items+=("PATH modification in: $(basename "$config")")
            print_status "info" "Found: PATH modification in $(basename "$config")"
        fi
    done
    
    # Check for desktop entries (Linux)
    if [ -f "$HOME/.local/share/applications/xshot.desktop" ]; then
        found_items+=("Desktop entry")
        print_status "info" "Found: Desktop entry"
    fi
    
    echo
    
    if [ ${#found_items[@]} -eq 0 ]; then
        print_status "warning" "No XShot installations found on this system"
        echo
        print_center "${DIM}Nothing to uninstall${NC}" ""
        echo
        exit 0
    else
        print_status "success" "Found ${#found_items[@]} XShot component(s) to remove"
    fi
    
    echo
    print_separator "─" "$DIM"
    echo
}

# Enhanced confirmation dialog
get_confirmation() {
    print_box "UNINSTALLATION CONFIRMATION" "$RED"
    echo
    
    print_status "warning" "This will completely remove XShot from your system!"
    echo
    echo -e "  ${RED}${BOOM} The following will be removed:${NC}"
    echo -e "    ${DIM}• Python packages and dependencies${NC}"
    echo -e "    ${DIM}• Executable files${NC}"
    echo -e "    ${DIM}• Installation directories${NC}"
    echo -e "    ${DIM}• Configuration files (optional)${NC}"
    echo -e "    ${DIM}• Shell PATH modifications${NC}"
    echo
    
    while true; do
        echo -e "${YELLOW}${QUESTION} Do you want to continue with the uninstallation? ${BOLD}(y/N)${NC}"
        read -r -p "$(echo -e "${CYAN}➤ ${NC}")" CONFIRM
        
        case "$CONFIRM" in
            [Yy]|[Yy][Ee][Ss])
                echo
                print_status "process" "Proceeding with uninstallation..."
                break
                ;;
            [Nn]|[Nn][Oo]|"")
                echo
                print_status "info" "Uninstallation cancelled by user"
                echo
                print_center "${GREEN}XShot remains installed${NC}" ""
                echo
                exit 0
                ;;
            *)
                print_status "error" "Please answer 'y' for yes or 'n' for no"
                echo
                ;;
        esac
    done
}

# Enhanced uninstallation with progress
uninstall_with_progress() {
    local steps=("Removing Python packages" "Removing executables" "Cleaning directories" "Removing PATH modifications" "Final cleanup")
    local total_steps=${#steps[@]}
    
    print_box "UNINSTALLATION PROGRESS" "$RED"
    echo
    
    for i in "${!steps[@]}"; do
        local step_num=$((i + 1))
        print_progress $step_num $total_steps "${steps[$i]}"
        
        case $step_num in
            1) remove_python_packages ;;
            2) remove_executables ;;
            3) remove_directories ;;
            4) remove_path_modifications ;;
            5) final_cleanup ;;
        esac
        
        sleep 0.5
    done
    
    echo
}

# Remove Python packages
remove_python_packages() {
    print_status "process" "Removing XShot Python packages..."
    
    # Try to uninstall the package
    if $PIP_CMD show xshot >/dev/null 2>&1; then
        show_loading "Uninstalling xshot package" 2
        $PIP_CMD uninstall -y xshot >/dev/null 2>&1 || true
        print_status "success" "Python package removed"
    else
        print_status "info" "No Python package found to remove"
    fi
    
    # Also try common variations
    for pkg in "xshot-py" "xshot_py" "XShot"; do
        if $PIP_CMD show "$pkg" >/dev/null 2>&1; then
            $PIP_CMD uninstall -y "$pkg" >/dev/null 2>&1 || true
            print_status "success" "Removed package: $pkg"
        fi
    done
}

# Remove executables
remove_executables() {
    print_status "process" "Removing executable files..."
    
    local removed_count=0
    local bin_locations=()
    
    if [ "$IS_TERMUX" = true ]; then
        bin_locations=("$PREFIX/bin/xshot")
    else
        bin_locations=("$HOME/.local/bin/xshot" "/usr/local/bin/xshot" "/usr/bin/xshot")
    fi
    
    for bin_path in "${bin_locations[@]}"; do
        if [ -f "$bin_path" ]; then
            show_loading "Removing $(basename "$bin_path") from $(dirname "$bin_path")" 1
            
            if [ -w "$(dirname "$bin_path")" ]; then
                rm -f "$bin_path" 2>/dev/null && {
                    print_status "success" "Removed: $bin_path"
                    ((removed_count++))
                }
            else
                sudo rm -f "$bin_path" 2>/dev/null && {
                    print_status "success" "Removed: $bin_path (with sudo)"
                    ((removed_count++))
                } || {
                    print_status "error" "Failed to remove: $bin_path"
                }
            fi
        fi
    done
    
    if [ $removed_count -eq 0 ]; then
        print_status "info" "No executable files found to remove"
    fi
}

# Remove directories with user choice
remove_directories() {
    print_status "process" "Processing directories..."
    
    # Installation directory
    if [ -d "$HOME/.xshot" ]; then
        echo
        print_status "question" "Remove installation directory ($HOME/.xshot)?"
        echo -e "  ${DIM}This contains the main XShot files${NC}"
        read -r -p "$(echo -e "${CYAN}➤ Remove? (Y/n): ${NC}")" REMOVE_INSTALL
        
        if [[ "$REMOVE_INSTALL" != "n" && "$REMOVE_INSTALL" != "N" ]]; then
            show_loading "Removing installation directory" 2
            rm -rf "$HOME/.xshot" 2>/dev/null
            print_status "success" "Installation directory removed"
        else
            print_status "info" "Installation directory kept"
        fi
    fi
    
    # Configuration directory
    if [ -d "$HOME/.config/xshot" ]; then
        echo
        print_status "question" "Remove configuration directory ($HOME/.config/xshot)?"
        echo -e "  ${DIM}This contains your settings and themes${NC}"
        read -r -p "$(echo -e "${CYAN}➤ Remove? (y/N): ${NC}")" REMOVE_CONFIG
        
        if [[ "$REMOVE_CONFIG" == "y" || "$REMOVE_CONFIG" == "Y" ]]; then
            show_loading "Removing configuration directory" 2
            rm -rf "$HOME/.config/xshot" 2>/dev/null
            print_status "success" "Configuration directory removed"
        else
            print_status "info" "Configuration directory kept"
        fi
    fi
    
    # Desktop entry
    if [ -f "$HOME/.local/share/applications/xshot.desktop" ]; then
        rm -f "$HOME/.local/share/applications/xshot.desktop" 2>/dev/null
        print_status "success" "Desktop entry removed"
    fi
}

# Remove PATH modifications
remove_path_modifications() {
    print_status "process" "Checking shell configurations..."
    
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
    local modified_count=0
    
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ]; then
            # Check if it contains XShot-related PATH modifications
            if grep -q "\.local/bin.*xshot\|xshot.*\.local/bin" "$config" 2>/dev/null; then
                echo
                print_status "question" "Remove XShot PATH modifications from $(basename "$config")?"
                read -r -p "$(echo -e "${CYAN}➤ Remove? (Y/n): ${NC}")" REMOVE_PATH
                
                if [[ "$REMOVE_PATH" != "n" && "$REMOVE_PATH" != "N" ]]; then
                    # Create backup
                    cp "$config" "$config.xshot-backup" 2>/dev/null
                    
                    # Remove XShot-related lines
                    sed -i.bak '/# XShot/d; /xshot/d' "$config" 2>/dev/null || {
                        # Fallback for systems without sed -i
                        grep -v -e "# XShot" -e "xshot" "$config" > "$config.tmp" && mv "$config.tmp" "$config"
                    }
                    
                    print_status "success" "PATH modifications removed from $(basename "$config")"
                    print_status "info" "Backup created: $config.xshot-backup"
                    ((modified_count++))
                fi
            fi
        fi
    done
    
    if [ $modified_count -eq 0 ]; then
        print_status "info" "No PATH modifications found to remove"
    fi
}

# Final cleanup
final_cleanup() {
    print_status "process" "Performing final cleanup..."
    
    # Clear any cached pip information
    show_loading "Clearing pip cache" 1
    $PIP_CMD cache purge >/dev/null 2>&1 || true
    
    # Update desktop database if available
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
    fi
    
    print_status "success" "Cleanup completed"
}

# Enhanced success message
show_success() {
    echo
    print_separator "═" "$GREEN"
    echo
    print_center "${GREEN}${BG_GREEN}${WHITE}   UNINSTALLATION COMPLETED!   ${NC}" ""
    echo
    print_center "${SPARKLES} XShot has been successfully removed! ${SPARKLES}" "$GREEN"
    echo
    print_separator "═" "$GREEN"
    echo
    
    print_box "POST-UNINSTALLATION NOTES" "$BLUE"
    echo
    echo -e "  ${GREEN}${CHECKMARK} ${BOLD}What was removed:${NC}"
    echo -e "    ${DIM}• XShot Python packages${NC}"
    echo -e "    ${DIM}• Executable files${NC}"
    echo -e "    ${DIM}• Installation directories (if selected)${NC}"
    echo -e "    ${DIM}• Configuration files (if selected)${NC}"
    echo
    echo -e "  ${YELLOW}${WARNING} ${BOLD}Please note:${NC}"
    echo -e "    ${DIM}• Restart your terminal to update PATH${NC}"
    echo -e "    ${DIM}• Backup files were created for shell configs${NC}"
    echo -e "    ${DIM}• Some dependencies may still be installed${NC}"
    echo
    
    if [ -f "$HOME/.bashrc.xshot-backup" ] || [ -f "$HOME/.zshrc.xshot-backup" ]; then
        echo -e "  ${BLUE}${FOLDER} ${BOLD}Backup files created:${NC}"
        for backup in "$HOME"/.*.xshot-backup; do
            if [ -f "$backup" ]; then
                echo -e "    ${DIM}• $(basename "$backup")${NC}"
            fi
        done
        echo
    fi
    
    print_separator "─" "$DIM"
    echo
    print_center "${DIM}Thank you for using XShot! ${STAR}${NC}" ""
    echo
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Initialize system detection
init_system() {
    # Detect if running on Termux
    if [ -d "/data/data/com.termux" ]; then
        IS_TERMUX=true
        PREFIX="/data/data/com.termux/files/usr"
        HOME="/data/data/com.termux/files/home"
        PYTHON_CMD="python"
        PIP_CMD="pip"
    else
        IS_TERMUX=false
        PREFIX="/usr"
        
        # Determine Python command
        if command_exists python3; then
            PYTHON_CMD="python3"
        elif command_exists python; then
            PYTHON_CMD="python"
        else
            PYTHON_CMD="python3"  # Default fallback
        fi
        
        # Determine pip command
        if command_exists pip3; then
            PIP_CMD="pip3"
        elif command_exists pip; then
            PIP_CMD="pip"
        else
            PIP_CMD="pip3"  # Default fallback
        fi
    fi
    
    # Check if running as root
    IS_ROOT=false
    if [ "$EUID" -eq 0 ] && [ "$IS_TERMUX" = false ]; then
        IS_ROOT=true
    fi
}

# Main uninstallation process
main() {
    # Initialize system
    init_system
    
    # Show header and system info
    show_header
    show_system_info
    
    # Scan for installations
    scan_installations
    
    # Get user confirmation
    get_confirmation
    
    # Perform uninstallation
    uninstall_with_progress
    
    # Show success message
    show_success
}

# Run main uninstallation
main
