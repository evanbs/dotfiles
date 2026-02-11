# Guia de Testes com Molecule

Este documento explica como testar os roles Ansible usando Molecule.

## O que é Molecule?

Molecule é uma ferramenta de testes para Ansible que permite:
- Testar roles em ambientes isolados (Docker)
- Validar idempotência (executar duas vezes, mudar apenas uma)
- Verificar se mudanças funcionam em diferentes plataformas
- Automatizar testes antes de fazer commits

## Instalação

### Método Recomendado: Script Automático

```bash
# Execute o script de instalação
./scripts/install-molecule.sh
```

Este script irá:
1. Instalar dependências (Python 3, pipx, Docker)
2. Instalar Molecule via pipx (instalação isolada)
3. Instalar plugins necessários (docker, ansible-lint)
4. Configurar permissões do Docker

Após a instalação, recarregue o shell:

```bash
exec zsh
```

### Método Manual

Se preferir instalar manualmente no zsh:

```bash
# 1. Instalar dependências
sudo apt update
sudo apt install -y python3-full python3-pip pipx docker.io

# 2. Adicionar ao grupo docker
sudo usermod -aG docker $USER
exec zsh

# 3. Instalar Molecule via pipx
pipx install molecule
pipx inject molecule 'molecule-plugins[docker]'
pipx inject molecule ansible-lint

# 4. Recarregar shell
exec zsh
```

### Verificação

```bash
# Verificar instalação
molecule --version
docker ps
```

## Estrutura de Testes

Cada role possui uma estrutura Molecule em `roles/<nome>/molecule/default/`:

```
roles/fnm/
└── molecule/
    └── default/
        ├── molecule.yml    # Configuração: plataforma, driver
        ├── converge.yml    # Playbook de teste
        └── verify.yml      # Verificações pós-instalação
```

### Arquivo molecule.yml

Define o ambiente de teste:

```yaml
driver:
  name: docker           # Usar Docker para testes
platforms:
  - name: ubuntu-test    # Nome do container
    image: ubuntu:22.04  # Imagem base
provisioner:
  name: ansible          # Usar Ansible
verifier:
  name: ansible          # Verificações com Ansible
```

### Arquivo converge.yml

Playbook que aplica o role:

```yaml
- name: Converge
  hosts: all
  tasks:
    - name: Include fnm role
      include_role:
        name: fnm
```

### Arquivo verify.yml

Verificações após instalação:

```yaml
- name: Verify
  hosts: all
  tasks:
    - name: Check if fnm is installed
      command: fnm --version
      changed_when: false
```

## Comandos do Molecule

Todos os comandos funcionam no zsh:

### Testar um Role Completo

```bash
# Entrar no diretório do role
cd roles/fnm

# Executar teste completo
molecule test
```

O comando `test` executa a sequência:
1. `destroy` - Remove containers anteriores
2. `create` - Cria novo container
3. `converge` - Aplica o role
4. `verify` - Executa verificações
5. `destroy` - Remove container de teste

### Comandos Individuais

```bash
# Criar ambiente de teste
molecule create

# Aplicar o role
molecule converge

# Executar verificações
molecule verify

# Acessar o container de teste
molecule login

# Destruir ambiente de teste
molecule destroy

# Ver logs
molecule list
```

### Desenvolvimento Iterativo

Durante desenvolvimento, use:

```bash
# 1. Criar ambiente uma vez
molecule create

# 2. Testar mudanças rapidamente
molecule converge

# 3. Verificar resultados
molecule verify

# 4. Acessar para debug (se necessário)
molecule login

# 5. Quando terminar
molecule destroy
```

## Testando Roles Existentes

### Role FNM

```bash
cd roles/fnm
molecule test
```

Testa:
- Instalação do FNM via Homebrew
- Instalação do Node.js LTS
- Configuração de corepack
- Instalação de yarn e pnpm

### Role Bun

```bash
cd roles/bun
molecule test
```

Testa:
- Instalação do Bun via Homebrew
- Criação de diretórios necessários
- Verificação de versão

### Testar Todos os Roles

```bash
# Script utilitário
./scripts/test-all-roles.sh
```

## Troubleshooting

### Erro: Permission denied (Docker)

```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
exec zsh

# Verificar grupos
groups
```

### Erro: molecule command not found

```bash
# Recarregar shell
exec zsh

# Ou usar caminho completo
~/.local/bin/molecule --version
```

### Erro: Container não inicia

```bash
# Verificar Docker
docker ps
sudo systemctl status docker

# Reiniciar Docker
sudo systemctl restart docker
```

### Erro: Ansible collection não encontrada

```bash
# Instalar collections necessárias
ansible-galaxy collection install community.general
```

### Limpar tudo e recomeçar

```bash
# Destruir todos os containers do Molecule
cd roles/fnm
molecule destroy

cd ../bun
molecule destroy

# Remover imagens antigas (opcional)
docker system prune -a
```

### Problemas específicos do ZSH

Se encontrar problemas com o zsh:

```bash
# 1. Verificar PATH
echo $PATH | grep ".local/bin"

# 2. Se necessário, adicionar ao ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
exec zsh

# 3. Verificar aliases que podem conflitar
alias | grep molecule
```

## Boas Práticas

1. **Sempre teste antes de commitar**
   ```bash
   cd roles/fnm && molecule test
   cd ../bun && molecule test
   ```

2. **Use converge durante desenvolvimento**
   - Mais rápido que `test` completo
   - Mantém container entre execuções

3. **Teste em múltiplas plataformas** (avançado)
   ```yaml
   # molecule.yml
   platforms:
     - name: ubuntu-22
       image: ubuntu:22.04
     - name: ubuntu-24
       image: ubuntu:24.04
   ```

4. **Mantenha verificações atualizadas**
   - Adicione checks em `verify.yml` para novas funcionalidades
   - Teste idempotência (executar duas vezes)

## Comandos Úteis no ZSH

```bash
# Atalho para testar role atual
alias mtest='molecule test'
alias mconv='molecule converge'
alias mver='molecule verify'
alias mdest='molecule destroy'

# Adicionar ao ~/.zshrc se desejar
```

## Integração com CI/CD (Futuro)

A estrutura Molecule permite adicionar testes automatizados:

```yaml
# .github/workflows/test.yml (exemplo)
name: Test Roles
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
      - name: Install Molecule
        run: pip install molecule molecule-plugins[docker]
      - name: Test FNM role
        run: cd roles/fnm && molecule test
```

## Recursos

- [Documentação oficial do Molecule](https://molecule.readthedocs.io/)
- [Guia de Scenarios](https://molecule.readthedocs.io/en/latest/configuration.html)
- [Plugins disponíveis](https://github.com/ansible-community/molecule-plugins)
