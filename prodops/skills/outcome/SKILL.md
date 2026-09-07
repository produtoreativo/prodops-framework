---
name: outcome
description: Verifica o Business Outcome e o Product Outcome de uma capability frente ao OBC comprometido. Use após o OBC atingir o estado Released para confirmar que o valor comprometido foi produzido — KPIs de negócio, SLOs, DORA Metrics e Observable Events.
---

# Outcome Skill

## Propósito

Use esta skill para verificar, com evidência operacional real, se a entrega produziu o valor comprometido no OBC.

O Outcome não é a entrega em si — é a confirmação de que a entrega produziu resultado. Um OBC Released sem verificação de Outcome é uma entrega não confirmada: o sistema não sabe se o valor foi produzido.

Esta skill verifica dois planos distintos:

- **Business Outcome:** KPIs e métricas de negócio verificados após operação continuada
- **Product Outcome:** comportamento técnico verificável — SLOs, DORA Metrics, Observable Events

---

## Quando Usar

- Após o OBC atingir o estado Released e um período operacional suficiente ter decorrido
- Em Assessment Reviews para verificar se capabilities entregues produziram valor
- Quando KPIs ou SLOs comprometidos no OBC precisam ser contrastados com dados reais
- Quando um OBC Released precisa ser movido para Archived com registro de resultado
- Para alimentar aprendizados do ciclo anterior antes de iniciar nova Business Intent

---

## Leitura Obrigatória

Antes de iniciar, ler:

- `prodops/framework/lifecycle.md` — estágio Outcome
- `prodops/framework/glossary.md` — termos Outcome, Business Outcome, Product Outcome, Observable Events, DORA Metrics
- `prodops/artifacts/obcs/<slug>.md` — OBC Released com KPIs e critérios comprometidos

---

## Fluxo de Verificação de Outcome

### Pré-condições

1. OBC em estado Released (`prodops/artifacts/obcs/<slug>.md`)
2. Release Trail com Promote concluído (`prodops/artifacts/trails/`)
3. Observable Events operando em produção (verificado pela Evidence Skill)
4. Período operacional suficiente para coleta de métricas (conforme declarado no OBC ou critério de negócio)

---

### 1. Ler o compromisso do OBC

Extrair do OBC Released:
- KPIs comprometidos: valores alvo, período de medição, fonte dos dados
- SLOs declarados: disponibilidade, latência, taxa de erro alvo
- Observable Events esperados: quais eventos, frequência, condições
- Critérios de aceite operacionais (seção "Resultados Esperados" do OBC)

---

### 2. Verificar o Business Outcome

**Business Outcome** é verificado pelo Assessment com suporte do Portfolio PM.

Para cada KPI comprometido no OBC:

1. Identificar a fonte de dados (dashboard, relatório, sistema de analytics).
2. Coletar o valor atual para o período de medição declarado.
3. Comparar com o valor alvo comprometido.
4. Classificar:
   - **Confirmado:** valor atingiu ou superou o alvo
   - **Parcial:** valor está abaixo do alvo mas dentro de margem aceitável documentada
   - **Não atingido:** valor está abaixo do alvo além da margem aceitável

5. Para KPIs não atingidos: registrar hipótese sobre causa e abrir follow-up Business Signal.

**Formato de registro:**

```markdown
### Business Outcome — <capability-slug>

| KPI | Alvo | Medido | Período | Status |
|---|---|---|---|---|
| <kpi-name> | <target> | <actual> | <period> | ✅ Confirmado / ⚠️ Parcial / ❌ Não atingido |

**Fonte dos dados:** <dashboard/sistema>
**Data de verificação:** <YYYY-MM-DD>
**Observações:** <contexto relevante>
```

---

### 3. Verificar o Product Outcome

**Product Outcome** é verificado pela jornada Operation e pelo Assessment Async.

#### SLOs

Para cada SLO declarado no OBC ou no Reliability Plan:

1. Ler a métrica atual do sistema de observabilidade (Datadog ou equivalente).
2. Comparar com o SLO comprometido (disponibilidade, latência P95, taxa de erro).
3. Verificar se o período de burn rate está dentro do Error Budget.

| SLO | Target | Atual | Error Budget | Status |
|---|---|---|---|---|
| Disponibilidade | ≥ 99.9% | <valor> | <budget restante> | <status> |
| Latência P95 | ≤ 300ms | <valor> | — | <status> |

#### DORA Metrics

Verificar as quatro métricas DORA para o período da capability:

| Métrica | Valor | Referência | Classificação |
|---|---|---|---|
| Deployment Frequency | | | Elite / High / Medium / Low |
| Lead Time for Changes | | | |
| Change Failure Rate | | | |
| Time to Restore Service | | | |

#### Observable Events

Para cada Observable Event declarado no OBC:
1. Confirmar que o evento está sendo emitido (verificar logs / Datadog).
2. Verificar frequência e condições de emissão.
3. Confirmar que não há alertas ativos relacionados ao evento.

---

### 4. Registrar o Outcome

Registrar os resultados no OBC Released:

```markdown
## Outcome Verificado

**Data de verificação:** <YYYY-MM-DD>
**Verificado por:** <PM + Tech Lead ou Assessment team>
**Período de operação:** <data-início> a <data-verificação>

### Business Outcome
<tabela de KPIs com status>

### Product Outcome
<SLOs, DORA, Observable Events>

### Conclusão
<Outcome confirmado / Parcial — ver follow-ups / Não atingido — causa registrada>

### Follow-ups
<lista de Business Signals abertos para KPIs não atingidos>
```

---

### 5. Decidir sobre ciclo do OBC

Com base nos resultados:

| Situação | Ação |
|---|---|
| Outcome confirmado | Transitar OBC para Archived. Registrar aprendizado em `learnings.md`. |
| Outcome parcial | Manter OBC Released. Abrir novo Business Signal para gap de valor. |
| Outcome não atingido | Manter OBC Released. Abrir investigação. Escalar para Portfolio PM. |

A transição para Archived requer registro explícito: data, quem decidiu, e síntese do Outcome produzido.

---

## Regras de Operação

1. Nunca verificar Outcome antes do período operacional suficiente — dados prematuros distorcem a análise.
2. Nunca marcar Business Outcome como confirmado sem dados da fonte declarada no OBC.
3. Nunca mover OBC para Archived sem verificação de Outcome registrada.
4. Para KPIs não atingidos: sempre registrar hipótese e abrir follow-up — não deixar silenciosamente sem rastreamento.
5. Nunca confundir "Released" com "Outcome confirmado" — Released significa entregue, não que o valor foi produzido.

---

## Saídas Esperadas

- Registro de Outcome no OBC Released (Business Outcome + Product Outcome)
- Tabela de KPIs com valores medidos vs. comprometidos
- SLOs e DORA Metrics verificados para o período
- Observable Events confirmados operando em produção
- Follow-up Business Signals abertos para gaps de valor (quando aplicável)
- Decisão sobre transição do OBC para Archived (com justificativa)

---

## Guardrails

- Nunca fabricar métricas — registrar apenas o que foi medido na fonte declarada.
- Nunca arquivar um OBC sem verificação de Outcome documentada.
- Não confundir Product Outcome (técnico, verificável pelo sistema) com Business Outcome (negócio, verificado pelo PM com suporte do Portfolio).
- Não tratar SLO violado como follow-up menor — escalar para a jornada Operation.

---

## Referências

→ [Lifecycle — estágio Outcome](../../framework/lifecycle.md)
→ [Glossário — Outcome](../../framework/glossary.md)
→ [OBC](../../framework/obc.md)
→ [Evidence Skill](../evidence/SKILL.md)
→ [Product Context Skill](../product-context/SKILL.md)
→ [Jornada Operation](../../framework/journeys/operation/README.md)
→ [DORA Metrics](../../framework/dora-metrics.md)
