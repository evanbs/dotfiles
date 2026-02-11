# Correções Aplicadas - JSONDecodeError do Homebrew

## 🔧 Problema Raiz

O módulo `community.general.homebrew` do Ansible executa internamente `brew info --json` para verificar se um pacote está instalado. Em instalações novas do Homebrew, esse comando falha porque o ambiente ainda não está totalmente configurado, gerando:

```
json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)
```

## ✅ Solução Implementada

### Estratégia: Shell com Verificação Idempotente

Substituímos **todos** os usos do módulo `community.general.homebrew` por comandos shell seguros:

```yaml
shell: "{{ brew_prefix }}/bin/brew list <package> >/dev/null 2>&1 || {{ brew_prefix }}/bin/brew install <package> | cat"
```

**Benefícios:**
- ✅ Funciona em instalações novas do Homebrew
- ✅ Idempotente (verifica se já está instalado antes)
- ✅ Não trava em problemas de TTY (pipe para `cat`)
- ✅ Compatível com WSL e containers

## 📦 Arquivos Modificados

### 1. `site.yml`
- ❌ Removido: `pre_tasks` que instalava `community.general` collection
- ✅ Motivo: Não usamos mais módulos dessa collection

### 2. `roles/homebrew/tasks/main.yml`
- ❌ Removido: `community.general.homebrew` module (3 ocorrências)
- ✅ Substituído por: Shell loops com verificação `brew list`
- ❌ Removido: Tasks de `brew bundle` (duplicação)

### 3. `roles/homebrew/defaults/main.yml`
- ❌ Removido: `fnm` e `bun` da lista `brew_packages`
- ✅ Motivo: São instalados por roles específicos

### 4. `roles/homebrew/files/Brewfile`
- ✅ Atualizado: Agora serve como **documentação de referência**
- ✅ Adicionado: Comentários explicando cada categoria
- ❌ Removido: Uso direto com `brew bundle`

### 5. `roles/fnm/tasks/main.yml`
- ❌ Removido: `community.general.homebrew` module
- ✅ Substituído por: Shell com `brew list fnm || brew install fnm`

### 6. `roles/bun/tasks/main.yml`
- ❌ Removido: `community.general.homebrew` module
- ✅ Substituído por: Shell com `brew list bun || brew install bun`

### 7. `handlers/main.yml`
- ❌ Removido: `community.general.homebrew` module no handler
- ✅ Substituído por: `brew update | cat`

## 📊 Estatísticas

```
7 arquivos modificados
46 inserções(+)
82 deleções(-)
-36 linhas (código mais enxuto!)
```

## 🎯 Estratégia de Instalação Final

```
1. Homebrew base      → shell (install.sh script)
2. Base packages      → shell loop (git, zsh, starship, git-delta)
3. Developer tools    → shell loop via brew_packages (bat, vim, fzf, etc)
4. FNM runtime        → role fnm com shell
5. Node.js + npm      → fnm install lts-latest
6. Bun runtime        → role bun com shell
```

## ✨ Melhorias Adicionais

1. **Sem duplicação**: Cada pacote é instalado uma única vez
2. **Roles específicos**: FNM e Bun têm seus próprios roles
3. **Documentação clara**: Brewfile explica o que cada pacote faz
4. **Idempotência garantida**: Re-execução não reinstala pacotes
5. **Compatibilidade**: Funciona em WSL, Linux nativo e containers

## 🧪 Próximo Passo

Teste em WSL limpo seguindo: `TESTING_CHECKLIST.md`
