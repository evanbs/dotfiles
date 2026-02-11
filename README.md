## dotfiles with Ansible

Provisiona um usuário de desenvolvimento sem sudo, Homebrew no Linux, zsh + oh-my-zsh, starship (tema Catppuccin Frappe) e dotfiles básicos (`.aliases`, `.zshrc`, `.gitconfig`).

### O que mudou?

#### FNM vs NVM

Este projeto migrou de NVM para FNM (Fast Node Manager) por:

- Performance superior (até 40x mais rápido)
- Instalação centralizada via Homebrew
- Menor impacto no startup do shell (~10ms vs ~200ms do NVM)
- Compatibilidade total com projetos existentes (`.nvmrc` e `.node-version`)
- Auto-switch de versão do Node por projeto

#### Comandos equivalentes

| NVM | FNM |
|-----|-----|
| `nvm install --lts` | `fnm install --lts` |
| `nvm use` | `fnm use` (automático com `--use-on-cd`) |
| `nvm alias default` | `fnm default` |
| `nvm list` | `fnm list` |
| `nvm current` | `fnm current` |

#### Bun - All-in-One JavaScript Runtime

Este projeto também inclui o Bun, um runtime JavaScript/TypeScript ultrarrápido que oferece:

- Runtime compatível com Node.js
- Package manager integrado (alternativa ao npm/yarn/pnpm)
- Bundler nativo
- Test runner integrado
- Performance significativamente superior ao Node.js

Bun e Node.js (via FNM) coexistem no sistema. Você pode escolher qual usar:

```bash
# Usar Bun
bun install
bun run dev

# Usar Node.js/npm
npm install
npm run dev
```

Para desabilitar a instalação do Bun, defina `install_bun: false` em `group_vars/all.yml`.

### Pré-requisitos
- Usuário atual com privilégios de `sudo` (será solicitado senha)
- Linux (Debian/Ubuntu recomendado; WSL2 suportado)

### Execução (um comando)

Por padrão, o playbook usa o usuário atual do sistema para a configuração. Você pode ajustar as variáveis em `group_vars/all.yml`.

O método recomendado é executar o script de bootstrap diretamente via `curl`. Este comando irá baixar e executar o script, que cuidará de todo o processo automaticamente.

```bash
curl -sSL https://raw.githubusercontent.com/evanbs/dotfiles/main/bootstrap.sh | bash
```

#### Método Alternativo (Clone Manual)

Se preferir clonar o repositório manualmente primeiro:

```bash
git clone https://github.com/evanbs/dotfiles ~/dotfiles && sudo ~/dotfiles/bootstrap.sh
```

### Customização

É possível customizar a instalação editando o arquivo `group_vars/all.yml`.

#### Variáveis de Instalação

Você pode ativar ou desativar a instalação de grupos de funcionalidades alterando as seguintes variáveis para `true` ou `false`:

```yaml
install_sudo_rules: true
install_homebrew: true
install_zsh: true
install_starship: true
install_node: true
install_dotfiles: true
install_ssh_config: true
```

#### Configuração do Git

Suas informações de usuário do Git também são configuradas neste arquivo:

```yaml
git_user_name: "Seu Nome"
git_user_email: "seu-email@example.com"
```

#### Execução com Tags

Para executar apenas partes específicas do playbook (por exemplo, para atualizar apenas uma configuração), você pode usar `tags` ao rodar o `ansible-playbook` manualmente.

**Exemplos:**
```bash
# Executar apenas as configurações de shell (zsh, oh-my-zsh, starship)
ansible-playbook site.yml --tags "shell,prompt"

# Aplicar apenas as configurações de dotfiles
ansible-playbook site.yml --tags "config"

# Instalar apenas pacotes (homebrew, node)
ansible-playbook site.yml --tags "packages"
```

As tags disponíveis são: `base`, `user`, `sudo`, `packages`, `homebrew`, `fnm`, `node`, `bun`, `javascript`, `shell`, `zsh`, `prompt`, `starship`, `config`, `dotfiles`, `security`, `ssh`.

### Verificações pós-provisionamento

```bash
id "$USER"
echo $SHELL
brew --version && git --version && delta --version && starship --version
fnm --version && node --version && npm --version
bun --version
# Clipboard (cat copia para a área de transferência)
echo "hello" | cat
```

Em seguida, um `zsh` de login é aberto automaticamente pelo `bootstrap.sh`.

#### Sudo

Por padrão, o provisionamento concede sudo sem senha (NOPASSWD) ao usuário atual usando `/etc/sudoers.d/<user>`.
Você pode desativar isso ajustando `sudo_nopasswd: false` em `group_vars/all.yml`.
Opcionalmente, é possível definir `sudo_timestamp_timeout` (em minutos) para reduzir prompts de senha.

### Clipboard

- Visualização de arquivos: use `bat arquivo.txt`.
- Copiar conteúdo para clipboard: `clip arquivo.txt` ou `echo "texto" | clip`.
- Ordem de preferências: `wl-copy` (Wayland) → `xclip` (X11) → `pbcopy` (macOS) → `tmux buffer` → `OSC52`.

## Estrutura do Projeto

```
.
├── ansible.cfg
├── bootstrap.sh
├── README.md
├── site.yml
├── group_vars/
│   └── all.yml
├── inventory/
│   └── hosts.ini
└── roles/
    ├── aws_tools/
    ├── biome/
    ├── dotfiles/
    ├── fnm/          # ← Migrado de 'node' para 'fnm'
    ├── homebrew/
    ├── kvm/
    ├── ohmyzsh/
    ├── sdkman/
    ├── snap/
    ├── ssh/
    ├── starship/
    ├── sudo/
    ├── user/
    └── zsh/
```

### Testes

Execute o script de validação para verificar se todas as ferramentas estão corretamente instaladas:

```bash
./validate_tools.sh
```

#### Testes Automatizados com Molecule

Para desenvolvedores que querem testar mudanças nos roles:

```bash
# 1. Instalar Molecule
./scripts/install-molecule.sh

# 2. Recarregar shell
exec zsh

# 3. Testar roles individuais
cd roles/fnm
molecule test

cd ../bun
molecule test

# 4. Ou testar todos
./scripts/test-all-roles.sh
```

Consulte [`docs/TESTING.md`](docs/TESTING.md) para guia completo de testes.

### Referências
- `scruffaluff/bootware` em Ansible Galaxy
- `legnoh/dotfiles` em Ansible Galaxy

### Migração e Documentação

- [Guia de Migração NVM → FNM](docs/MIGRATION_NVM_TO_FNM.md) - Instruções detalhadas para usuários que estão migrando do NVM


