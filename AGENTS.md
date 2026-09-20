# ProdOps Framework — Guia do Agente

> **Este repositório é o framework canônico** (`produtoreativo/prodops-framework`).
> As mudanças chegam via PR de export do upstream empírico (`payments-api`).
> Não edite scripts canônicos diretamente aqui — as mudanças pertencem ao upstream.

---

## ⚠️ REGRA CRÍTICA — VERSÃO DO RUNTIME ACOMPANHA O FRAMEWORK

**Toda vez que o número de versão do framework for incrementado, os seguintes
arquivos DEVEM ser atualizados para o mesmo valor — sem exceção:**

| Arquivo | Campo a atualizar |
|---|---|
| `prodops/scripts/setup-wsl.sh` | `PRODOPS_VERSION="vX.Y.Z"` |
| `prodops/scripts/setup-mac.sh` | `PRODOPS_VERSION="vX.Y.Z"` |
| `prodops/runtime/runtime.yaml.example` | `framework-version: "vX.Y.Z"` |
| `CHANGELOG.md` | entrada para a nova versão |

O gate `prodops/scripts/validate-export-manifest.sh` falha automaticamente se
`PRODOPS_VERSION` em qualquer script divergir da versão em `framework-lock.yaml`.

> **Nota:** `framework-lock.yaml` é gerado pelo processo de export a partir de `payments-api`
> e **não faz parte do estado commitado deste repositório**. A ausência do arquivo na árvore
> de trabalho é comportamento esperado — não é uma inconsistência. O gate só é executado
> durante o fluxo de export, quando o arquivo existe.

**Cheque estes arquivos antes de aprovar qualquer PR de export.**

---

## Regra de classificação de modo para agentes

Ao trabalhar neste repositório, o agente deve inferir o modo correto a partir do estado dos artefatos — não de labels subjetivos:

| Estado do OBC | Modo inferido |
|---|---|
| CommitmentGate registrado com outcome Promover ou Promover com restrição (OBC em Refining ou Readiness) | **Downstream** |
| Sem CommitmentGate registrado (OBC em Draft) | **Upstream** |
| OBC ausente | Pré-Business Intent ou Finding de Diligence — não é classificação de modo válida |

**Dois modos de falha de agente a evitar:**

- **Rigor máximo indiscriminado:** tratar tudo como Downstream, aplicar Gates onde não cabem, bloquear exploração ao exigir OBC Readiness durante hipótese. Sintoma: agente pergunta "onde está o OBC Committed?" durante um experimento Upstream.
- **Permissividade total:** tratar tudo como Upstream, avançar sem Gates, implementar sem verificar se OBC está em Readiness ou se BDD existe. Sintoma: agente executa Bootstrap sem verificar as 5 pré-condições do Downstream Ready.

Quando o modo for ambíguo, o agente deve perguntar ao usuário — não assumir.

---

## Protocolo de review de PR de export

Todo PR de export vem de `payments-api` via `export-framework.sh`. Ao revisar:

1. Confirmar que `PRODOPS_VERSION` em `setup-wsl.sh` = versão do PR
2. Confirmar que `PRODOPS_VERSION` em `setup-mac.sh` = versão do PR
3. Confirmar que `CHANGELOG.md` tem entrada para a versão exportada
4. Confirmar que nenhum arquivo product-specific vazou:
   - `prodops/artifacts/**` → nunca deve aparecer
   - `prodops/exec/**` → nunca deve aparecer
5. Aprovar e fazer merge

---

## Estrutura do repositório

```
prodops-framework/
  prodops/
    framework/     ← documentação canônica do framework
    skills/        ← skills canônicas (bootstrap, hack, sync, finish, ship...)
    templates/     ← templates canônicos
    scripts/       ← scripts de instalação e validação
    runtime/       ← Reference Implementation (RI) do runtime
  AGENTS.md        ← este arquivo (gerenciado pelo upstream via export)
  CLAUDE.md        ← instrução para Claude Code (gerenciado via export)
  CHANGELOG.md     ← histórico de versões
  consumers.yaml   ← registry de consumidores para propagação de CI
```

---

## O que pode ser editado diretamente neste repo

- `consumers.yaml` — registrar/remover consumidores do framework
- `CHANGELOG.md` — notas editoriais após um merge de export (raramente)
- `README.md`, `README.en.md` — documentação geral do framework

**Nunca editar diretamente:** `prodops/scripts/*.sh`, `prodops/skills/**`,
`prodops/framework/**`, `prodops/runtime/**`. Essas mudanças pertencem ao
upstream empírico (`payments-api`) e chegam aqui via export.
