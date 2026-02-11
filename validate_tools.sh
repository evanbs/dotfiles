#!/usr/bin/env bash
# Script para validar se todas as ferramentas estão instaladas e disponíveis

set -e

# Adicionar Homebrew ao PATH se não estiver
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
fi

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Contadores
TOTAL=0
OK=0
FAIL=0
SKIP=0

# Funções auxiliares
log_ok() {
    echo -e "${GREEN}✓${NC} $1"
    OK=$((OK + 1))
    TOTAL=$((TOTAL + 1))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    FAIL=$((FAIL + 1))
    TOTAL=$((TOTAL + 1))
}

log_skip() {
    echo -e "${YELLOW}⊘${NC} $1 (não instalado ou desabilitado)"
    SKIP=$((SKIP + 1))
    TOTAL=$((TOTAL + 1))
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_version() {
    local tool=$1
    local cmd=$2
    local version_cmd=${3:-"--version"}
    
    if command -v "$tool" >/dev/null 2>&1; then
        if $cmd $version_cmd >/dev/null 2>&1; then
            local version=$($cmd $version_cmd 2>&1 | head -1)
            log_ok "$tool: $version"
            return 0
        else
            log_ok "$tool: instalado (sem --version)"
            return 0
        fi
    else
        log_fail "$tool: não encontrado"
        return 1
    fi
}

check_exists() {
    local tool=$1
    local path=$2
    
    if [ -f "$path" ] || command -v "$tool" >/dev/null 2>&1; then
        log_ok "$tool: encontrado"
        return 0
    else
        log_fail "$tool: não encontrado"
        return 1
    fi
}

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Validação de Ferramentas Instaladas${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================
# Sistema e Shell
# ============================================
echo -e "${BLUE}=== Sistema e Shell ===${NC}"

# Shell padrão
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    log_ok "Shell padrão: $CURRENT_SHELL"
else
    log_fail "Shell padrão: $CURRENT_SHELL (esperado: zsh)"
fi

# Zsh
ZSH_PATH=""
if command -v zsh >/dev/null 2>&1; then
    ZSH_PATH=$(command -v zsh)
elif [ -f "/home/linuxbrew/.linuxbrew/bin/zsh" ]; then
    ZSH_PATH="/home/linuxbrew/.linuxbrew/bin/zsh"
elif [ -f "/usr/bin/zsh" ]; then
    ZSH_PATH="/usr/bin/zsh"
fi

if [ -n "$ZSH_PATH" ] && [ -f "$ZSH_PATH" ]; then
    log_ok "Zsh: instalado em $ZSH_PATH"
else
    log_fail "Zsh: não encontrado"
fi

# Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_ok "Oh My Zsh: instalado"
else
    log_fail "Oh My Zsh: não encontrado"
fi

echo ""

# ============================================
# Homebrew e Pacotes
# ============================================
echo -e "${BLUE}=== Homebrew e Pacotes ===${NC}"

# Homebrew
if command -v brew >/dev/null 2>&1; then
    BREW_VERSION=$(brew --version 2>&1 | head -1)
    log_ok "Homebrew: $BREW_VERSION"
    
    # Pacotes do Homebrew
    BREW_PACKAGES=("git" "git-delta" "zsh" "starship" "bat" "vim" "eza" "httpyac" "yq" "ripgrep" "tldr" "jq" "wget" "wl-clipboard" "xclip" "watchman" "fzf" "htop" "ncdu" "gemini-cli")
    
    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list "$pkg" &>/dev/null 2>&1; then
            log_ok "  $pkg: instalado via Homebrew"
        else
            log_skip "  $pkg: não instalado via Homebrew"
        fi
    done
else
    log_fail "Homebrew: não encontrado"
fi

echo ""

# ============================================
# Ferramentas de Linha de Comando
# ============================================
echo -e "${BLUE}=== Ferramentas de Linha de Comando ===${NC}"

# Git
check_version "git" "git"

# Git Delta
if command -v delta >/dev/null 2>&1; then
    DELTA_VERSION=$(delta --version 2>&1 | head -1)
    log_ok "Git Delta: $DELTA_VERSION"
else
    log_skip "Git Delta: não encontrado"
fi

# Starship
check_version "starship" "starship"

# Bat
check_version "bat" "bat"

# Vim
check_version "vim" "vim"

# Eza
if command -v eza >/dev/null 2>&1; then
    EZA_VERSION=$(eza --version 2>&1 | head -1)
    log_ok "Eza: $EZA_VERSION"
else
    log_skip "Eza: não encontrado"
fi

# HTTPie/Yac
if command -v httpyac >/dev/null 2>&1; then
    HTTPYAC_VERSION=$(httpyac --version 2>&1 | head -1 || echo "instalado")
    log_ok "HTTPyac: $HTTPYAC_VERSION"
else
    log_skip "HTTPyac: não encontrado"
fi

# YQ
check_version "yq" "yq"

# Ripgrep
check_version "rg" "rg"

# TLDR
if command -v tldr >/dev/null 2>&1; then
    TLDR_VERSION=$(tldr --version 2>&1 | head -1 || echo "instalado")
    log_ok "TLDR: $TLDR_VERSION"
else
    log_skip "TLDR: não encontrado"
fi

# JQ
check_version "jq" "jq"

# Wget
check_version "wget" "wget"

# FZF
if command -v fzf >/dev/null 2>&1; then
    FZF_VERSION=$(fzf --version 2>&1 | head -1)
    log_ok "FZF: $FZF_VERSION"
else
    log_skip "FZF: não encontrado"
fi

# Htop
check_version "htop" "htop"

# NCDU
check_version "ncdu" "ncdu"

# Watchman
if command -v watchman >/dev/null 2>&1; then
    WATCHMAN_VERSION=$(watchman --version 2>&1 | head -1)
    log_ok "Watchman: $WATCHMAN_VERSION"
else
    log_skip "Watchman: não encontrado"
fi

# Gemini CLI (o comando é 'gemini', não 'gemini-cli')
if command -v gemini >/dev/null 2>&1; then
    GEMINI_VERSION=$(gemini --version 2>&1 | head -1 || echo "instalado")
    log_ok "Gemini CLI: $GEMINI_VERSION"
else
    log_skip "Gemini CLI: não encontrado (comando: gemini)"
fi

echo ""

# ============================================
# Node.js e FNM
# ============================================
echo -e "${BLUE}=== Node.js e FNM ===${NC}"

# FNM
if command -v fnm >/dev/null 2>&1; then
    FNM_VERSION=$(fnm --version 2>&1)
    log_ok "FNM: $FNM_VERSION"
    
    # Configurar FNM environment
    eval "$(fnm env)"
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version 2>&1)
        log_ok "Node.js: $NODE_VERSION"
        
        # NPM
        if command -v npm >/dev/null 2>&1; then
            NPM_VERSION=$(npm --version 2>&1)
            log_ok "NPM: $NPM_VERSION"
        fi
        
        # Yarn (via corepack)
        if command -v yarn >/dev/null 2>&1; then
            YARN_VERSION=$(yarn --version 2>&1)
            log_ok "Yarn: $YARN_VERSION"
        else
            log_skip "Yarn: não encontrado"
        fi
        
        # PNPM (via corepack)
        if command -v pnpm >/dev/null 2>&1; then
            PNPM_VERSION=$(pnpm --version 2>&1)
            log_ok "PNPM: $PNPM_VERSION"
        else
            log_skip "PNPM: não encontrado"
        fi
    else
        log_skip "Node.js: não instalado via FNM"
    fi
else
    log_skip "FNM: não instalado"
fi

# Bun
if command -v bun >/dev/null 2>&1; then
    BUN_VERSION=$(bun --version 2>&1)
    log_ok "Bun: v$BUN_VERSION"
else
    log_skip "Bun: não instalado"
fi

echo ""

# ============================================
# Java e SDKMAN
# ============================================
echo -e "${BLUE}=== Java e SDKMAN ===${NC}"

# SDKMAN
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    log_ok "SDKMAN: instalado"
    
    # Carregar SDKMAN
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    
    # SDKMAN version
    if command -v sdk >/dev/null 2>&1; then
        SDK_VERSION=$(sdk version 2>&1 | head -1 || echo "instalado")
        log_ok "SDK: $SDK_VERSION"
    fi
    
    # Java
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -1)
        log_ok "Java: $JAVA_VERSION"
        
        # JAVA_HOME
        if [ -n "${JAVA_HOME:-}" ]; then
            log_ok "JAVA_HOME: $JAVA_HOME"
        else
            log_fail "JAVA_HOME: não configurado"
        fi
    else
        log_skip "Java: não instalado via SDKMAN"
    fi
else
    log_skip "SDKMAN: não instalado"
fi

echo ""

# ============================================
# Biome
# ============================================
echo -e "${BLUE}=== Biome ===${NC}"

if command -v biome >/dev/null 2>&1; then
    BIOME_VERSION=$(biome --version 2>&1 | head -1)
    log_ok "Biome: $BIOME_VERSION"
else
    log_skip "Biome: não encontrado"
fi

echo ""

# ============================================
# Snap
# ============================================
echo -e "${BLUE}=== Snap ===${NC}"

if command -v snap >/dev/null 2>&1; then
    SNAP_VERSION=$(snap --version 2>&1 | head -1)
    log_ok "Snap: $SNAP_VERSION"
else
    log_skip "Snap: não encontrado"
fi

echo ""

# ============================================
# KVM/QEMU
# ============================================
echo -e "${BLUE}=== KVM/QEMU ===${NC}"

# QEMU
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    QEMU_VERSION=$(qemu-system-x86_64 --version 2>&1 | head -1)
    log_ok "QEMU: $QEMU_VERSION"
else
    log_skip "QEMU: não encontrado"
fi

# Virsh
if command -v virsh >/dev/null 2>&1; then
    VIRSH_VERSION=$(virsh --version 2>&1)
    log_ok "Virsh: $VIRSH_VERSION"
else
    log_skip "Virsh: não encontrado"
fi

# Grupos do usuário
if groups "$USER" | grep -q libvirt; then
    log_ok "Grupo libvirt: usuário está no grupo"
else
    log_skip "Grupo libvirt: usuário não está no grupo"
fi

if groups "$USER" | grep -q kvm; then
    log_ok "Grupo kvm: usuário está no grupo"
else
    log_skip "Grupo kvm: usuário não está no grupo"
fi

echo ""

# ============================================
# Ansible
# ============================================
echo -e "${BLUE}=== Ansible ===${NC}"

if command -v ansible >/dev/null 2>&1; then
    ANSIBLE_VERSION=$(ansible --version 2>&1 | head -1)
    log_ok "Ansible: $ANSIBLE_VERSION"
else
    log_skip "Ansible: não encontrado"
fi

if command -v ansible-playbook >/dev/null 2>&1; then
    ANSIBLE_PB_VERSION=$(ansible-playbook --version 2>&1 | head -1)
    log_ok "Ansible Playbook: $ANSIBLE_PB_VERSION"
else
    log_skip "Ansible Playbook: não encontrado"
fi

echo ""

# ============================================
# Dotfiles
# ============================================
echo -e "${BLUE}=== Arquivos de Configuração ===${NC}"

DOTFILES=(".zshrc" ".aliases" ".gitconfig" ".functions")
for dotfile in "${DOTFILES[@]}"; do
    if [ -f "$HOME/$dotfile" ]; then
        log_ok "$dotfile: existe"
    else
        log_skip "$dotfile: não encontrado"
    fi
done

# SSH
if [ -d "$HOME/.ssh" ]; then
    log_ok ".ssh: diretório existe"
    if [ -f "$HOME/.ssh/id_rsa" ] || [ -f "$HOME/.ssh/id_ed25519" ]; then
        log_ok "Chave SSH: encontrada"
    else
        log_skip "Chave SSH: não encontrada"
    fi
else
    log_skip ".ssh: diretório não encontrado"
fi

echo ""

# ============================================
# Resumo Final
# ============================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Resumo${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Total verificado: ${TOTAL}"
echo -e "${GREEN}✓ Instalado e funcionando: ${OK}${NC}"
echo -e "${RED}✗ Não encontrado: ${FAIL}${NC}"
echo -e "${YELLOW}⊘ Não instalado/desabilitado: ${SKIP}${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ Todas as ferramentas esperadas estão instaladas!${NC}"
    exit 0
else
    echo -e "${RED}✗ Algumas ferramentas não foram encontradas.${NC}"
    echo -e "${YELLOW}Execute o playbook novamente para instalar as ferramentas faltantes.${NC}"
    exit 1
fi

