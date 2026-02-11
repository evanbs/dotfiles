# Guia de Migração: NVM → FNM

## Para Usuários Existentes

Se você já tem este dotfiles instalado com NVM, a migração para FNM é simples e automática.

### Processo de Migração

1. **Faça backup das configurações atuais** (opcional, mas recomendado):
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   cp ~/.bashrc ~/.bashrc.backup
   ```

2. **Execute o playbook atualizado**:
   ```bash
   cd ~/dotfiles
   git pull origin main
   sudo ./bootstrap.sh
   ```

3. **FNM instalará automaticamente** o Node.js LTS e configurará o ambiente

4. **Remova NVM manualmente** (opcional, após verificar que tudo funciona):
   ```bash
   rm -rf ~/.nvm
   # Remover linhas do NVM de shells que não são gerenciados pelo Ansible
   ```

### O que acontece automaticamente

- FNM é instalado via Homebrew
- Node.js LTS é instalado via FNM
- Corepack é habilitado (yarn e pnpm disponíveis)
- `.zshrc` é atualizado para usar FNM em vez de NVM
- FNM detecta automaticamente arquivos `.nvmrc` e `.node-version`

### Arquivos Afetados

- `~/.zshrc` - Atualizado automaticamente pelo Ansible
- `~/.nvm/` - Pode ser removido após migração
- `~/.local/share/fnm/` - Novo diretório para dados do FNM

### Verificação pós-migração

Execute o script de validação para confirmar que tudo está funcionando:

```bash
cd ~/dotfiles
./validate_tools.sh
```

Você também pode verificar manualmente:

```bash
# Verificar FNM
fnm --version

# Verificar Node.js
node --version

# Verificar npm
npm --version

# Verificar yarn e pnpm (via corepack)
yarn --version
pnpm --version
```

## Para Novos Usuários

Se você está instalando este dotfiles pela primeira vez, não precisa se preocupar com a migração. O FNM será instalado automaticamente como parte do processo de setup.

## Diferenças entre NVM e FNM

### Performance

- **FNM**: ~10ms de overhead no startup do shell
- **NVM**: ~200ms de overhead no startup do shell
- **Resultado**: Shell inicia até 20x mais rápido

### Compatibilidade

FNM é totalmente compatível com:
- Arquivos `.nvmrc` (formato do NVM)
- Arquivos `.node-version` (formato padrão)
- Auto-switch automático ao entrar em diretórios com esses arquivos

### Comandos

A maioria dos comandos do NVM tem equivalentes diretos no FNM:

| Tarefa | NVM | FNM |
|--------|-----|-----|
| Instalar Node LTS | `nvm install --lts` | `fnm install --lts` |
| Instalar versão específica | `nvm install 18.19.0` | `fnm install 18.19.0` |
| Usar versão | `nvm use 18` | `fnm use 18` (ou automático) |
| Listar versões instaladas | `nvm list` | `fnm list` |
| Versão atual | `nvm current` | `fnm current` |
| Definir padrão | `nvm alias default 18` | `fnm default 18` |
| Desinstalar versão | `nvm uninstall 18` | `fnm uninstall 18` |

### Auto-switch

FNM muda automaticamente a versão do Node quando você entra em um diretório com `.nvmrc` ou `.node-version`. Com NVM, você precisa executar `nvm use` manualmente.

## Troubleshooting

### FNM não encontrado após migração

Se o FNM não for encontrado, certifique-se de que o Homebrew está no PATH:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Depois, recarregue a configuração do shell:

```bash
source ~/.zshrc
```

### Node não encontrado após instalar FNM

O ambiente do FNM precisa ser inicializado. Execute:

```bash
eval "$(fnm env)"
```

Isso já deveria estar no seu `.zshrc`. Se não estiver, execute o playbook novamente.

### Quero usar uma versão específica do Node

```bash
# Instalar versão específica
fnm install 20.11.0

# Definir como padrão
fnm default 20.11.0

# Ou usar apenas no projeto atual
cd meu-projeto
echo "20.11.0" > .node-version
fnm use
```

### Problemas com pacotes globais do npm

Pacotes globais instalados com NVM não são automaticamente transferidos para FNM. Você precisará reinstalá-los:

```bash
# Listar pacotes globais atuais (se ainda tiver NVM)
npm list -g --depth=0

# Com FNM, reinstale os necessários
npm install -g <nome-do-pacote>
```

## Rollback

Se você precisar voltar para o NVM por algum motivo:

### Opção 1: Usar versão anterior do repositório

```bash
cd ~/dotfiles
git checkout <commit-antes-da-migração>
sudo ./bootstrap.sh
```

### Opção 2: Instalar NVM manualmente

```bash
# Desinstalar FNM
brew uninstall fnm

# Instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Recarregar shell
source ~/.bashrc  # ou ~/.zshrc
```

## Suporte e Feedback

Se você encontrar problemas durante a migração, por favor:

1. Verifique o script de validação: `./validate_tools.sh`
2. Consulte a documentação do FNM: https://github.com/Schniz/fnm
3. Abra uma issue no repositório se o problema persistir

## Benefícios da Migração

1. **Startup mais rápido**: Shell inicia instantaneamente
2. **Auto-switch**: Não precisa executar `nvm use` manualmente
3. **Centralização**: Todas as ferramentas via Homebrew
4. **Manutenção**: Menos dependências de scripts bash complexos
5. **Compatibilidade**: Funciona com todos os projetos existentes

A migração para FNM torna o ambiente de desenvolvimento mais rápido e eficiente, sem sacrificar funcionalidade ou compatibilidade.
