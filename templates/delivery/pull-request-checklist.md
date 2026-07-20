# Pull Request Checklist

- [ ] A mudança passou pelo Hack Flow.
- [ ] Existe teste antes ou junto da implementação (Red Bar confirmado).
- [ ] Foram priorizados testes de integração/acceptance.
- [ ] Não foram criados mocks indevidos de regra de negócio.
- [ ] Contratos (OpenAPI, BDD Feature, AsyncAPI) foram atualizados quando necessário.
- [ ] Logs e mensagens de erro relevantes foram validados.
- [ ] Lint executado (`npm run lint` exitou 0).
- [ ] Testes executados (unit + acceptance quando aplicável).
- [ ] Build executado.
- [ ] Arquitetura e Event Storming atualizados se a mudança foi estrutural.
- [ ] Evidências registradas no Release Trail ou upstream-trail.
- [ ] Definition of Done satisfeita. Ver [definition-of-done.md](../engineering/definition-of-done.md).
