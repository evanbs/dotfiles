#!/usr/bin/env bash
set -euo pipefail

# Este script foi projetado para ser executado remotamente, por exemplo:
# curl -sSL https://raw.githubusercontent.com/evanbs/dotfiles/main/bootstrap.sh | bash

# --- Configurações ---
REPO_URL="https://github.com/evanbs/dotfiles.git"
CLONE_DIR="/tmp/dotfiles-bootstrap"

# --- Funções Auxiliares ---
log() { echo -e "[bootstrap] $*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1; }

# --- Verificação de Sudo ---
# O script precisa de privilégios de root para instalar pacotes e configurar o sistema.
if [ "${EUID}" -ne 0 ]; then
  log "Este script precisa ser executado como root. Tentando re-executar com sudo..."
  # Este truque re-executa o script a partir da URL com sudo.
  # Assumimos que o script está nesta URL específica.
  exec sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/evanbs/dotfiles/main/bootstrap.sh)"
  exit
fi

# --- Lógica Principal (executando como root) ---

# 1. Instalar git se não estiver presente
if ! need_cmd git; then
  log "Instalando git..."
  if need_cmd apt-get; then
    apt-get update -y
    apt-get install -y git
  elif need_cmd dnf; then
    dnf install -y git
  elif need_cmd pacman; then
    pacman -Sy --noconfirm git
  else
    log "ERRO: Não foi possível instalar o git. Por favor, instale-o manualmente e tente novamente."
    exit 1
  fi
fi

# 2. Clonar o repositório
log "Clonando o repositório de dotfiles para ${CLONE_DIR}..."
# Limpa execuções anteriores
if [ -d "$CLONE_DIR" ]; then
  log "Limpando clone anterior."
  rm -rf "$CLONE_DIR"
fi
git clone --depth 1 "$REPO_URL" "$CLONE_DIR"

# 3. Entrar no diretório e executar a lógica do Ansible
cd "$CLONE_DIR"
log "Diretório do projeto: $(pwd)"

# A lógica a seguir é adaptada do seu script original.
install_ansible() {
  if need_cmd ansible; then
    log "Ansible já está instalado."
    return
  fi
  log "Instalando Ansible..."
  if need_cmd apt-get; then
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip sshpass ca-certificates curl
    if ! apt-get install -y ansible-core; then
      apt-get install -y ansible || true
    fi
  elif need_cmd dnf; then
    dnf -y install python3 python3-pip sshpass ca-certificates curl
    dnf -y install ansible-core || dnf -y install ansible || true
  elif need_cmd pacman; then
    pacman -Sy --noconfirm python python-pip openssh ca-certificates curl
    pacman -Sy --noconfirm ansible || true
  else
    log "ERRO: Gerenciador de pacotes não suportado para instalar o Ansible."
    exit 1
  fi
}

install_ansible

ANSIBLE_BIN="$(command -v ansible-playbook)"
if [ -z "$ANSIBLE_BIN" ]; then
    log "ERRO: ansible-playbook não foi encontrado após a tentativa de instalação."
    exit 1
fi

log "Executando playbook do Ansible..."
# Obtém o usuário original que invocou o sudo
CURRENT_USER="${SUDO_USER:-$(logname)}"
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" == "root" ]; then
    log "ERRO: Não foi possível determinar o usuário não-root. Execute como um usuário normal com sudo."
    exit 1
fi

log "Playbook será executado para o usuário: ${CURRENT_USER}"

# Executa o playbook. Já estamos como root.
ANSIBLE_CONFIG="${CLONE_DIR}/ansible.cfg" "$ANSIBLE_BIN" site.yml -i inventory/hosts.ini --extra-vars "dev_username=$CURRENT_USER" "$@"

# 4. Limpeza
log "Limpando o repositório clonado..."
rm -rf "$CLONE_DIR"

log "Concluído com sucesso!"
log "Para que as alterações tenham efeito, inicie uma nova sessão de shell ou execute: exec zsh -l"