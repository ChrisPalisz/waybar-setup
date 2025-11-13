#!/bin/bash

################################################################################
# Waybar Installation and Configuration Script for Arch Linux
# Based on Omarchy waybar configuration
#
# This script installs and configures waybar with a setup inspired by Omarchy
# but adapted for standard Arch Linux systems (non-Omarchy).
#
# Features:
# - Full waybar installation with dependencies
# - Multiple theme options
# - Hyprland workspace integration
# - System monitoring (CPU, battery, network, audio)
# - Bluetooth support
# - System tray
# - Optional features configuration
#
# Usage: ./install-waybar.sh [options]
#   --skip-install    Skip package installation
#   --theme <name>    Set theme (catppuccin, nord, gruvbox, etc.)
#   --help            Show this help message
################################################################################

set -e

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SKIP_INSTALL=false
THEME="catppuccin"
CONFIG_DIR="${HOME}/.config/waybar"

################################################################################
# Helper Functions
################################################################################

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================${NC}\n"
}

show_help() {
    cat << EOF
Waybar Installation Script for Arch Linux

Usage: $0 [options]

Options:
    --skip-install       Skip package installation step
    --theme <name>       Set color theme (default: catppuccin)
                        Available: catppuccin, catppuccin-latte, nord,
                        gruvbox, tokyo-night, rose-pine, everforest,
                        kanagawa
    --help              Show this help message

Examples:
    $0                                  # Full installation with default theme
    $0 --theme nord                     # Install with Nord theme
    $0 --skip-install --theme gruvbox   # Only configure, don't install packages

EOF
    exit 0
}

################################################################################
# Parse Command Line Arguments
################################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --theme)
            THEME="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            ;;
    esac
done

################################################################################
# Package Installation
################################################################################

install_packages() {
    print_header "Installing Waybar and Dependencies"

    # Core packages
    local packages=(
        waybar              # The bar itself
        nerd-fonts         # For icons
        ttf-font-awesome   # Additional icons
        otf-font-awesome   # Additional icons
    )

    # Optional but recommended packages
    local optional_packages=(
        bluez              # Bluetooth support
        bluez-utils        # Bluetooth utilities
        blueberry          # Bluetooth manager (GUI)
        networkmanager     # Network management
        network-manager-applet  # NetworkManager GUI
        pamixer            # Audio mixer CLI
        pipewire           # Audio server
        wireplumber        # Pipewire session manager
        playerctl          # Media player control
        btop               # System monitor
        jq                 # JSON parsing (for scripts)
    )

    print_info "Installing core packages..."
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        print_success "Core packages installed successfully"
    else
        print_error "Failed to install core packages"
        exit 1
    fi

    print_info "Installing optional packages..."
    if sudo pacman -S --needed --noconfirm "${optional_packages[@]}"; then
        print_success "Optional packages installed successfully"
    else
        print_warning "Some optional packages failed to install (continuing anyway)"
    fi
}

################################################################################
# Theme Definitions
################################################################################

get_theme_colors() {
    local theme=$1

    case $theme in
        catppuccin)
            echo "@define-color foreground #cdd6f4;"
            echo "@define-color background #181824;"
            echo "@define-color accent #89b4fa;"
            ;;
        catppuccin-latte)
            echo "@define-color foreground #4c4f69;"
            echo "@define-color background #eff1f5;"
            echo "@define-color accent #1e66f5;"
            ;;
        nord)
            echo "@define-color foreground #d8dee9;"
            echo "@define-color background #2e3440;"
            echo "@define-color accent #88c0d0;"
            ;;
        gruvbox)
            echo "@define-color foreground #ebdbb2;"
            echo "@define-color background #282828;"
            echo "@define-color accent #83a598;"
            ;;
        tokyo-night)
            echo "@define-color foreground #c0caf5;"
            echo "@define-color background #1a1b26;"
            echo "@define-color accent #7aa2f7;"
            ;;
        rose-pine)
            echo "@define-color foreground #e0def4;"
            echo "@define-color background #191724;"
            echo "@define-color accent #31748f;"
            ;;
        everforest)
            echo "@define-color foreground #d3c6aa;"
            echo "@define-color background #2d353b;"
            echo "@define-color accent #a7c080;"
            ;;
        kanagawa)
            echo "@define-color foreground #dcd7ba;"
            echo "@define-color background #1f1f28;"
            echo "@define-color accent #7e9cd8;"
            ;;
        *)
            print_warning "Unknown theme '$theme', using catppuccin"
            get_theme_colors "catppuccin"
            ;;
    esac
}

################################################################################
# Create Configuration Files
################################################################################

create_config() {
    print_header "Creating Waybar Configuration"

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    # Backup existing configuration if it exists
    if [ -f "$CONFIG_DIR/config.jsonc" ]; then
        print_info "Backing up existing configuration..."
        mv "$CONFIG_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc.backup.$(date +%s)"
        print_success "Backup created"
    fi

    if [ -f "$CONFIG_DIR/style.css" ]; then
        mv "$CONFIG_DIR/style.css" "$CONFIG_DIR/style.css.backup.$(date +%s)"
    fi

    # Create config.jsonc
    print_info "Creating config.jsonc..."
    cat > "$CONFIG_DIR/config.jsonc" << 'EOF'
{
  "reload_style_on_change": true,
  "layer": "top",
  "position": "top",
  "spacing": 0,
  "height": 26,
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": [
    "group/tray-expander",
    "bluetooth",
    "network",
    "pulseaudio",
    "cpu",
    "battery"
  ],
  "hyprland/workspaces": {
    "on-click": "activate",
    "format": "{icon}",
    "format-icons": {
      "default": "",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5",
      "6": "6",
      "7": "7",
      "8": "8",
      "9": "9",
      "active": "󱓻"
    },
    "persistent-workspaces": {
      "1": [],
      "2": [],
      "3": [],
      "4": [],
      "5": []
    }
  },
  "cpu": {
    "interval": 5,
    "format": "󰍛",
    "tooltip-format": "CPU: {usage}%",
    "on-click": "kitty -e btop"
  },
  "clock": {
    "format": "{:L%A %H:%M}",
    "format-alt": "{:L%d %B W%V %Y}",
    "tooltip": false
  },
  "network": {
    "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
    "format": "{icon}",
    "format-wifi": "{icon}",
    "format-ethernet": "󰀂",
    "format-disconnected": "󰤮",
    "tooltip-format-wifi": "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}",
    "tooltip-format-ethernet": "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}",
    "tooltip-format-disconnected": "Disconnected",
    "interval": 3,
    "spacing": 1,
    "on-click": "nm-connection-editor"
  },
  "battery": {
    "format": "{capacity}% {icon}",
    "format-discharging": "{icon}",
    "format-charging": "{icon}",
    "format-plugged": "",
    "format-icons": {
      "charging": ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"],
      "default": ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    "format-full": "󰂅",
    "tooltip-format-discharging": "{power:>1.0f}W↓ {capacity}%",
    "tooltip-format-charging": "{power:>1.0f}W↑ {capacity}%",
    "interval": 5,
    "states": {
      "warning": 20,
      "critical": 10
    }
  },
  "bluetooth": {
    "format": "",
    "format-disabled": "󰂲",
    "format-connected": "",
    "tooltip-format": "Devices connected: {num_connections}",
    "on-click": "blueberry"
  },
  "pulseaudio": {
    "format": "{icon}",
    "on-click": "pavucontrol",
    "on-click-right": "pamixer -t",
    "tooltip-format": "Playing at {volume}%",
    "scroll-step": 5,
    "format-muted": "",
    "format-icons": {
      "default": ["", "", ""]
    }
  },
  "group/tray-expander": {
    "orientation": "inherit",
    "drawer": {
      "transition-duration": 600,
      "children-class": "tray-group-item"
    },
    "modules": ["custom/expand-icon", "tray"]
  },
  "custom/expand-icon": {
    "format": "",
    "tooltip": false
  },
  "tray": {
    "icon-size": 12,
    "spacing": 17
  }
}
EOF
    print_success "config.jsonc created"

    # Create style.css with selected theme
    print_info "Creating style.css with $THEME theme..."

    # Create theme colors file
    mkdir -p "$CONFIG_DIR/themes"
    get_theme_colors "$THEME" > "$CONFIG_DIR/themes/${THEME}.css"

    cat > "$CONFIG_DIR/style.css" << EOF
@import "themes/${THEME}.css";

* {
  background-color: @background;
  color: @foreground;

  border: none;
  border-radius: 0;
  min-height: 0;
  font-family: 'CaskaydiaMono Nerd Font', 'Noto Sans Nerd Font', monospace;
  font-size: 12px;
}

.modules-left {
  margin-left: 8px;
}

.modules-right {
  margin-right: 8px;
}

#workspaces button {
  all: initial;
  padding: 0 6px;
  margin: 0 1.5px;
  min-width: 9px;
  color: @foreground;
}

#workspaces button.empty {
  opacity: 0.5;
}

#workspaces button.active {
  color: @accent;
  font-weight: bold;
}

#workspaces button:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

#cpu,
#battery,
#pulseaudio {
  min-width: 12px;
  margin: 0 7.5px;
}

#tray {
  margin-right: 16px;
}

#bluetooth {
  margin-right: 17px;
}

#network {
  margin-right: 13px;
}

#custom-expand-icon {
  margin-right: 20px;
}

tooltip {
  padding: 2px;
  background-color: @background;
  border: 1px solid @accent;
}

#clock {
  margin-left: 8.75px;
  font-weight: bold;
}

.hidden {
  opacity: 0;
}

/* Battery warning states */
#battery.warning {
  color: #f9e2af;
}

#battery.critical {
  color: #f38ba8;
  animation: blink 1s linear infinite;
}

@keyframes blink {
  50% {
    opacity: 0.5;
  }
}

/* Pulseaudio muted state */
#pulseaudio.muted {
  opacity: 0.6;
}

/* Network disconnected state */
#network.disconnected {
  color: #f38ba8;
}
EOF
    print_success "style.css created with $THEME theme"
}

################################################################################
# Create Helper Scripts
################################################################################

create_helper_scripts() {
    print_header "Creating Helper Scripts"

    local bin_dir="${HOME}/.local/bin"
    mkdir -p "$bin_dir"

    # Create waybar restart script
    print_info "Creating waybar-restart script..."
    cat > "$bin_dir/waybar-restart" << 'EOF'
#!/bin/bash
# Restart waybar
killall waybar 2>/dev/null
waybar &
EOF
    chmod +x "$bin_dir/waybar-restart"
    print_success "waybar-restart created"

    # Create waybar reload config script
    print_info "Creating waybar-reload script..."
    cat > "$bin_dir/waybar-reload" << 'EOF'
#!/bin/bash
# Reload waybar configuration
killall -SIGUSR2 waybar
EOF
    chmod +x "$bin_dir/waybar-reload"
    print_success "waybar-reload created"

    # Create theme switcher script
    print_info "Creating waybar-theme script..."
    cat > "$bin_dir/waybar-theme" << 'EOFTHEME'
#!/bin/bash

THEME_DIR="${HOME}/.config/waybar/themes"
CONFIG_DIR="${HOME}/.config/waybar"

if [ -z "$1" ]; then
    echo "Usage: waybar-theme <theme-name>"
    echo "Available themes:"
    ls "$THEME_DIR" | sed 's/.css$//'
    exit 1
fi

THEME="$1"
THEME_FILE="${THEME_DIR}/${THEME}.css"

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme '$THEME' not found!"
    echo "Available themes:"
    ls "$THEME_DIR" | sed 's/.css$//'
    exit 1
fi

# Update style.css to import new theme
sed -i "s|@import \"themes/.*\.css\";|@import \"themes/${THEME}.css\";|" "$CONFIG_DIR/style.css"

echo "Theme changed to: $THEME"
echo "Reloading waybar..."
killall -SIGUSR2 waybar || waybar &
EOFTHEME
    chmod +x "$bin_dir/waybar-theme"
    print_success "waybar-theme created"

    # Create all theme files
    print_info "Creating all theme files..."
    local themes=("catppuccin" "catppuccin-latte" "nord" "gruvbox" "tokyo-night" "rose-pine" "everforest" "kanagawa")
    for theme in "${themes[@]}"; do
        get_theme_colors "$theme" > "$CONFIG_DIR/themes/${theme}.css"
    done
    print_success "All theme files created"
}

################################################################################
# Setup Autostart
################################################################################

setup_autostart() {
    print_header "Setting up Autostart"

    # Check if using Hyprland
    if [ -f "${HOME}/.config/hypr/hyprland.conf" ]; then
        print_info "Hyprland configuration detected"

        # Check if waybar is already in hyprland.conf
        if grep -q "exec-once.*waybar" "${HOME}/.config/hypr/hyprland.conf"; then
            print_warning "Waybar autostart already configured in Hyprland"
        else
            print_info "Add the following line to your ~/.config/hypr/hyprland.conf:"
            echo -e "${GREEN}exec-once = waybar${NC}"
        fi
    else
        print_info "To autostart waybar, add it to your window manager/compositor configuration"
    fi
}

################################################################################
# Final Instructions
################################################################################

show_final_instructions() {
    print_header "Installation Complete!"

    cat << EOF
${GREEN}Waybar has been successfully installed and configured!${NC}

${BLUE}Configuration Location:${NC}
  - Config: ${CONFIG_DIR}/config.jsonc
  - Style:  ${CONFIG_DIR}/style.css
  - Themes: ${CONFIG_DIR}/themes/

${BLUE}Helper Scripts (in ~/.local/bin):${NC}
  - waybar-restart  : Restart waybar
  - waybar-reload   : Reload configuration
  - waybar-theme    : Switch themes

${BLUE}Usage Examples:${NC}
  # Start waybar
  waybar &

  # Restart waybar
  waybar-restart

  # Reload configuration (without restart)
  waybar-reload

  # Change theme
  waybar-theme nord
  waybar-theme gruvbox
  waybar-theme tokyo-night

${BLUE}Current Theme:${NC} ${THEME}

${BLUE}Available Themes:${NC}
  - catppuccin
  - catppuccin-latte
  - nord
  - gruvbox
  - tokyo-night
  - rose-pine
  - everforest
  - kanagawa

${BLUE}Customization:${NC}
  - Edit ${CONFIG_DIR}/config.jsonc to modify modules and behavior
  - Edit ${CONFIG_DIR}/style.css to customize appearance
  - Create custom themes in ${CONFIG_DIR}/themes/

${BLUE}Note:${NC}
  - Make sure ~/.local/bin is in your PATH
  - This configuration is optimized for Hyprland
  - Adjust terminal commands in config.jsonc if not using kitty
  - Some modules may require additional configuration (bluetooth, network, etc.)

${YELLOW}To start waybar now, run:${NC} waybar &

EOF
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "Waybar Installation Script"
    print_info "Theme: $THEME"
    print_info "Skip Installation: $SKIP_INSTALL"
    echo

    # Install packages
    if [ "$SKIP_INSTALL" = false ]; then
        install_packages
    else
        print_info "Skipping package installation"
    fi

    # Create configuration
    create_config

    # Create helper scripts
    create_helper_scripts

    # Setup autostart
    setup_autostart

    # Show final instructions
    show_final_instructions

    print_success "Setup complete!"
}

# Run main function
main
