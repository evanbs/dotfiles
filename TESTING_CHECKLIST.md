# Checklist de Teste - Instalação Limpa

## 🎯 Objetivo
Validar instalação em ambiente WSL completamente limpo.

## ✅ Mudanças Aplicadas

### 1. Removido módulo `community.general.homebrew`
**Problema:** O módulo falha em instalações novas do Homebrew porque tenta executar `brew info --json` antes do ambiente estar configurado.

**Solução:** Todos os comandos `brew` agora usam `shell` com verificação idempotente:
```bash
brew list <package> >/dev/null 2>&1 || brew install <package> | cat
```

### 2. Corrigido PATH do FNM
**Problema:** Comandos `fnm`, `node`, `npm`, `corepack` não eram encontrados porque dependem de `eval "$(fnm env)"` OU do caminho completo.

**Solução:** Todos os comandos FNM/Node agora usam caminho completo:
```bash
# Antes (não funcionava)
eval "$(fnm env)"
fnm install lts-latest

# Depois (funciona)
eval "$({{ brew_prefix }}/bin/fnm env)"
{{ brew_prefix }}/bin/fnm install lts-latest
{{ brew_prefix }}/bin/fnm exec --using=lts-latest npm install -g pkg
```

### 3. Consolidado variáveis em `group_vars/all.yml`
**Problema:** Variáveis `yarn_version` e `pnpm_version` estavam em `group_vars/versions.yml` que não é carregado automaticamente pelo Ansible.

**Solução:** Todas as variáveis foram movidas para `group_vars/all.yml`:
```yaml
node_version: "lts-latest"
yarn_version: "stable"
pnpm_version: "latest"
bun_version: "latest"
fnm_version: "latest"
starship_version: "latest"
zsh_version: "latest"
sdkman_version: "latest"
```

### 2. Arquivos modificados:
```
group_vars/all.yml               → Consolidadas todas as variáveis de versão
handlers/main.yml                → Handler de update brew
roles/biome/tasks/main.yml       → Comandos npm com fnm exec
roles/bun/tasks/main.yml         → Instalação do Bun
roles/fnm/tasks/main.yml         → Caminhos completos para fnm/node/npm
roles/homebrew/defaults/main.yml → Removido fnm/bun (roles próprios)
roles/homebrew/files/Brewfile    → Documentação de referência
roles/homebrew/tasks/main.yml    → Tasks de instalação base e tools
site.yml                         → Removido pre_task do community.general
```

**Removido:**
```
group_vars/versions.yml          → Variáveis movidas para all.yml
```

### 3. Estratégia de instalação:
1. **Base packages** (git, git-delta, zsh, starship) → shell loop
2. **Developer tools** (bat, vim, fzf, etc) → shell loop via `brew_packages`
3. **Runtimes** (fnm, bun) → roles específicos com shell

## 🧪 Testes em WSL Limpo

### Preparação do Ambiente
```powershell
# No PowerShell (Administrador)
wsl --list --verbose
wsl --unregister Ubuntu
wsl --install Ubuntu
```

### Execução
```bash
# No WSL novo (após criar usuário)
curl -sSL https://raw.githubusercontent.com/evanbs/dotfiles/main/bootstrap.sh | bash
```

### Pontos Críticos de Validação

#### 1️⃣ Instalação do Homebrew
```bash
# Deve instalar sem erros
/home/linuxbrew/.linuxbrew/bin/brew --version
```

#### 2️⃣ Base Packages
```bash
# Todos devem instalar no primeiro loop
git --version
zsh --version
starship --version
```

#### 3️⃣ Developer Tools
```bash
# Instalação via brew_packages deve ser idempotente
bat --version
fzf --version
ripgrep --version
```

#### 4️⃣ FNM e Node
```bash
# Role fnm deve instalar FNM + Node LTS
fnm --version
node --version
npm --version
```

#### 5️⃣ Bun
```bash
# Role bun deve instalar Bun
bun --version
```

#### 6️⃣ Validação Completa
```bash
# Script de validação
./validate_tools.sh
```

## ❌ Erros Esperados (NÃO devem ocorrer)

1. ~~`json.decoder.JSONDecodeError: Expecting value: line 1 column 1`~~
2. ~~`brew bundle failed! Failed to fetch bun, wl-clipboard`~~
3. ~~`Error: No available formula with the name "bun"`~~

## ✅ Saída Esperada

```
TASK [homebrew : Install base packages via brew] ***************
changed: [localhost]

TASK [homebrew : Install developer CLI tools via brew] *********
changed: [localhost] => (item=bat)
changed: [localhost] => (item=vim)
...

TASK [fnm : Install FNM via Homebrew] **************************
changed: [localhost]

TASK [bun : Install Bun via Homebrew] **************************
changed: [localhost]

PLAY RECAP *****************************************************
localhost    : ok=X    changed=Y    unreachable=0    failed=0
```

## 📝 Notas

- **Tempo estimado**: ~10-15 minutos para instalação completa
- **Idempotência**: Executar novamente deve mostrar `ok` ao invés de `changed`
- **Logs**: Toda saída é capturada com `| cat` para evitar problemas de TTY

## 🚨 Se algo falhar

1. Capture o erro completo (stack trace)
2. Verifique qual task falhou
3. Execute manualmente para debug:
   ```bash
   cd ~/workspace/dotfiles
   ansible-playbook site.yml -vvv
   ```
