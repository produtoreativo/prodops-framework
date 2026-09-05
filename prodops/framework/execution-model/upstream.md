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

## Condições para abrir um experimento formal

Todas as quatro condições devem ser verdadeiras para justificar a abertura de um experimento formal:

1. **Hipótese falsificável** — é possível definir o que invalidaria a hipótese
2. **Hipótese não respondida** — a resposta não existe nas evidências já disponíveis
3. **Resposta tem valor de decisão** — afeta o que será construído ou como será construído
4. **Custo de ignorar > custo de experimentar** — o custo de assumir a hipótese como verdadeira sem testar é maior do que o custo do experimento

Se qualquer condição falhar, o experimento não é o instrumento correto: pode ser uma pesquisa interna, uma decisão de negócio, ou trabalho que já cabe diretamente em Downstream.

## Evidence Threshold

O Evidence Threshold é o critério que define quando a evidência coletada é suficiente para levar o Decision Package ao CommitmentGate.

**É opcional, mas recomendado.** Quando declarado:
- Deve ser registrado no `experiment.md` no início do experimento
- Revisões ao critério (afrouxar ou endurecer) devem ser registradas no `upstream-trail.md` com justificativa
- Atingir o threshold não convoca automaticamente o CommitmentGate — convoca o trio

Sem Evidence Threshold declarado, o critério de parada é o julgamento do autor do experimento. Nesse caso, o autor é o responsável por documentar no Decision Package por que a evidência acumulada é suficiente.

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

## Perpetual Discovery — Anti-padrão

O Perpetual Discovery ocorre quando um experimento continua acumulando evidências indefinidamente sem avançar para uma decisão de compromisso. O experimento não falhou — ele nunca terminou.

**Quatro sinais diagnósticos objetivos:**

| Sinal | Critério | Ação |
|-------|----------|------|
| **S1** | Sem progressão no `upstream-trail` por 3 ou mais sessões consecutivas | Identificar bloqueio; escalar ao trio |
| **S2** | Questões marcadas como "não respondíveis com evidências disponíveis" por 5 ou mais dias | Revisar hipótese; considerar CommitmentGate com outcome Descartar ou Aguardar |
| **S3** | Evidence Threshold declarado identificado como não atingível sem nova hipótese, após 3 ou mais sessões de coleta | Reformular hipótese ou revisar threshold; registrar decisão no trail |
| **S4** | Stakeholder com decisão bloqueada há 10 ou mais dias úteis por causa deste experimento | CommitmentGate imediato — a decisão de esperar mais também é uma decisão válida (outcome Aguardar) |

A presença de qualquer sinal não exige encerramento imediato — exige **convocação do trio para decidir conscientemente** se o experimento deve continuar, ser suspenso ou encerrado.

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
- Hipótese respondida com Evidence Threshold satisfeito (se declarado)
- OBC Draft existe (ao menos o arquivo com nome e referência ao experimento)
- BDD draft legível

**Critério de verificabilidade do Decision Package:** um membro do trio que não participou do experimento deve conseguir ler o Decision Package e chegar às mesmas conclusões sem contexto verbal adicional. Se o Decision Package requer explicação oral para ser compreendido, ele não está pronto.

Após o CommitmentGate com outcome **Promover**:

1. BDD Feature movida de `prodops/artifacts/experiments/<NNN-slug>/features/` para `prodops/artifacts/bdd/`
2. OBC movido de `prodops/artifacts/experiments/<NNN-slug>/obcs/` para `prodops/artifacts/obcs/` (estado: Refining)
3. Entrada no Iteration Plan em `prodops/artifacts/plans/iteration-plan.md`
4. Reliability Plan atualizado em `prodops/framework/journeys/assessment/reliability-plans/`

→ [Processo completo e Outcomes Canônicos](../journeys/discovery/README.md#commitmentgate--transição-upstream--downstream)


---

→ **Próximo:** [Modo Downstream](downstream.md)
