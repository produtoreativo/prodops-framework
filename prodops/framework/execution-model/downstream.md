# Modo Downstream

Downstream é o **modo de compromisso** do Framework ProdOps.

## Definição canônica

Downstream representa um modo de compromisso. A partir do momento em que uma Business Intent entra em Downstream, existe compromisso de entrega, qualidade e confiabilidade. Todo trabalho passa a seguir obrigatoriamente o modelo operacional do ProdOps.

## Propósito

Entregar software com rastreabilidade, critérios de aceite verificáveis e evidência registrada em cada etapa.

## Características do modo

No Downstream:

- existe compromisso de implementação
- existe compromisso de confiabilidade
- existe governança
- existe validação obrigatória
- existe rastreabilidade
- existe geração de evidências
- existe conformidade com o modelo operacional

As Skills deixam de ser opcionais. Passam a fazer parte do processo de execução — participam da validação das jornadas, produzem evidências e garantem consistência.

## OBC no Downstream

Ao entrar no Downstream, o OBC deixa de ser apenas um registro. Ele passa a ser o contrato operacional do trabalho.

Durante o Discovery (no Icebox), será refinado até atingir o estado Committed. Esse OBC controla a evolução das jornadas seguintes: Iteration Backlog → Iteration Plan → Delivery.

## Quando usar o modo Downstream

- Item aprovado no Iteration Plan
- Implementar OBC + BDD Feature existente
- Entregar feature com compromisso formal
- Executar item do Reliability Plan

## Três momentos de transição

O Downstream possui três momentos explícitos, cada um com condições de entrada verificáveis:

### Momento 1 — CommitmentGate → Downstream Declared

O compromisso foi assumido. O CommitmentGate com outcome **Promover** é o único evento que abre o Downstream.

**Condições de entrada obrigatórias para o CommitmentGate emitir Promover:**
1. Hipótese respondida com Evidence Threshold satisfeito (se declarado)
2. Decision Package com substância real — legível por membro do trio que não participou do experimento
3. OBC Draft existente como arquivo (ao menos o arquivo com nome e referência ao experimento)
4. BDD draft legível — rascunho dos cenários de comportamento esperado

**Estado resultante:** `Downstream Declared` — item entra no Icebox para refinamento.

---

### Momento 2 — Promoção de artefatos + entrada no Icebox

Ocorre logo após o CommitmentGate. São ações distintas do Momento 1:
- OBC transita `Draft → Refining`
- Work Item criado no Icebox referenciando o experimento e o OBC
- upstream-trail do experimento atualizado com registro da promoção

---

### Momento 3 — Readiness Gate → Downstream Ready

**Condições obrigatórias antes de iniciar qualquer fase de Delivery:**
1. OBC em `prodops/artifacts/obcs/` com estado **Committed**
2. BDD Feature em `prodops/artifacts/bdd/`
3. Riscos documentados em `prodops/artifacts/risks/risks.md`
4. Entrada no Iteration Plan com status `Entrou` em `prodops/artifacts/plans/iteration-plan.md`
5. Reliability Plan quando houver movimentação financeira, integração externa, mudança de SLO, risco alto/crítico ou alteração de persistência ou segurança

**Estado resultante:** `Downstream Ready` → `Delivery Started` (após Bootstrap.Started).

Quando faltar um requisito obrigatório, o Downstream para antes da Delivery, indica o responsável e orienta a próxima ação.

## Sequência obrigatória

```
Bootstrap → Hack → Sync → Finish → Ship → Validate → Promote
```

O trabalho é dividido em dois ciclos:

```
CI Sync: Bootstrap → Hack → Sync → Finish     (trabalho local, síncrono)
CI Async: Ship → Validate → Promote            (plataforma, pipelines, ambientes)
```

## Fases

| Fase | Descrição | Link |
|---|---|---|
| Bootstrap | Dependências + infraestrutura local + configuração + smoke gate | [../journeys/delivery/phases/bootstrap/README.md](../journeys/delivery/phases/bootstrap/README.md) |
| Hack | Implementação via ProdOps TDD | [../journeys/delivery/phases/hack/README.md](../journeys/delivery/phases/hack/README.md) |
| Sync | Branch sync (rebase) + alinhamento de artefatos (align) | [../journeys/delivery/phases/sync/README.md](../journeys/delivery/phases/sync/README.md) |
| Finish | Quality Gates + PR | [../journeys/delivery/phases/finish/README.md](../journeys/delivery/phases/finish/README.md) |
| Ship | Preparation + Deployment | [../journeys/delivery/phases/ship/README.md](../journeys/delivery/phases/ship/README.md) |
| Validate | Runtime + observabilidade + SLO | [../journeys/delivery/phases/validate/README.md](../journeys/delivery/phases/validate/README.md) |
| Promote | Aprovação formal + Release Trail | [../journeys/delivery/phases/promote/README.md](../journeys/delivery/phases/promote/README.md) |

## Evidências

Registrar evidências significativas de entrega no trail da sessão ativa em `prodops/artifacts/trails/sessions/YYYY-MM-DD-<session-id>.md`.

## Downstream Direto (sem Upstream prévio)

Um Business Signal pode entrar diretamente em Downstream sem passar por exploração Upstream quando:

- A demanda é confirmada por canais independentes (sem necessidade de experimento)
- O escopo está delimitado com clareza suficiente para comprometer
- As questões abertas são classificadas como **refinamento** — não bloqueiam o início, são resolvidas no Icebox
- A incerteza remanescente é aceitável com o compromisso sendo assumido explicitamente

**Esta é uma calibração correta de modo** — não ausência de discovery. O discovery acontece dentro do compromisso, na jornada Discovery rodando em modo Downstream com rigor bloqueante e Readiness Gate antes da Delivery.

O PM deve documentar explicitamente a justificativa para entrada direta em Downstream (ex: "clareza suficiente sobre o que construir; prazo não permite exploração Upstream"). Questões abertas classificadas como refinamento devem ser listadas e marcadas como não bloqueantes.

---

## Anti-padrões do Downstream

| ID | Nome | Descrição |
|----|------|-----------|
| **AP-D1** | Gate Theater | Gates executados formalmente sem que os artefatos satisfaçam os critérios. O ritual existe; a substância, não. |
| **AP-D2** | Proxy Commitment | OBC marcado como Committed sem critérios de sucesso mensuráveis. O compromisso é nomeado, mas não é verificável. |
| **AP-D3** | Forced Readiness | Readiness Gate aprovado com lacunas conhecidas por pressão de prazo. Diferente do Waiver (que é explícito e registrado), o Forced Readiness é silencioso. |
| **AP-D4** | Phantom BDD | BDD Feature escrito após o código, descrevendo o que foi implementado em vez do comportamento esperado. O teste passa porque o código já existe — não porque o comportamento foi especificado. |
| **AP-D5** | Release Trail Vazio | Promote executado sem Release Trail preenchido. O compromisso foi honrado, mas não é verificável por quem não participou. |

**Distinção AP-D3 vs. Waiver:** um Waiver é o reconhecimento *explícito e registrado* de que um critério não está satisfeito, com justificativa e compromisso de resolução dentro de prazo definido. AP-D3 é o avanço *silencioso* sem que o gap seja reconhecido. O Waiver é governança; AP-D3 é evasão de governança.

---

## Protocolo de Regressão Downstream → Upstream

Triggered quando uma hipótese é invalidada durante a Delivery — o que foi comprometido não pode ser honrado como comprometido.

**Esta é uma suspensão formal de compromisso** — não um retorno a uma etapa anterior. A sequência obrigatória:

1. **Registrar no Release Trail:** entrada documentando o motivo da suspensão, a hipótese invalidada e a decisão de regressão
2. **Abrir novo experimento Upstream:** referenciando o OBC original e o Downstream suspenso; o experimento investiga o que invalidou a hipótese
3. **Transitar o OBC:** `Committed → Refining` (a transição é registrada no OBC com data e justificativa)
4. **Atualizar o Work Item:** status volta para Icebox; Downstream Declared permanece registrado como histórico

O time e a liderança devem ser notificados. A regressão não é falha de processo — é o protocolo correto quando a evidência muda durante a execução.

---

## O Downstream deve preservar

Rastreabilidade desde o estado atual e o assessment até a implementação, validação e promoção.


---

→ **Próximo:** [Jornada Discovery](../journeys/discovery/README.md)
