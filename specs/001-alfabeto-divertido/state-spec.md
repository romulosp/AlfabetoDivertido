# Estado e ciclo de vida — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

## Entidades e restrições

| Entidade | Campos conceituais | Restrições |
| --- | --- | --- |
| Palavra | palavra, emoji | Banco com 29 pares; palavras em maiúsculas; montagem usa tamanho de 3 a 4 |
| Exemplo | letra, palavra, emoji | 26 entradas; letra única entre A e Z; preservar palavras acentuadas dos exemplos |
| Sessão | identificador, tela, modo, somAtivo | Tela em menu/jogo/celebração; modo em primeiraLetra/montePalavra/alfabeto ou vazio no início |
| Rodada | questões, índice, resultados, acertosDePrimeira | Exatamente 8 questões distintas; índice ativo de 0 a 7; acertos de primeira entre 0 e 8 |
| Questão | tipo, palavra, emoji, teveErro, concluída | Registro único; erro anterior não pode voltar a falso dentro da questão |
| Alternativas | três letras | Exatamente 3 letras distintas A–Z; uma correta e duas diferentes dela |
| Montagem | posição, ocorrências, espaços | Posição de 0 ao tamanho da palavra; uma ocorrência por letra da palavra |
| Ocorrência | identificador, letra, usada | Identificador único no conjunto; duas letras iguais não compartilham consumo |
| Resultado | estado | Pendente, semErro ou comErro; concluído não retorna a pendente na mesma rodada |
| Seleção livre | letra, identificadorDaSeleção | Apenas a seleção mais recente comanda a carta, o brilho e a fala pendente |
| Ator | nome, visível, reação, balão | Nome “Rômulo Penha”; reação espera/feliz/confuso; não altera a pontuação |
| Recursos transitórios | atividade proprietária, temporizadores, fala, sons, partículas | Cada recurso deve ser cancelável ou descartável ao invalidar sua atividade |

## Invariantes

- A unidade de pontuação é uma questão inteira; na montagem, uma palavra inteira.
- `acertosDePrimeira` é igual ao número de resultados `semErro` já registrados.
- Uma questão concluída soma no máximo um resultado e agenda no máximo um avanço.
- O número de questões concluídas é o total de resultados `semErro` ou `comErro`.
- O progresso é `concluídas / 8`; erros não impedem progresso depois da conclusão.
- Letras usadas permanecem indisponíveis; escolher letra errada não consome ocorrência.
- Na montagem, os espaços preenchidos formam exatamente o prefixo correto da palavra.
- A questão mantém `teveErro` verdadeiro depois de qualquer erro, inclusive após encaixes corretos.
- O alfabeto não possui rodada, resultados ou estrelas ativos.
- Áudio, animações e tempo de resposta não decidem pontuação.
- Estado visual é consequência dos dados; classes CSS não são fonte da verdade.
- Ações de uma sessão invalidada não podem alterar a sessão atual.

## Transições

| Evento | Antes | Depois |
| --- | --- | --- |
| Iniciar modo avaliado | Menu ou celebração | Nova sessão de jogo; 8 questões; índice 0; resultados pendentes |
| Errar inicial | Questão aberta | Mesmo índice; `teveErro` verdadeiro; feedback de nova tentativa |
| Acertar inicial | Questão aberta | Concluída; registrar semErro/comErro; opções bloqueadas; avanço pendente |
| Encaixar letra intermediária | Palavra incompleta | Posição aumenta em 1; somente uma ocorrência consumida |
| Errar encaixe | Palavra incompleta | Posição e ocorrências inalteradas; `teveErro` verdadeiro |
| Encaixar última letra | Palavra incompleta | Concluída; registrar resultado uma vez; avanço pendente |
| Avançar antes da oitava | Questão concluída | Índice aumenta em 1; nova questão sem tentativas |
| Avançar após a oitava | Oito resultados registrados | Celebração com estrelas calculadas |
| Abrir alfabeto | Menu | Jogo livre; nenhuma rodada ativa; seleção vazia |
| Selecionar letra | Alfabeto | Seleção nova; substituir carta e fala pendente |
| Voltar ao menu | Jogo ou celebração | Sessão anterior invalidada; transientes cancelados; ator escondido |
| Jogar de novo | Celebração | Novo sorteio do mesmo modo; rodada e estrelas reiniciadas |
| Desligar som | Qualquer tela | Som falso; fala, sons ativos e agendados interrompidos; jogo inalterado |

## Pontuação

Faixas e cálculo normativo em [rules-spec.md](rules-spec.md), sem tabela duplicada.

## Integridade de conteúdo

Antes de iniciar uma rodada, garantir que existam pelo menos oito palavras elegíveis e que as alternativas possam ser distintas. Com o banco normativo de [content-spec.md](content-spec.md), essa condição é satisfeita. Não diminuir o total da rodada nem criar questão com conteúdo indefinido para ocultar uma inconsistência futura.

Nenhum campo representa nome de criança ou informação pessoal. O nome Rômulo Penha pertence exclusivamente ao ator mascote.


## Implementação e validação

`js/core/state.js` cria uma sessão com estado autoritativo e agenda/cancela temporizadores associados ao identificador da sessão. `pendingCount` permite inspecionar recursos pendentes sem expor controles na interface. `js/app.js` coordena invalidação, parada do áudio, limpeza do ator/efeitos e saída de telas. Renderização usa callbacks para decisões, sem duplicar estado. As ações antigas verificam sessão e questão; encadeamento de voz verifica também seleção e versão de áudio. Ver [fluxo de integração](Design.md) e testes de cancelamento.
