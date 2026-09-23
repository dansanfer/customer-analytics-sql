# Customer Analytics & Cohort Retention (PostgreSQL) 📊

Projeto prático de **SQL Analítico** focado em mensuração de retenção de clientes, análise de coortes (*cohort analysis*) e segmentação comportamental **RFM (Recency, Frequency, Monetary)** sobre dados transacionais.

---

## 🎯 Contexto e Objetivos de Negócio

Empresas orientadas a dados precisam de compreender o ciclo de vida do cliente para reduzir a rotatividade (*churn*), priorizar investimentos operacionais e identificar contas de alto valor.

Este repositório aborda duas frentes centrais:
1. **Análise de Coorte (Cohort):** Monitorizar a percentagem de clientes que continuam ativos nos meses subsequentes à primeira compra.
2. **Segmentação RFM:** Classificar a base por recência de compra, frequência e volume financeiro para ações orientadas de gestão.

---

## 🛠️ Tecnologias e Habilidades SQL Demonstradas

- **SGBD:** PostgreSQL
- **Modelagem Relacional:** Definição de chaves primárias/estrangeiras, tipos temporais (`TIMESTAMPTZ`) e restrições de integridade (`CHECK`).
- **Otimização de Índices:** Índices compostos e B-Tree (`idx_transactions_customer_date`) para aceleração de filtros e agregações.
- **Consultas Analíticas Avançadas:**
  - Common Table Expressions (**CTEs**) encadeadas para legibilidade e pipeline modular.
  - Funções de Janela (**Window Functions**): `MIN() OVER (...)` e `NTILE(4) OVER (...)`.
  - Manipulação Temporal: `DATE_TRUNC`, `DATE_PART`, diferenças de intervalos e cálculo de mês relativo.

---

## 📂 Estrutura do Repositório

- `sql/01_schema.sql`: Definição DDL de tabelas e índices.
- `sql/02_seed.sql`: Povoamento sintético de transações.
- `sql/03_cohort_analysis.sql`: Matriz de retenção mês a mês.
- `sql/04_rfm_segmentation.sql`: Segmentação de clientes com NTILE(4).
- `README.md`: Documentação e análise de negócio.

---

## 📈 Resultados e Análises

### 1. Matriz de Retenção de Clientes (Cohort)
A consulta calcula o mês de aquisição e o índice temporal (Mês 0, Mês 1, Mês 2...) para extrair a taxa percentual de recompra:

| Mês de Aquisição (Coorte) | Clientes Totais | Mês 0 | Mês 1 | Mês 2 | Mês 3 | Mês 4 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **2026-01** | 24 | 100% | 45.8% | 37.5% | 29.2% | 20.8% |
| **2026-02** | 26 | 100% | 50.0% | 34.6% | 23.1% | - |

> **Diagnóstico:** A maior perda de atividade ocorre entre o Mês 0 e o Mês 1 (~50%), evidenciando a necessidade de ações imediatas de envolvimento e acompanhamento logo após o registo inicial.

---

### 2. Segmentação RFM
Distribuição da base de clientes por quartis analíticos com pontuação de 1 a 4:

- **VIP / Campeão (Score 10-12):** Clientes com compras recentes, alta frequência e maior volume transacionado.
- **Cliente Leal (Score 8-9):** Utilizadores consistentes com histórico frequente de atividade.
- **Em Risco de Churn (Recência baixa, Frequência alta):** Clientes historicamente ativos que deixaram de interagir nos últimos períodos.
- **Hibernando / Perdido:** Utilizadores com registos antigos e sem novas compras.

---

## 🚀 Como Reproduzir Localmente

1. Clone o repositório em sua máquina:
   ```bash
   git clone [https://github.com/dansanfer/customer-analytics-sql.git](https://github.com/dansanfer/customer-analytics-sql.git)
   ```

2. Conecte ao seu servidor PostgreSQL e crie a base de dados:
   ```sql
   CREATE DATABASE customer_analytics;
   ```

3. Abra o seu cliente de banco de dados (DBeaver, pgAdmin ou terminal `psql`), selecione a base `customer_analytics` e execute os scripts da pasta `/sql` na seguinte ordem:
   - **`01_schema.sql`**: Criação da estrutura de tabelas e índices.
   - **`02_seed.sql`**: Inserção dos dados sintéticos para simulação.
   - **`03_cohort_analysis.sql`**: Execução e cálculo da retenção por coorte.
   - **`04_rfm_segmentation.sql`**: Execução da classificação de clientes por RFM.