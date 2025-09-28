## dotfiles with Ansible

Provisiona um usuário de desenvolvimento sem sudo, Homebrew no Linux, zsh + oh-my-zsh, starship (tema Catppuccin Frappe) e dotfiles básicos (`.aliases`, `.zshrc`, `.gitconfig`).

### Pré-requisitos
- Usuário atual com privilégios de `sudo` (será solicitado senha)
- Linux (Debian/Ubuntu recomendado; WSL2 suportado)

### Execução (um comando)

Caso esteja clonando via Git (substitua a URL pelo seu repositório):

```bash
git clone <URL_DO_SEU_REPO> ~/dotfiles && sudo ~/dotfiles/bootstrap.sh
```

Por padrão cria o usuário `dev`. Altere variáveis em `group_vars/all.yml` se desejar.

### Verificações pós-provisionamento

```bash
id dev
sudo su - dev
echo $SHELL
brew --version && git --version && delta --version && starship --version
# Clipboard (cat copia para a área de transferência)
echo "hello" | cat
```

Em seguida, um `zsh` de login é aberto automaticamente pelo `bootstrap.sh`.

### Clipboard

- Visualização de arquivos: use `bat arquivo.txt`.
- Copiar conteúdo para clipboard: `cat arquivo.txt` ou `echo "texto" | cat`.
- Ordem de preferências: `wl-copy` (Wayland) → `xclip` (X11) → `pbcopy` (macOS) → `tmux buffer` → `OSC52`.

### Referências
- `scruffaluff/bootware` em Ansible Galaxy
- `legnoh/dotfiles` em Ansible Galaxy


