# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** é uma ferramenta de automação em shell script que configura sistemas Ubuntu após a instalação. Suporta Ubuntu 22.04 (Jammy), 24.04 (Noble) e 26.04 (Resolute) com perfis de execução e grupos nomeados para montar combinações.

## O que o TTDAIU Instala

### Perfis (`ENV`)
| Perfil | Inclui |
|--------|--------|
| `base` | backup, apt-upgrade, build-tools, network-base, sysutils, bash, sysctl, sudoers |
| `desktop` | base + gráficos/mídia/produtividade, Chromium, LibreOffice, editores, LaTeX |
| `devops` | base + devtools, virt, network (Docker, Node, Go, Rust, QEMU, Ansible, …) |
| `embedded` | base + SDCC/Z80/m6502/ARM + Godot |
| `full` | base + todos os componentes |

### Grupos nomeados (`SCRIPT` / `COMPONENT`)
Monte instalações sem listar cada componente: `devtools`, `editors`, `ai`, `virt`, `embedded`, `desktop`, `network`, `gamedev`.  
`SCRIPT` (alias `COMPONENT`) substitui a lista do perfil. Veja `make list` para o catálogo completo.

### Conteúdo do perfil full (`ENV=full`)
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
- **Nginx**, **QEMU**, **libvirt**, **Ansible**, toolchains **ARM** / **Z80**: Via APT

#### Pacotes do Sistema (100+)
Bibliotecas de desenvolvimento, LaTeX, ferramentas de rede, gráficos, produtividade, monitores do sistema.

## Início Rápido

```bash
# Instalar dependências (curl, rsync)
make install-deps

# Executar setup completo na máquina local (Noble/24.04)
make run

# Perfis intermediários
make run ENV=desktop
make run ENV=devops
make run ENV=embedded

# Grupos nomeados e/ou componentes focados (substitui a seleção do ENV)
make run SCRIPT=ai,docker
make run COMPONENT=qt,ocr
make run SCRIPT=devtools,virt
make run SCRIPT=java

# Catálogo de perfis, grupos e componentes
make list

# Apenas perfil base
make run ENV=base

# Preview sem aplicar alterações
make dry-run
make dry-run SCRIPT=node

# Executar em máquina remota via SSH
make run HOST=root@servidor
make run HOST=root@servidor UBUNTU_VERSION=resolute SCRIPT=z80
make run HOST=root@servidor UBUNTU_VERSION=jammy SCRIPT=z80
```

## Estrutura do Projeto

```
ttdaiu/
├── ubuntu/noble/                  # Ubuntu 24.04 (Noble)
│   ├── setup.sh                   # Orquestrador
│   ├── files/bash/                # Dotfiles (.bashrc, .bash_aliases, .bash_extras, .profile)
│   ├── files/sysctl/              # Ajustes de kernel (vm.swappiness)
│   └── scripts/
│       ├── lib.sh                 # Funções comuns (log, retry, apt_install, snap_install…)
│       ├── profiles.sh            # Perfis ENV + grupos nomeados SCRIPT
│       ├── install-backup.sh
│       ├── install-bash.sh
│       ├── install-build-tools.sh
│       ├── install-sysctl.sh
│       ├── install-docker.sh
│       ├── install-node.sh
│       └── …                      # Um script por componente
├── ubuntu/jammy/                  # Ubuntu 22.04 (Jammy) — mesma estrutura
├── ubuntu/resolute/               # Ubuntu 26.04 (Resolute) — mesma estrutura
├── make/
│   ├── run-shell.sh               # Lógica de execução local e remota
│   ├── install-deps.sh            # Instala curl e rsync
│   └── cleanup.sh
├── docs/                          # GUIDE.md, GUIDE-PT.md
├── Makefile
└── LICENSE
```

## Documentação

- **Guia em português**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md)
- **English guide**: [docs/GUIDE.md](docs/GUIDE.md)

## Licença

MIT — veja [LICENSE](LICENSE).
