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
```

Em seguida, abra um novo terminal para carregar o zsh e o starship.

### Referências
- `scruffaluff/bootware` em Ansible Galaxy
- `legnoh/dotfiles` em Ansible Galaxy


