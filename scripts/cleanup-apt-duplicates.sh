#!/usr/bin/env bash
set -euo pipefail

# Script para limpar repositórios APT duplicados
# Criado para resolver warnings do apt-get update

echo "=== Limpeza de Repositórios APT Duplicados ==="
echo ""

# Backup dos arquivos antes de modificar
BACKUP_DIR="/tmp/apt-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Fazendo backup em: $BACKUP_DIR"
sudo cp -a /etc/apt/sources.list.d/ "$BACKUP_DIR/"
echo "✓ Backup concluído"
echo ""

# 1. Limpar nodesource.list - manter apenas a entrada sem arch=amd64
echo "1. Corrigindo /etc/apt/sources.list.d/nodesource.list..."
if [[ -f /etc/apt/sources.list.d/nodesource.list ]]; then
    # Criar arquivo temporário com apenas uma entrada
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | \
        sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    echo "   ✓ Removida duplicata do NodeSource"
else
    echo "   ⚠ Arquivo não encontrado, pulando..."
fi
echo ""

# 2. Remover archive_ubuntu_com_ubuntu.list (universe já está em ubuntu.sources)
echo "2. Removendo /etc/apt/sources.list.d/archive_ubuntu_com_ubuntu.list..."
if [[ -f /etc/apt/sources.list.d/archive_ubuntu_com_ubuntu.list ]]; then
    sudo rm /etc/apt/sources.list.d/archive_ubuntu_com_ubuntu.list
    echo "   ✓ Removido arquivo redundante (universe já em ubuntu.sources)"
else
    echo "   ⚠ Arquivo não encontrado, pulando..."
fi
echo ""

# 3. Atualizar cache do APT
echo "3. Atualizando cache do APT..."
sudo apt-get update 2>&1 | grep -E "(Hit:|Get:|Err:|W:)" || true
echo ""

# 4. Verificar se ainda há warnings
echo "4. Verificando se ainda há warnings..."
WARNINGS=$(sudo apt-get update 2>&1 | grep "^W:" || true)
if [[ -z "$WARNINGS" ]]; then
    echo "   ✓ Nenhum warning encontrado!"
else
    echo "   ⚠ Ainda há alguns warnings:"
    echo "$WARNINGS"
fi
echo ""

echo "=== Limpeza Concluída ==="
echo "Backup salvo em: $BACKUP_DIR"
echo ""
echo "Para reverter as mudanças (se necessário):"
echo "  sudo cp -a $BACKUP_DIR/sources.list.d/* /etc/apt/sources.list.d/"
