#!/usr/bin/env bash
# Script explicitamente em bash para compatibilidade com pipefail
set -euo pipefail

# Script para instalar Molecule e dependências para testes de roles Ansible
# Usa pipx para instalação isolada, evitando conflitos com Python do sistema

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Verificar se é Ubuntu/Debian
if ! command -v apt >/dev/null 2>&1; then
    log_error "Este script é para sistemas baseados em Debian/Ubuntu"
    exit 1
fi

log_info "Instalando Molecule e dependências..."

# 1. Instalar dependências do sistema
log_info "Instalando dependências do sistema..."
sudo apt update
sudo apt install -y python3-full python3-pip pipx docker.io

# 2. Adicionar usuário ao grupo docker
log_info "Adicionando usuário ao grupo docker..."
if ! groups | grep -q docker; then
    sudo usermod -aG docker "$USER"
    log_warn "Você foi adicionado ao grupo docker."
    log_warn "Execute: exec zsh"
    log_warn "Ou faça logout/login para que as mudanças tenham efeito"
fi

# 3. Garantir que pipx está no PATH
log_info "Configurando pipx..."
pipx ensurepath

# 4. Instalar Molecule via pipx
log_info "Instalando Molecule via pipx..."
if pipx list | grep -q molecule; then
    log_warn "Molecule já está instalado, atualizando..."
    pipx upgrade molecule
else
    pipx install molecule
fi

# 5. Instalar plugins do Molecule
log_info "Instalando plugins do Molecule..."
pipx inject molecule 'molecule-plugins[docker]'
pipx inject molecule ansible-lint

# 6. Verificar instalação
log_info "Verificando instalação..."
if command -v molecule >/dev/null 2>&1; then
    MOLECULE_VERSION=$(molecule --version | head -1)
    log_success "Molecule instalado: $MOLECULE_VERSION"
else
    log_error "Falha na instalação do Molecule"
    exit 1
fi

# 7. Verificar Docker
if docker ps >/dev/null 2>&1; then
    log_success "Docker está funcionando"
else
    log_warn "Docker não está acessível. Execute: exec zsh"
fi

echo ""
log_success "Instalação concluída!"
echo ""
echo "Próximos passos:"
echo "1. Recarregue o shell: exec zsh"
echo "2. Teste um role: cd roles/fnm && molecule test"
echo ""
