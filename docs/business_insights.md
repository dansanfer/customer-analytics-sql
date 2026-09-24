# Relatório Executivo: Diagnóstico de Retenção & Segmentação RFM 📈

**Data:** Setembro de 2026  
**Público-alvo:** Direção Comercial, Marketing e Gestão de Produto  
**Autor:** Equipe de Análise de Dados  

---

## 1. Sumário Executivo

Este documento traduz os dados transacionais extraídos da base analítica em recomendações táticas e estratégicas. A análise focou-se em duas vertentes principais: o comportamento de rotatividade (*churn*) ao longo do ciclo de vida dos clientes (Análise de Coorte) e a concentração de receita por perfil comportamental (Matriz RFM).

---

## 2. Diagnóstico de Retenção (Cohort Analysis)

### Padrão Identificado
- **Queda Abrupta no Mês 1:** Observa-se uma perda média de retenção superior a **50% logo no primeiro mês** após a primeira transação em todas as coortes analisadas.
- **Estabilização Tardia:** Os clientes que sobrevivem após o terceiro mês ($M_3$) mantêm uma taxa de atividade relativamente previsível (~20% a 25%), constituindo o núcleo fixo da base.

### Recomendações Estratégicas
1. **Campanha de Ativação do Dia 14:** Implementar réguas automáticas de comunicação (e-mail/SMS/Push) aos 14 dias após a compra inicial, oferecendo benefício exclusivo ou recomendação de produtos correlacionados.
2. **Onboarding Guiado:** Mapear o percurso do cliente na primeira semana para garantir que alcança o momento de perceção de valor (*Aha! Moment*) antes do encerramento do primeiro ciclo de 30 dias.

---

## 3. Segmentação RFM & Matriz de Ação

Com base na distribuição de Recência, Frequência e Valor Monetário, a base foi dividida em quatro agrupamentos estratégicos:

| Segmento | Comportamento Observado | Plano de Ação Recomendado |
| :--- | :--- | :--- |
| **VIP / Campeão** | Compras recentes, alta frequência e maior ticket médio. | Canal de atendimento prioritário, acesso antecipado a lançamentos e programa de vantagens exclusivas sem desconto agressivo. |
| **Cliente Leal** | Compradores consistentes com ticket estável. | Estratégias de *cross-sell* e incentivo a assinaturas ou planos de recorrência. |
| **Em Risco de Churn** | Histórico com múltiplas transações, mas inativos há mais de 60 dias. | Contacto ativo de reativação (*win-back*) com pesquisa de satisfação e cupão de retorno com validade curta. |
| **Hibernando / Perdido** | Baixa frequência e sem compras nos últimos 120 dias. | Redução da frequência de envios para evitar custos de comunicação desnecessários; incluir apenas em saldos sazonais de grande escala. |

---

## 4. Próximos Passos de Dados & Produto

- [ ] Integrar alertas automáticos no Slack quando um cliente do segmento **VIP** ultrapassar 45 dias sem novas compras.
- [ ] Implementar modelo preditivo de propensão ao cancelamento (*Machine Learning*) utilizando os dados históricos consolidados.