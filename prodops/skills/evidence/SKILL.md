---
name: evidence
description: Captura, estrutura e vincula evidências ao longo do lifecycle. Use para registrar Upstream Evidence (pacotes de evidência de experimentos) e Downstream Evidence (Release Trail, Observable Events), garantindo rastreabilidade do compromisso assumido ao valor entregue.
---

# Evidence Skill

## Propósito

Use esta skill para produzir, estruturar e vincular evidências verificáveis ao longo do lifecycle canônico.

Evidência no ProdOps não é documentação opcional — é a prova de que o que foi comprometido foi realizado (Downstream) ou de que o que foi explorado produziu aprendizado (Upstream). Sem evidência, o sistema não pode distinguir entrega de intenção.

Esta skill opera em dois contextos distintos:

- **Upstream Evidence:** evidências de experimentos — o que foi testado, como, e o que se concluiu
- **Downstream Evidence:** evidências de entrega — o que foi entregue, como foi validado, e o que está operando em produção

---

## Quando Usar

**Upstream Evidence:**
- Ao concluir um experimento e montar o Decision Package
- Ao registrar resultados de entrevistas, benchmarks, spikes ou protótipos
- Quando o Evidence Threshold declarado no `experiment.md` precisa ser verificado
- Para garantir que o CommitmentGate tem substrato verificável

**Downstream Evidence:**
- Ao concluir o CI Sync (Finish) e produzir as evidências de qualidade
- Ao concluir o CI Async (Validate / Promote) e atualizar o Release Trail
- Quando Observable Events precisam ser registrados ou verificados em produção
- Para vincular evidências operacionais ao OBC Released

---

## Leitura Obrigatória

Antes de iniciar, ler:

- `prodops/framework/lifecycle.md` — estágios Evidence e Context Discovery
- `prodops/framework/glossary.md` — termos Evidence, Upstream Evidence, Downstream Evidence, Observable Events, Release Trail
- `prodops/framework/obc.md` — seções "OBC no Upstream" e "OBC no Downstream"

---

## Upstream Evidence

### Estrutura do Evidence Package

O Evidence Package de um experimento deve conter:

| Item | Localização | Descrição |
|---|---|---|
| Hipótese original | `experiment.md` — seção Hipótese | O que foi testado e por quê |
| Método | `experiment.md` — seção Metodologia | Como a hipótese foi testada |
| Artefatos produzidos | `experiment.md` — seção Descobertas | Código, protótipos, métricas, outputs |
| Resultado observado | `experiment.md` — seção Descobertas | O que foi observado, com dados |
| Conclusão | `experiment.md` — seção Recomendação | Hipótese confirmada, refutada ou inconclusiva |
| Material de suporte | `evidence/` do experimento | Outputs de comando, payloads, capturas — apenas quando relevante |

### Verificação do Evidence Threshold

Se o `experiment.md` declara um Evidence Threshold (critério de suficiência):

1. Ler o critério declarado.
2. Verificar se cada item do critério está satisfeito com referência concreta no Evidence Package.
3. Registrar o resultado da verificação na seção "Decision Package" do `experiment.md`.

Se o Evidence Threshold não for satisfeito: não convocar o CommitmentGate. Retornar ao experimento.

### Registro no upstream-trail

Ao finalizar o Evidence Package, registrar no `upstream-trail.md` do experimento:
- Data de conclusão do Evidence Package
- Lista dos artefatos produzidos
- Resultado da verificação do Evidence Threshold
- Status: pronto para CommitmentGate (ou bloqueado, com motivo)

---

## Downstream Evidence

### Release Trail

O Release Trail é o log append-only que documenta cada fase da jornada Delivery. É a evidência primária de que a entrega foi realizada conforme o compromisso.

**Estrutura de uma entrada no Release Trail:**

```markdown
## <YYYY-MM-DD> — <Fase>

**work-item-id:** <issue-number>
**iteration-id:** <iteration-id>
**correlation-id:** <uuid>
**status:** <completed | failed | blocked>

<resumo: o que foi feito, evidências principais, próximo passo>
```

**Localização:** `prodops/artifacts/trails/sessions/YYYY-MM-DD-<session-id>.md`

**Regras do Release Trail:**
1. Nunca modificar entradas existentes — o trail é append-only.
2. Toda fase concluída ou bloqueada deve gerar uma entrada antes de avançar.
3. Incluir sempre: `work-item-id`, `correlation-id`, `status` e timestamp.
4. Em caso de regressão (Downstream → Upstream): registrar o motivo da suspensão antes de encerrar.

---

### Observable Events

Observable Events são os sinais emitidos pelo sistema em produção que provam que o comportamento comprometido está operando.

**Ao registrar Observable Events como evidência:**

1. Ler os Observable Events declarados no OBC em `prodops/artifacts/obcs/<slug>.md`.
2. Verificar que cada evento declarado está sendo emitido em produção (confirmar via Datadog, logs ou ferramenta de observabilidade configurada).
3. Registrar a verificação no Release Trail ou no OBC Released.
4. Se algum Observable Event não estiver emitindo: abrir follow-up issue e registrar no Release Trail.

**Condição de saída do estágio Evidence:** Release Trail completo + Observable Events operando em produção verificados.

---

## Vinculação de Evidências ao OBC

Toda evidência deve ser vinculada ao OBC que a originou:

| Tipo de evidência | Onde vincular |
|---|---|
| Upstream Evidence (Decision Package) | Seção "Evidências" do OBC em experimento |
| Release Trail | Seção "Evidências" do OBC Released |
| Observable Events confirmados | Seção "Observabilidade" do OBC Released |
| Métricas de Outcome | Seção "KPIs / Resultados Esperados" do OBC Released |

O OBC Released deve ser legível como prova completa de que o ciclo foi honrado — da intenção à evidência operacional.

---

## Regras de Operação

1. Evidência não é documentação retrospectiva — deve ser produzida no momento do trabalho, não reconstruída após.
2. Nunca marcar o Evidence Package como completo sem verificar o Evidence Threshold (quando declarado).
3. Nunca fechar o estágio Evidence sem Release Trail completo e Observable Events verificados.
4. Não duplicar evidências — cada artefato de evidência referencia o OBC que o originou; o OBC referencia os artefatos.
5. Material de suporte em `evidence/` é para detalhes técnicos — o argumento principal deve estar no `experiment.md` ou no Release Trail.

---

## Saídas Esperadas

**Upstream Evidence:**
- `experiment.md` com Evidence Package completo e Decision Package verificável
- `upstream-trail.md` atualizado com status do Evidence Package
- Evidence Threshold verificado (quando declarado)

**Downstream Evidence:**
- Release Trail atualizado com entradas de cada fase concluída
- Observable Events verificados em produção
- OBC atualizado com referências às evidências

---

## Guardrails

- Nunca inventar evidências — registrar apenas o que foi observado e verificado.
- Nunca marcar OBC como Released sem evidências concretas de operação em produção.
- Nunca omitir entradas de falha ou bloqueio no Release Trail — o trail deve refletir o que realmente aconteceu.
- Não confundir "código mergeado" com "capability entregue" — a entrega só está completa quando o Release Trail está fechado e os Observable Events estão operando.

---

## Referências

→ [Lifecycle — estágio Evidence](../../framework/lifecycle.md)
→ [Glossário — Evidence](../../framework/glossary.md)
→ [OBC](../../framework/obc.md)
→ [Commitment Skill](../commitment/SKILL.md)
→ [Outcome Skill](../outcome/SKILL.md)
→ [Jornada Discovery — experimentos](../../framework/journeys/discovery/README.md)
→ [Downstream Skill](../downstream/SKILL.md)
