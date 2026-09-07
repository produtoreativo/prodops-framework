# derive-context

Ferramenta de derivação do lifecycle state do produto.

## Propósito

Gera `prodops/artifacts/context/prodops-context.yaml` — um snapshot machine-readable do estado atual de todas as capabilities do produto, organizado por estágio do lifecycle canônico.

O arquivo de contexto é consumido por:
- `pce-agent` — para obter visão rápida do estado sem ler todos os artefatos
- `product-context` skill — como complemento à leitura direta de OBCs
- Scripts de CI que precisam verificar o estado do produto

## Uso

```bash
# Gerar contexto com saída padrão
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh

# Gerar em path customizado
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh \
  --output prodops/artifacts/context/prodops-context.yaml

# Modo silencioso (apenas escreve o arquivo)
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh --quiet
```

## Saída

```yaml
# prodops-context.yaml
derived_at: "2026-09-07T12:00:00Z"
framework_version: "v2.1.0"
active_iteration: "v0.6.0"

obcs:
  draft:
    - new-payment-method
  refining:
    - invoice-boleto
  committed:
    - split-payment
  in_delivery:
    - create-invoice-boleto
  released:
    - pix-instant-payment

active_experiments:
  - slug: 042-provider-x-integration

iteration_capabilities:
  - create-invoice-boleto
  - split-payment
```

## Quando re-gerar

Execute após qualquer uma dessas ações:
- Mudança de estado de um OBC (Draft → Refining, etc.)
- Abertura ou fechamento de um experimento
- Mudança no Iteration Plan
- Início ou término de uma iteração

## Integração com CI

Adicionar ao pipeline de CI para manter o contexto sempre atualizado:

```yaml
# .github/workflows/prodops-context.yml
on:
  push:
    paths:
      - 'prodops/artifacts/obcs/**'
      - 'prodops/artifacts/experiments/**'
      - 'prodops/artifacts/plans/**'
jobs:
  derive-context:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash prodops/runtime/tools/derive-context/scripts/derive-context.sh --quiet
      - run: git diff --exit-code prodops/artifacts/context/ || git add prodops/artifacts/context/ && git commit -m "chore(context): update prodops-context.yaml"
```

## Referências

→ [Product Context Skill](../../skills/product-context/SKILL.md)
→ [PCE Agent](../../agents/pce-agent.md)
→ [Lifecycle](../../framework/lifecycle.md)
