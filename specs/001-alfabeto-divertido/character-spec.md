# Ator — Rômulo Penha — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

## Identidade

| Característica | Definição |
| --- | --- |
| Nome | **Rômulo Penha** |
| Identidade | Tucano mascote e personagem de apoio à criança. |
| Papel | Acompanhar as atividades, incentivar tentativas e celebrar o aprendizado. |
| Presença | Canto inferior esquerdo nas telas de jogo e celebração; escondido no menu. |
| Aparência | Corpo escuro, barriga clara, asa turquesa, pés alaranjados, bico laranja grande com ponta escura e olho branco com pupila. |
| Estados | Espera com respiração discreta, felicidade com salto e confusão com inclinação leve. Com movimento reduzido, usar estados visuais estáticos equivalentes. |
| Comunicação | Balão temporário com as frases da tabela de eventos abaixo, reagindo a acertos, erros, montagem de palavras e seleção de letras. |
| Interação | Personagem de apoio que não recebe foco nem captura toque ou clique e não bloqueia controles. |
| Identificação acessível | “Rômulo Penha, o tucano mascote”. |
| Rastreabilidade | CHG-101-ATOR-MASCOTE, CHG-102-ATOR-MASCOTE-REACAO, CHG-106-ATOR-MASCOTE-FALA e CHG-207-ANIM-MASCOTE-IDLE. |

A grafia sem acento permanece somente na citação do título original do anexo; o nome oficial do ator nesta especificação é **Rômulo Penha**.

## Eventos e balões

| Evento | Estado | Balão |
| --- | --- | --- |
| Início de rodada | Espera | Vamos brincar! |
| Acerto de inicial | Feliz | Isso!, Boa!, Aê! ou Mandou bem! |
| Erro de inicial | Confuso | Tenta outra! |
| Encaixe intermediário | Feliz | Continua! |
| Palavra concluída | Feliz | Montou tudinho! |
| Erro de montagem | Confuso | Tenta de novo! |
| Entrada no alfabeto | Espera | Toca numa letra! |
| Escolha no alfabeto | Feliz | {LETRA} de {EXEMPLO} |
| Celebração | Feliz | Você é fera! com 3 estrelas; Mandou bem! com 1 ou 2 |
| Retorno ao menu | Escondido | Nenhum balão residual |

O balão aceita quebra de linha, tem largura limitada ao espaço disponível e tem a duração definida em [animation-spec.md](animation-spec.md). Identificar o SVG uma vez como “Rômulo Penha, o tucano mascote”; o balão não é região de anúncio concorrente ao feedback da atividade.

## Implementação e validação

SVG inline em `index.html`; estados em `js/actors/tucano.js`; aparência em `styles/components.css`. Tempos e movimentos são definidos somente em [animation-spec.md](animation-spec.md). O ator não decide respostas ou pontuação. Ver validação de presença, identificação, balão e espaço livre para controles.
