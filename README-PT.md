# TTDAIU - Things to Do After Installing Ubuntu

![CI](https://github.com/carlosdelfino/ttdaiu/workflows/CI/badge.svg)

**TTDAIU** é uma ferramenta de automação baseada em Ansible que configura e otimiza sistemas Ubuntu após a instalação. Ele instala aplicativos essenciais, ferramentas de desenvolvimento e utilitários do sistema automaticamente.

## Propósito

Automatizar o processo de configuração pós-instalação para sistemas Ubuntu, garantindo configuração consistente entre máquinas com intervenção manual mínima.

## Início Rápido

### Pré-requisitos
- Ubuntu 22.04 (Jammy) ou 24.04 (Noble)
- Ansible instalado (ou execute `make install-deps`)
- Acesso sudo

### Uso Básico

```bash
# Instalar dependências
make install-deps

# Executar configuração completa (Ubuntu 24.04)
make run

# Executar componentes específicos
make run TAGS=packages

# Executar para Ubuntu 22.04
make run UBUNTU_VERSION=jammy

# Visualizar alterações sem aplicar
make dry-run
```

## Documentação

- **Guia**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md) - Guia completo com todos os targets e variáveis

## Aviso

Este projeto é destinado ao uso pessoal. Sinta-se à vontade para fazer fork e personalizá-lo para suas próprias necessidades.