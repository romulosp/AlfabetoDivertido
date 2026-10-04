# Regras do jogo — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

### Regras de pontuação e progresso

Uma **questão** corresponde a reconhecer uma inicial ou montar uma palavra completa. Uma **rodada** corresponde a oito questões. **Acerto de primeira** significa concluir a questão inteira sem selecionar nenhuma letra incorreta durante essa questão.

| Acertos de primeira em 8 questões | Regra preservada da referência | Estrelas |
| --- | --- | --- |
| 8 | Proporção ≥ 0,9 | 3 |
| 5, 6 ou 7 | Proporção ≥ 0,6 e < 0,9 | 2 |
| 0, 1, 2, 3 ou 4 | Proporção < 0,6 | 1 |

Todas as questões podem ser concluídas após erros. O número de estrelas recompensa acertos sem erro, mas nunca impede a conclusão. Não há perda de vidas, cronômetro, penalidade negativa ou eliminação.

O progresso representa questões concluídas, e não acertos de primeira: 0%, 12,5%, 25%, 37,5%, 50%, 62,5%, 75%, 87,5% e 100%. A entrada numa questão nova não incrementa a barra antes de ela ser concluída.

## Respostas e conclusão

Primeira Letra oferece três alternativas distintas A–Z, exatamente uma correta. Erro mantém a questão aberta e registra tentativa incorreta. Monte a Palavra consome uma ocorrência independente da próxima letra; letra errada ou usada não avança nem preenche. Letras iguais têm identificadores distintos. Concluir registra uma única vez o resultado da questão inteira. As oito questões são distintas em cada rodada; jogar novamente zera resultados e sorteia outra rodada, sem proibir coincidências com a anterior.

Alfabeto é exploração livre A–Z, sem rodada, estrelas ou avaliação. Selecionar novamente a mesma letra é permitido; somente a seleção mais recente controla o exemplo e a fala. Nenhuma regra depende de classes CSS, áudio ou tempo de animação.

## Implementação e validação

`js/game/rounds.js` contém funções puras de sorteio, alternativas, ocorrências, decisões e conclusão. `js/core/state.js` guarda o estado. Testes puros executam sem DOM/áudio; integração verifica faixas 0–4, 5–7 e 8, palavra inteira, duplicação de entradas e oito questões. Dados normativos em [content-spec.md](content-spec.md).
