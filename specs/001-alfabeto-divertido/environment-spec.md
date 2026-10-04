# Ambiente e tema — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

## Identidade visual

A aparência DEVE seguir a referência: fundo pastel em azul, creme e rosa; título grande e arredondado com destaque amarelo; cartões e botões com cantos arredondados e sombra de relevo; figuras grandes; letras maiúsculas e espaços generosos. Não há imagens de referência adicionais: a fidelidade visual é ao estilo e às proporções descritos no código entregue.

**Paleta-base**: rosa `#FF6B9D`, turquesa `#4ECDC4`, amarelo `#FFE66D`, roxo `#A78BFA`, laranja `#FF9F43`, verde `#7ED957`, vermelho suave `#FF6B6B`, texto escuro `#2C3E50`, creme `#FFF8E7` e branco `#FFFFFF`. Botões de modos usam respectivamente rosa, turquesa e roxo. A paleta serve de base e deve receber ajustes localizados para contraste.

## Direção visual

O aprendizado é o centro da tela; os efeitos confirmam ações sem ocultar perguntas ou respostas.

| Elemento | Definição |
| --- | --- |
| Fundo | Gradiente azul `#B8E6F5`, creme `#FFF8E7` e rosa `#FFE1EC`, com movimento definido em [animation-spec.md](animation-spec.md) |
| Texto principal | Escuro `#2C3E50`, grande e legível |
| Cores de apoio | Rosa, turquesa, amarelo, roxo, laranja e verde da paleta-base acima |
| Tipografia | Fonte arredondada, amigável e legível, disponível localmente, com alternativa `system-ui`; sem download |
| Cantos | Botões e cartões grandes: aproximadamente 22–26 px; espaços de montagem: 18 px |
| Relevo | Sombra curta sob botões; pressionar reduz o relevo e desloca levemente o botão |
| Conteúdo | Palavras e letras em maiúsculas; textos de orientação curtos |
| Contraste | Ajustar fundo ou cor do texto para 4,5:1 em texto comum e 3:1 em texto grande |
| Toque | Área mínima de 44 × 44 px; espaçamento que evite tocar em dois controles |

As cores da referência são base visual, não autorização para texto ilegível. Sombra e relevo não substituem contraste ou foco.

## Execução e distribuição

A distribuição é a pasta completa `apps/alfabeto-divertido/`, contendo um único HTML de entrada e recursos CSS/JS relativos. Deve abrir diretamente por `file://` sem servidor, build, framework, CDN, imagens/fontes remotas ou requisições HTTP. Copiar só o HTML não é suficiente nesta versão.

Scripts clássicos externos com `defer`, em ordem explícita de dependência, usam IIFEs e o único namespace `window.AlfabetoDivertido`. Não usar `type="module"`, importação dinâmica, fetch ou carregador customizado. Esta escolha preserva `file://`; veja a decisão R01 em [research.md](research.md).

CSS tem quatro camadas declaradas em ordem: base, theme, components, animations. Base define reset e acessibilidade global; tema define tokens e fundo; componentes define layout, estados estáticos e responsividade; animações define movimentos e redução de movimento. SVG inline e emojis continuam locais. Som e fallback são definidos em [audio-spec.md](audio-spec.md). Layout responsivo é definido em [scene-spec.md](scene-spec.md).

Falhas de voz ou áudio não causam erros de console nem impedem a interação. Validação ocorre com rede bloqueada, incluindo cópia da pasta em outro caminho. Não há promessa de melhoria de desempenho só por separar arquivos.
