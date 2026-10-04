# Alfabeto Divertido — Versão modular 2.0.0

O jogo abre por [index.html](../../apps/alfabeto-divertido/index.html), sem servidor ou rede. Distribuir a pasta inteira `apps/alfabeto-divertido/`, mantendo CSS e JavaScript locais.

## Especificações por domínio

| Arquivo | Fonte normativa |
| --- | --- |
| [spec.md](spec.md) | Objetivos, histórias, FR e contrato de entrega |
| [scene-spec.md](scene-spec.md) | Cenas, componentes, navegação, foco e textos |
| [character-spec.md](character-spec.md) | Ator Rômulo Penha, identidade e balões |
| [animation-spec.md](animation-spec.md) | Matriz CHG, tempos, efeitos e movimento reduzido |
| [environment-spec.md](environment-spec.md) | Ambiente, tema e execução offline |
| [rules-spec.md](rules-spec.md) | Regras de resposta, progresso e estrelas |
| [content-spec.md](content-spec.md) | 29 palavras/emojis e 26 exemplos |
| [state-spec.md](state-spec.md) | Entidades, invariantes e ciclo de vida |
| [audio-spec.md](audio-spec.md) | Voz local PT-BR, efeitos e fallback |

## Integração e execução

[Design.md](Design.md) define arquivos, dependências e integração. [proposal.md](proposal.md) explica a mudança de escopo; [plan.md](plan.md) define sequência; [tasks.md](tasks.md) registra trabalho; [validation.md](validation.md) registra evidências; [quickstart.md](quickstart.md) explica abertura e testes. [research.md](research.md) documenta decisões técnicas e fontes; [contratos](contracts/ui-contract.md) preserva identificadores DOM. [data-model.md](data-model.md) é ponte para state-spec.md.

Testes estão fora da distribuição. Evidências novas ficam em `tests/evidence/modular/`; as anteriores e o checklist de requisitos 1.0.0 são históricos. Aceite humano pendente não é substituído por automação. Os três modos, oito questões, estrelas, acessibilidade e identidade do ator devem ser preservados em qualquer alteração futura.
