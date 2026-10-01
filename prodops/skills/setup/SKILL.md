---
name: setup
description: Configura um repositório recém-instalado com o ProdOps — preenche placeholders do runtime.yaml, provisiona labels canônicos, cria o GitHub Project e prepara o .env. Idempotente — executa apenas os passos pendentes. Deve ser o primeiro skill invocado em qualquer repo novo.
---

# Setup Skill

Orquestra o setup completo de um repositório após a instalação do ProdOps.
Detecta o que ainda está em estado virgem e executa apenas esses passos —
nunca sobrescreve configuração já existente.

**Execute `/setup` antes de qualquer outro skill** em um repo recém-instalado.

---

## Quando Usar

- Imediatamente após `install-prodops.sh` em um repo novo
- Quando qualquer valor de `runtime.yaml` ainda é placeholder (`YOUR_*` ou `project-number: 0`)
- Para diagnosticar o que falta configurar em um repo já existente

**Invocação:** `/setup`

---

## Leitura Obrigatória

1. `prodops/runtime/runtime.yaml` — estado atual de configuração
2. `prodops/framework/github-workspace.md` — lista canônica de labels e campos

---

## Momento 1 — Diagnóstico de Estado

Ler `prodops/runtime/runtime.yaml` e classificar cada campo:

| Campo | Pendente se... |
|---|---|
| `github.owner` | valor é `YOUR_ORG` |
| `github.repository` | valor é `YOUR_REPO` |
| `cloud-events.source` | contém `YOUR_ORG` ou `YOUR_REPO` |
| `github.project-number` | valor é `0` |
| `datadog.service` | valor é `YOUR_SERVICE` |

Verificar também:
- 38 labels canônicos presentes no repo (`gh label list`)
- `.env` presente e no `.gitignore`

Reportar o diagnóstico completo antes de executar qualquer passo.
Se nenhum campo estiver pendente: reportar "Setup já concluído" e encerrar.

---

## Momento 2 — Preencher runtime.yaml

Para cada campo pendente identificado no M1:

**`owner` e `repository`:**
```bash
git remote get-url origin
# https://github.com/ORG/REPO.git  →  owner=ORG, repository=REPO
# git@github.com:ORG/REPO.git      →  owner=ORG, repository=REPO
```

**`cloud-events.source`:**
```
https://github.com/<owner>/<repository>
```

**`datadog.service`:**
Usar `<repository>` como valor default. O operador pode sobrescrever depois.

**`project-number`:**
Não alterar aqui — será preenchido pelo `/provision` no Momento 4.

Atualizar o arquivo `prodops/runtime/runtime.yaml` com os valores inferidos.
Não commitar ainda — o commit único ocorre no Momento 4 após o project-number ser preenchido.

---

## Momento 3 — Provisionar Labels Canônicos

Criar os 38 labels canônicos via `gh label create`. Idempotente — pular labels
já existentes sem erro.

**Família `operation` — cor `#0075ca`:**
`operation:capture`, `operation:create`, `operation:define`, `operation:refine`,
`operation:update`, `operation:prototype`, `operation:review`, `operation:approve`,
`operation:validate`, `operation:split`, `operation:merge`, `operation:promote`,
`operation:implement`, `operation:experiment`, `operation:release`,
`operation:archive`, `operation:deprecate`, `operation:discard`,
`operation:cancel`, `operation:provision`

**Família `artifact-type` — cor `#e4e669`:**
`artifact-type:business-signal`, `artifact-type:business-intent`,
`artifact-type:global-obc`, `artifact-type:local-obc`, `artifact-type:bdd-feature`,
`artifact-type:architecture`, `artifact-type:iteration-plan`,
`artifact-type:reliability-plan`, `artifact-type:release-trail`,
`artifact-type:experiment`, `artifact-type:evidence`,
`artifact-type:risk-register`, `artifact-type:context-capsule`

**Família `journey` — cor `#d93f0b`:**
`journey:discovery`, `journey:assessment`, `journey:delivery`,
`journey:operation`, `journey:diligence`

```bash
# Padrão de criação (idempotente):
gh label create "operation:capture" \
  --repo <owner>/<repository> \
  --color "0075ca" \
  --description "ProdOps operation: capture" 2>/dev/null || true
```

Repetir para todos os 38 labels. Confirmar contagem ao final.

---

## Momento 4 — Executar `/provision`

Verificar se `project-number` ainda é `0`. Se sim, invocar o skill `/provision`:

1. Localizar `ProdOps — template` via `gh project list --owner <owner>`
2. `gh project copy <template-number> --source-owner <owner> --target-owner <owner> --title "ProdOps — <repository>"`
3. `gh project edit <number> --owner <owner> --visibility PUBLIC`
4. Vincular ao repositório via GraphQL `linkProjectV2ToRepository`
5. Atualizar `project-number` no `runtime.yaml`

Se `project-number` ≠ 0: pular este momento — projeto já provisionado.

Após o projeto ser provisionado (ou confirmado existente): realizar o **commit único**
de todas as mudanças do `runtime.yaml` acumuladas nos Momentos 2 e 4:

```
chore(prodops): setup inicial — runtime.yaml + GitHub Project
```

---

## Momento 5 — Configurar .env

1. Verificar se `.env` existe no root do repositório
2. Se não existe e `.env.example` existe: copiar `.env.example` → `.env`
3. Se `.env.example` não existe: criar `.env` vazio com comentário de instrução
4. Verificar se `.env` está no `.gitignore` — se não: adicionar e commitar separado
5. Reportar quais variáveis `DD_*` ainda têm valores placeholder ou vazios

Nunca commitar `.env`. Nunca logar seu conteúdo.

---

## Momento 6 — Validar

Executar checklist de conformidade final:

| Item | Verificação |
|---|---|
| `runtime.yaml` sem `YOUR_*` | `grep -c YOUR_ prodops/runtime/runtime.yaml` == 0 |
| `project-number` ≠ 0 | leitura do campo |
| 38 labels presentes | `gh label list --limit 60 \| grep -cE "^(operation\|artifact-type\|journey):"` == 38 |
| `.env` presente | `test -f .env` |
| `.env` no `.gitignore` | `grep -q "^\.env" .gitignore` |
| GitHub Project linked | consulta GraphQL `ProjectV2.repositories` |

Reportar resultado:

```
Setup — COMPLETO
```

ou

```
Setup — PARCIAL
Pendências:
  - <item>: <motivo>
  - ...
Ação: corrigir manualmente ou re-executar /setup
```

---

## Guardrails

- **Nunca sobrescrever** valores já configurados (não-placeholder) em `runtime.yaml`
- **Nunca commitar `.env`** — verificar `.gitignore` antes de qualquer `git add`
- **Nunca inventar** `owner` ou `repository` — inferir exclusivamente do remote origin
- **Nunca pular** o Momento 6 — o setup só é considerado concluído após validação
- **Nunca executar `/provision`** se `project-number` ≠ 0

---

## Referências

→ [github-workspace.md](../../framework/github-workspace.md) — lista canônica de labels
→ [/provision](../provision/SKILL.md) — sub-passo do Momento 4
→ [runtime.yaml](../../runtime/runtime.yaml) — arquivo configurado por este skill
→ [install-prodops.sh](../../scripts/install-prodops.sh) — script de instalação que precede este skill
