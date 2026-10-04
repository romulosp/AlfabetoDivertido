# Implementation Plan — Arquitetura modular estática

**Versão**: 2.0.0 · **Data**: 2026-10-04 · **Projeto**: Local, sem Git/CI configurada.

## Objetivo e fontes

Refatorar `apps/alfabeto-divertido/`, mantendo `index.html` como única entrada e separando arquivos locais por responsabilidade. [spec.md](spec.md) identifica requisitos; [Design.md](Design.md) define caminhos, dependências e limites; as oito specs de domínio definem detalhes normativos sem cópia de conteúdo.

## Contexto técnico

HTML, CSS e JavaScript nativos, sem servidor, instalação ou compilação para jogar. Dependências de execução: DOM, `matchMedia`, SpeechSynthesis e Web Audio opcionais. Estado em memória. CSS em camadas e scripts clássicos `defer` em IIFEs preservam `file://`; o namespace único é `window.AlfabetoDivertido`.

O jogo distribui somente `index.html`, `styles/` e `js/`. Árvore detalhada em [Design.md](Design.md). Documentação e testes não são dependências do produto. Testes usam Node e Playwright exclusivamente no desenvolvimento.

## Constituição e limites

Constituição 1.0.0: unidades coesas testáveis, testes antes do comportamento novo, suíte crítica local e CI adicional quando configurada, versão/hash e revisão de aceitação registrados. Não criar CLI ou biblioteca distribuída para módulos internos do jogo. Não declarar aceite humano concluído por testes automáticos.

## Sequência de implementação

1. Registrar contrato modular executável, verificar falha na versão embutida e adaptar testes de regras para carregar módulos externos.
2. Extrair dados imutáveis e estado/cancelamento; separar decisões e pontuação puras em regras.
3. Extrair áudio sem DOM; separar ator e efeitos; deixar criação/atualização visual com renderização e coordenação com app.
4. Extrair CSS por camada preservando valores e seletores; substituir blocos embutidos por recursos relativos no HTML.
5. Transferir detalhes normativos para specs de domínio e transformar documentos anteriores em índices e integração. Atualizar distribuição, proposta, roteiro e contratos.
6. Rodar testes funcionais, arquitetura e pasta relocada em Chrome/Edge sem rede; capturar cenas e medir PERF-01 novamente.
7. Registrar evidências da versão 2.0.0 e manter pendências humanas explícitas. Duração de 15 minutos da versão anterior é histórica até nova execução desse teste.

## Validação e tarefas

Executar `node --test --test-concurrency=1 tests/modular.spec.mjs tests/alfabeto.spec.mjs`, repetindo com `BROWSER_CHANNEL=msedge`. Executar PERF-01 separadamente, com relógio real. As tarefas T001–T056 registram a implementação anterior; T057 em diante registram a refatoração. Ver [tasks.md](tasks.md), [validation.md](validation.md) e [quickstart.md](quickstart.md).
