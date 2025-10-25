## dotfiles with Ansible

Provisiona um usuário de desenvolvimento sem sudo, Homebrew no Linux, zsh + oh-my-zsh, starship (tema Catppuccin Frappe) e dotfiles básicos (`.aliases`, `.zshrc`, `.gitconfig`).

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

As tags disponíveis são: `base`, `user`, `sudo`, `packages`, `homebrew`, `node`, `shell`, `zsh`, `prompt`, `starship`, `config`, `dotfiles`, `security`, `ssh`.

### Verificações pós-provisionamento

```bash
id "$USER"
echo $SHELL
brew --version && git --version && delta --version && starship --version
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
    ├── gemini_cli/
    ├── homebrew/
    ├── kvm/
    ├── node/
    ├── ohmyzsh/
    ├── pyenv/
    ├── sdkman/
    ├── ssh/
    ├── starship/
    ├── sudo/
    ├── user/
    ├── vscode/
    └── zsh/
```

### Referências
- `scruffaluff/bootware` em Ansible Galaxy
- `legnoh/dotfiles` em Ansible Galaxy


