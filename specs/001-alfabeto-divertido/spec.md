# Feature Specification: Alfabeto Divertido — Rômulo Penha, o tucano mascote

**Feature Branch**: Não criada; projeto sem repositório Git inicializado.

**Feature Directory**: `specs/001-alfabeto-divertido`

**Created**: 2026-10-04

**Status**: Implementado; testes desktop aprovados; aceite manual pendente.

**Input original da fase documental**: Criar a especificação completa do jogo educativo “Alfabeto Divertido”, usando a referência entregue pelo usuário, para orientar sua implementação futura em um único HTML offline. Nesta etapa, entregar a SPEC, sem implementar o jogo.

**Referência de origem**: Os dois anexos `Pasted text.txt` entregues pelo usuário têm conteúdo idêntico. O documento de referência se intitula “🎈 Alfabeto Divertido — Versão com Romulo Penha (Tucano Mascote)”. As regras, mensagens, conteúdo e marcadores relevantes foram incorporados a esta especificação para que ela possa orientar a geração sem exigir acesso aos caminhos temporários dos anexos.

**Objetivo do produto**: Permitir que crianças em alfabetização reconheçam a primeira letra de palavras, montem palavras curtas e explorem o alfabeto, com orientação em português brasileiro e estímulos visuais acolhedores.

**Limite da fase documental (concluída)**: A especificação e os documentos complementares foram entregues antes do código. O usuário posteriormente autorizou a implementação em `apps/alfabeto-divertido/index.html`; a etapa atual executa esse plano e registra evidências de validação.

**Documentos complementares**: [Proposta](proposal.md), [Design](Design.md), [Plano de implementação](plan.md), [Tarefas](tasks.md) e [Validação](validation.md). O [índice](README.md) lista também pesquisa, modelo de dados, contratos e roteiro de uso.

**Alteração de escopo — versão 2.0.0**: O usuário autorizou a arquitetura modular estática; DC-001 substitui o antigo empacotamento em um arquivo. Regras e identidade foram preservadas.

## Clarifications

### Session 2026-10-04

- **Destino da implementação**: O usuário autorizou a execução e determinou `apps/alfabeto-divertido/index.html` como caminho do jogo. DC-008 aplica-se à fase documental anterior.

Refinamento autorizado pelo pedido “corrigir todos os problemas levantados”. Não foram necessárias novas perguntas: as decisões abaixo são padrões documentados a partir do escopo existente, sem atribuir respostas não fornecidas ao usuário.

- **C1 — Testes antes do código**: Os testes das responsabilidades comuns, incluindo voz local, ausência/falha de APIs, mute, foco e movimento reduzido, devem ser escritos antes de sua implementação na fundação. As fases posteriores ampliam ou executam essa cobertura.
- **C2 — Validação local e CI**: A constituição foi atualizada explicitamente para exigir automação local antes de qualquer entrega e a mesma suíte em CI quando houver CI configurada. O projeto local não precisa criar infraestrutura remota para gerar seu HTML.
- **I1 — Marcos incrementais**: Cada marco valida apenas os modos já implementados. Um caso com várias atividades só recebe aprovação final depois que todo o seu escopo aplicável for executado.
- **A1 — Desempenho**: O limite permanece 200 ms por amostra, medido no perfil PERF-01 de validation.md: navegador Chromium, viewport de tablet, CPU desacelerada 4× e 20 amostras por cenário, com hardware/versões registrados antes da execução.
- **I2 — Som na celebração**: Menu, jogo e celebração devem ter controle de som visível e acessível, compartilhando o mesmo estado.
- **A2 — Voz opcional**: V015 depende de voz local PT-BR disponível. A ausência comprovada permite “Não aplicável” apenas nesse caso; V016, de fallback, continua obrigatório.
- **U1 — Constituição única**: O template duplicado foi removido; a constituição efetiva possui uma única versão, 1.0.0, sem placeholders.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reconhecer a primeira letra (Priority: P1)

Como criança em alfabetização, quero ver uma palavra e sua imagem, ouvir a pergunta e escolher a letra que inicia a palavra, recebendo incentivo para tentar novamente quando errar.

**Why this priority**: Oferece uma atividade de reconhecimento de letras com início, progresso e conclusão completos.

**Independent Test**: Abrir o jogo, escolher “Primeira Letra” e concluir oito questões, incluindo uma resposta errada seguida da correta. Verificar progresso, feedback e estrelas.

**Acceptance Scenarios**:

1. **Given** o menu inicial, **When** a criança escolhe “Primeira Letra”, **Then** começa uma rodada de exatamente oito questões, o tucano aparece e a primeira questão apresenta pergunta, emoji, pista e três opções distintas.
2. **Given** uma questão ainda sem tentativas, **When** a criança escolhe a letra inicial correta, **Then** recebe feedback positivo, a questão conta como acerto de primeira e o jogo avança uma única vez após o tempo de celebração local.
3. **Given** uma questão sem resposta correta, **When** a criança escolhe uma letra incorreta, **Then** vê “Quase! Tente outra letra 🤔”, permanece na questão e pode tentar novamente sem limite de tentativas.
4. **Given** uma questão na qual houve erro, **When** a criança finalmente escolhe a letra correta, **Then** conclui a questão, mas ela não entra na contagem de acertos de primeira.
5. **Given** a oitava questão, **When** a criança acerta, **Then** o jogo completa o progresso e abre a celebração com a quantidade de estrelas correspondente ao desempenho.

### User Story 2 - Montar palavras curtas (Priority: P1)

Como criança em alfabetização, quero tocar nas letras disponíveis para colocá-las na ordem da palavra apresentada, vendo cada espaço se preencher.

**Why this priority**: É o segundo modo obrigatório de rodada e exercita a sequência de letras da palavra.

**Independent Test**: Iniciar “Monte a Palavra”, concluir oito palavras e incluir uma palavra com letras repetidas, como CASA ou BOLO. Verificar preenchimento sequencial, consumo individual das letras e pontuação.

**Acceptance Scenarios**:

1. **Given** o menu, **When** a criança escolhe “Monte a Palavra”, **Then** começa uma rodada de exatamente oito palavras com três ou quatro letras, uma imagem por palavra, espaços vazios e as letras da palavra embaralhadas.
2. **Given** a próxima posição vazia, **When** a criança toca na letra esperada, **Then** somente essa posição é preenchida com animação, somente o botão escolhido é consumido e a próxima posição é destacada.
3. **Given** uma palavra com letras repetidas, **When** uma ocorrência é usada, **Then** as outras ocorrências permanecem disponíveis até serem usadas em suas posições.
4. **Given** uma palavra incompleta, **When** a criança toca numa letra diferente da próxima esperada, **Then** nenhum espaço é preenchido, nenhuma letra é consumida e aparece “A próxima letra é outra. Tente de novo 🤔”.
5. **Given** uma palavra montada inteira sem erro, **When** a última letra é encaixada, **Then** a questão conta uma única vez como acerto de primeira e o jogo avança após o feedback.
6. **Given** uma palavra que recebeu pelo menos uma tentativa errada, **When** ela é concluída, **Then** avança normalmente, sem ganhar acerto de primeira, independentemente de quantas letras corretas foram usadas antes ou depois do erro.

### User Story 3 - Explorar livremente o alfabeto (Priority: P1)

Como criança em alfabetização, quero tocar em qualquer letra do alfabeto para ver seu exemplo e ouvir sua pronúncia, sem precisar completar uma rodada.

**Why this priority**: É o terceiro modo obrigatório e oferece exploração livre, sem avaliação.

**Independent Test**: Abrir “Brincar com o Alfabeto”, selecionar todas as 26 letras e conferir cada exemplo. Selecionar várias letras rapidamente e voltar ao menu.

**Acceptance Scenarios**:

1. **Given** o menu, **When** a criança abre “Brincar com o Alfabeto”, **Then** encontra as 26 letras A–Z em ordem, a orientação “Toque em uma letra para ouvir 👇” e nenhum contador de questões ou avaliação por estrelas.
2. **Given** a grade do alfabeto, **When** a criança toca em A, **Then** A recebe destaque, uma carta mostra A, 🐝 e ABELHA, e o tucano fala no balão “A de ABELHA”.
3. **Given** som habilitado e voz disponível, **When** uma letra é escolhida, **Then** o jogo pronuncia a letra e depois “{LETRA} de {EXEMPLO}” em português brasileiro.
4. **Given** uma letra selecionada, **When** outras letras são tocadas rapidamente, **Then** a carta e o balão passam a representar a última escolha e falas atrasadas das escolhas anteriores não reaparecem.
5. **Given** qualquer quantidade de letras exploradas, **When** a criança volta ao menu, **Then** retorna normalmente, sem abrir a tela de celebração.

### User Story 4 - Celebrar, repetir e trocar de modo (Priority: P2)

Como criança, quero celebrar minha rodada, jogar novamente ou escolher outra brincadeira, sempre começando com uma rodada nova.

**Why this priority**: Completa o ciclo de aprendizagem e permite usar os três modos sem recarregar a página.

**Independent Test**: Concluir rodadas com 0, 4, 5, 7 e 8 acertos de primeira. Usar “Jogar de novo”, “Menu” e a saída durante uma transição.

**Acceptance Scenarios**:

1. **Given** uma rodada finalizada, **When** o total de acertos de primeira é 8, **Then** a celebração exibe três estrelas e as mensagens correspondentes ao melhor resultado.
2. **Given** uma rodada finalizada, **When** o total é 5, 6 ou 7, **Then** exibe duas estrelas; com 0, 1, 2, 3 ou 4, exibe uma estrela.
3. **Given** a celebração, **When** a criança escolhe “🔁 Jogar de novo”, **Then** inicia o mesmo modo com oito novas questões sorteadas, progresso e pontuação zerados.
4. **Given** jogo ou celebração, **When** a criança escolhe o botão de menu ou pressiona Escape, **Then** retorna ao menu, o mascote fica escondido e nenhuma ação atrasada altera a tela depois da saída.
5. **Given** um acerto cujo avanço automático ainda está pendente, **When** a criança sai e inicia outro modo, **Then** o avanço antigo não interfere na nova atividade.
6. **Given** a celebração com fala ou efeitos ativos, **When** a criança usa o controle de som dessa tela, **Then** o áudio é interrompido e o estado desligado permanece ao jogar de novo ou voltar ao menu.

### User Story 5 - Brincar sem internet, com acessibilidade (Priority: P1)

Como responsável ou criança, quero abrir o HTML de entrada da pasta do jogo no navegador e jogar usando toque, mouse ou teclado, mesmo sem internet, podendo desligar o som e reduzir os movimentos.

**Why this priority**: Define a forma de uso solicitada e garante que conteúdo, controles e aprendizado permaneçam disponíveis em diferentes dispositivos.

**Independent Test**: Abrir o arquivo local com a rede desativada; executar todos os modos; navegar só pelo teclado; testar tela estreita, zoom e preferência por movimento reduzido.

**Acceptance Scenarios**:

1. **Given** a pasta final do jogo salva no dispositivo, **When** ele é aberto diretamente no navegador com a rede desativada, **Then** menu, imagens, três modos, feedback visual e celebração funcionam sem instalar ou baixar dependências.
2. **Given** som habilitado, **When** o controle de som é desligado, **Then** narração e efeitos sonoros param e continuam desativados nas demais telas até nova ativação.
3. **Given** ausência de suporte a voz ou ausência de voz brasileira utilizável offline, **When** a criança joga, **Then** as atividades permanecem funcionais e as instruções continuam visíveis em texto, sem erros de execução.
4. **Given** navegação por teclado, **When** a criança usa Tab, Enter, Espaço e Escape, **Then** alcança e aciona todos os controles da tela atual, identifica o foco e retorna ao menu com Escape.
5. **Given** preferência por movimento reduzido, **When** a criança joga, **Then** não há gradiente em movimento, partículas, pulsos ou saltos; texto, cores, preenchimentos e pontuação continuam comunicando o resultado.

### Edge Cases

- Cliques duplos ou toques rápidos na resposta correta não podem somar duas vezes nem pular uma questão.
- Letras já consumidas em “Monte a Palavra” não podem ser utilizadas novamente por toque, mouse ou teclado.
- Tocar numa letra errada e imediatamente na correta não pode permitir que uma limpeza atrasada de animação apague o feedback do acerto.
- Repetir um erro na mesma questão continua sendo um único marcador de questão com tentativa; não subtrai pontos nem cria resultados adicionais.
- A letra correta permanece disponível após tentativas erradas; a criança nunca fica sem caminho para concluir.
- Sair durante uma pergunta, narração, confete ou espera de avanço cancela ações pendentes da atividade anterior.
- Reiniciar após a celebração remove estrelas e resultados anteriores antes de começar a nova rodada.
- A última questão preenche o progresso antes da celebração; não existe uma nona questão.
- Ativar ou desativar o som durante a fala não muda a questão, a seleção ou a pontuação.
- Uma voz disponibilizada pelo navegador apenas depois da abertura deve poder ser usada em futuras falas sem recarregar o jogo.
- Uma voz que exige rede não pode comprometer a execução offline. O fallback é textual, sem exigir conexão ou download.
- No alfabeto, clicar rapidamente em letras diferentes não pode deixar várias falas antigas em fila ou vários destaques de seleção persistentes.
- Ativar respostas por teclado deve produzir efeitos visuais junto ao botão acionado, mesmo sem coordenadas de mouse.
- Em telas pequenas, paisagem ou zoom de 200%, os controles permanecem alcançáveis; rolagem é permitida e preferível a cortar conteúdo.
- O tucano e o balão não capturam interação nem encobrem visualmente opções, navegação ou feedback essencial.
- O banco definido nesta spec contém palavras suficientes para oito questões distintas. Caso seu conteúdo seja alterado no futuro, a alteração não pode reduzir silenciosamente o total da rodada.

## Requirements *(mandatory)*

### Functional Requirements

#### Menu, navegação e ciclo de jogo

- **FR-001**: O jogo DEVE abrir no menu com o título “Alfabeto Divertido” e o subtítulo “Vamos aprender a ler brincando! 🎉”.
- **FR-002**: O menu DEVE oferecer exatamente os três modos descritos nesta spec, com os nomes, ícones e descrições do catálogo de textos.
- **FR-003**: O jogo DEVE apresentar telas distintas de menu, jogo e celebração, com transição suave. Somente a tela atual pode receber foco ou interação.
- **FR-004**: “Primeira Letra” e “Monte a Palavra” DEVEM possuir exatamente oito questões por rodada. “Brincar com o Alfabeto” DEVE ser livre, sem limite de questões, pontuação ou encerramento automático.
- **FR-005**: Ao iniciar uma rodada, o jogo DEVE zerar índice, resultados, acertos de primeira, tentativas e progresso da palavra. As oito questões DEVEM ser sorteadas sem repetir palavras dentro da mesma rodada.
- **FR-006**: Durante o jogo DEVE existir acesso ao menu e ao controle de som. A celebração DEVE oferecer “🔁 Jogar de novo”, “🏠 Menu” e controle de som. Escape DEVE retornar ao menu a partir de jogo ou celebração.
- **FR-007**: Saída, reinício e troca de modo DEVEM cancelar narração e ações atrasadas capazes de alterar telas, perguntas ou pontuação. Uma rodada anterior não pode atuar sobre a seguinte.

#### Primeira Letra

- **FR-008**: Cada questão DEVE apresentar “Qual é a primeira letra de {PALAVRA}?”, com destaque na palavra, seu emoji e uma pista visual formada por “?” seguido das demais letras; para GATO, “?ATO”.
- **FR-009**: Cada questão DEVE oferecer três letras maiúsculas distintas, em ordem embaralhada: a primeira letra da palavra e duas letras diferentes dela, retiradas de A–Z.
- **FR-010**: A resposta correta DEVE concluir a questão uma única vez, preencher visualmente a inicial da pista, destacar o botão correto, animar o emoji e exibir “🎉 {LETRA} de {PALAVRA}!”. A inicial preenchida explicita a resposta sem alterar a regra da referência.
- **FR-011**: Uma resposta errada DEVE marcar que houve tentativa incorreta, manter a questão disponível e apresentar o feedback de erro do catálogo. O avanço automático só ocorre após a resposta correta.
- **FR-012**: Após o acerto, as opções DEVEM ficar indisponíveis durante o feedback e o avanço DEVE ocorrer aproximadamente 1,6 segundo depois, salvo se a criança sair antes.

#### Monte a Palavra

- **FR-013**: As questões deste modo DEVEM usar apenas palavras de três ou quatro letras do banco de referência.
- **FR-014**: Cada questão DEVE mostrar “Monte a palavra: {PALAVRA}”, o emoji correspondente, um espaço por letra e um conjunto embaralhado contendo exatamente as letras da palavra, inclusive suas repetições.
- **FR-015**: A montagem DEVE ocorrer da esquerda para a direita. O próximo espaço DEVE estar destacado. Tocar na letra esperada preenche somente esse espaço, anima o preenchimento e consome somente o botão escolhido.
- **FR-016**: Botões consumidos DEVEM permanecer visualmente identificáveis como usados e indisponíveis para qualquer forma de ativação.
- **FR-017**: Uma escolha incorreta DEVE manter intactos os espaços e as letras disponíveis, marcar a questão como tendo erro e apresentar o feedback correspondente do catálogo.
- **FR-018**: Encaixes corretos intermediários DEVEM oferecer reforço positivo breve; se houve erro antes, o feedback de erro DEVE ser substituído por orientação coerente com o encaixe atual. Somente a palavra completa conclui a questão e altera o progresso de rodada.
- **FR-019**: Ao concluir a palavra, o jogo DEVE mostrar “🎉 Isso! {PALAVRA}!”, animar positivamente o emoji, celebrar e avançar aproximadamente 1,8 segundo depois. A questão só pode ser registrada uma vez.

#### Progresso, pontuação e estrelas

- **FR-020**: Nos modos com rodada, o jogo DEVE mostrar oito indicadores de questões e uma barra de progresso proporcional às questões concluídas, com representação acessível do total. Depois de k questões concluídas, a barra representa k/8, mesmo quando houve erros.
- **FR-021**: O indicador da questão atual DEVE ser distinguível; questões concluídas sem erro DEVEM usar estado positivo verde e questões concluídas após erro DEVEM usar estado laranja, acompanhados de rótulos acessíveis. Cor sozinha não basta para comunicar o estado.
- **FR-022**: O total de acertos de primeira DEVE aumentar somente ao concluir uma questão sem nenhuma tentativa incorreta. No modo de montagem, a unidade de pontuação é a palavra inteira, não cada letra. Tentativas erradas não reduzem pontuação já obtida.
- **FR-023**: A quantidade de estrelas DEVE ser calculada ao fim de oito questões conforme [rules-spec.md](rules-spec.md). O resultado NÃO DEVE depender de velocidade, quantidade de cliques ou modo escolhido.
- **FR-024**: A celebração DEVE apresentar três posições de estrelas, destacando apenas as conquistadas, e utilizar título, mensagem e reação do tucano correspondentes ao resultado. “Jogar de novo” DEVE manter o modo escolhido e fazer novo sorteio, sem prometer palavras diferentes da rodada anterior.

#### Brincar com o Alfabeto

- **FR-025**: O modo livre DEVE exibir as 26 letras maiúsculas A–Z em ordem e usar exatamente os exemplos definidos em [content-spec.md](content-spec.md).
- **FR-026**: Selecionar uma letra DEVE destacar seu botão, atualizar uma carta com letra, emoji e palavra, e mostrar no balão “{LETRA} de {EXEMPLO}”. A carta entra com animação de virar.
- **FR-027**: A instrução “Toque em uma letra para ouvir 👇” DEVE estar disponível desde a entrada no modo. Nenhuma rodada anterior pode deixar indicadores, feedback de erro ou pontuação nesta tela.
- **FR-028**: Somente a seleção mais recente DEVE controlar carta, destaque e fala pendente. A pronúncia isolada da letra DEVE preceder a frase do exemplo, sem que o jogo interrompa sua própria primeira fala para iniciar a segunda.

#### Mascote, feedback e efeitos

- **FR-029**: O ator **Rômulo Penha** DEVE ser o tucano mascote do jogo, apresentado no canto inferior esquerdo durante jogo e celebração e escondido no menu, conforme a referência. Seu nome na interface e nas descrições acessíveis DEVE usar a grafia **Rômulo Penha**, com acento.
- **FR-030**: O tucano DEVE manter identidade visual com corpo escuro, barriga clara, asa turquesa, pés alaranjados, bico laranja grande com ponta escura e olho branco com pupila. Seu nome DEVE estar disponível como descrição acessível.
- **FR-031**: Acertos DEVEM provocar felicidade com salto; erros DEVEM provocar confusão com inclinação leve; a espera DEVE ter respiração discreta. O balão DEVE apresentar frases curtas de [character-spec.md](character-spec.md), com duração de [animation-spec.md](animation-spec.md) e depois desaparecer suavemente.
- **FR-032**: O tucano e seu balão DEVEM permanecer decorativos para interação: não capturam clique, toque ou foco. O layout DEVE reservar espaço suficiente para evitar que escondam conteúdo essencial, inclusive em telas estreitas.
- **FR-033**: Acertos e erros DEVEM oferecer feedback textual e visual. Quando o som estiver ativo e disponível, DEVEM oferecer também feedback sonoro; jamais depender somente de som ou somente de cor.
- **FR-034**: Os efeitos infantis DEVEM incluir gradiente animado, transições entre telas, preenchimento de espaços, olhos nas letras, reação dos emojis, confete de formas variadas, explosão de estrelas, flash leve de erro, onda no botão correto e brilho na letra escolhida no alfabeto, conforme [animation-spec.md](animation-spec.md).
- **FR-035**: Partículas e sobreposições DEVEM ser temporárias, não capturar interação e desaparecer após seus efeitos. O flash de erro DEVE ocorrer uma vez por feedback, com baixa intensidade, sem estroboscópio.

#### Som e uso acessível

- **FR-036**: A interface, as mensagens e a narração DEVEM usar português brasileiro. O som começa habilitado, mas só pode ser iniciado conforme as permissões de interação do navegador.
- **FR-037**: Menu, jogo e celebração DEVEM apresentar controle de som visível e acessível. Todos compartilham o mesmo estado: 🔊 habilitado e 🔇 desabilitado, com nome acessível e indicação do estado. Desligá-lo DEVE interromper falas e efeitos ativos e agendados e impedir novas emissões até a reativação.
- **FR-038**: A voz DEVE preferir uma voz `pt-BR` local disponível. Falta de suporte, voz ou autorização DEVE resultar em fallback silencioso e instruções textuais completas, preservando todos os modos e a pontuação.
- **FR-039**: Todos os controles DEVEM funcionar com toque, mouse e teclado, ter foco visível e nome acessível. Ícones sozinhos precisam de descrição; emojis decorativos não podem provocar leitura duplicada da palavra.
- **FR-040**: Ao trocar de tela ou questão, o foco DEVE ser colocado em um ponto coerente da nova atividade. Feedback e mudanças de progresso DEVEM ser anunciáveis por leitores de tela sem duplicar a narração e sem leitura contínua das partículas ou do balão decorativo.
- **FR-041**: Controles DEVEM ter área de toque mínima de 44 × 44 pixels; textos comuns DEVEM ter contraste mínimo de 4,5:1 e textos grandes de 3:1. O visual colorido DEVE ser ajustado onde necessário para satisfazer contraste sem perder a paleta.
- **FR-042**: O jogo DEVE respeitar a preferência por movimento reduzido, substituindo animações e partículas por feedback estático equivalente. Transições curtas não são consideradas, por si só, cumprimento desse requisito.
- **FR-043**: O jogo DEVE se adaptar a celular, tablet e computador, em retrato e paisagem, permitir zoom e rolagem quando necessária e manter os controles acessíveis sem sobreposição pelo mascote.

#### Contrato de entrega da implementação

As restrições a seguir definem a entrega vigente. DC-001 foi atualizado pelo pedido explícito de refatoração; DC-008 registra somente o limite histórico da fase documental.

- **DC-001**: Entregar um único `apps/alfabeto-divertido/index.html` de entrada, sem CSS ou JavaScript embutidos. Recursos externos locais, separados por responsabilidade, fazem parte da distribuição da pasta completa. Abertura direta por `file://`, totalmente offline e sem servidor.
- **DC-002**: O artefato NÃO DEVE usar frameworks, bibliotecas externas, CDN, fontes remotas, imagens remotas, serviços de backend ou dependências de rede. Deve funcionar sem instalação, compilação ou servidor local.
- **DC-003**: O mascote DEVE usar SVG inline e as imagens do conteúdo DEVEM preservar os emojis de referência. Efeitos sonoros podem ser sintetizados localmente; não podem depender de arquivos de áudio externos.
- **DC-004**: A narração DEVE usar a funcionalidade nativa **SpeechSynthesis**, com idioma `pt-BR` e preferência por voz brasileira instalada. A disponibilidade de uma voz offline depende do navegador e do sistema; o fallback descrito em FR-038 é obrigatório.
- **DC-005**: Os comentários `CHG-XXX` DEVEM existir nos trechos principais associados aos efeitos e comportamentos da matriz de [animation-spec.md](animation-spec.md). Cada marcador deve corresponder a uma funcionalidade efetivamente presente, não somente a uma menção textual.
- **DC-006**: O arquivo final DEVE abrir sem erros de console e sem exceções não tratadas, inclusive quando áudio ou voz não estiverem disponíveis. Não deve realizar requisições de rede iniciadas pelo jogo.
- **DC-007**: A implementação DEVE preservar as regras, conteúdos e mensagens desta spec e corrigir comportamentos incompletos da referência quando necessário para satisfazer consistência, acessibilidade e cancelamento de ações pendentes.
- **DC-008**: Esta entrega de especificação NÃO DEVE criar o HTML do jogo, componentes, bibliotecas, testes executáveis ou código de aplicação. Esses artefatos pertencem à etapa posterior de implementação.

### Especificações por domínio

Cada documento abaixo é a fonte normativa de seus detalhes; os FR acima continuam identificando os requisitos do produto.

| Domínio | Fonte |
| --- | --- |
| Regras e pontuação | [rules-spec.md](rules-spec.md) |
| Conteúdo pedagógico | [content-spec.md](content-spec.md) |
| Estado e ciclo de vida | [state-spec.md](state-spec.md) |
| Cenas, navegação e textos | [scene-spec.md](scene-spec.md) |
| Ator Rômulo Penha | [character-spec.md](character-spec.md) |
| Animações e matriz CHG | [animation-spec.md](animation-spec.md) |
| Ambiente, tema e distribuição offline | [environment-spec.md](environment-spec.md) |
| Áudio e voz PT-BR | [audio-spec.md](audio-spec.md) |

### Key Entities *(include if feature involves data)*

- **Modo**: Uma das três atividades. Define se existe rodada avaliada ou exploração livre.
- **Palavra de referência**: Texto em maiúsculas e emoji associado; fonte das questões dos dois modos avaliados.
- **Exemplo de letra**: Relação entre uma letra A–Z, palavra de exemplo e emoji.
- **Rodada**: Modo avaliado, oito questões sorteadas, questão atual, resultados por questão e número de acertos de primeira.
- **Questão**: Palavra, imagem, inicial correta e alternativas no primeiro modo, ou sequência de espaços e ocorrências de letras no segundo; inclui registro de qualquer tentativa incorreta e conclusão.
- **Ocorrência de letra**: Um botão individual do conjunto da montagem; distingue letras idênticas e registra se aquela ocorrência já foi consumida.
- **Resultado da questão**: Pendente, concluída sem erro ou concluída depois de erro. Determina indicador de progresso e contribuição para estrelas.
- **Seleção do alfabeto**: Letra escolhida mais recentemente e seu exemplo; sem pontuação.
- **Estado do som**: Habilitado ou desabilitado, compartilhado entre telas durante a sessão.
- **Ator Rômulo Penha**: Tucano mascote que acompanha e incentiva a criança; sua identidade e participação são definidas em character-spec.md.
- **Estado do mascote**: Visibilidade de Rômulo Penha, reação de espera/felicidade/confusão e texto temporário do balão.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Uma pessoa com a pasta final do jogo consegue abrir o menu e iniciar qualquer modo sem instalar ferramentas e com a rede desativada. Todos os elementos visuais e atividades continuam disponíveis.
- **SC-002**: Em dez rodadas completas de cada modo avaliado, todas terminam após exatamente oito questões, sem repetição de palavra dentro da rodada, bloqueio ou avanço duplicado.
- **SC-003**: Os nove resultados possíveis de acertos de primeira, de 0 a 8, produzem exatamente a quantidade de estrelas definida em rules-spec.md. Responder corretamente após erro nunca recupera o crédito de primeira tentativa.
- **SC-004**: As 26 letras apresentam os exemplos corretos; quando há voz brasileira offline disponível e som ativo, cada seleção oferece pronúncia e exemplo em português brasileiro, em sequência coerente. O teste auditivo real V015 é condicionado à disponibilidade dessa voz; o fallback V016 é obrigatório em todos os ambientes-alvo.
- **SC-005**: Em dez sequências de saída, reinício ou troca de modo durante feedback, nenhuma ação da atividade antiga reaparece ou modifica a nova atividade.
- **SC-006**: Todas as ações essenciais dos três modos e da celebração podem ser concluídas somente pelo teclado, com foco visível e sem alcançar controles de telas inativas.
- **SC-007**: Em áreas de visualização de 320 × 568, 390 × 844, 768 × 1024, 1024 × 768 e 1366 × 768, e em zoom de 200%, todo conteúdo essencial permanece alcançável sem sobreposição pelo mascote ou corte permanente de controles. Rolagem pode ser usada quando necessária.
- **SC-008**: No perfil PERF-01 definido em validation.md, cada uma das 20 amostras por cenário oferece retorno visual em até 200 ms, medido do evento de entrada até o ponto conservador de confirmação visual definido naquele perfil. O perfil fixa viewport de 768 × 1024, zoom de 100%, CPU desacelerada 4×, rede desligada e som desligado, com máquina e versões registradas. Acertos e erros também são compreensíveis com movimento reduzido.
- **SC-009**: Depois de desabilitar o som, nenhuma nova fala ou efeito sonoro ocorre nas próximas questões ou telas até a reativação. Desabilitar o áudio não altera progresso ou pontuação.
- **SC-010**: A verificação de todos os fluxos principais, letras repetidas, cliques rápidos e fallback de voz não encontra erros de execução nem controles inacessíveis.

## Assumptions

- O público principal são crianças em alfabetização; a faixa etária exata não foi fixada. Um responsável pode abrir o arquivo e orientar a primeira interação.
- A referência fornecida é a base de identidade e conteúdo; não foi fornecido um segundo layout ou captura visual para substituir seu estilo.
- O modo Alfabeto permanece livre. A exigência de oito questões vale para os dois modos avaliados, como no código de referência.
- Não há exigência de login, perfis, cadastro de criança, histórico persistente, ranking, sincronização, impressão, instalação como aplicativo ou painel administrativo.
- Pontuação, rodada e preferência de som podem existir apenas durante a sessão. Ao recarregar, retorna ao menu e ao som habilitado; persistência entre aberturas está fora do escopo.
- Navegadores modernos em computador, celular e tablet são o ambiente-alvo. A entrega deve registrar os navegadores efetivamente verificados; não se exige compatibilidade com navegadores obsoletos.
- Voz brasileira offline instalada é uma dependência opcional do ambiente para narração. O aprendizado e a execução não podem depender dela. A aparência dos emojis pode variar entre sistemas.
- A barra de progresso solicitada complementa os oito indicadores da referência; não substitui a distinção entre questões sem erro e com tentativa.
- Completar a inicial da pista após acerto, remover feedback de erro depois de um encaixe correto e aplicar a reação positiva do emoji também na montagem são correções de coerência visual; não mudam pontuação, conteúdo ou regras.
- As durações indicadas seguem a referência e admitem pequenos ajustes para legibilidade, sem atrasar indefinidamente o fluxo nem alterar a regra de avanço após acerto.
- A constituição 1.0.0 reconhece unidades lógicas testáveis, agora separadas por responsabilidade e exige testes locais antes da entrega, com CI adicional quando configurada. As regras de CLI aplicam-se somente a ferramentas ou bibliotecas efetivamente expostas; não exigem criar uma CLI para o jogo. A implementação deve validar os fluxos sem introduzir dependências de rede ou ferramentas no pacote entregue.
- Nesta fase, o usuário autorizou complementar a especificação com proposta, design, plano, tarefas e validação em Markdown. Gerar esses documentos não inicia automaticamente a implementação nem a execução de testes.
