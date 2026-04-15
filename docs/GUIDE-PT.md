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
| `make install-deps` | Instala `curl` e `rsync` |
| `make info` | Mostra a configuração atual |
| `make clean` | Remove arquivos temporários |
| `make help` | Exibe resumo de uso |

---

## Variáveis

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `UBUNTU_VERSION` | `noble` | `noble` (24.04) ou `jammy` (22.04) |
| `ENV` | `full` | `base` (mínimo) ou `full` (completo) |
| `SCRIPT` | *(todos)* | Lista de scripts separada por vírgula |
| `HOST` | *(local)* | Destino remoto, ex: `root@192.168.1.10` |

### Exemplos

```bash
make install                                         # Noble, full, local
make install ENV=base                                # Apenas perfil base
make install SCRIPT=node                             # Apenas node
make install SCRIPT=docker,golang,node               # Múltiplos scripts
make install UBUNTU_VERSION=jammy HOST=root@servidor # Jammy em host remoto
make dry-install SCRIPT=node                         # Preview apenas node
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

### Perfil base (`ENV=base`)

| Script | O que faz |
|--------|-----------|
| `backup` | Faz backup dos dotfiles em `~/.ttdaiu_backup/`; gera `restore.sh` |
| `packages` | Instala 100+ pacotes APT (libs de dev, LaTeX, mídia, rede, produtividade) |
| `bash` | Copia `.bashrc`, `.bash_aliases`, `.bash_extras`, `.profile` |

### Perfil full — scripts adicionais (`ENV=full`)

| Script | Método | O que instala |
|--------|--------|---------------|
| `qemu` | APT | qemu-kvm, virt-manager, bridge-utils |
| `libvirt` | APT | libvirt-clients, libvirt-daemon-system, libvirt-dev |
| `nginx` | APT | nginx, php-fpm |
| `z80` | APT | sdcc, z80asm, z80dasm |
| `github` | APT | CLI `gh` com chave GPG e repositório oficial |
| `chromium` | Snap | Navegador Chromium |
| `code` | Snap | Visual Studio Code |
| `codium` | Snap | VSCodium |
| `golang` | Snap | Go + cria `~/go/{src,bin,pkg}` |
| `libreoffice` | Snap | LibreOffice |
| `docker` | APT | docker-ce + grupo de usuário + serviço |
| `node` | APT | Node.js via NodeSource + Corepack + pnpm + yarn + prefixo npm |
| `codex` | npm | `@openai/codex@latest` (instala em `~/.npm-global`) |
| `claude` | nativo | `curl -fsSL https://claude.ai/install.sh \| bash` |
| `gemini` | npm | `@google/gemini-cli@latest` (instala em `~/.npm-global`) |
| `opencode` | nativo | `curl -fsSL https://opencode.ai/install \| bash` |

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
1. `rsync` copia `ubuntu/noble/` (ou `ubuntu/jammy/`) para `/tmp/ttdaiu/` no host remoto
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

Cada `setup.sh` valida a versão do SO antes de rodar. Use `UBUNTU_VERSION=jammy` para máquinas 22.04:

```bash
make install UBUNTU_VERSION=jammy HOST=root@servidor
```

### Snap não disponível (WSL)

Scripts que instalam via Snap verificam a disponibilidade do `snapd`. Se não disponível, registram um aviso e pulam — sem falha.

### Pacotes npm global não encontrados após instalação

O script `node` configura o prefixo npm para `~/.npm-global` e o adiciona ao `.bashrc`. É necessário recarregar o shell:

```bash
source ~/.bashrc
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
