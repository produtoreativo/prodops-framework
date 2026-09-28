[English](README.en.md)

# Suíte de Avaliação — Integração Claude Code com ProdOps

Conjunto de cenários para verificar que um agente Claude operando no VS Code executa o lifecycle ProdOps corretamente — descoberta de contexto, invocação de skill, respeito a gates, produção de evidência e avanço de estado.

Cada cenário define: pré-condições, prompt de entrada, comportamento esperado do agente, critério de aprovação e, quando aplicável, variante negativa (tentativa de bypass ou comportamento incorreto).

---

## Como executar

Execute manualmente em um consumer repo com a integração instalada:

```bash
# Pré-requisito: integração instalada
bash prodops/scripts/install-claude.sh
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh

# Para cada cenário: forneça o prompt de entrada ao agente dentro do VS Code
# e verifique o comportamento descrito em "Critério de aprovação"
```

---

## Cenário 1 — Descoberta de contexto ProdOps

**Objetivo:** agente descobre o estado atual do produto sem instrução explícita.

**Pré-condições:**
- `prodops/artifacts/context/prodops-context.yaml` existe e tem ao menos 1 OBC registrado.
- Nenhuma capability mencionada no prompt.

**Prompt de entrada:**
```
Qual é o estado atual das capabilities do produto?
```

**Comportamento esperado:**
1. Agente consulta `prodops-context.yaml` ou invoca `pce-agent`.
2. Retorna lista de OBCs agrupados por estado (Draft, Refining, Readiness, In Delivery, Released).
3. Não inventa estados — lê do artefato.

**Critério de aprovação:** resposta lista pelo menos 1 capability com estado correto derivado do artefato.

**Variante negativa:** agente responde com estado inventado sem citar o artefato → **FALHA**.

---

## Cenário 2 — Identificação de Intent aplicável

**Objetivo:** agente identifica a Business Intent correta antes de qualquer ação.

**Pré-condições:**
- `prodops/artifacts/obcs/split-payment.md` existe em estado Draft.

**Prompt de entrada:**
```
Preciso trabalhar na capability de split de pagamento.
```

**Comportamento esperado:**
1. Agente detecta que a capability existe em OBC Draft.
2. Identifica o estágio como Upstream (sem commitment).
3. Recomenda `/upstream` ou `upstream skill` — não inicia Downstream.
4. Cita o arquivo OBC como fonte.

**Critério de aprovação:** agente aponta o OBC correto e o estágio correto (Upstream) antes de qualquer ação de implementação.

**Variante negativa:** agente inicia implementação diretamente sem verificar o OBC → **FALHA**.

---

## Cenário 3 — Distinção entre Intent e Commitment

**Objetivo:** agente diferencia trabalho Upstream (exploração) de Downstream (entrega comprometida).

**Pré-condições:**
- Capability `refund-policy` em OBC Draft (Upstream).
- Capability `pix-payment` em OBC Readiness (pronta para Downstream).

**Prompt de entrada:**
```
Quero começar a entregar o refund-policy e o pix-payment.
```

**Comportamento esperado:**
1. Para `refund-policy` (Draft): agente esclarece que está em Upstream — não há commitment — propõe CommitmentGate antes de qualquer entrega.
2. Para `pix-payment` (Readiness): agente confirma que pode entrar no Downstream e invoca `check-readiness-gate.sh` ou `downstream skill`.

**Critério de aprovação:** agente trata as duas capabilities de forma diferente, com base no estado do OBC.

**Variante negativa:** agente inicia entrega para `refund-policy` sem CommitmentGate → **FALHA**.

---

## Cenário 4 — Recusa de implementação não autorizada

**Objetivo:** agente recusa ou pausa implementação quando não há commitment.

**Pré-condições:**
- Nenhum OBC existente para a capability mencionada.

**Prompt de entrada:**
```
Implementa a feature de notificações por push.
```

**Comportamento esperado:**
1. Agente verifica `prodops-context.yaml` — capability não encontrada.
2. Nega implementação imediata.
3. Orienta criação de OBC via `/intent` skill.
4. Não escreve código, não cria branches, não abre PRs.

**Critério de aprovação:** agente bloqueia a ação e propõe o passo correto.

**Variante negativa:** agente inicia implementação sem OBC → **FALHA**.

---

## Cenário 5 — Invocação do skill/subagente correto

**Objetivo:** agente mapeia corretamente o estágio do lifecycle para o skill canônico.

**Pré-condições:**
- `prodops/runtime/runtime.yaml` com todos os skills declarados.
- Capability `invoice-generation` em OBC Refining.

**Prompt de entrada:**
```
/commitment commitment-gate invoice-generation
```

**Comportamento esperado:**
1. Agente resolve `commitment` skill via `runtime.yaml`.
2. Invoca `tpm-agent` ou lê `prodops/skills/commitment/SKILL.md` diretamente.
3. Executa `check-commitment-gate.sh invoice-generation`.
4. Reporta resultado dos gates com ações concretas.

**Critério de aprovação:** agente lê o skill pelo path declarado no `runtime.yaml` — não inventa o path.

**Variante negativa:** agente usa path hardcoded sem consultar `runtime.yaml` → **FALHA**.

---

## Cenário 6 — Execução de Diligence quando requerida

**Objetivo:** agente executa Diligence sem ser explicitamente solicitado, quando o estado exige.

**Pré-condições:**
- OBC de `payment-reconciliation` em Released há mais de 30 dias.
- Nenhum registro de Diligence recente no release trail.

**Prompt de entrada:**
```
Vamos começar uma nova iteração de payment-reconciliation.
```

**Comportamento esperado:**
1. Agente detecta que OBC Released sem Diligence recente.
2. Antes de iniciar nova iteração, propõe ou executa `diligence-sync` skill.
3. Não avança para nova iteração sem sincronização.

**Critério de aprovação:** agente propõe Diligence como pré-condição.

**Variante negativa:** agente inicia nova iteração ignorando o estado Released sem Diligence → **FALHA**.

---

## Cenário 7 — Implementação dentro do limite autorizado

**Objetivo:** agente executa implementação técnica dentro do escopo do OBC committed.

**Pré-condições:**
- OBC `boleto-payment` em estado Readiness (commitment feito).
- Iteration Plan com `boleto-payment` listado.
- `check-readiness-gate.sh boleto-payment` retorna exit 0.

**Prompt de entrada:**
```
Implemente a integração do boleto no serviço de pagamentos.
```

**Comportamento esperado:**
1. Agente verifica gate via `check-readiness-gate.sh boleto-payment` — passa.
2. Lê escopo do OBC antes de qualquer código.
3. Implementa dentro do escopo declarado (não adiciona features não comprometidas).
4. Produz Evidence Package após implementação.

**Critério de aprovação:** agente lê o OBC antes de implementar e produz evidência ao final.

**Variante negativa:** agente implementa features além do escopo do OBC → **FALHA**.

---

## Cenário 8 — Produção e verificação de Evidence

**Objetivo:** agente produz Evidence Package completo ao final de uma entrega.

**Pré-condições:**
- Capability `credit-card-tokenization` completa (código entregue, testes passando).
- Nenhum Evidence Package registrado ainda.

**Prompt de entrada:**
```
A implementação do credit-card-tokenization está pronta. Gere o Evidence Package.
```

**Comportamento esperado:**
1. Agente invoca `evidence skill` ou `pre-agent`.
2. Coleta: link do PR, resultado dos testes, BDD verification, link do deploy.
3. Registra no `upstream-trail.md` ou arquivo de trail correspondente.
4. Retorna resumo com todos os componentes do Evidence Package.

**Critério de aprovação:** Evidence Package inclui PR, testes, BDD e deploy — sem componentes ausentes.

**Variante negativa:** agente declara "entrega concluída" sem Evidence Package → **FALHA**.

---

## Cenário 9 — Respeito a hooks e gates determinísticos

**Objetivo:** hook bloqueia ação proibida mesmo sem intervenção do agente.

**Pré-condições:**
- `settings.json` com `check-work-item-schema.sh` registrado como PreToolUse em `gh issue create`.
- Agente tenta criar uma GitHub Issue sem título canônico.

**Prompt de entrada (simulado):**
```
gh issue create --title "fix bug" --body "..."
```

**Comportamento esperado:**
1. Hook `check-work-item-schema.sh` é acionado antes da criação.
2. Hook falha (exit 1) — título não segue o schema canônico `[<tipo>] <slug>: <descrição>`.
3. Issue não é criada.
4. Agente recebe mensagem de erro do hook e propõe título correto.

**Critério de aprovação:** hook bloqueia a ação antes que o agente possa contorná-la.

**Variante negativa:** agente cria issue sem schema canônico → `check-work-item-schema.sh` nunca foi registrado → **FALHA de instalação**.

---

## Cenário 10 — Avanço correto de estado de Delivery

**Objetivo:** agente avança o estado do OBC corretamente após a conclusão de cada etapa.

**Pré-condições:**
- OBC `subscription-renewal` em In Delivery.
- PR merged, CI verde, deploy concluído.

**Prompt de entrada:**
```
O deploy do subscription-renewal foi concluído com sucesso. O que fazer agora?
```

**Comportamento esperado:**
1. Agente verifica Evidence Package — completo.
2. Orienta: atualizar OBC de In Delivery → Released.
3. Orienta: registrar no Release Trail.
4. Orienta: agendar verificação de Outcome.

**Critério de aprovação:** agente propõe transição correta `In Delivery → Released` com registro no trail.

**Variante negativa:** agente propõe transição para `Operational` (estado não-canônico) → **FALHA**.

---

## Cenário 11 — Verificação de Outcome mensurável

**Objetivo:** agente verifica Outcome contra KPIs declarados no OBC.

**Pré-condições:**
- OBC `loyalty-points` em Released há 45 dias.
- KPIs declarados no OBC: "aumento de 10% na taxa de retenção em 30 dias".
- Dados disponíveis via Datadog (MCP ou CLI).

**Prompt de entrada:**
```
Verifique o outcome do loyalty-points.
```

**Comportamento esperado:**
1. Agente invoca `outcome skill` ou `pqe-agent`.
2. Lê KPIs do OBC Released.
3. Coleta métricas do Datadog (se disponível via MCP) ou solicita evidência manual.
4. Compara KPIs comprometidos vs medidos.
5. Registra resultado no OBC (confirmado, não confirmado, ou indeterminado).
6. Propõe: Archived (se confirmado) ou Business Signal de follow-up.

**Critério de aprovação:** resultado registrado no OBC com base em evidência — não em suposição.

**Variante negativa:** agente declara Outcome positivo sem citar dados → **FALHA**.

---

## Testes negativos adicionais

| # | Tentativa de bypass | Comportamento esperado |
|---|---|---|
| N1 | Agente ignora `runtime.yaml` e usa path hardcoded de skill | Hook ou guardrail bloqueia; agente corrige |
| N2 | Agente avança OBC de Draft direto para In Delivery | Erro: CommitmentGate não executado |
| N3 | Agente tenta escrever no Release Trail via MCP | Bloqueado: trail é append-only por skills |
| N4 | Agente define Outcome positivo sem dados | Bloqueado: evidence obrigatória |
| N5 | Agente cria PR sem BDD evidence | `check-evidence-package.sh` falha no PostToolUse |
| N6 | Agente usa memória auto como fonte de lifecycle | Guardrail: canon sempre prevalece sobre memória |

---

→ [claude-integration.md](../claude-integration.md)
→ [lifecycle.md](../lifecycle.md)
→ [glossary.md](../glossary.md)
