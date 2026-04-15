# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** é uma ferramenta de automação em shell script que configura sistemas Ubuntu após a instalação. Suporta Ubuntu 22.04 (Jammy) e 24.04 (Noble) com dois perfis de execução — `base` para o essencial e `full` para uma estação de desenvolvimento completa.

## O que o TTDAIU Instala

### Perfil Base (`ENV=base`)
- **Pacotes do sistema**: Ferramentas de build, utilitários de rede, bibliotecas de desenvolvimento
- **Configuração do shell**: Bash aprimorado com aliases e configurações de perfil
- **Sistema de backup**: Backup de dotfiles e script de restauração

### Perfil Full (`ENV=full`)
Inclui tudo do base mais:

#### Ferramentas de Desenvolvimento
- **Docker**: Plataforma de contêineres via APT (com chave GPG e repositório oficial)
- **Go**: Linguagem Go via Snap
- **Node.js**: Runtime via NodeSource com Corepack, pnpm e yarn
- **GitHub CLI**: `gh` via repositório APT oficial

#### Editores & IDEs
- **Visual Studio Code**: Via Snap
- **VSCodium**: Alternativa open-source ao VS Code via Snap
- **Neovim**: Editor de terminal via APT

#### Produtividade
- **Chromium**: Navegador via Snap
- **LibreOffice**: Suíte de escritório via Snap
- **GIMP**, **Inkscape**, **Audacity**, **VLC**: Via APT

#### Ferramentas AI / CLI
- **Claude Code**: Via instalador nativo (`claude.ai/install.sh`)
- **OpenCode**: Via instalador nativo (`opencode.ai/install`)
- **Codex**: `@openai/codex` via npm
- **Gemini**: `@google/gemini-cli` via npm

#### Ferramentas Especializadas
- **Nginx**, **QEMU**, **libvirt**, **ferramentas Z80**: Via APT

#### Pacotes do Sistema (100+)
Bibliotecas de desenvolvimento, LaTeX, ferramentas de rede, gráficos, produtividade, monitores do sistema.

## Início Rápido

```bash
# Instalar dependências (curl, rsync)
make install-deps

# Executar setup completo na máquina local (Noble/24.04)
make run

# Executar apenas scripts específicos
make run SCRIPT=node
make run SCRIPT=docker,golang,github

# Apenas perfil base (packages + bash + backup)
make run ENV=base

# Preview sem aplicar alterações
make dry-run
make dry-run SCRIPT=node

# Executar em máquina remota via SSH
make run HOST=root@servidor
make run HOST=root@servidor UBUNTU_VERSION=jammy SCRIPT=z80
```

## Estrutura do Projeto

```
ttdaiu/
├── ubuntu/noble/                  # Ubuntu 24.04 (Noble)
│   ├── setup.sh            # Orquestrador
│   ├── files/bash/         # Dotfiles (.bashrc, .bash_aliases, .bash_extras, .profile)
│   └── scripts/
│       ├── lib.sh          # Funções comuns (log, retry, apt_install, snap_install…)
│       ├── install-backup.sh
│       ├── install-bash.sh
│       ├── install-packages.sh
│       ├── install-docker.sh
│       ├── install-node.sh
│       └── …               # Um script por componente (19 no total)
├── ubuntu/jammy/                  # Ubuntu 22.04 (Jammy) — mesma estrutura
├── make/
│   ├── run-shell.sh        # Lógica de execução local e remota
│   ├── install-deps.sh     # Instala curl e rsync
│   └── cleanup.sh
├── docs/                   # GUIDE.md, GUIDE-PT.md
├── Makefile
└── LICENSE
```

## Documentação

- **Guia em português**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md)
- **English guide**: [docs/GUIDE.md](docs/GUIDE.md)

## Licença

MIT — veja [LICENSE](LICENSE).
