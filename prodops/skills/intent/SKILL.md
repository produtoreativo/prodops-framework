---
name: intent
description: Formaliza intenções de negócio e de produto. Use para identificar e registrar Business Signals, elevar um sinal a Business Intent, criar ou particionar um OBC, obter Owner Approval para um fluxo local, e garantir que o Product Backlog receba o Product Intent correto antes de qualquer exploração ou commitment.
---

# Intent Skill

## Propósito

Use esta skill para formalizar intenções — do sinal ao Product Backlog — sem avançar para exploração ou compromisso de entrega.

A Intent Skill opera exclusivamente sobre os dois primeiros estágios do lifecycle canônico: **Business Signal** e **Business Intent / Product Intent**. Não inclui exploração, CommitmentGate nem Delivery.

→ Para exploração Upstream, use `/upstream`.
→ Para CommitmentGate e transição Upstream → Downstream, use `/commitment`.
→ Para o contexto atual do produto, use `/product-context`.

---

## Quando Usar

- Um sinal de mercado, cliente ou operação precisa ser registrado
- Uma Business Intent precisa ser criada ou estruturada
- Um Global OBC precisa ser particionado em Local OBCs por produto
- Um fluxo local requer Owner Approval para criar diretamente um Local OBC
- O Product Backlog recebeu um item cujas origens e referências precisam ser estabelecidas

---

## Leitura Obrigatória

Antes de iniciar, ler:

- `prodops/framework/lifecycle.md` — estágios Business Signal e Business Intent / Product Intent
- `prodops/framework/glossary.md` — termos Business Signal, Business Intent, Product Intent, Global OBC, Local OBC
- `prodops/framework/obc.md` — dois níveis do OBC, particionamento, fluxo global vs. local
- `prodops/framework/backlogs.md` — hierarquia de backlogs

---

## Fluxo de Formalização

### 1. Business Signal → Business Intent

**Entradas:** qualquer observação — benchmark, reclamação de cliente, dado de mercado, proposta interna, decisão regulatória.

**Ações:**
1. Registrar o sinal na Product Tracking List ou Portfolio Tracking List com: descrição, origem, data, relevância estratégica.
2. Avaliar se o sinal é estrategicamente relevante para perseguir.
3. Se relevante: elevar a **Business Intent** — documento com objetivo, valor esperado e hipóteses iniciais.
4. Se irrelevante ou prematuro: registrar como descartado com justificativa e data.

**Artefato produzido:** entrada na Tracking List + documento de Business Intent (quando o sinal é elevado).

---

### 2. Business Intent → OBC Draft (fluxo global)

Quando a Business Intent vem do Portfolio (BIB):

1. Confirmar que um Global OBC foi criado no repositório de portfólio da plataforma.
2. Identificar todos os produtos envolvidos na entrega da Business Intent.
3. Executar o **Particionamento do OBC**: para cada produto, criar um Local OBC em rascunho referenciando o Global OBC.
4. Atualizar a tabela de rastreabilidade no Global OBC com os Local OBCs criados.

**Local OBC criado em:** `prodops/artifacts/obcs/<slug>.md` (estado: Draft)

---

### 3. Business Intent → OBC Draft (fluxo local / Owner Approval)

Quando a Business Intent não vem do Portfolio:

1. Confirmar que a Business Intent está registrada na Product Tracking List.
2. Obter aprovação do Product Owner para iniciar o trabalho localmente (**Owner Approval**).
3. Criar o Local OBC Draft referenciando a Business Intent e o Product Tracking Item que justificaram o Owner Approval.

**Local OBC criado em:** `prodops/artifacts/obcs/<slug>.md` (estado: Draft)

---

### 4. OBC Draft → Product Backlog (Product Intent)

O **Product Intent** é a formalização da Business Intent no nível do produto — o momento em que o Local OBC Draft entra no Product Backlog.

1. Verificar que o Local OBC Draft existe e referencia corretamente sua origem.
2. Adicionar o item ao Product Backlog (view Icebox) com estado Draft.
3. Confirmar que a rastreabilidade está estabelecida: de qual Business Intent / Global OBC este Product Intent veio.

**Condição de saída deste estágio:** Product Intent aceito no Product Backlog → pronto para Context Discovery (Upstream) ou para CommitmentGate direto (quando o contexto é suficiente).

---

## Regras de Operação

1. Não criar Local OBC sem referência a uma Business Intent ou Global OBC.
2. Não criar Local OBC em nome do produto sem Owner Approval (fluxo local) ou Particionamento (fluxo global).
3. Não avançar para CommitmentGate nesta skill — isso pertence a `/commitment`.
4. Não inventar KPIs ou critérios de aceite — registrar apenas o que o stakeholder declarou.
5. Não confundir Business Intent (entidade estratégica, pode ser multi-produto) com Product Intent (entidade de produto, pertence a um único Product Backlog).
6. Usar o slug canônico: `<NNN-short-slug>` para Local OBCs.

---

## Saídas Esperadas

- Entrada na Product Tracking List ou Portfolio Tracking List (Business Signal)
- Documento de Business Intent (quando o sinal é elevado)
- Local OBC Draft em `prodops/artifacts/obcs/<slug>.md` com estado Draft
- Rastreabilidade documentada: Global OBC (fluxo global) ou Business Intent + Tracking Item (fluxo local)
- Product Backlog atualizado com o Product Intent no Icebox

---

## Guardrails

- Nunca criar um OBC Draft sem declarar sua origem (Global OBC ou Business Intent + Tracking Item).
- Nunca elevar um Business Signal diretamente a OBC pulando a Business Intent — o OBC é o contrato da Intent, não do sinal.
- Nunca criar Work Items no GitHub sem declarar `artifact_type`, `artifact_id`, `operation` e `journey`.
- Nunca registrar compromisso de entrega nesta skill — compromisso é responsabilidade do CommitmentGate.

---

## Referências

→ [Lifecycle](../../framework/lifecycle.md)
→ [Glossário](../../framework/glossary.md)
→ [OBC](../../framework/obc.md)
→ [Backlogs](../../framework/backlogs.md)
→ [Jornada Discovery](../../framework/journeys/discovery/README.md)
→ [Commitment Skill](../commitment/SKILL.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
