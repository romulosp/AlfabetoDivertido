# Proposal — Refatoração modular do Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04 · **Escopo**: Autorizado pelo usuário.

## Problema e resultado

A implementação anterior concentrava marcação, estilos, dados e comportamentos em um HTML. A manutenção exige separar responsabilidades coesas, preservando a abertura estática offline e todas as regras de alfabetização. O resultado mantém um único HTML de entrada e distribui CSS/JS locais com a pasta do jogo.

## Escopo

Separar CSS em quatro camadas e JavaScript em oito módulos de domínio, conforme [Design.md](Design.md). Separar também as especificações em cenas, ator, animações, ambiente, regras, conteúdo, estado e áudio. Cada detalhe normativo tem uma fonte própria, indicada por [spec.md](spec.md); documentos de integração usam links.

Preservar três modos, oito questões, banco pedagógico, acerto de primeira, progresso, estrelas, mensagens, CHG, SVG inline de Rômulo Penha, teclado, zoom, responsividade e movimento reduzido. Áudio permanece local PT-BR com fallback textual.

## Decisões e compensações

Distribuir a pasta inteira facilita manutenção por responsabilidade, mas copiar apenas o HTML deixa de ser suficiente. Scripts clássicos externos com `defer` e escopos isolados preservam `file://`, sem servidor ou build. A justificativa técnica está em [research.md](research.md). A mudança de formato de distribuição usa versão 2.0.0.

Separar arquivos não garante menor custo de renderização. A meta de resposta continua sendo medida por PERF-01, em [validation.md](validation.md). Não adicionar frameworks, loaders, barramento de eventos, microsserviços, pacotes de runtime ou arquivos por função pequena.

## Execução e aceitação

[plan.md](plan.md) define sequência, [tasks.md](tasks.md) registra execução e [validation.md](validation.md) reúne evidências reais. Testes ficam fora do produto e verificam regras, DOM, cancelamento, áudio, acessibilidade e relocação offline da pasta. Resultados anteriores permanecem históricos; verificações humanas pendentes não são aprovadas pela refatoração.
