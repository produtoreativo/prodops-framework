---
name: provision
description: Provisiona o GitHub Workspace do produto a partir do estado virgem — cria o projeto gerenciado via cópia do template canônico, vincula ao repositório e registra o project-number no runtime.yaml. Executa apenas quando project-number = 0 no runtime.yaml.
---
<!-- MATERIALIZED FILE — DO NOT EDIT MANUALLY
     Source:    prodops/skills/provision/SKILL.md
     Player:    codex
     Generator: prodops/scripts/agents/materialize-skills.sh
     Generated: 2026-10-01T20:01:49Z
     To update: bash prodops/scripts/agents/materialize-skills.sh --skill provision
-->

# Provision Skill

Provisiona o GitHub Project do produto a partir do template canônico
(`ProdOps — template`), vincula ao repositório e registra o
`project-number` no `runtime.yaml`. Gate de entrada: `project-number: 0`.

**Não use este skill para atualizar um projeto já existente.** Se o
projeto existe mas está com drift, usar `workspace-reconciliation`.

---

## Quando Usar

- Primeiro setup do produto (virgin state: `project-number: 0`)
- Após exclusão deliberada do projeto para re-provisionamento

**Invocação:** `/provision`

---

## Leitura Obrigatória

1. `prodops/runtime/runtime.yaml` — confirmar `project-number: 0`, ler `owner` e `repository`
2. `prodops/framework/github-workspace.md` — campos canônicos e view canônica esperados

---

## Momento 1 — Verificar Estado Virgem

Ler `runtime.yaml`. Se `project-number` ≠ 0: parar e reportar o número
atual. O projeto já existe — usar `workspace-reconciliation` para
diagnosticar drift.

Se `project-number: 0`: prosseguir.

Registrar em memória: `owner`, `repository`.

---

## Momento 2 — Localizar Template Canônico

```bash
gh project list --owner <owner> --format json
```

Localizar o projeto cujo `title` é exatamente `ProdOps — template`.
Registrar o número do template.

Se não encontrado: parar. Reportar que o template canônico está ausente.
O template deve ser criado via `workspace-reconciliation reconcile` antes
de provisionar.

---

## Momento 3 — Criar Projeto Gerenciado

```bash
gh project copy <template-number> \
  --source-owner <owner> \
  --target-owner <owner> \
  --title "ProdOps — <repository>"
```

Após a cópia, confirmar que o novo projeto aparece na listagem com
`title: "ProdOps — <repository>"` e registrar seu `number` e `id`.

Tornar PUBLIC imediatamente após a cópia:

```bash
gh project edit <number> --owner <owner> --visibility PUBLIC
```

---

## Momento 4 — Vincular ao Repositório

`gh project copy` copia campos e views mas **não** vincula o projeto ao
repositório. Executar obrigatoriamente:

```bash
gh api graphql -f query='
  mutation {
    linkProjectV2ToRepository(input: {
      projectId: "<project-id>"
      repositoryId: "<repo-id>"
    }) { repository { nameWithOwner } }
  }'
```

Para obter o `repositoryId`:

```bash
gh repo view <owner>/<repository> --json id -q '.id'
```

Confirmar que `nameWithOwner` na resposta corresponde a `<owner>/<repository>`.

---

## Momento 5 — Registrar project-number no runtime.yaml

Atualizar `prodops/runtime/runtime.yaml`:

```yaml
github:
  owner: <owner>
  repository: <repository>
  project-number: <N>   # número real retornado pelo Momento 3
```

Commit:

```
chore(prodops): provisiona GitHub Project — <repository>
```

---

## Momento 6 — Validar

Verificar o estado final do projeto criado:

```bash
gh api graphql -f query='
query {
  node(id: "<project-id>") {
    ... on ProjectV2 {
      title number public
      fields(first: 30) { totalCount }
      views(first: 5) { totalCount nodes { name layout } }
    }
  }
}'
```

Critérios de sucesso:

| Item | Esperado |
|---|---|
| `title` | `ProdOps — <repository>` |
| `public` | `true` |
| `fields.totalCount` | 27 (13 built-in + 14 custom) |
| `views.totalCount` | 1 |
| view name | `01 — Delivery Timeline` |
| view layout | `BOARD_LAYOUT` |

Se qualquer critério falhar: reportar o desvio e não avançar para o commit.

---

## Known Platform Limitations

- **`group_by` em views:** não configurável via API (REST 404, GraphQL sem
  mutation). Configurar via UI se necessário.
- **DELETE de views via REST:** `DELETE /orgs/{org}/projectsV2/{N}/views/{V}`
  retorna 404. Usar GraphQL:
  `deleteProjectV2View(input: { viewId: "..." }) { __typename }`
- **`gh project copy` não vincula ao repositório:** executar sempre o
  Momento 4 após a cópia.
- **Visibilidade herdada do template:** `gh project copy` herda a
  visibilidade do source — verificar e corrigir com `gh project edit`
  após a cópia.

---

## Guardrails

- **Nunca executar** se `project-number` ≠ 0 — usar `workspace-reconciliation`.
- **Nunca criar o projeto sem o template canônico** — o template é pré-requisito.
- **Nunca commitar** o `project-number` sem validar o Momento 6.
- **Nunca modificar** o template canônico neste skill — use
  `workspace-reconciliation reconcile` para atualizar o template.

---

## Referências

→ [github-workspace.md](../../../prodops/framework/github-workspace.md) — spec canônica de campos e views
→ [runtime.yaml](../../../prodops/runtime/runtime.yaml) — onde project-number é registrado
→ [workspace-reconciliation](../diligence/workspace-reconciliation/SKILL.md) — para drift pós-provisionamento
