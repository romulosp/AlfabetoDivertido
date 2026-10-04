# Conteúdo pedagógico — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

### Conteúdo pedagógico de referência

O banco de palavras DEVE conter estes 29 pares. As duas atividades de rodada usam o mesmo banco; a montagem filtra por tamanho. Nesta versão, todas as palavras listadas têm três ou quatro letras.

| Palavra | Emoji | Palavra | Emoji | Palavra | Emoji |
| --- | --- | --- | --- | --- | --- |
| GATO | 🐱 | PATO | 🦆 | BOLA | ⚽ |
| CASA | 🏠 | SAPO | 🐸 | RATO | 🐭 |
| DADO | 🎲 | FACA | 🔪 | VACA | 🐄 |
| LOBO | 🐺 | URSO | 🐻 | FLOR | 🌸 |
| FOGO | 🔥 | MESA | 🪑 | CAMA | 🛏️ |
| PIPA | 🪁 | ROSA | 🌹 | TREM | 🚂 |
| MAPA | 🗺️ | BOLO | 🎂 | MOTO | 🏍️ |
| VELA | 🕯️ | SOL | ☀️ | MAR | 🌊 |
| UVA | 🍇 | OVO | 🥚 | LUA | 🌙 |
| BOI | 🐂 | MEL | 🍯 | — | — |

Os exemplos do alfabeto DEVEM ser os seguintes, preservando inclusive K, W e Y:

| Letra | Exemplo | Emoji | Letra | Exemplo | Emoji |
| --- | --- | --- | --- | --- | --- |
| A | ABELHA | 🐝 | N | NAVIO | 🚢 |
| B | BOLA | ⚽ | O | OVO | 🥚 |
| C | CASA | 🏠 | P | PATO | 🦆 |
| D | DADO | 🎲 | Q | QUEIJO | 🧀 |
| E | ELEFANTE | 🐘 | R | RATO | 🐭 |
| F | FLOR | 🌸 | S | SAPO | 🐸 |
| G | GATO | 🐱 | T | TREM | 🚂 |
| H | HIPOPÓTAMO | 🦛 | U | UVA | 🍇 |
| I | ILHA | 🏝️ | V | VACA | 🐄 |
| J | JACARÉ | 🐊 | W | WIFI | 📶 |
| K | KIWI | 🥝 | X | XÍCARA | ☕ |
| L | LUA | 🌙 | Y | YOUTUBE | ▶️ |
| M | MACACO | 🐵 | Z | ZEBRA | 🦓 |

## Implementação e validação

`js/data/content.js` é a única fonte de dados em execução: total de questões, alfabeto, palavras/emojis, exemplos e nomes de modos. Arrays e entradas são imutáveis; o sorteio trabalha em cópias. Não repetir bancos por modo. O catálogo de mensagens de tela está em [scene-spec.md](scene-spec.md), falas do ator em [character-spec.md](character-spec.md). Validar todos os 29 pares, 26 exemplos e palavras repetidas CASA, BOLO e OVO.
