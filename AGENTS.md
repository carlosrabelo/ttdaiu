# Diretrizes para Agentes de Desenvolvimento (AGENTS.md)

Este documento registra decisões arquiteturais e restrições de design do projeto TTDAIU que devem ser seguidas por todos os agentes de IA e desenvolvedores que trabalharem nesta base de código.

## 1. Estrutura de Diretórios por Versão do Ubuntu

*   **Regra:** O projeto **deve manter sempre 3 diretórios separados** (um para cada versão suportada do Ubuntu), localizados sob a pasta `ubuntu/` (por exemplo: `ubuntu/jammy/`, `ubuntu/noble/`, `ubuntu/resolute/`).
*   **Racional:** A separação explícita por versão faz parte da ideia de design do projeto. Mesmo que ocorra repetição de código nos scripts utilitários ou arquivos de configuração entre as diferentes versões, essa duplicação é aceita e esperada para garantir o isolamento e a facilidade de execução direta e independente dos scripts de cada versão.
*   **Ação:** Não tente consolidar ou unificar esses diretórios. Qualquer melhoria ou correção em um script comum que afete múltiplas versões do Ubuntu deve ser replicada nos diretórios correspondentes.
