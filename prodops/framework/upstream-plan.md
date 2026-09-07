# Plano de Experimento

O **Plano de Experimento** é o artefato de coordenação do modo Upstream — o equivalente do Iteration Plan para o regime não bloqueante (advisory).

Enquanto o Iteration Plan registra *o que está sendo entregue nesta iteração* (capabilities comprometidas), o Plano de Experimento registra *o que está sendo investigado agora* (hipóteses ativas). Os dois artefatos são simétricos: um governa o Downstream em execução, o outro governa o Upstream em exploração.

---

## O que é

**Natureza:** VIEW sobre os itens do Icebox que possuem um experimento Upstream ativo — ou seja, itens com `experiment.md` e `upstream-trail.md` presentes e em andamento.

**Pergunta:** Quais hipóteses estão sendo investigadas neste momento?

**Não é:** Uma lista de tarefas. O Plano de Experimento não define sequência nem impõe prazo. É um instrumento de visibilidade e controle de WIP — não de planejamento de sprint.

---

## Estrutura

| Campo | Descrição |
|---|---|
| **ID** | Identificador do experimento (EXP-NNN) |
| **Hipótese** | Uma linha: o que está sendo testado |
| **Estado** | Ativo / Aguardando (dependência externa) / Concluído (aguardando CommitmentGate) |
| **Decision Package** | Pronto / Em construção / Não iniciado |
| **Sessões desde última entrada** | Contador de sessões desde a última entrada no upstream-trail (sinal S1 do Perpetual Discovery) |
| **Discovery WIP** | Posição neste experimento dentro do WIP total (ex: 2/3) |

---

## Relação com o Iteration Plan

| Dimensão | Plano de Experimento | Iteration Plan |
|---|---|---|
| **Modo** | Upstream (não bloqueante / advisory) | Downstream (bloqueante) |
| **O que lista** | Experimentos com hipótese ativa | Capabilities com OBC Committed |
| **Gate de entrada** | Abertura de experimento pelo PM/Tech Lead | CommitmentGate outcome Promover + Readiness Gate |
| **Gate de saída** | CommitmentGate (qualquer dos 6 outcomes) | Promote concluído → OBC Released |
| **Limite de WIP** | Discovery WIP (controlado pela equipe) | Capacidade da iteração |
| **Artefato central** | `experiment.md` + `upstream-trail.md` | OBC Committed + BDD Feature |

---

## Discovery WIP

O Discovery WIP é a métrica primária do Plano de Experimento: o número de experimentos Upstream ativos simultaneamente. Um Discovery WIP alto indica dispersão de atenção entre múltiplas hipóteses, o que tende a aumentar o TTE (Time to Evidence) de todos eles.

O limite de Discovery WIP é uma decisão de cada time — não um valor fixo do framework. O Plano de Experimento torna esse limite visível e controlável.

---

## Sinais de alerta no Plano de Experimento

| Sinal | Critério | Diagnóstico |
|---|---|---|
| **S1** | Experimento ativo sem progressão de hipótese por 3+ sessões (upstream-trail tem entradas mas `Hypothesis` não mudou há 2+ semanas e Decision Package não tem substância) | Stagnação — experimento travado sem decisão |
| **S2** | Experimento ativo há mais de N semanas sem Decision Package | Perpetual Discovery — exploração sem critério de parada |
| **S3** | Discovery WIP acima do limite definido pelo time | Dispersão — muitas hipóteses em paralelo |
| **S4** | Experimento com Decision Package pronto mas CommitmentGate não convocado | Decision Latency — evidência disponível, decisão adiada |

Quando múltiplos sinais estão ativos simultaneamente, a convocação do CommitmentGate é a resposta operacional específica — não para forçar aprovação, mas para decidir o destino do experimento.

---

## Artefato canônico

`prodops/artifacts/product/backlogs/experiment-plan.md`

O Plano de Experimento é atualizado no início de cada sessão de trabalho Upstream, antes de qualquer atividade de exploração. Sua manutenção é responsabilidade do Autor (condutor do experimento) com revisão do PM.

---

## Relação com o Icebox e o PIB

```
Product Intent Backlog (PIB)
    │
    └─ [VIEW] Icebox         (OBC ≠ Committed)
            │
            └─ [VIEW] Plano de Experimento   (experimentos Upstream ativos)
                       │
                       └─ CommitmentGate → Iteration Backlog (OBC Committed)
```

Um item do PIB pode estar no Icebox sem estar no Plano de Experimento — por exemplo, quando aguarda uma decisão de negócio externa antes de abrir um experimento. O Plano de Experimento é a subview ativa do Icebox para o trabalho de exploração em curso.
