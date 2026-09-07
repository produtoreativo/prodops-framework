# ProdOps Lifecycle — Regras de Comportamento

## Regra 1: Identificar o estágio antes de agir

Antes de iniciar qualquer trabalho sobre uma capability ou OBC, determine o estágio do lifecycle canônico:

1. Business Signal
2. Business Intent / Product Intent
3. Context Discovery (Exploração Upstream)
4. Commitment (CommitmentGate)
5. Diligence & Readiness
6. Iteration
7. Delivery
8. Evidence
9. Outcome

Se o estágio for incerto, leia `prodops/skills/product-context/SKILL.md` e execute-a antes de prosseguir.

## Regra 2: Modo determina rigor

- **Upstream** (sem compromisso): não há gates obrigatórios, não há OBC Committed, não há Release Trail. O objetivo é aprendizado.
- **Downstream** (comprometido): todos os gates são bloqueantes. OBC Committed é obrigatório. Release Trail é mandatório. Sem bypass.

Nunca aplique rigor de Downstream a trabalho em modo Upstream. Nunca aplique a flexibilidade de Upstream a trabalho já em modo Downstream.

## Regra 3: CommitmentGate é a fronteira de modo

A transição Upstream → Downstream ocorre exclusivamente através do CommitmentGate. O gate formaliza a capability (o compromisso), não o código (o qual pode ir a produção antes ou depois do gate).

Nunca declare um item como "comprometido" sem o CommitmentGate registrado no `upstream-trail.md`.

## Regra 4: Evidence é obrigatória, não opcional

- Toda exploração Upstream deve produzir um Evidence Package antes do CommitmentGate.
- Toda entrega Downstream deve atualizar o Release Trail a cada fase.
- Todo OBC Released deve ter Observable Events verificados em produção.

Sem evidência verificável, o sistema não distingue entrega de intenção.

## Regra 5: Outcome fecha o ciclo

Um OBC Released sem verificação de Outcome é um ciclo incompleto. O sistema não sabe se o valor foi produzido.

Nunca mova um OBC para Archived sem verificação de Outcome documentada (KPIs + SLOs + Observable Events).

## Referências

→ [Lifecycle canônico](prodops/framework/lifecycle.md)
→ [Glossário](prodops/framework/glossary.md)
→ [OBC — estados](prodops/framework/obc.md)
