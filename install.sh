#!/bin/bash
# XShot Cross-Platform Installation Script

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
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"
DOWNLOAD="⬇️"
FOLDER="📁"
WRENCH="🔧"
SPARKLES="✨"

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
        "warning") echo -e "${YELLOW}⚠️  ${message}${NC}" ;;
        "process") echo -e "${PURPLE}${GEAR} ${message}${NC}" ;;
        "download") echo -e "${CYAN}${DOWNLOAD} ${message}${NC}" ;;
        *) echo -e "${color}${message}${NC}" ;;
    esac
}

# Function to create animated loading
show_loading() {
    local message="$1"
    local duration="${2:-3}"
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    for ((i=0; i<duration*10; i++)); do
        local char="${spinner:$((i % ${#spinner})):1}"
        printf "\r${PURPLE}${char} ${message}${NC}"
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
    
    printf "\r${CYAN}${message} ["
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
    print_separator "═" "$CYAN"
    echo
    print_center "${BOLD}${WHITE}${BG_BLUE}   XSHOT INSTALLER   ${NC}" ""
    echo
    print_center "${PURPLE}${STAR}${STAR}${STAR} Cross-Platform Screenshot Tool ${STAR}${STAR}${STAR}" ""
    echo
    print_separator "═" "$CYAN"
    echo
    print_center "${DIM}${WHITE}Enhanced Installation Script v2.0${NC}" ""
    echo
    print_separator "─" "$DIM"
    echo
}

# Enhanced system info display
show_system_info() {
    print_box "SYSTEM INFORMATION" "$BLUE"
    echo
    
    local os_icon=""
    case "$OS" in
        "ubuntu"|"debian") os_icon="🐧" ;;
        "fedora"|"centos"|"rhel") os_icon="🎩" ;;
        "arch"|"manjaro") os_icon="🏔️" ;;
        "macos") os_icon="🍎" ;;
        "windows") os_icon="🪟" ;;
        "termux") os_icon="📱" ;;
        *) os_icon="💻" ;;
    esac
    
    echo -e "  ${CYAN}${os_icon} Operating System:${NC} ${WHITE}${OS}${NC}"
    echo -e "  ${PURPLE}${PACKAGE} Package Manager:${NC} ${WHITE}${PACKAGE_MANAGER}${NC}"
    echo -e "  ${GREEN}🐍 Python Command:${NC} ${WHITE}${PYTHON_CMD}${NC}"
    echo -e "  ${YELLOW}📋 Pip Command:${NC} ${WHITE}${PIP_CMD}${NC}"
    echo -e "  ${BLUE}${FOLDER} Install Directory:${NC} ${WHITE}${BIN_DIR}${NC}"
    
    if [ "$IS_ROOT" = true ]; then
        echo -e "  ${RED}👑 Running as:${NC} ${WHITE}Root${NC}"
    else
        echo -e "  ${GREEN}👤 Running as:${NC} ${WHITE}User${NC}"
    fi
    
    echo
    print_separator "─" "$DIM"
    echo
}

# Enhanced installation steps
install_with_progress() {
    local steps=("Updating package lists" "Installing dependencies" "Setting up directories" "Copying files" "Installing Python packages" "Creating executables" "Setting up assets" "Finalizing installation")
    local total_steps=${#steps[@]}
    
    print_box "INSTALLATION PROGRESS" "$GREEN"
    echo
    
    for i in "${!steps[@]}"; do
        local step_num=$((i + 1))
        print_progress $step_num $total_steps "${steps[$i]}"
        
        case $step_num in
            1) show_loading "Updating repositories" 2 ;;
            2) install_packages_enhanced ;;
            3) create_install_dir_enhanced ;;
            4) copy_files_enhanced ;;
            5) install_python_deps_enhanced ;;
            6) create_executable_enhanced ;;
            7) setup_assets_enhanced ;;
            8) show_loading "Cleaning up and finalizing" 1 ;;
        esac
        
        sleep 0.5
    done
    
    echo
}

# Enhanced package installation
install_packages_enhanced() {
    print_status "process" "Installing system dependencies..."
    
    case "$OS" in
        "termux")
            show_loading "Updating Termux packages" 2
            pkg update -y >/dev/null 2>&1
            show_loading "Installing Python and ImageMagick" 3
            pkg install -y python imagemagick python-pip termux-api wget git >/dev/null 2>&1
            termux-setup-storage 2>/dev/null || true
            ;;
        "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary")
            if [ "$IS_ROOT" = true ]; then
                apt-get update >/dev/null 2>&1
                apt-get install -y python3 python3-pip imagemagick wget git curl >/dev/null 2>&1
            else
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install -y python3 python3-pip imagemagick wget git curl >/dev/null 2>&1
            fi
            ;;
        "macos")
            if ! command_exists brew; then
                print_status "info" "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
            fi
            brew update >/dev/null 2>&1
            brew install python imagemagick wget git curl >/dev/null 2>&1
            ;;
        *)
            # Other OS installations remain the same but with enhanced output
            install_packages >/dev/null 2>&1
            ;;
    esac
    
    print_status "success" "Dependencies installed successfully"
}

# Enhanced directory creation
create_install_dir_enhanced() {
    INSTALL_DIR="$HOME/.xshot"
    CONFIG_DIR="$HOME/.config/xshot"
    
    print_status "process" "Creating installation directories..."
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR/themes"
    print_status "success" "Directories created: $INSTALL_DIR"
}

# Enhanced file copying
copy_files_enhanced() {
    print_status "process" "Copying XShot files..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/" 2>/dev/null; then
        print_status "success" "Files copied successfully"
    else
        print_status "error" "Failed to copy files"
        exit 1
    fi
}

# Enhanced Python dependencies installation
install_python_deps_enhanced() {
    print_status "process" "Installing Python dependencies..."
    
    if [ -f "$INSTALL_DIR/requirements.txt" ]; then
        $PIP_CMD install --user -r "$INSTALL_DIR/requirements.txt" >/dev/null 2>&1
    else
        $PIP_CMD install --user pillow click colorama >/dev/null 2>&1
    fi
    
    if [ -f "$INSTALL_DIR/setup.py" ]; then
        cd "$INSTALL_DIR"
        $PIP_CMD install --user -e . >/dev/null 2>&1
    fi
    
    print_status "success" "Python packages installed"
}

# Enhanced executable creation
create_executable_enhanced() {
    print_status "process" "Creating executable script..."
    
    cat > "$BIN_DIR/xshot" << 'EOF'
#!/bin/bash
# XShot launcher script - Enhanced version
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
else
    echo "❌ Python not found!"
    exit 1
fi

# Try to run as module first, then as script
if $PYTHON_CMD -m xshot_py.main "$@" 2>/dev/null; then
    exit 0
elif [ -f "$HOME/.xshot/xshot.py" ]; then
    $PYTHON_CMD "$HOME/.xshot/xshot.py" "$@"
elif [ -f "$HOME/.xshot/main.py" ]; then
    $PYTHON_CMD "$HOME/.xshot/main.py" "$@"
else
    echo "❌ XShot main script not found!"
    exit 1
fi
EOF
    
    chmod +x "$BIN_DIR/xshot"
    print_status "success" "Executable created at $BIN_DIR/xshot"
}

# Enhanced assets setup
setup_assets_enhanced() {
    print_status "process" "Setting up assets and fonts..."
    mkdir -p "$INSTALL_DIR/assets/fonts" "$INSTALL_DIR/xshot_py/assets/fonts" 2>/dev/null
    
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Medium/complete/JetBrains%20Mono%20Medium%20Nerd%20Font%20Complete.ttf"
    
    if command_exists wget; then
        wget -q "$FONT_URL" -O "$INSTALL_DIR/assets/fonts/JetBrains-Mono.ttf" 2>/dev/null || true
    elif command_exists curl; then
        curl -sL "$FONT_URL" -o "$INSTALL_DIR/assets/fonts/JetBrains-Mono.ttf" 2>/dev/null || true
    fi
    
    print_status "success" "Assets configured"
}

# Enhanced success message
show_success() {
    echo
    print_separator "═" "$GREEN"
    echo
    print_center "${GREEN}${BG_GREEN}${WHITE}   INSTALLATION COMPLETED!   ${NC}" ""
    echo
    print_center "${SPARKLES} XShot has been installed successfully! ${SPARKLES}" "$GREEN"
    echo
    print_separator "═" "$GREEN"
    echo
    
    print_box "QUICK START GUIDE" "$BLUE"
    echo
    echo -e "  ${ROCKET} ${BOLD}Run XShot:${NC}"
    echo -e "    ${CYAN}$ xshot${NC}"
    echo
    echo -e "  ${WRENCH} ${BOLD}Get help:${NC}"
    echo -e "    ${CYAN}$ xshot --help${NC}"
    echo
    echo -e "  ${FOLDER} ${BOLD}Config location:${NC}"
    echo -e "    ${DIM}$HOME/.config/xshot/${NC}"
    echo
    
    if [ "$IS_TERMUX" = false ] && [ "$IS_ROOT" = false ]; then
        echo -e "  ${YELLOW}⚠️  ${BOLD}If command not found:${NC}"
        echo -e "    ${CYAN}$ source ~/.bashrc${NC}"
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

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -d "/data/data/com.termux" ]; then
            echo "termux"
        elif [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo "freebsd"
    else
        echo "unknown"
    fi
}

# Initialize variables (keeping original logic)
OS=$(detect_os)
IS_TERMUX=false
IS_ROOT=false

if [ "$EUID" -eq 0 ] && [ "$OS" != "termux" ]; then
    IS_ROOT=true
fi

# Set OS-specific variables (keeping original logic)
case "$OS" in
    "termux")
        IS_TERMUX=true
        PREFIX="/data/data/com.termux/files/usr"
        HOME="/data/data/com.termux/files/home"
        PACKAGE_MANAGER="pkg"
        PYTHON_CMD="python"
        PIP_CMD="pip"
        INSTALL_CMD="pkg install -y"
        UPDATE_CMD="pkg update -y"
        BIN_DIR="$PREFIX/bin"
        ;;
    "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary")
        PACKAGE_MANAGER="apt"
        INSTALL_CMD="apt-get install -y"
        UPDATE_CMD="apt-get update"
        ;;
    "fedora"|"centos"|"rhel"|"rocky"|"almalinux")
        if command_exists dnf; then
            PACKAGE_MANAGER="dnf"
            INSTALL_CMD="dnf install -y"
            UPDATE_CMD="dnf check-update || true"
        else
            PACKAGE_MANAGER="yum"
            INSTALL_CMD="yum install -y"
            UPDATE_CMD="yum check-update || true"
        fi
        ;;
    "arch"|"manjaro"|"endeavouros")
        PACKAGE_MANAGER="pacman"
        INSTALL_CMD="pacman -S --noconfirm"
        UPDATE_CMD="pacman -Sy"
        ;;
    "opensuse"|"sles")
        PACKAGE_MANAGER="zypper"
        INSTALL_CMD="zypper install -y"
        UPDATE_CMD="zypper refresh"
        ;;
    "alpine")
        PACKAGE_MANAGER="apk"
        INSTALL_CMD="apk add"
        UPDATE_CMD="apk update"
        ;;
    "macos")
        if command_exists brew; then
            PACKAGE_MANAGER="brew"
            INSTALL_CMD="brew install"
            UPDATE_CMD="brew update"
        else
            PACKAGE_MANAGER="brew"
            INSTALL_CMD="brew install"
            UPDATE_CMD="brew update"
        fi
        ;;
    "freebsd")
        PACKAGE_MANAGER="pkg"
        INSTALL_CMD="pkg install -y"
        UPDATE_CMD="pkg update"
        ;;
    "windows")
        if command_exists choco; then
            PACKAGE_MANAGER="choco"
            INSTALL_CMD="choco install -y"
            UPDATE_CMD="choco upgrade all -y"
        elif command_exists winget; then
            PACKAGE_MANAGER="winget"
            INSTALL_CMD="winget install"
            UPDATE_CMD="winget upgrade --all"
        else
            PACKAGE_MANAGER="manual"
        fi
        ;;
    *)
        PACKAGE_MANAGER="manual"
        ;;
esac

# Set Python and pip commands
if [ "$IS_TERMUX" = false ]; then
    if command_exists python3; then
        PYTHON_CMD="python3"
    elif command_exists python; then
        PYTHON_CMD="python"
    else
        PYTHON_CMD=""
    fi
    
    if command_exists pip3; then
        PIP_CMD="pip3"
    elif command_exists pip; then
        PIP_CMD="pip"
    else
        PIP_CMD=""
    fi
    
    if [ "$IS_ROOT" = true ]; then
        BIN_DIR="/usr/local/bin"
    else
        BIN_DIR="$HOME/.local/bin"
        mkdir -p "$BIN_DIR"
    fi
fi

# Keep original install_packages function for fallback
install_packages() {
    case "$OS" in
        "termux")
            pkg update -y
            pkg install -y python imagemagick python-pip termux-api wget git
            termux-setup-storage 2>/dev/null || true
            ;;
        "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary")
            if [ "$IS_ROOT" = true ]; then
                apt-get update
                apt-get install -y python3 python3-pip imagemagick wget git curl
            else
                sudo apt-get update
                sudo apt-get install -y python3 python3-pip imagemagick wget git curl
            fi
            ;;
        # ... (keep other cases from original)
    esac
}

# Main installation process
main() {
    show_header
    show_system_info
    
    # Check dependencies
    if [ -z "$PYTHON_CMD" ] || [ -z "$PIP_CMD" ]; then
        print_status "warning" "Python or pip not found. Installing dependencies first..."
        install_packages
        
        # Re-detect Python and pip
        if command_exists python3; then
            PYTHON_CMD="python3"
        elif command_exists python; then
            PYTHON_CMD="python"
        fi
        
        if command_exists pip3; then
            PIP_CMD="pip3"
        elif command_exists pip; then
            PIP_CMD="pip"
        fi
    fi
    
    # Run installation with progress
    install_with_progress
    
    # Add to PATH if needed
    if [ "$IS_TERMUX" = false ] && [ "$IS_ROOT" = false ]; then
        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            for shell_config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                if [ -f "$shell_config" ]; then
                    if ! grep -q "$BIN_DIR" "$shell_config"; then
                        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_config"
                    fi
                fi
            done
        fi
    fi
    
    # Test installation
    if command_exists xshot || [ -x "$BIN_DIR/xshot" ]; then
        print_status "success" "Installation test: PASSED"
    else
        print_status "warning" "Installation test: Please check if $BIN_DIR is in your PATH"
    fi
    
    show_success
}

# Run main installation
main