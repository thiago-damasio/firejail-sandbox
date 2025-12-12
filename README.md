# 🔒 Firejail Sandbox Browser

A secure browser launcher using [Firejail](https://firejail.wordpress.com/) for maximum isolation and privacy.

## Features

- **Ultra-secure profile** - Drops all capabilities, enables seccomp, isolates filesystem
- **Network filtering** - Only allows DNS (53), HTTP (80), and HTTPS (443)
- **Privacy hardening** - Blocks camera, microphone, USB, and input devices
- **Auto-redirect resolution** - Follows URL redirects before opening
- **Clean output** - Suppresses Firejail/GTK warnings (use `-v` for debug)

## Requirements

- Linux with Firejail installed
- Firefox browser
- curl (for redirect resolution)

```bash
# Ubuntu/Debian
sudo apt install firejail firefox curl

# Arch Linux
sudo pacman -S firejail firefox curl
```

## Installation

```bash
git clone https://github.com/thiago-damasio/firejail-sandbox.git
cd firejail-sandbox
chmod +x sandbox_browser.sh
```

## Usage

```bash
# Basic usage
./sandbox_browser.sh https://example.com

# Verbose mode (shows all Firejail output)
./sandbox_browser.sh -v https://example.com
./sandbox_browser.sh --verbose https://example.com
```

## Security Features

| Feature | Description |
|---------|-------------|
| `private` | Private home directory (empty) |
| `private-dev` | Minimal /dev with no real devices |
| `private-tmp` | Private /tmp directory |
| `caps.drop all` | Drops all Linux capabilities |
| `seccomp` | System call filtering |
| `x11 none` | No X11 access |
| `dbus-* none` | No D-Bus access |
| `novideo` | No webcam access |
| `nosound` | No audio access |

## What Gets Blocked

- 🚫 Home directory access
- 🚫 USB devices
- 🚫 Camera and microphone
- 🚫 System logs
- 🚫 Non-HTTP/HTTPS network traffic
- 🚫 D-Bus communication

## Configuration Files

On first run, the script creates:

- `/etc/firejail/firefox-ultra.profile` - Ultra-secure Firefox profile
- `/etc/firejail/whitelist-minimal-http.inc` - Network filtering rules

## License

MIT License - Use at your own risk.

## Contributing

Pull requests welcome! Please test thoroughly before submitting.
