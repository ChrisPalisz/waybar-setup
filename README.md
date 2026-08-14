# Waybar Setup for Arch Linux

A complete waybar installation and configuration script for Arch Linux, inspired by the Omarchy distribution but adapted for standard Arch systems.

## Features

- 🎨 **8 Built-in Themes** - Catppuccin, Nord, Gruvbox, Tokyo Night, Rose Pine, and more
- 🔄 **Easy Theme Switching** - Change themes on-the-fly with a simple command
- ⚙️ **Hyprland Integration** - Workspace indicators and window manager integration
- 📊 **System Monitoring** - CPU, battery, network, audio, and bluetooth status
- 🛠️ **Helper Scripts** - Convenient scripts for restart, reload, and theme switching
- 📦 **Complete Installation** - Handles all dependencies automatically
- 🎯 **Clean Configuration** - Well-documented and easy to customize

## Preview

The waybar configuration includes:
- **Left**: Hyprland workspaces
- **Center**: Clock with date toggle
- **Right**: System tray, Bluetooth, Network, Audio, CPU, Battery

All with beautiful icons from Nerd Fonts and smooth animations.

## Requirements

- Arch Linux (or Arch-based distribution)
- Hyprland (recommended, but adaptable to other Wayland compositors)
- `sudo` access for package installation

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/mlynchdev/waybar-setup.git
cd waybar-setup

# Run the installation script
./install-waybar.sh
```

### Custom Installation

```bash
# Install with a specific theme
./install-waybar.sh --theme nord

# Skip package installation (only configure)
./install-waybar.sh --skip-install

# Combine options
./install-waybar.sh --skip-install --theme gruvbox
```

### Available Options

- `--skip-install` - Skip package installation step (useful if packages are already installed)
- `--theme <name>` - Set initial theme (default: catppuccin)
- `--help` - Show help message

## Themes

The following themes are included:

| Theme | Style |
|-------|-------|
| **catppuccin** | Mocha variant with purple accents (default) |
| **catppuccin-latte** | Light variant for daytime use |
| **nord** | Cool, arctic-inspired palette |
| **gruvbox** | Retro groove with warm colors |
| **tokyo-night** | Dark theme inspired by Tokyo at night |
| **rose-pine** | Natural pine, faux fur and a bit of soho vibes |
| **everforest** | Comfortable green forest theme |
| **kanagawa** | Dark theme inspired by famous Japanese painting |

## Usage

### Starting Waybar

```bash
# Start waybar
waybar &

# Or add to your Hyprland config

Original hyprlang format (~/.config/hypr/hyprland.conf)
exec-once = waybar

New Lua format (~/.config/hypr/hyprland.conf)
hl.on("hyprland.start", function ()
   hl.exec_cmd("waybar")
 end)

#

```

### Helper Scripts

After installation, these scripts will be available in `~/.local/bin`:

```bash
# Restart waybar (useful after config changes that need full restart)
waybar-restart

# Reload configuration without restarting (faster, preserves state)
waybar-reload

# Switch themes
waybar-theme nord
waybar-theme gruvbox
waybar-theme tokyo-night
```

### Theme Switching

```bash
# List available themes
waybar-theme

# Switch to a specific theme
waybar-theme nord          # Cool blue theme
waybar-theme gruvbox       # Warm retro theme
waybar-theme tokyo-night   # Dark night theme
waybar-theme rose-pine     # Natural pine theme
```

## Configuration

### File Locations

- **Main Config**: `~/.config/waybar/config.jsonc`
- **Styles**: `~/.config/waybar/style.css`
- **Themes**: `~/.config/waybar/themes/`
- **Helper Scripts**: `~/.local/bin/waybar-*`

### Customization

#### Modifying Modules

Edit `~/.config/waybar/config.jsonc` to add, remove, or configure modules:

```jsonc
{
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": [
    "bluetooth",
    "network",
    "pulseaudio",
    "cpu",
    "battery"
  ]
}
```

#### Customizing Appearance

Edit `~/.config/waybar/style.css` to modify spacing, sizes, colors, and more:

```css
* {
  font-size: 12px;  /* Change font size */
}

#workspaces button {
  padding: 0 6px;   /* Adjust workspace button padding */
}
```

#### Creating Custom Themes

Create a new file in `~/.config/waybar/themes/mytheme.css`:

```css
@define-color foreground #your-fg-color;
@define-color background #your-bg-color;
@define-color accent #your-accent-color;
```

Then use it:

```bash
waybar-theme mytheme
```

## Modules Configuration

### Hyprland Workspaces
- Click to activate workspace
- Shows numbers 1-5 as persistent workspaces
- Highlights active workspace

### Clock
- Left click: Toggle between time and date format
- Shows day of week and 24-hour time by default

### Network
- Shows WiFi signal strength or ethernet connection
- Displays bandwidth usage in tooltip
- Click to open network manager

### Audio (PulseAudio)
- Shows volume level with icon
- Left click: Open pavucontrol (audio mixer)
- Right click: Mute/unmute
- Scroll: Adjust volume

### Bluetooth
- Shows bluetooth status and connection count
- Click to open bluetooth manager (blueberry)

### CPU
- Shows CPU icon
- Tooltip displays CPU usage percentage
- Click to open btop (system monitor)

### Battery
- Shows battery level with appropriate icon
- Different icons for charging/discharging states
- Color changes at 20% (warning) and 10% (critical)

### System Tray
- Expandable tray for system icons
- Click the arrow to expand/collapse

## Packages Installed

### Core Packages
- `waybar` - The status bar
- `nerd-fonts` - Icon fonts
- `ttf-font-awesome` - Additional icons
- `otf-font-awesome` - Additional icons

### Optional Packages
- `bluez`, `bluez-utils`, `blueberry` - Bluetooth support
- `networkmanager`, `network-manager-applet` - Network management
- `pamixer` - Audio control
- `pipewire`, `wireplumber` - Audio server
- `playerctl` - Media player control
- `btop` - System monitor
- `pavucontrol` - Audio mixer GUI

## Troubleshooting

### Waybar doesn't start

```bash
# Check for errors
waybar

# Check if waybar is already running
killall waybar
waybar &
```

### Icons not showing

Make sure Nerd Fonts are installed:

```bash
sudo pacman -S nerd-fonts
```

Then restart waybar:

```bash
waybar-restart
```

### Module not working

Check if the required package is installed:

```bash
# For bluetooth
sudo pacman -S bluez bluez-utils blueberry

# For network
sudo pacman -S networkmanager network-manager-applet

# For audio
sudo pacman -S pipewire wireplumber pamixer pavucontrol
```

### Configuration not reloading

Some changes require a full restart:

```bash
waybar-restart
```

### Scripts not found

Make sure `~/.local/bin` is in your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"

# Reload shell
source ~/.bashrc  # or source ~/.zshrc
```

## Customization Examples

### Change Terminal Emulator

If you don't use kitty, edit `config.jsonc` and replace `kitty` with your terminal:

```jsonc
"cpu": {
  "on-click": "alacritty -e btop"  // or gnome-terminal, wezterm, etc.
}
```

### Adjust Bar Height

In `config.jsonc`:

```jsonc
{
  "height": 30  // Change from 26 to 30
}
```

### Change Font

In `style.css`:

```css
* {
  font-family: 'JetBrainsMono Nerd Font', monospace;
  font-size: 14px;
}
```

### Add Custom Module

In `config.jsonc`:

```jsonc
"custom/weather": {
  "format": "{}",
  "exec": "curl wttr.in/?format=1",
  "interval": 3600
}
```

Don't forget to add it to your modules list:

```jsonc
"modules-center": ["clock", "custom/weather"]
```

## Advanced Configuration

### Multiple Bar Instances

Create separate config files for different monitors or positions:

```bash
# Top bar
waybar -c ~/.config/waybar/config-top.jsonc &

# Bottom bar
waybar -c ~/.config/waybar/config-bottom.jsonc &
```

### Custom Scripts

Add custom scripts to display any information:

```jsonc
"custom/script": {
  "exec": "~/.config/waybar/scripts/myscript.sh",
  "interval": 5,
  "return-type": "json"
}
```

## Contributing

Feel free to submit issues and pull requests for:
- New themes
- Module configurations
- Bug fixes
- Documentation improvements
- Feature requests

## License

MIT License - Feel free to use and modify as needed.

## Resources

- [Waybar Documentation](https://github.com/Alexays/Waybar/wiki)
- [Hyprland Documentation](https://wiki.hyprland.org/)
- [Nerd Fonts](https://www.nerdfonts.com/)

## Credits

Configuration inspired by the [Omarchy](https://omakub.org/) distribution.

---

**Note**: This configuration is optimized for Hyprland on Wayland. For other window managers or compositors, you may need to adjust the workspace module and other compositor-specific features.
