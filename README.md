## dotfiles with Ansible

Provisiona um usuário de desenvolvimento sem sudo, Homebrew no Linux, zsh + oh-my-zsh, starship (tema Catppuccin Frappe) e dotfiles básicos (`.aliases`, `.zshrc`, `.gitconfig`).

### Pré-requisitos
- Usuário atual com privilégios de `sudo` (será solicitado senha)
- Linux (Debian/Ubuntu recomendado; WSL2 suportado)

### Execução (um comando)

Caso esteja clonando via Git (substitua a URL pelo seu repositório):

```bash
git clone https://github.com/evanbs/dotfiles ~/dotfiles && sudo ~/dotfiles/bootstrap.sh
```

Por padrão usa o usuário atual do sistema. Você pode ajustar em `group_vars/all.yml`.

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

### Referências
- `scruffaluff/bootware` em Ansible Galaxy
- `legnoh/dotfiles` em Ansible Galaxy


