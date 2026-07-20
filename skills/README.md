# Skills

Skills representam comportamento executável utilizado por agentes.

Skills NÃO são documentação conceitual.
Skills NÃO são templates.
Skills NÃO são capabilities.

## Skills disponíveis

| Skill | Fase/Jornada | Link |
|---|---|---|
| Bootstrap | Fase Bootstrap | [bootstrap/SKILL.md](bootstrap/SKILL.md) |
| Hack | Fase Hack | [hack/SKILL.md](hack/SKILL.md) |
| Sync | Fase Sync | [sync/SKILL.md](sync/SKILL.md) |
| Finish | Fase Finish | [finish/SKILL.md](finish/SKILL.md) |
| Ship | Fase Ship | [ship/SKILL.md](ship/SKILL.md) |
| Validate | Fase Validate | [validate/SKILL.md](validate/SKILL.md) |
| Upstream | Jornada Discovery | [upstream/SKILL.md](upstream/SKILL.md) |
| `upstream/move-to-downstream` | Step within Upstream | [upstream/steps/move-to-downstream/SKILL.md](upstream/steps/move-to-downstream/SKILL.md) |
| Downstream | Modo Downstream | [downstream/SKILL.md](downstream/SKILL.md) |
| Promote | Fase Promote | [promote/SKILL.md](promote/SKILL.md) |
| `hack/start` | Branch preparation step within Hack | [hack/steps/start/SKILL.md](hack/steps/start/SKILL.md) |
| `hack/tdd` | Step within Hack | [hack/steps/tdd/SKILL.md](hack/steps/tdd/SKILL.md) |
| `hack/commit` | Step within Hack | [hack/steps/commit/SKILL.md](hack/steps/commit/SKILL.md) |
| `upstream/deploy-to-sandbox` | Step within Upstream | [upstream/steps/deploy-to-sandbox/SKILL.md](upstream/steps/deploy-to-sandbox/SKILL.md) |
| `payments-api-local-testing` | Referência de testes locais | [payments-api-local-testing/SKILL.md](payments-api-local-testing/SKILL.md) |

## Estrutura de cada Skill

Cada Skill deve conter:
- **Objetivo** — o que a skill faz
- **Quando utilizar** — condição de entrada
- **Entradas** — artefatos consumidos
- **Saídas** — artefatos produzidos
- **Capabilities utilizadas** — lista de capabilities
