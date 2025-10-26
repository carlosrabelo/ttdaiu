# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** é uma ferramenta de automação abrangente baseada em Ansible que configura sistemas Ubuntu após a instalação. Oferece dois perfis de execução - `base` para configuração essencial do sistema e `full` para provisionamento completo de estação de desenvolvimento.

## O que o TTDAIU Instala

### Perfil Base (`ENV=base`)
- **Essenciais do Sistema**: Atualizações do sistema, ferramentas de compilação, utilitários de rede
- **Configuração do Shell**: Bash aprimorado com aliases e configurações de perfil
- **Sistema de Backup**: Scripts automatizados de backup e funcionalidade de restauração

### Perfil Full (`ENV=full`)
Inclui todos os componentes base mais:

#### Ferramentas de Desenvolvimento
- **Docker**: Plataforma de contêineres (instalação APT ou Snap)
- **Go**: Ambiente de desenvolvimento Go com workspace configurado
- **Node.js**: Runtime v22.x com suporte npm, pnpm e yarn
- **GitHub CLI**: Interface de linha de comando do GitHub

#### Editores & IDEs
- **Visual Studio Code**: Via Snap
- **VSCodium**: Alternativa open-source do VS Code
- **Neovim**: Editor de terminal aprimorado

#### Aplicativos de Produtividade
- **Chromium**: Navegador web via Snap
- **LibreOffice**: Suíte de escritório completa
- **GIMP**: Editor de imagens
- **Inkscape**: Editor de gráficos vetoriais
- **Audacity**: Editor de áudio
- **VLC**: Reprodutor de mídia

#### Ferramentas AI/CLI
- **Claude Code**: Assistente de codificação AI da Anthropic
- **OpenCode**: Assistente de desenvolvimento com IA
- **Codex**: Assistente de codificação da OpenAI
- **Gemini**: Assistente AI do Google

#### Ferramentas Especializadas
- **Nginx**: Servidor web
- **Libvirt**: Virtualização KVM/QEMU
- **Ferramentas Z80**: Ambiente de desenvolvimento assembly Z80

#### Pacotes Adicionais
- **Desenvolvimento**: Java, Python, PHP, cliente PostgreSQL, Hugo, Jekyll
- **Rede**: Ferramentas VPN, utilitários SSH, análise de rede
- **Gráficos**: Suporte de fontes, ferramentas de manipulação de imagem
- **Produtividade**: Comparação de arquivos, área de trabalho remota, visualizadores
- **LaTeX**: Instalação TeX Live completa com TeXstudio
- **Sistema**: Ferramentas de monitoramento, gerenciamento de processos, engine de jogos

## Início Rápido

### Pré-requisitos
- Ubuntu 22.04 (Jammy) ou 24.04 (Noble)
- Acesso sudo sem interação de senha
- Conectividade com internet para downloads de pacotes

### Uso Básico

```bash
# Instalar Ansible e dependências
make install-deps

# Executar configuração base (pacotes essenciais mínimos)
make run

# Executar configuração completa (estação de desenvolvimento completa)
make run ENV=full

# Executar para Ubuntu 22.04
make run UBUNTU_VERSION=jammy

# Visualizar alterações sem aplicar
make dry-run

# Executar componentes específicos apenas
make run TAGS=docker,golang
```

### Perfis de Ambiente

```bash
# Perfil base - ferramentas essenciais do sistema
make run ENV=base                    # Padrão: packages, bash, backup

# Perfil full - ambiente de desenvolvimento completo
make run ENV=full                    # Todas as roles base + desenvolvimento, produtividade, ferramentas AI
```

### Execução Baseada em Tags

```bash
# Apenas ferramentas de desenvolvimento
make run TAGS=docker,golang,node,github

# Aplicativos de produtividade
make run TAGS=chromium,libreoffice,code

# Ferramentas AI/CLI
make run TAGS=claude,opencode,codex,gemini

# Utilitários do sistema
make run TAGS=packages,bash,backup
```

## Documentação

- **Guia Completo**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md) - Uso detalhado com todos os targets, variáveis e opções de configuração
- **English**: [docs/GUIDE.md](docs/GUIDE.md) - Complete guide in English

## Estrutura do Projeto

```
ttdaiu/
├── noble/          # Playbooks Ubuntu 24.04 (Noble)
├── jammy/          # Playbooks Ubuntu 22.04 (Jammy)
├── scripts/        # Scripts auxiliares
├── docs/          # Documentação
└── Makefile       # Interface de comandos
```

Cada diretório de versão contém roles idênticas organizadas por função:
- `roles/packages/` - Instalação de pacotes do sistema
- `roles/docker/`, `roles/golang/`, `roles/node/` - Ferramentas de desenvolvimento
- `roles/code/`, `roles/codium/`, `roles/chromium/` - Aplicativos
- `roles/claude/`, `roles/opencode/` - Assistentes AI

## Aviso

Este projeto é destinado ao uso pessoal e configuração de estações de desenvolvimento. Sinta-se à vontade para fazer fork e personalizar as listas de pacotes e configurações para suas necessidades específicas.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.