[English](mcp-boundaries.en.md)

# Fronteiras MCP — ProdOps Framework

Define o que é responsabilidade de MCP (Model Context Protocol) versus artefatos do repositório versus definições canônicas do framework. A separação é necessária para que o canon não dependa de disponibilidade de sistemas externos.

---

## Princípio fundamental

> **MCP expõe estado atual e ferramentas. Nunca define conceitos canônicos.**

Definições de lifecycle, termos do glossário, regras de governança e estrutura de artefatos residem exclusivamente em `prodops/framework/` e `prodops/skills/`. MCP acessa estado operacional externo — nunca é a fonte de verdade sobre o que o framework *significa*.

---

## Matriz de fronteiras

| Informação | Fonte canônica | MCP tool | Observação |
|---|---|---|---|
| Definição de OBC, CommitmentGate, lifecycle | `prodops/framework/` | ❌ Nunca via MCP | Canon imutável; MCP pode estar indisponível |
| Estado atual de um OBC (Draft/Refining/etc.) | `prodops/artifacts/obcs/<slug>.md` | ❌ Lido localmente | Arquivo Markdown é fonte de verdade |
| GitHub Issues — estado, labels, assignees | `gh issue view` (Bash) ou MCP GitHub | ✅ Estado externo | Complementa artefatos; não os substitui |
| PRs — status, checks, review | MCP GitHub / `gh pr view` | ✅ Estado externo | CI/CD state não vive em artefatos |
| Métricas de observabilidade (DORA, SLOs) | MCP Datadog / observabilidade | ✅ Estado externo | Leitura; nunca escrita via MCP |
| Runtime events / Observable Events | MCP runtime ou `prodops/runtime/` | ✅ Estado externo | Emissão via skills, não via MCP direto |
| Iteration Plan atual | `prodops/artifacts/plans/iteration-plan.md` | ❌ Lido localmente | Arquivo Markdown é fonte de verdade |
| Release Trail | `prodops/artifacts/trails/` | ❌ Append-only localmente | Nunca delegar escrita a MCP |
| AWS / infraestrutura / lambdas / queues | MCP AWS ou CLI | ✅ Estado externo | Leitura de estado; provisionamento requer gate |
| Secrets / credenciais | Vault / AWS Secrets Manager via MCP | ✅ Com restrição | Nunca em artefatos; nunca em memória de agente |

---

## Regras de uso

### MCP pode ser usado para

1. **Ler estado externo** que não existe em artefatos locais (GitHub, CI/CD, observabilidade, cloud).
2. **Emitir eventos** quando a skill correspondente instrui explicitamente (`prodops-emit-event`).
3. **Consultar métricas** para verificação de Outcome (DORA, SLOs, alerts).
4. **Resolver dependências externas** declaradas em riscos ou Reliability Plan.

### MCP nunca deve ser usado para

1. **Substituir leitura de artefatos canônicos** — nunca use MCP para "descobrir" o estado de um OBC ou de uma iteração; leia o arquivo Markdown.
2. **Definir o que um conceito significa** — se o MCP retorna um valor diferente do canonical, o canonical prevalece.
3. **Escrever Release Trail ou upstream-trail** — esses são append-only por skills, não por ferramentas externas.
4. **Contornar gates** — nunca use disponibilidade de MCP como critério de bypass de gate.

---

## Integrações avaliadas

### GitHub (MCP ou `gh` CLI)

**Uso legítimo:** consultar estado de Issues, PRs, checks, labels, assignees, project boards.

**Limitação:** GitHub é a Canonical Operational Representation — reflexo do estado canônico em `prodops/artifacts/`. Se divergirem, o artefato Markdown prevalece. A Diligence é responsável por resolver divergências (skill `diligence-sync`).

### CI/CD

**Uso legítimo:** ler status de pipelines, resultados de testes, deploy gates.

**Limitação:** o resultado de um pipeline não substitui um gate canônico (Quality Gate, Readiness Gate). Pipeline verde é evidência, não gate.

### Datadog / Observabilidade

**Uso legítimo:** ler SLO atual, error rate, latência, alertas ativos para verificação de Outcome e Observable Events.

**Limitação:** métricas externas informam a verificação de Outcome; não definem os critérios de aceite (que estão no OBC e no Reliability Plan).

### AWS / Runtime

**Uso legítimo:** ler estado de lambdas, queues, bancos de dados para diagnóstico de Observable Events ou para Reliability Plan.

**Limitação:** provisionamento e mudanças de infraestrutura requerem gate explícito (Readiness Gate ou CommitmentGate para mudanças de SLO).

---

→ **Próximo:** [`claude-integration.md`](claude-integration.md)
→ **Referência:** [`automation-first.md`](automation-first.md), [`runtime/`](../runtime/)
