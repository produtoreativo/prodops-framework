# Modo Upstream

Upstream é o **modo de exploração** do Framework ProdOps.

## Definição canônica

Upstream representa um modo de exploração. Seu objetivo é reduzir incertezas antes de assumir qualquer compromisso de entrega. O Upstream não representa uma promessa — representa um espaço para aprender. Todo trabalho realizado no Upstream é considerado experimental.

## Propósito

Reduzir incerteza antes de assumir qualquer compromisso formal. O software produzido no Upstream pode ter qualidade de produção — o que não existe é compromisso de entrega, OBC Committed ou Release Trail. O rigor é uma escolha do engenheiro, não uma imposição do modo.

## Características do modo

No Upstream:

- não existem gates obrigatórios
- não existe obrigação de concluir artefatos
- não existe obrigação de produzir um OBC Committed
- não existe obrigação de seguir todas as Skills
- o engenheiro decide quais Skills utilizar
- vibecoding é permitido
- experimentação é incentivada
- falhar faz parte do processo

O objetivo é aprender o mais rápido possível.

Um experimento Upstream pode produzir código de qualidade de produção. O rótulo exploratório descreve o modelo de compromisso — sem gates obrigatórios, sem OBC Committed, sem Release Trail — não o limite de implantação. Por decisão explícita do time e da liderança, esse código pode ser implantado em produção ou em ambientes produtivos controlados sem exigir promoção formal para Downstream. O CommitmentGate formaliza a transição de modo; não é pré-condição de implantação.

## OBC no Upstream

Quando uma Business Intent entra no Business Intent Backlog, um OBC é criado como Draft.

Durante o Upstream:

- o OBC permanece em Draft
- pode ser atualizado continuamente
- pode permanecer incompleto
- não bloqueia o avanço dos experimentos

O OBC funciona como memória do aprendizado — não como mecanismo de validação.

## Quando usar o modo Upstream

- Hipótese a validar, incerteza alta
- Explorar uma capability nova
- Prototipar integração com provedor
- Validar fluxo de negócio antes de comprometer
- Explorar abordagem técnica antes de decidir

## Jornadas no Upstream

**Upstream não é sinônimo de Discovery.** Todas as 5 jornadas do ProdOps estão disponíveis no Upstream — com rigor advisory. O engenheiro decide quais aplicar e com qual profundidade.

| Jornada | Comportamento no Upstream |
|---------|--------------------------|
| **Discovery** | Exploratória — sem artefatos obrigatórios, sem gate de saída; experimentos, spikes, protótipos, Event Storming |
| **Delivery** | Advisory — fases CI-Sync (Bootstrap → Finish) e CI-Async (Ship → Promote) disponíveis; Promote pode ir a sandbox ou, por decisão do time, a produção; sem Release Trail obrigatório |
| **Operation** | Experimental — observação de comportamento em sandbox ou ambiente controlado; sem SLO obrigatório, sem runbook formal |
| **Assessment** | Informa, não bloqueia — análise de riscos, premortem, Reliability Plan são opcionais e usados quando úteis |
| **Diligence** | Leve — verificação de consistência de artefatos conforme o engenheiro julgar necessário |

No Upstream, o engenheiro pode usar qualquer skill de fase com rigor completo se quiser — por exemplo, `/hack tdd` com ciclo Red/Green/Refactor idêntico ao Downstream. A diferença é que o rigor é uma escolha, não uma imposição.

## Três atos de implantação no Upstream

No Upstream, o código pode chegar a diferentes ambientes. Existem três atos distintos — com autorização e reversão diferentes. Nenhum dos três é promoção de capability.

| Ato | O que é | Autorização | Reversão |
|-----|---------|-------------|----------|
| **Sandbox Deploy** | Deploy em stack efêmera e isolada (`experiment-*`), sem tráfego de cliente real | O engenheiro decide | Destruir a stack (`action=teardown`) |
| **Produção Controlada** | Código Upstream implantado em produção real, sem CommitmentGate | Decisão explícita do time e da liderança | Rollback imediato disponível; sem Release Trail exigido |
| **Promoção de Capability** | CommitmentGate outcome Promover: BDD + OBC movidos; item entra no Downstream | Trio PM + Tech Lead + Autor | Processo formal de rollback Downstream |

**Produção Controlada não é uma violação do modo Upstream** — é um ato autorizado. O que a diferencia da Promoção é que o **compromisso de capability** (OBC Committed, Release Trail, Downstream gates) não foi assumido. O código chega a produção; a capability permanece em exploração.

## Como executar no modo Upstream

→ [Jornada Discovery no Upstream](../journeys/discovery/README.md) — exploração, experimentos, Decision Package
→ [Delivery no Upstream](../journeys/delivery/README.md) — fases disponíveis com rigor advisory
→ [Sandbox Deploy](../journeys/discovery/README.md#sandbox-deploy-upstream) — deploy em ambiente controlado sem rigor Downstream

## Encerramento do Upstream — CommitmentGate

O Upstream não termina automaticamente. O trio (PM + Tech Lead + Autor) é convocado explicitamente quando o Decision Package estiver pronto. Esse gate é o **CommitmentGate** — ele decide o destino da *capability*, não do código.

Existem **6 outcomes canônicos**. Cada um tem protocolo de ação distinto:

| Outcome | Ação obrigatória |
|---------|-----------------|
| **Promover** | BDD + OBC movidos para paths committed; item entra no Iteration Plan com `Entrou`; Downstream inicia |
| **Promover com restrição** | Subconjunto promovido; partes restritas permanecem em Upstream para novo experimento |
| **Requer outro experimento** | Criar novo experimento com hipótese mais específica; registrar decisão no `upstream-trail.md` atual |
| **Aguardar decisão de negócio** | Bloquear na Product Tracking List com decisor e data esperada; não abrir novo experimento até a decisão chegar |
| **Aguardar dependência externa** | Registrar no Reliability Plan e na Product Tracking List; monitorar no Continuous Assessment |
| **Descartar** | Registrar aprendizado em `prodops/framework/journeys/discovery/learnings.md`; fechar experimento com justificativa no `upstream-trail.md` |

A transição para Downstream só ocorre no outcome **Promover** ou **Promover com restrição**. Nos demais, a capability permanece no mesmo estágio em que estava antes do Upstream.

## Resultado esperado

Ao final de um ciclo Upstream, deve existir:

- Hipótese respondida com evidência
- Decision Package completo
- Recomendação clara (promover, requer outro experimento, aguardar, descartar)
- Artefatos ProdOps atualizados

## Sandbox Deploy (Upstream)

Um experimento pode ser implantado em AWS real sem passar pelo rigor do Downstream.

Objetivo: validar comportamento contra um provedor real (ex: Asaas sandbox) quando o ambiente local não é suficiente.

**Características:**

- Ativado manualmente via `workflow_dispatch` — nunca em push
- Stack efêmera: `payments-api-experiment` + `payments-api-dynamo-experiment`
- Recursos AWS prefixados `experiment-*` — isolados de staging e production
- Role IAM dedicada `payments-api-github-experiment` — escopo restrito a `experiment-*`
- Sem gate de aprovação, sem Release Trail, sem OBC committed
- **Obrigatório:** stack destruída ao final do experimento via `action=teardown`

→ [Step: deploy-to-sandbox](../../skills/upstream/steps/deploy-to-sandbox/SKILL.md)
→ Workflow de deploy: `.github/workflows/experiment-deploy.yml` (implementado pelo produto)
→ Role IAM: `api/infra/iam-experiment-role.yaml` (implementado pelo produto)

## Promoção para Downstream (CommitmentGate)

A transição Upstream → Downstream é mediada pelo **CommitmentGate** — gate formal convocado pelo trio PM + Tech Lead + Autor.

Pré-condições mínimas para convocar o CommitmentGate:
- Decision Package completo
- OBC Draft existe (ao menos o arquivo com nome e referência ao experimento)
- BDD draft legível

Após o CommitmentGate com outcome **Promover**:

1. BDD Feature movida de `prodops/artifacts/experiments/<NNN-slug>/features/` para `prodops/artifacts/bdd/`
2. OBC movido de `prodops/artifacts/experiments/<NNN-slug>/obcs/` para `prodops/artifacts/obcs/` (estado: Refining)
3. Entrada no Iteration Plan em `prodops/artifacts/plans/iteration-plan.md`
4. Reliability Plan atualizado em `prodops/framework/journeys/assessment/reliability-plans/`

→ [Processo completo e Outcomes Canônicos](../journeys/discovery/README.md#commitmentgate--transição-upstream--downstream)
