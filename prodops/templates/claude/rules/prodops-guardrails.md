# ProdOps Guardrails — Restrições Transversais

Estas restrições se aplicam a todos os agentes e skills em qualquer modo de execução.

## Artefatos

- **Nunca invente OBCs, BDD Features, riscos ou critérios de aceite** sem gatilho canônico documentado.
- **Nunca modifique artefatos de runtime de outra iteração** — cada iteração tem seu próprio ITERATION_DIR.
- **Nunca apague artefatos de trail** — Release Trail e upstream-trail são append-only.
- **Nunca escreva conteúdo fora do escopo declarado** de uma skill ou agente.

## Work Items

- **Nunca crie GitHub Issues ou PRs sem declarar** `artifact_type`, `artifact_id`, `operation` e `journey`.
- **Sempre use o padrão canônico de título**: `[Artifact ID]: descrição`.
- **Nunca atribua labels informais** — use apenas os labels canônicos definidos no Work Item Schema.

## Gates e Transições

- **Nunca pule gates obrigatórios** — readiness gate, CommitmentGate, quality gates.
- **Nunca registre um outcome fora dos 6 canônicos** do CommitmentGate.
- **Nunca avance para Downstream** sem Readiness Gate aprovado.
- **Nunca feche iteração** antes de todos os gates de iteração passarem.

## Segurança e Código

- **Nunca force push em `main`/`master`** sem confirmação explícita do usuário.
- **Nunca bypasse hooks** (`--no-verify`) sem autorização explícita registrada.
- **Nunca commite arquivos com credenciais** ou segredos — verificar antes de `git add`.
- **Nunca modifique scripts canônicos** em `prodops/scripts/`, `prodops/skills/`, `prodops/framework/` ou `prodops/runtime/` — eles são gerenciados pelo upstream.

## Escopo de Repositório

- **Nunca crie artefatos de execução** (Features BDD, protótipos, código) para capabilities que pertencem a outro repositório.
- Registre dependências externas como: dependência externa, risco de release, nota do Reliability Plan.

## Referências

→ [Work Item Schema](prodops/framework/execution-mapping/work-item-schema.md)
→ [Lifecycle](prodops/framework/lifecycle.md)
→ [OBC — governança](prodops/framework/obc.md)
