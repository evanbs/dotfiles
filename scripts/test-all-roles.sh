#!/usr/bin/env bash
# Script em bash para compatibilidade com arrays e pipefail
set -euo pipefail

# Script para testar todos os roles que possuem testes Molecule

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

cd "$PROJECT_ROOT"

# Array de roles com testes
ROLES_WITH_TESTS=("fnm" "bun")
FAILED=()

for role in "${ROLES_WITH_TESTS[@]}"; do
    log_info "Testando role: $role"
    
    if [ -d "roles/$role/molecule" ]; then
        cd "roles/$role"
        if molecule test; then
            log_success "Role $role passou nos testes"
        else
            log_error "Role $role falhou nos testes"
            FAILED+=("$role")
        fi
        cd "$PROJECT_ROOT"
    else
        log_error "Role $role não possui testes Molecule"
    fi
    
    echo ""
done

echo "=========================================="
if [ ${#FAILED[@]} -eq 0 ]; then
    log_success "Todos os roles passaram nos testes!"
    exit 0
else
    log_error "Roles que falharam: ${FAILED[*]}"
    exit 1
fi
