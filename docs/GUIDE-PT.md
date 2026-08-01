# TTDAIU - Guia Detalhado

## Sumário

1. [Targets do Make](#targets-do-make)
2. [Variáveis](#variáveis)
3. [Scripts Disponíveis](#scripts-disponíveis)
4. [Execução Remota via SSH](#execução-remota-via-ssh)
5. [Como Funciona](#como-funciona)
6. [Solução de Problemas](#solução-de-problemas)

---

## Targets do Make

| Target | Descrição |
|--------|-----------|
| `make install` | Executa o setup (local por padrão) |
| `make dry-install` | Mostra o que seria executado, sem alterações |
| `make list` | Lista perfis, grupos e componentes |
| `make install-deps` | Instala `curl` e `rsync` |
| `make info` | Mostra a configuração atual |
| `make clean` | Remove arquivos temporários |
| `make help` | Exibe resumo de uso |

---

## Variáveis

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `UBUNTU_VERSION` | `noble` | `resolute` (26.04), `noble` (24.04) ou `jammy` (22.04) |
| `ENV` | `full` | Perfil: `base`, `desktop`, `devops`, `embedded` ou `full` |
| `SCRIPT` / `COMPONENT` | *(todos)* | Componentes e/ou grupos nomeados (substitui a lista do `ENV`) |
| `HOST` | *(local)* | Destino remoto, ex: `root@192.168.1.10` |

### Exemplos

```bash
make install                                         # Noble, full, local
make install ENV=base                                # Apenas perfil base
make install ENV=desktop                             # Perfil desktop
make install ENV=devops                              # Perfil devops
make install ENV=embedded                            # Perfil embedded
make install SCRIPT=ai,docker                        # Grupo nomeado + componente
make install COMPONENT=qt,ocr                        # Alias de SCRIPT
make install SCRIPT=devtools,virt                    # Só grupos nomeados
make install SCRIPT=java                             # Componente focado
make list                                            # Catálogo de perfis/grupos/componentes
make install UBUNTU_VERSION=jammy HOST=root@servidor # Jammy em host remoto
make install UBUNTU_VERSION=resolute                 # Resolute/26.04 local
make dry-install SCRIPT=ai                           # Preview só do grupo ai
```

### Configuração persistente com `.env`

```bash
cat > .env << EOF
UBUNTU_VERSION=jammy
ENV=full
EOF

make install SCRIPT=docker   # usa UBUNTU_VERSION e ENV do .env
```

---

## Scripts Disponíveis

Perfis e grupos estão definidos em `ubuntu/*/scripts/profiles.sh`.

### Perfis (`ENV`)

| Perfil | O que executa |
|--------|---------------|
| `base` | `backup`, `apt-upgrade`, `build-tools`, `network-base`, `sysutils`, `bash`, `sysctl`, `sudoers` |
| `desktop` | base + `desktop` + `editors` + `latex` |
| `devops` | base + grupos `devtools` + `virt` + `network` |
| `embedded` | base + grupos `embedded` + `gamedev` |
| `full` | base + todos os scripts de componente |

### Grupos nomeados (`SCRIPT`)

| Grupo | Expande para |
|-------|--------------|
| `devtools` | java, php, postgres, github, golang, rust, node, docker, distrobox |
| `editors` | code, codium, qt |
| `ai` | codex, claude, gemini, opencode |
| `virt` | qemu, libvirt |
| `embedded` | sdcc, z80, m6502, arm |
| `desktop` | graphics, media, desktop-utils, flatpak, ocr, remote, chromium, libreoffice |
| `network` | network-extra, nginx, ansible |
| `gamedev` | godot, sdl |

Quando `SCRIPT` / `COMPONENT` está definido, ele **substitui** a lista do perfil. Misture grupos e componentes (`SCRIPT=ai,docker,java`).

Use `make list` para ver o catálogo completo.

### Componentes do perfil base (`ENV=base`)

| Componente | O que faz |
|------------|-----------|
| `backup` | Faz backup dos dotfiles em `~/.ttdaiu_backup/`; gera `restore.sh` |
| `apt-upgrade` | Roda `apt-get dist-upgrade` e limpa o cache APT |
| `build-tools` | Toolchain de build (cmake, build-essential, git, jq, shellcheck, …) |
| `network-base` | net-tools, nmap, openssh-server, rclone |
| `sysutils` | btop, htop, neovim, smartmontools, tree, … |
| `bash` | Injeta dotfiles; organiza PATH no `.profile`; remove linhas ad-hoc de instaladores |
| `sysctl` | Define `vm.swappiness=10` via `/etc/sysctl.d/99-ttdaiu-swappiness.conf` |
| `sudoers` | Sudo sem senha para `MAIN_USER` via `/etc/sudoers.d/99-ttdaiu-nopasswd` |

### Scripts de componente (também usados por `ENV=full`)

| Script | Método | O que instala |
|--------|--------|---------------|
| `java` | APT | default-jdk, default-jre, gradle |
| `php` | APT | php-cli, php-gd, php-imagick, php-mysql, php-snmp |
| `postgres` | APT | postgresql-client |
| `sdl` | APT | libsdl2-*-dev, love |
| `qt` | APT | qtcreator, qt6-*-dev |
| `desktop-utils` | APT | meld, bleachbit, mc, evince, gnome-tweaks, wkhtmltopdf, qrencode, yadm |
| `flatpak` | APT | flatpak |
| `ocr` | APT | tesseract-ocr, tesseract-ocr-por |
| `remote` | APT | remmina, filezilla |
| `qemu` | APT | qemu-kvm, virt-manager, bridge-utils, cpu-checker |
| `libvirt` | APT | libvirt-clients, libvirt-daemon-system, libvirt-dev |
| `nginx` | APT | nginx, php-fpm |
| `arm` | APT | gcc-arm-none-eabi |
| `ansible` | APT | ansible |
| `z80` | APT | z80asm, z80dasm |
| `github` | APT | CLI `gh` com chave GPG e repositório oficial |
| `chromium` | Snap | Navegador Chromium |
| `code` | Snap | Visual Studio Code |
| `codium` | Snap | VSCodium |
| `golang` | Snap | Go + cria `~/go/{src,bin,pkg}` |
| `rust` | rustup | `curl … \| sh -s -- -y --no-modify-path`; PATH via bash `.profile` |
| `libreoffice` | Snap | LibreOffice |
| `docker` | APT | docker-ce + grupo de usuário + serviço |
| `distrobox` | APT / upstream | Distrobox (APT no Noble/Resolute; instalador upstream no Jammy) |
| `node` | APT | Node.js via NodeSource + Corepack + pnpm + yarn + prefixo npm |
| `codex` | npm | `@openai/codex@latest` (instala em `~/.npm-global`) |
| `claude` | nativo | `curl -fsSL https://claude.ai/install.sh \| bash` |
| `gemini` | npm | `@google/gemini-cli@latest` (instala em `~/.npm-global`) |
| `opencode` | nativo | `curl … \| bash -s -- --no-modify-path`; PATH via bash `.profile` |

### Executar scripts individualmente

Cada script é autossuficiente e pode ser executado diretamente (como root):

```bash
sudo bash ubuntu/noble/scripts/install-docker.sh
sudo bash ubuntu/noble/scripts/install-node.sh
```

Variáveis de ambiente respeitadas pelos scripts:

```bash
DRY_RUN=true sudo bash ubuntu/noble/scripts/install-node.sh
NODE_VERSION=20.x sudo bash ubuntu/noble/scripts/install-node.sh
```

---

## Execução Remota via SSH

Quando `HOST` é definido, o `make` usa `rsync` para copiar os scripts para a máquina remota e executa `setup.sh` via SSH.

```bash
# Noble remoto (padrão)
make install HOST=root@192.168.1.50

# Resolute remoto
make install UBUNTU_VERSION=resolute HOST=root@192.168.1.50

# Jammy remoto
make install UBUNTU_VERSION=jammy HOST=root@192.168.1.50

# Scripts específicos em host remoto
make install HOST=root@x042 SCRIPT=z80,docker
```

**Requisitos:**
- Autenticação SSH por chave (sem senha)
- `rsync` instalado localmente
- Usuário remoto deve ser `root` ou ter `sudo` sem senha

**Como funciona:**
1. `rsync` copia `ubuntu/noble/` (ou `ubuntu/resolute/`, `ubuntu/jammy/`) para `/tmp/ttdaiu/` no host remoto
2. SSH executa `bash /tmp/ttdaiu/setup.sh` com os argumentos passados

---

## Como Funciona

### Fluxo de execução

```
make install SCRIPT=node
  └── make/run-shell.sh
       └── cd ubuntu/noble/ && sudo bash setup.sh --env=full --scripts=node
            └── ubuntu/noble/scripts/install-node.sh
```

### setup.sh

- Valida a versão do SO (aborta se a versão não corresponder ao diretório)
- Detecta WSL e disponibilidade de systemd
- Determina `MAIN_USER` e `MAIN_HOME` a partir de `SUDO_USER`
- Executa `apt-get update` (pulado quando `--scripts=` está definido)
- Executa cada script solicitado na ordem

### Funções do lib.sh

Todos os scripts fazem `source lib.sh`, que fornece:

| Função | Descrição |
|--------|-----------|
| `log_info / log_ok / log_warn / log_error / log_step` | Saída colorida |
| `run_cmd` | Executa ou imprime (se `DRY_RUN=true`) |
| `apt_install` | `apt-get install -y` com 3 tentativas |
| `snap_install` | `snap install` com 3 tentativas |
| `npm_global` | `npm install -g` como `MAIN_USER` |
| `enable_service` | `systemctl enable --now` (se systemd disponível) |
| `detect_wsl / detect_systemd / get_main_user / get_os_version` | Detecção de ambiente |

### Modo dry-run

Passe `--dry-run` (via `make dry-install`) para imprimir o que seria executado sem fazer alterações:

```bash
make dry-install SCRIPT=docker
```

Exemplo de saída:
```
==> Instalando Docker (apt)
[DRY-RUN] apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
[DRY-RUN] Baixaria chave GPG e adicionaria repositório Docker
...
```

---

## Solução de Problemas

### Versão incorreta do Ubuntu

Cada `setup.sh` valida a versão do SO antes de rodar. Faça `UBUNTU_VERSION` corresponder ao seu SO:

```bash
make install UBUNTU_VERSION=resolute HOST=root@servidor   # 26.04
make install UBUNTU_VERSION=noble    HOST=root@servidor   # 24.04
make install UBUNTU_VERSION=jammy    HOST=root@servidor   # 22.04
```

### Snap não disponível (WSL)

Scripts que instalam via Snap verificam a disponibilidade do `snapd`. Se não disponível, registram um aviso e pulam — sem falha.

### Pacotes npm global não encontrados após instalação

O script `node` configura o prefixo npm para `~/.npm-global`; o PATH vem do bloco bash em `.profile`. Recarregue o shell (ou abra um novo login shell):

```bash
source ~/.profile
```

O `npm -g list` reflete os pacotes instalados no prefixo configurado (`~/.npm-global`). Se aparecer vazio, verifique:

```bash
npm config get prefix   # deve retornar /home/<usuário>/.npm-global
```

### Docker: permissão negada após instalação

O script `docker` adiciona seu usuário ao grupo `docker`, mas a mudança só tem efeito após re-login:

```bash
newgrp docker   # aplica imediatamente na sessão atual
```

### SSH remoto: rsync ou conexão falha

Verifique:
1. Autenticação por chave SSH configurada: `ssh-copy-id root@servidor`
2. `rsync` instalado localmente: `apt-get install rsync`
3. Host remoto acessível: `ssh root@servidor echo ok`
