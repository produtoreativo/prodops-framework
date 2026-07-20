# Upstream Experiments

## Propósito

Este documento indexa todos os experimentos Upstream executados para este produto.

Experimentos reduzem incerteza antes de a implementação avançar para Downstream.

Cada experimento deve responder a uma pergunta principal.

Não duplicar conteúdo de experimento aqui.

Referenciar o diretório do experimento.

---

# Workflow

```text
Pergunta de Negócio

↓

Experimento

↓

Aprendizado

↓

Decisão

↓

Assessment

↓

Downstream
```

---

# Status dos Experimentos

| ID | Capability | Status | Recomendação | Próximo Passo |
|----|------------|--------|--------------|---------------|
| 001 | Credit Card Lifecycle | 🟡 Em andamento | Subconjunto hospedado para Assessment; cartão salvo/novo precisam de decisões | Decidir armazenamento de token e fronteira PCI |
| 002 | Sandbox Funding | 🟡 Em andamento | Aguardar dependência externa | Coletar evidência do Sandbox Asaas |
| 003 | Hosted vs Tokenized | 🟡 Em andamento | Avançar para Downstream | Preparar intake Downstream para cartão hospedado |
| 004 | Checkout Gateway Feature Flag Readiness | 🟡 Em andamento | Aguardar dependência externa | Coletar evidência de Feature Flag do Checkout |
| 005 | Datadog Native AWS Instrumentation | ✅ Concluído | Avançar para Downstream após confirmar parâmetros do pipeline AWS | Validar deploy SAM com Datadog Extension layer e Secrets Manager secret |
| 006 | Upstream Trail per Experiment | ✅ Concluído | Manter como padrão operacional Upstream | Usar layout de diretório para novos experimentos |

---

# Legenda de Status

| Ícone | Significado |
|-------|-------------|
| ⏳ | Planejado |
| 🟡 | Em andamento |
| ✅ | Concluído |
| 🚀 | Promovido para Downstream |
| ❌ | Cancelado |

---

# Recomendações

Cada experimento concluído deve terminar com exatamente uma recomendação.

Recomendações possíveis:

- Avançar para Downstream
- Executar outro experimento Upstream
- Aguardar decisão de negócio
- Aguardar dependência externa
- Descartar capability

---

# Regras de Promoção

Uma capability pode avançar para Downstream apenas quando:

- O comportamento de negócio está compreendido.
- As principais incertezas técnicas estão resolvidas.
- Os impactos no Reliability Plan estão documentados.
- O OBC está suficientemente definido.
- Os cenários BDD estão definidos.
- O Validation Workbench demonstra o fluxo de negócio esperado.
- O Assessment aprova a capability.

---

# Foco Atual

Capability em investigação atual:

**Pagamento com Cartão de Crédito via Asaas**

Experimento atual:

**001 - Credit Card Payment Lifecycle with Asaas**

Próximos experimentos planejados:

- Continuar 002 com evidência do Sandbox Asaas
- Preparar intake Downstream para pagamento com cartão hospedado após aprovação de Produto e Tech Lead
- Executar experimento focado em armazenamento de token de cartão salvo após contribuição de Segurança/Arquitetura

---

# Experimentos Concluídos

Mover experimentos concluídos aqui após a promoção.

| ID | Capability | Release Downstream |
|----|------------|--------------------|

---

# Notas

Experimentos são intencionalmente pequenos.

Quando uma nova pergunta surgir, criar um novo experimento em vez de expandir um existente.

O objetivo é manter cada experimento focado em reduzir uma única incerteza.

Novos experimentos devem usar esta estrutura:

```text
prodops/journeys/discovery/experiments/NNN-short-slug/
  experiment.md
  upstream-trail.md
  evidence/
```

Arquivos planos restaurados de caminhos legados são artefatos históricos. Mantê-los legíveis, mas não criar novos experimentos nesse formato.
