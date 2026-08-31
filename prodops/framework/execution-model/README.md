# Execution Model

Upstream e Downstream são **modos de execução** do Framework ProdOps — não são jornadas, não são fases e não substituem as jornadas.

## Distinção crítica — o erro mais comum

> **Upstream não é sinônimo de Discovery.**
> **Downstream não é sinônimo de Delivery.**

Esta confusão vem do mercado, onde "upstream" e "downstream" costumam nomear *fases* de um processo linear: primeiro descobre-se (upstream), depois entrega-se (downstream). No ProdOps, os termos têm outro significado: descrevem o **nível de compromisso e rigor** aplicado ao trabalho — não qual jornada está sendo executada.

**As 3 jornadas de produto (Discovery, Delivery, Operation) e as 2 jornadas transversais (Assessment, Diligence) estão disponíveis nos dois modos.** O modo determina como cada jornada é executada — com rigor advisory (Upstream) ou com rigor bloqueante (Downstream).

## Terminologia canônica

| Conceito | Definição |
|---|---|
| **Upstream** | Modo de exploração — rigor advisory, sem compromisso de entrega |
| **Downstream** | Modo de compromisso — rigor bloqueante, entrega formal |
| **Discovery** | Jornada de produto — presente nos dois modos com comportamentos diferentes |
| **Delivery** | Jornada de produto — presente nos dois modos; Downstream exige Release Trail e produção obrigatória |
| **Operation** | Jornada de produto — presente nos dois modos; Upstream limita-se a sandbox/experimento controlado |
| **Assessment** | Jornada transversal — presente nos dois modos; Downstream pode bloquear |
| **Diligence** | Jornada transversal — presente nos dois modos; Downstream pode bloquear |

Os modos não substituem as jornadas. Eles definem o rigor com que as jornadas serão executadas.

## O que diferencia os modos

```
                     UPSTREAM              DOWNSTREAM
                  (exploração)            (compromisso)
                        │                      │
 Discovery          exploratória          preparatória + gate
 Delivery       advisory, sandbox        bloqueante, produção
 Operation      sandbox/experimento      produção real
 Assessment     informa, não bloqueia    pode bloquear
 Diligence      leve                     bloqueante
                        │                      │
 Gates          nenhum obrigatório       todos obrigatórios
 OBC            Draft / Refining         Refining na entrada; Committed obrigatório para Delivery Started
 Release Trail  não obrigatório          obrigatório
 Rigor          o engenheiro decide      sequência obrigatória
```

## Fluxo de decisão da Business Intent

Toda Business Intent segue um dos dois modos. No BIB, a decisão da exploração global é do Portfolio; no Product Backlog, a decisão local é do Product Owner. Nenhuma transição acontece automaticamente.

```
Business Intent
  ↓
Escolha do modo (Product Owner)
       ↓                                    ↓
  UPSTREAM                             DOWNSTREAM
  rigor advisory                       rigor bloqueante
  sem compromisso de entrega           com compromisso de entrega
       │                                    │
  Discovery (exploratória)            Discovery (preparatória — Icebox)
  Delivery  (sandbox / prod opt.)     Delivery  (produção obrigatória)
  Operation (experimental)            Operation (produção real)
  Assessment (informa)                Assessment (pode bloquear)
  Diligence (leve)                    Diligence (bloqueante)
       │                                    │
  CommitmentGate ─────────────────────► Downstream
  (quando Decision Package pronto)
```

Não existe transição automática entre os modos. A mudança deve ser uma decisão explícita — o CommitmentGate.

## Upstream

Modo permissivo e experimental, sem compromisso de entrega.

**Características:**
- Sem compromisso de entrega
- Liberdade para selecionar capabilities e práticas conforme necessidade
- O engenheiro decide quais skills e fases aplicar, e com qual rigor
- Todas as 5 jornadas disponíveis com rigor advisory
- Foco em aprendizado — o código é consequência, não o objetivo

Upstream transforma hipóteses em conhecimento validado.

→ [Detalhes do modo Upstream](upstream.md)

## Downstream

Modo com compromisso de entrega e aplicação completa dos quality gates vigentes.

**Características:**
- Compromisso formal com critérios de aceite (OBC + BDD Feature)
- Governança e rastreabilidade completas
- Artefatos obrigatórios antes do início
- Evidências registradas em cada etapa
- Sequência completa obrigatória

Downstream entrega software com conhecimento validado pela Discovery, realizada diretamente em Downstream ou promovida do Upstream.

→ [Detalhes do modo Downstream](downstream.md)

## Como escolher o modo

| Situação | Modo |
|---|---|
| Hipótese a validar, incerteza alta | Upstream |
| Item com compromisso, sendo guiado até completar readiness | Downstream |
| Explorar uma capability nova | Upstream |
| Executar item com todos os gates de readiness satisfeitos | Downstream |
| Prototipar integração com provedor | Upstream |
| Entregar feature com compromisso | Downstream |

## Frase canônica

> **O modo define o rigor — não as jornadas.**
> **As mesmas 5 jornadas existem nos dois modos; o que muda é o compromisso.**

Qualquer compressão que mapeie Upstream para uma jornada específica ("Upstream aprende", "Upstream é discovery") ou Downstream para outra ("Downstream entrega", "Downstream é delivery") está errada. Essas frases reproduzem a interpretação de mercado — não o modelo ProdOps.
