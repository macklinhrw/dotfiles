#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 is not installed. Please install it first."
        exit 1
    fi
}

install_go() {
    log "Installing Go..."
    
    # Check if Go is already installed (check both PATH and common locations)
    if command -v go &> /dev/null || [[ -f "/usr/local/go/bin/go" ]]; then
        if command -v go &> /dev/null; then
            GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
            log "Go $GO_VERSION is already installed and in PATH"
        else
            GO_VERSION=$(/usr/local/go/bin/go version | awk '{print $3}' | sed 's/go//')
            log "Go $GO_VERSION is already installed at /usr/local/go"
        fi
        return 0
    fi
    
    # Determine architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    # Download and install Go
    GO_VERSION="1.21.5"
    GO_TARBALL="go${GO_VERSION}.linux-${ARCH}.tar.gz"
    
    log "Downloading Go $GO_VERSION for $ARCH..."
    cd /tmp
    curl -LO "https://go.dev/dl/$GO_TARBALL"
    
    # Check if download was successful
    if [[ ! -f "$GO_TARBALL" ]]; then
        error "Failed to download Go $GO_VERSION"
        exit 1
    fi
    
    # Verify the download is a valid gzip file
    if ! gzip -t "$GO_TARBALL" 2>/dev/null; then
        error "Downloaded file is not a valid gzip archive"
        rm -f "$GO_TARBALL"
        exit 1
    fi
    
    # Remove existing Go installation if it exists
    sudo rm -rf /usr/local/go
    
    # Extract and install Go
    if ! sudo tar -C /usr/local -xzf "$GO_TARBALL"; then
        error "Failed to extract Go archive"
        rm -f "$GO_TARBALL"
        exit 1
    fi
    
    # Add Go to PATH
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        if ! grep -q "/usr/local/go/bin" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Go installation" >> "$SHELL_CONFIG"
            echo 'export PATH=$PATH:/usr/local/go/bin' >> "$SHELL_CONFIG"
            echo 'export GOPATH=$HOME/go' >> "$SHELL_CONFIG"
            echo 'export PATH=$PATH:$GOPATH/bin' >> "$SHELL_CONFIG"
            log "Added Go to PATH in $SHELL_CONFIG"
        fi
    fi
    
    # Export for current session
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    
    # Clean up
    rm -f "/tmp/$GO_TARBALL"
    
    # Verify installation
    if [[ -f "/usr/local/go/bin/go" ]]; then
        log "Go installed successfully!"
        log "Go version: $(/usr/local/go/bin/go version)"
    else
        error "Go installation failed - binary not found"
        exit 1
    fi
}

setup_aliases() {
    log "Setting up shell aliases..."
    
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        if ! grep -q "alias ll=" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Custom aliases" >> "$SHELL_CONFIG"
            echo "alias ll='ls -la'" >> "$SHELL_CONFIG"
            log "Added ll alias to $SHELL_CONFIG"
        fi
    fi
}

install_jump() {
    log "Installing jump directory navigator..."
    
    # Check if jump is already installed
    if command -v jump &> /dev/null; then
        warn "Jump is already installed, skipping..."
        return 0
    fi
    
    # Ensure Go is in PATH and GOPATH is set
    if [[ -f "/usr/local/go/bin/go" ]]; then
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
    fi
    
    # Check if Go is available
    if ! command -v go &> /dev/null; then
        error "Go is not available. Please install Go first."
        exit 1
    fi
    
    # Create GOPATH directory if it doesn't exist
    mkdir -p "$GOPATH/bin"
    
    # Install jump using Go
    log "Installing jump using Go..."
    go install github.com/gsamokovarov/jump@latest
    
    # Add jump to shell configuration
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        if ! grep -q "jump shell" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Jump directory navigator" >> "$SHELL_CONFIG"
            echo 'eval "$(jump shell)"' >> "$SHELL_CONFIG"
            log "Added jump configuration to $SHELL_CONFIG"
        fi
    fi
}

install_neovim_nightly() {
    log "Installing Neovim nightly..."
    
    # Check if Neovim is already installed
    if command -v nvim &> /dev/null; then
        NVIM_VERSION=$(nvim --version | head -1)
        log "Neovim is already installed: $NVIM_VERSION"
        return 0
    fi
    
    # Determine architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) NVIM_ARCH="linux-x86_64" ;;
        aarch64) NVIM_ARCH="linux-arm64" ;;
        *) error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    # Download latest nightly build
    NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-${NVIM_ARCH}.tar.gz"
    INSTALL_DIR="/opt/nvim"
    
    log "Downloading Neovim nightly build..."
    cd /tmp
    curl -LO "$NVIM_URL"
    
    # Check if download was successful
    if [[ ! -f "nvim-${NVIM_ARCH}.tar.gz" ]]; then
        error "Failed to download Neovim nightly build"
        exit 1
    fi
    
    # Remove existing installation if it exists
    sudo rm -rf "$INSTALL_DIR"
    
    # Extract and install
    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -C "$INSTALL_DIR" --strip-components=1 -xzf "nvim-${NVIM_ARCH}.tar.gz"
    
    # Create symlink in /usr/local/bin
    sudo ln -sf "$INSTALL_DIR/bin/nvim" /usr/local/bin/nvim
    
    # Add to PATH if not already there
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        if ! grep -q "$INSTALL_DIR/bin" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Neovim nightly" >> "$SHELL_CONFIG"
            echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$SHELL_CONFIG"
            log "Added Neovim to PATH in $SHELL_CONFIG"
        fi
    fi
    
    # Export for current session
    export PATH="$INSTALL_DIR/bin:$PATH"
    
    # Clean up
    rm -f "/tmp/nvim-${NVIM_ARCH}.tar.gz"
    
    log "Neovim nightly installed successfully!"
    log "Neovim version: $(nvim --version | head -1)"
}

install_astrovim() {
    log "Installing AstroVim..."
    
    # Check if neovim is installed
    check_command nvim
    
    # Check if AstroVim is already installed
    if [[ -d "$HOME/.config/nvim" ]]; then
        warn "Neovim configuration already exists. Backing up..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Backup other nvim directories if they exist
    [[ -d "$HOME/.local/share/nvim" ]] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    [[ -d "$HOME/.local/state/nvim" ]] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    [[ -d "$HOME/.cache/nvim" ]] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Clone AstroVim template
    log "Cloning AstroVim template..."
    git clone --depth 1 https://github.com/AstroNvim/template "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    
    log "AstroVim installed successfully!"
    log "Run 'nvim' to complete the installation."
}

set_zsh_as_default() {
    log "Setting zsh as default shell..."
    
    # Check if zsh is installed
    check_command zsh
    
    # Check if zsh is already the default shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        log "Zsh is already the default shell"
        return 0
    fi
    
    # Change default shell to zsh
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    
    log "Default shell changed to zsh. Please log out and log back in for the change to take effect."
}

install_powerlevel10k() {
    log "Installing Powerlevel10k..."
    
    # Check if zsh is installed
    check_command zsh
    
    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh not found. Installing Oh My Zsh first..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Check if Powerlevel10k is already installed
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        warn "Powerlevel10k is already installed, skipping..."
        return 0
    fi
    
    # Clone Powerlevel10k repository
    log "Cloning Powerlevel10k repository..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    # Update .zshrc to use Powerlevel10k theme
    if [[ -f "$HOME/.zshrc" ]]; then
        log "Updating .zshrc to use Powerlevel10k theme..."
        sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    fi
    
    # Copy custom Powerlevel10k configuration
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$SCRIPT_DIR/.p10k.zsh" ]]; then
        log "Copying custom Powerlevel10k configuration..."
        cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
        
        # Add p10k config source to .zshrc if not already there
        if [[ -f "$HOME/.zshrc" ]] && ! grep -q "source ~/.p10k.zsh" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$HOME/.zshrc"
            echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$HOME/.zshrc"
        fi
    fi
    
    log "Powerlevel10k installed successfully!"
    log "Your custom configuration has been applied."
}

install_claude_code() {
    log "Installing Claude Code..."
    
    # Check if node and npm are installed
    check_command node
    check_command npm
    
    # Check Node.js version
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    REQUIRED_VERSION="18.0.0"
    
    if ! printf '%s\n%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V -C; then
        error "Node.js version $NODE_VERSION is too old. Please install Node.js 18 or higher."
        exit 1
    fi
    
    # Check if claude code is already installed
    if command -v claude &> /dev/null; then
        warn "Claude Code is already installed, skipping..."
        return 0
    fi
    
    # Set up npm global directory to avoid permission issues
    if [[ ! -d "$HOME/.npm-global" ]]; then
        log "Setting up npm global directory..."
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"
        
        # Add to PATH if not already there
        SHELL_CONFIG=""
        if [[ "$SHELL" == *"zsh"* ]]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            SHELL_CONFIG="$HOME/.bashrc"
        fi
        
        if [[ -n "$SHELL_CONFIG" ]]; then
            if ! grep -q ".npm-global/bin" "$SHELL_CONFIG"; then
                echo "" >> "$SHELL_CONFIG"
                echo "# Add npm global bin to PATH" >> "$SHELL_CONFIG"
                echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$SHELL_CONFIG"
                log "Added npm global bin to PATH in $SHELL_CONFIG"
            fi
        fi
        
        # Export for current session
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi
    
    # Install Claude Code
    log "Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code
    
    log "Claude Code installed successfully!"
    log "Run 'claude' to start using Claude Code."
}

main() {
    log "Starting dotfiles installation..."
    
    # Set zsh as default shell
    set_zsh_as_default
    
    # Install Go
    install_go
    
    # Setup shell aliases
    setup_aliases
    
    # Install jump
    install_jump
    
    # Install Neovim nightly
    install_neovim_nightly
    
    # Install AstroVim
    install_astrovim
    
    # Install Powerlevel10k
    install_powerlevel10k
    
    # Install Claude Code
    install_claude_code
    
    log "Installation complete!"
    log "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to reload your configuration."
}

main "$@"