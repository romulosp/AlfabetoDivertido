# UI Contract — Telas e ações

**Estado**: Contratos aplicados ao HTML; automação desktop executada.  
**Fontes**: [SPEC](../spec.md), [Design](../Design.md), [modelo](../data-model.md)

Este contrato descreve a interface local da aplicação. Não há API de rede, endpoint, autenticação, CLI ou interface pública para terceiros.

## Telas e pontos de integração

Os identificadores abaixo preservam a referência e podem ser usados nos testes de desenvolvimento futuros. São pontos DOM do HTML de entrada, preservados pela renderização modular.

| Identificador de referência | Função |
| --- | --- |
| screen-menu | Menu com três modos |
| screen-game | Cabeçalho e conteúdo da atividade selecionada |
| screen-celebration | Resultado e ações finais |
| game-body | Conteúdo variável da questão ou do alfabeto |
| progress | Indicadores e barra de questões; ausente no modo livre |
| feedback | Texto de resultado e orientação da atividade |
| sound-toggle / sound-toggle-game / sound-toggle-celebration | Controle visível e acessível em cada uma das três telas, com estado sincronizado |
| slots / pool | Espaços e ocorrências da palavra em montagem |
| alpha-card-wrap | Carta da seleção mais recente do alfabeto |
| mascote-romulo / mascote-balao | Ator Rômulo Penha e seu balão; identificadores sem acento preservados |

## Ações

| Ação | Pré-condição | Resultado obrigatório | Ação inválida |
| --- | --- | --- | --- |
| Iniciar Primeira Letra | Menu ativo | Rodada zerada de 8 questões e foco na atividade | Não iniciar rodada duplicada por duplo toque |
| Iniciar Monte a Palavra | Menu ativo | Rodada zerada de 8 palavras elegíveis | Não reduzir total por falha de conteúdo |
| Iniciar Alfabeto | Menu ativo | Grade A–Z sem avaliação | Não herdar progresso anterior |
| Escolher inicial | Jogo de inicial; questão aberta | Erro mantém questão; acerto registra resultado e agenda um avanço | Ignorar se questão concluída ou tela inativa |
| Escolher ocorrência | Montagem aberta; botão não usado | Consumir apenas se letra for a próxima esperada | Ignorar botão usado ou palavra concluída |
| Selecionar letra livre | Alfabeto ativo | Substituir carta, seleção e sequência de voz | Ignorar callbacks de seleção anterior |
| Alternar som | Controle da tela atual | Estado único; mute interrompe som ativo e agendado | Não alterar índice ou pontuação |
| Menu / Escape | Jogo ou celebração | Invalidar atividade; limpar recursos; mostrar menu e foco coerente | No menu, Escape não inicia nenhuma ação |
| Jogar de novo | Celebração ativa | Novo sorteio no mesmo modo | Não carregar resultados antigos |
| Avanço automático | Questão concluída e sessão ainda atual | Próxima questão ou celebração | Ignorar sessão invalidada ou avanço já aplicado |

## Estados acessíveis

- Botões possuem nomes compreensíveis e ativação nativa por Enter/Espaço.
- Menu, jogo e celebração possuem controle de som disponível; os três refletem o mesmo estado de áudio.
- Controles de telas inativas não recebem foco nem são anunciados como disponíveis.
- Progresso informa questões concluídas de um total de oito; indicadores distinguem questão atual e resultados.
- Seleção do alfabeto é identificável como selecionada; ocorrências usadas ficam desabilitadas.
- A região de feedback comunica acerto, erro e orientação sem depender do emoji.
- O SVG tem identificação “Rômulo Penha, o tucano mascote”; balão e partículas não geram anúncios redundantes.
- Foco, contraste, movimento reduzido e espaço reservado seguem [Design.md](../Design.md).

## Resultado e cancelamento

Uma ação correta conclui uma questão no máximo uma vez. No retorno ao menu, na nova rodada e na seleção de outra letra, os efeitos tardios da atividade ou seleção anterior devem ser descartados. Nenhum contrato depende do sucesso da narração.

## Observação para testes

Os futuros testes podem observar a tela, as opções e o progresso ou injetar conteúdo determinístico antes de iniciar uma atividade. Recursos de teste não devem criar controles ou atalhos secretos na interface entregue à criança. A automação é ferramenta de desenvolvimento externa à pasta do jogo distribuída.
