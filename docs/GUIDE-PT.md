# TTDAIU - Manual Detalhado

## Sumário

1. [Targets do Make](#targets-do-make)
2. [Variáveis de Ambiente](#variáveis-de-ambiente)
3. [Tags Disponíveis](#tags-disponíveis)
4. [Opções de Configuração](#opções-de-configuração)
5. [Uso Avançado](#uso-avançado)

## Targets do Make

### Targets Principais

#### `make run`
**Propósito**: Executar o playbook Ansible completo
**Padrão**: Ubuntu 24.04 (Noble), ambiente base

```bash
make run                                    # Padrão: noble, base
make run UBUNTU_VERSION=jammy              # Ubuntu 22.04
make run ENV=full                          # Ambiente completo
make run TAGS=packages                     # Apenas tags específicas
```

#### `make dry-run`
**Propósito**: Visualizar alterações sem aplicá-las
**Uso**: Mesmas opções que `make run` mas com flags `--check --diff`

```bash
make dry-run                               # Visualizar todas as alterações
make dry-run TAGS=docker                   # Visualizar instalação do Docker
```

#### `make install-deps`
**Propósito**: Instalar dependências do sistema
**Instala**: ansible, git, sshpass, python3-pip

```bash
make install-deps
```

### Targets de Manutenção

#### `make check` / `make syntax`
**Propósito**: Validar sintaxe do playbook Ansible
**Verifica**: Sintaxe YAML, estrutura do playbook

```bash
make check
```

#### `make lint`
**Propósito**: Executar ansible-lint para qualidade do código
**Requer**: pacote ansible-lint

```bash
make lint
```

#### `make clean`
**Propósito**: Limpar arquivos temporários e artefatos
**Remove**: Arquivos temporários do Ansible, logs, cache

```bash
make clean
```

#### `make info`
**Propósito**: Exibir informações de configuração do projeto
**Mostra**: Configurações atuais, caminhos, versões

```bash
make info
```

#### `make secure-creds`
**Propósito**: Configurar gerenciamento seguro de credenciais
**Cria**: Arquivos vault criptografados para uso em produção

```bash
make secure-creds
```

## Variáveis de Ambiente

### Variáveis Principais

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `UBUNTU_VERSION` | `noble` | Versão Ubuntu: `noble` (24.04) ou `jammy` (22.04) |
| `ENV` | `base` | Ambiente: `base` (mínimo) ou `full` (completo) |
| `TAGS` | `all` | Lista separada por vírgula de tags para executar |
| `ANSIBLE_DIR` | `./noble` | Caminho para diretório de configuração Ansible |
| `PLAYBOOK` | `site.yml` | Nome do playbook principal |
| `INVENTORY` | `inventory/base.ini` | Arquivo de inventário ambiente base |
| `FULL_INVENTORY` | `inventory/full.ini` | Arquivo de inventário ambiente completo |

### Exemplos de Uso

```bash
# Sobrescrever versão Ubuntu
UBUNTU_VERSION=jammy make run

# Usar ambiente completo
ENV=full make run

# Executar apenas tags específicas
TAGS=packages,docker make run

# Combinar múltiplas variáveis
UBUNTU_VERSION=jammy ENV=full TAGS=docker,golang make run
```

## Tags Disponíveis

### Tags de Sistema

| Tag | Descrição | Componentes |
|-----|-----------|------------|
| `packages` | Pacotes essenciais do sistema | Atualizações, utilitários, ferramentas de rede |
| `bash` | Configuração do shell | Bashrc aprimorado, aliases, configurações de perfil |
| `backup` | Configuração do sistema de backup | Scripts de backup, funcionalidade de restauração |

### Tags de Desenvolvimento

| Tag | Descrição | Componentes |
|-----|-----------|------------|
| `docker` | Plataforma de contêineres Docker | Docker CE/EE, docker-compose |
| `golang` | Ambiente de desenvolvimento Go | Ferramentas linguagem Go, configuração GOPATH |
| `node` | Desenvolvimento Node.js | Runtime Node.js, npm, npx |
| `github` | Ferramentas CLI GitHub | CLI gh, gerenciamento de repositórios |

### Tags de Aplicações

| Tag | Descrição | Componentes |
|-----|-----------|------------|
| `code` | Visual Studio Code | Editor VS Code, extensões |
| `codium` | VSCodium (VS Code open-source) | Editor VSCodium |
| `chromium` | Navegador web | Navegador Chromium via Snap |
| `libreoffice` | Suíte de escritório | Ferramentas de produtividade LibreOffice |

### Tags de IA/CLI

| Tag | Descrição | Componentes |
|-----|-----------|------------|
| `claude` | Claude AI CLI | Ferramenta de linha de comando Claude da Anthropic |
| `codex` | OpenAI Codex CLI | Assistente de codificação OpenAI |
| `gemini` | Google Gemini CLI | Assistente IA Google |
| `opencode` | OpenCode AI CLI | Assistente de desenvolvimento com IA |

### Tags Especializadas

| Tag | Descrição | Componentes |
|-----|-----------|------------|
| `nginx` | Servidor web | Servidor HTTP Nginx |
| `libvirt` | Virtualização | Ferramentas de virtualização KVM/QEMU |
| `z80` | Desenvolvimento Z80 | Ferramentas de desenvolvimento assembly Z80 |

## Opções de Configuração

### Feature Flags

Controle grupos principais de recursos através do dicionário `features`:

```yaml
features:
  install_development_tools: true
  install_media_tools: true
  install_productivity_tools: true
  install_latex_tools: true
  configure_bash: true
  setup_networking: true
  enable_backups: true
  install_ai_cli_tools: true
```

### Configuração Docker

```yaml
docker_install_method: "apt"    # Opções: "apt", "snap"
docker_users: ["ubuntu"]        # Usuários para adicionar ao grupo docker
```

### Categorias de Pacotes

Configure grupos de pacotes em `roles/packages/defaults/main.yml`:

```yaml
packages_system:
  - curl
  - wget
  - git

packages_development:
  - build-essential
  - python3-dev

packages_media:
  - vlc
  - audacity
```

## Uso Avançado

### Arquivos de Inventário Personalizados

Crie arquivos de inventário personalizados para ambientes específicos:

```bash
# Criar inventário personalizado
cp noble/inventory/base.ini noble/inventory/custom.ini

# Usar inventário personalizado
INVENTORY=inventory/custom.ini make run
```

### Sobrescrita de Variáveis

Sobrescreva variáveis temporariamente:

```bash
cd noble
ansible-playbook site.yml -i inventory/base.ini \
  -e '{"features": {"install_ai_cli_tools": false}}' \
  --tags packages
```

### Configuração Específica de Ambiente

Use arquivo `.env` para configuração persistente:

```bash
# Criar arquivo .env
cat > .env << EOF
UBUNTU_VERSION=jammy
ENV=full
TAGS=packages,docker,golang
EOF

# Make carregará .env automaticamente
make run
```

### Modo Debug

Habilite saída verbosa para solução de problemas:

```bash
# Método 1: Execução Ansible direta
cd noble
ansible-playbook -v site.yml -i inventory/base.ini

# Método 2: Modificar run-ansible.sh temporariamente
# Adicionar flag -v ao comando ansible-playbook
```

### Execução Seletiva de Roles

Execute roles específicas sem tags:

```bash
cd noble
ansible-playbook site.yml -i inventory/base.ini \
  --start-at-task="Install Docker packages"
```

### Execução Condicional

Use condições `when` em playbooks para lógica avançada:

```yaml
- name: Install development tools
  ansible.builtin.apt:
    name: "{{ packages_development }}"
    state: present
  when: features.install_development_tools | bool
```

## Solução de Problemas

### Problemas Comuns

1. **Permissão Negada**
   ```bash
   # Garantir acesso sudo
   sudo -v
   make run
   ```

2. **Ansible Não Encontrado**
   ```bash
   make install-deps
   ```

3. **Problemas com Snap**
   ```bash
   sudo systemctl status snapd
   sudo systemctl restart snapd
   ```

4. **Problemas de Rede**
   ```bash
   # Verificar conectividade
   ping -c 4 archive.ubuntu.com
   ping -c 4 api.snapcraft.io
   ```

### Arquivos de Log

Logs do Ansible são armazenados em:
- `~/.ansible/log/` - Logs padrão do Ansible
- `/tmp/ansible-*` - Logs temporários de execução

### Recuperação

Reverta alterações específicas:

```bash
# Remover pacotes específicos
sudo apt remove nome-pacote

# Resetar arquivos de configuração
git checkout noble/roles/nome_role/files/
```

## Melhores Práticas

1. **Sempre use dry-run primeiro**: `make dry-run`
2. **Verifique sintaxe**: `make check` antes da execução
3. **Use tags para instalação seletiva**: Evite alterações desnecessárias
4. **Backup dados importantes**: Antes de alterações maiores
5. **Teste em ambiente virtual**: Antes do uso em produção
6. **Mantenha documentação atualizada**: Documente alterações personalizadas

## Dicas de Performance

1. **Execução paralela**: Ansible executa tarefas em paralelo por padrão
2. **Conexões locais**: Use `connection: local` para configuração de máquina única
3. **Cache de pacotes**: Cache APT acelera instalações repetidas
4. **Pré-carregamento Snap**: Pacotes Snap são cacheados localmente

## Considerações de Segurança

1. **Revise listas de pacotes**: Garanta apenas pacotes necessários instalados
2. **Use credenciais seguras**: `make secure-creds` para produção
3. **Audite roles**: Revise roles personalizadas para problemas de segurança
4. **Isolamento de rede**: Execute em rede isolada quando possível
5. **Atualizações regulares**: Mantenha Ansible e pacotes do sistema atualizados