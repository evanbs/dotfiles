#!/usr/bin/env bash
set -euo pipefail

# Re-exec with sudo if not root
if [ "${EUID}" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo -e "[bootstrap] $*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_ansible() {
  if need_cmd ansible; then
    return
  fi
  log "Instalando Ansible..."
  if need_cmd apt-get; then
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip sshpass ca-certificates curl git
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible
  elif need_cmd dnf; then
    dnf -y install python3 python3-pip sshpass ca-certificates curl git
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible
  elif need_cmd pacman; then
    pacman -Sy --noconfirm python python-pip openssh ca-certificates curl git
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible
  else
    log "Gerenciador de pacotes não detectado; instalando Ansible via pip."
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible
  fi
}

install_ansible

cd "$PROJECT_DIR"

log "Executando playbook..."
ANSIBLE_CONFIG="$PROJECT_DIR/ansible.cfg" ansible-playbook site.yml -i inventory/hosts.ini "$@"
log "Concluído. Abrindo uma sessão zsh de login como o usuário dev..."

# Abre uma sessão zsh de login para aplicar as configurações no ambiente do usuário dev
exec sudo -iu dev zsh -l


