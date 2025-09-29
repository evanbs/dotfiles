#!/usr/bin/env bash
set -euo pipefail

# Re-exec with sudo if not root
if [ "${EUID}" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo -e "[bootstrap] $*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# Atualização base antes do Ansible (em sistemas Debian/Ubuntu)
if need_cmd apt-get; then
  log "Atualizando pacotes base (apt)..."
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y git
fi

install_ansible() {
  if need_cmd ansible; then
    return
  fi
  log "Instalando Ansible..."
  if need_cmd apt-get; then
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip sshpass ca-certificates curl git
    # Preferir pacote do sistema para evitar PEP 668 (externally-managed-environment)
    if ! apt-get install -y ansible-core; then
      apt-get install -y ansible || true
    fi
  elif need_cmd dnf; then
    dnf -y install python3 python3-pip sshpass ca-certificates curl git
    dnf -y install ansible-core || dnf -y install ansible || true
  elif need_cmd pacman; then
    pacman -Sy --noconfirm python python-pip openssh ca-certificates curl git
    pacman -Sy --noconfirm ansible || true
  else
    log "Gerenciador de pacotes não detectado; instalando Ansible em venv local."
    python3 -m venv "$PROJECT_DIR/.venv"
    "$PROJECT_DIR/.venv/bin/pip" install --upgrade pip
    "$PROJECT_DIR/.venv/bin/pip" install ansible
  fi
}

install_ansible

cd "$PROJECT_DIR"

# Determina binário do ansible-playbook (sistema ou venv local)
ANSIBLE_BIN="$(command -v ansible-playbook || true)"
if [ -z "$ANSIBLE_BIN" ] && [ -x "$PROJECT_DIR/.venv/bin/ansible-playbook" ]; then
  ANSIBLE_BIN="$PROJECT_DIR/.venv/bin/ansible-playbook"
fi

log "Executando playbook..."
CURRENT_USER="${SUDO_USER:-$USER}"
ANSIBLE_CONFIG="$PROJECT_DIR/ansible.cfg" "$ANSIBLE_BIN" site.yml -i inventory/hosts.ini --extra-vars "dev_username=$CURRENT_USER" "$@"
log "Concluído. Abrindo uma sessão zsh de login como o usuário $CURRENT_USER..."

# Abre uma sessão zsh de login para aplicar as configurações no ambiente do usuário atual
exec sudo -iu "$CURRENT_USER" zsh -l


