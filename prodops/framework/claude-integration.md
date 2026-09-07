# Claude Code Integration — Arquitetura ProdOps

Este documento descreve a arquitetura completa da integração Claude Code com o ProdOps Framework — como agentes, skills, hooks, regras e a camada de contexto se articulam para cobrir o lifecycle canônico.

→ Para o lifecycle canônico, ver [`lifecycle.md`](lifecycle.md).
→ Para as skills, ver [`prodops/skills/README.md`](../skills/README.md).
→ Para os agentes, ver [`prodops/agents/`](../agents/).

---

## Visão geral

```
Consumer Repo
├── CLAUDE.md                          ← instrução principal (Wave 3)
├── .claude/
│   ├── agents/                        ← agentes materializados (Wave 2)
│   │   ├── pce-agent.md
│   │   ├── tpm-agent.md
│   │   ├── pre-agent.md
│   │   ├── pqe-agent.md
│   │   ├── downstream-agent.md
│   │   └── diligence-agent.md
│   ├── rules/                         ← regras de lifecycle (Wave 3)
│   │   ├── prodops-lifecycle.md
│   │   ├── prodops-skills.md
│   │   └── prodops-guardrails.md
│   ├── hooks/                         ← gate validators (Wave 4)
│   │   ├── check-commitment-gate.sh
│   │   ├── check-readiness-gate.sh
│   │   ├── check-evidence-package.sh
│   │   └── check-work-item-schema.sh
│   └── settings.json                  ← permissões + hooks registrados
├── prodops/
│   ├── skills/                        ← skills canônicos (Wave 1)
│   │   ├── intent/
│   │   ├── commitment/
│   │   ├── product-context/
│   │   ├── evidence/
│   │   ├── outcome/
│   │   ├── upstream/
│   │   ├── downstream/
│   │   └── diligence/
│   ├── agents/                        ← fonte dos agentes
│   ├── runtime/
│   │   ├── runtime.yaml               ← registro canônico de skill paths
│   │   └── tools/
│   │       └── derive-context/        ← gerador de contexto (Wave 5)
│   └── artifacts/
│       └── context/
│           └── prodops-context.yaml   ← snapshot do lifecycle state (Wave 5)
```

---

## Camadas da integração

### Camada 1 — Skills (Wave 1)

Skills são regras de execução autoritativas para cada ação no lifecycle. Cada skill é autossuficiente: define quando usar, leitura obrigatória, fluxo de execução, saídas e guardrails.

| Skill | Estágio do lifecycle | Invocação |
|---|---|---|
| `intent` | Business Signal → Product Intent | `/intent` |
| `commitment` | CommitmentGate + Readiness Gate | `/commitment` |
| `product-context` | Leitura de estado atual | `/product-context` |
| `upstream` | Qualquer trabalho no modo Upstream (sem compromisso de entrega) | `/upstream` |
| `downstream` | Ciclo comprometido de entrega no modo Downstream (CI Sync + CI Async) | `/downstream` |
| `evidence` | Evidence (Upstream + Downstream) | `/evidence` |
| `outcome` | Business + Product Outcome | `/outcome` |
| `diligence` | Sincronização transversal | `/diligence` |

**Regra de resolução:** todos os paths de skills estão declarados em `prodops/runtime/runtime.yaml` (seção `skills:`). Leia o runtime.yaml antes de invocar qualquer skill.

---

### Camada 2 — Agentes (Wave 2)

Agentes são orchestrators que leem skills e executam seu fluxo. Cada agente é especializado em um domínio do lifecycle.

| Agente | Skill base | Responsabilidade |
|---|---|---|
| `pce-agent` | `product-context` | Leitura e consolidação de estado de capability |
| `tpm-agent` | `commitment` | CommitmentGate + Readiness Gate |
| `pre-agent` | `evidence` | Evidence Package + Release Trail |
| `pqe-agent` | `outcome` | Business Outcome + Product Outcome |
| `downstream-agent` | `downstream` | CI Sync + CI Async completo |
| `diligence-agent` | `diligence` | Sincronização de OBC e workspace |

**Materialização:** os agentes em `prodops/agents/` são copiados para `.claude/agents/` pelo script `materialize-agents.sh` (ou por `install-claude.sh`).

---

### Camada 3 — Adapter `.claude/` (Wave 3)

O adaptador `.claude/` é o ponto de entrada do Claude Code no consumer repo.

**`CLAUDE.md`** — instrução principal:
- Tabela de entrypoints por ação (qual skill ou agente usar)
- Regra de resolução via `runtime.yaml`
- Mapeamento do lifecycle
- Restrição de modificação de artefatos canônicos

**`.claude/rules/`** — regras de lifecycle carregadas automaticamente:
- `prodops-lifecycle.md` — 5 regras de modo, CommitmentGate, Evidence, Outcome
- `prodops-skills.md` — resolução de skills e mapeamento estágio→skill
- `prodops-guardrails.md` — guardrails transversais (artefatos, gates, Work Items, código)

---

### Camada 4 — Hooks (Wave 4)

Scripts de validação executados antes de ações críticas.

| Hook | Trigger | Validação |
|---|---|---|
| `check-commitment-gate.sh` | Antes do CommitmentGate | Decision Package, OBC Draft, BDD draft |
| `check-readiness-gate.sh` | Antes do Downstream | 5 gates de prontidão |
| `check-evidence-package.sh` | Antes do CommitmentGate | Evidence Package completo |
| `check-work-item-schema.sh` | PreToolUse em `gh issue create` | Título canônico, labels obrigatórios |

O `check-work-item-schema.sh` é registrado no `settings.json` como hook PreToolUse automático para toda invocação de `gh issue create`.

---

### Camada 5 — Context Layer (Wave 5)

`derive-context.sh` gera `prodops/artifacts/context/prodops-context.yaml` — snapshot machine-readable do estado atual do produto.

**Conteúdo:**
- OBCs por estado (Draft, Refining, Committed, In Delivery, Released)
- Experimentos Upstream ativos
- Capabilities na iteração ativa

**Uso:**
- `pce-agent` e `product-context` skill consomem o arquivo para responder rapidamente sem ler todos os artefatos
- CI pode re-gerar automaticamente após mudanças em OBCs ou experimentos

---

## Fluxo de decisão de agente

Quando um agente precisa agir sobre uma capability:

```
1. Verificar prodops-context.yaml (se disponível) para o estágio atual
   ↓ se incerto
2. Invocar pce-agent (ou product-context skill) para determinar estágio
   ↓
3. Mapear estágio → skill canônica
   ↓
4. Executar hook de gate (quando aplicável) antes da ação
   ↓
5. Ler skill via runtime.yaml e executar seu fluxo
   ↓
6. Produzir artefato e atualizar evidência
```

---

## Instalação em consumer repos

```bash
# 1. Instalar o ProdOps Framework
bash prodops/scripts/install-prodops.sh

# 2. Instalar a integração Claude Code
bash prodops/scripts/install-claude.sh

# 3. Gerar o contexto inicial
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh

# 4. Verificar
bash prodops/scripts/doctor.sh
```

O `install-claude.sh` cria:
- `.claude/agents/` — agentes materializados
- `.claude/rules/` — regras canônicas de lifecycle
- `.claude/hooks/` — scripts de validação
- `.claude/settings.json` — permissões e hooks registrados

---

## Cenários de avaliação

### Cenário 1 — Formalização de intenção

```
Usuário: "Recebemos feedback que clientes querem split de pagamento"
→ Agente: Qual estágio? → pce-agent: não registrado → recomenda /intent
→ intent skill: registra Business Signal → Business Intent → OBC Draft
→ Saída: OBC Draft em prodops/artifacts/obcs/split-payment.md
```

### Cenário 2 — CommitmentGate após experimento

```
Usuário: "/commitment commitment-gate 042-split-payment"
→ tpm-agent: verifica pré-condições via check-commitment-gate.sh
→ Decision Package OK, OBC Draft OK, BDD draft OK
→ Registra outcome "Promover" no upstream-trail.md
→ Move OBC e BDD para paths committed
→ Atualiza Iteration Plan
```

### Cenário 3 — Verificação de Outcome

```
Usuário: "Verificar outcome do split-payment (Released há 30 dias)"
→ pce-agent: OBC em Released → estágio Outcome
→ pqe-agent: lê KPIs do OBC, coleta dados do Datadog
→ Compara KPIs comprometidos vs medidos
→ Registra resultado no OBC Released
→ Recomenda: Archived (se confirmado) ou follow-up Business Signal
```

### Cenário 4 — Context Discovery bloqueado

```
Usuário: "/downstream DS-42"
→ downstream-agent: verifica Readiness Gate via check-readiness-gate.sh
→ Gate 1 falha: OBC não está em estado Committed
→ Para com: lista de gates faltando + ação concreta necessária
→ Não inicia Bootstrap
```

---

## Referências

→ [Lifecycle](lifecycle.md)
→ [Glossário](glossary.md)
→ [Skills README](../skills/README.md)
→ [install-claude.sh](../scripts/install-claude.sh)
→ [derive-context.sh](../runtime/tools/derive-context/scripts/derive-context.sh)
→ [Work Item Schema](execution-mapping/work-item-schema.md)
