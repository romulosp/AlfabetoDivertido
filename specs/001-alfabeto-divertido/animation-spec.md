# Animações e efeitos — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

| Comentário a preservar no código | Comportamento verificável |
| --- | --- |
| CHG-101-ATOR-MASCOTE | Tucano em SVG inline, com identidade de Rômulo Penha, no canto inferior esquerdo do jogo e da celebração. |
| CHG-102-ATOR-MASCOTE-REACAO | Felicidade com salto de aproximadamente 0,8 s; confusão com inclinação leve de aproximadamente 0,6 s. |
| CHG-103-ATOR-LETRAS-OLHINHOS | Botões de letras dos modos com rodada têm dois pequenos olhos claros, sem prejudicar a leitura da letra. |
| CHG-105-ATOR-EMOJI-REAGE | Emoji da questão cresce e inclina levemente no acerto; balança brevemente no erro. Nos dois modos com rodada. |
| CHG-106-ATOR-MASCOTE-FALA | Balão curto, legível e temporário, com cerca de 2,2 s de duração; pode quebrar linha para não sair da tela. |
| CHG-201-ANIM-TRANSICAO-TELA | Entrada e saída suaves com transparência e pequeno deslocamento, aproximadamente 0,35 s. |
| CHG-203-ANIM-SLOT-FILL-BOUNCE | Espaço preenchido recebe destaque amarelo e pequeno crescimento seguido de retorno, aproximadamente 0,45 s. |
| CHG-205-ANIM-PROGRESSO-FILL | Indicador atual pulsa discretamente; estados concluídos e barra refletem o progresso real. |
| CHG-206-ANIM-CARD-ALPHA-FLIP | Carta da letra entra como se virasse, aproximadamente 0,55 s. |
| CHG-207-ANIM-MASCOTE-IDLE | Respiração discreta em ciclo de aproximadamente 4 s enquanto o tucano está visível e em espera. |
| CHG-301-EFEITO-CONFETE-FORMAS | Acertos e conclusão lançam confete variado com quadrados, círculos, triângulos, estrelas e corações; quantidade maior na celebração. |
| CHG-302-EFEITO-EXPLOSAO-ESTRELAS | Estrelas partem do botão correto acionado e desaparecem em cerca de 1 s; acionamento por teclado também tem origem visual coerente. |
| CHG-303-EFEITO-FLASH-ERRO | Flash vermelho suave de aproximadamente 18% de opacidade, com duração de 0,25–0,3 s; não captura interação. |
| CHG-306-EFEITO-SHOCKWAVE-ACERTO | O botão correto mostra onda verde expansiva e temporária de aproximadamente 0,8 s. |
| CHG-307-EFEITO-GLOW-LETRA-FALADA | Letra escolhida no alfabeto recebe brilho temporário; não deixa destaque de escolhas antigas. |
| CHG-308-EFEITO-GRADIENT-ANIMADO | Fundo gradiente pastel se movimenta lentamente em ciclo de aproximadamente 30 s. |

## Animações e movimento reduzido

A matriz acima é a referência única dos 16 marcadores CHG. Preservar nomes dos comentários. Priorizar mudanças de transformação e opacidade em efeitos; limitar a quantidade de partículas e removê-las ao terminar ou sair do modo.

Os comentários CHG continuam presentes com movimento reduzido, mas os efeitos móveis DEVEM ser suprimidos ou substituídos por estados estáticos: gradiente estático, transições imediatas ou discretas sem deslocamento, tucano sem salto/respiração, cartas sem giro e nenhum confete, explosão, onda, flash ou pulso. Manter preenchimento, indicação correta/errada, seleção e texto. O feedback de erro estático substitui o flash.

## Implementação e validação

`styles/animations.css` contém keyframes, transições e movimento reduzido. `js/effects/particles.js` gera e limpa partículas; `js/actors/tucano.js` agenda reações. Quantidades máximas: 18 confetes por acerto, 48 na celebração e 8 estrelas por explosão. Limpeza por término e invalidação da sessão; nova preferência de movimento reduzido remove efeitos em curso. Não alterar regras durante animações.
