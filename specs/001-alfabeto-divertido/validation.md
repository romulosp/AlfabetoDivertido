# Validation — Plano de aceitação e registro de evidências

**Data**: 2026-10-04  
**Estado do jogo**: Implementado; automação desktop aprovada; aceite manual pendente.
**Base**: [SPEC](spec.md), [Design](Design.md), [plano](plan.md), [contratos](contracts/ui-contract.md)

Este arquivo registra evidências reais. Chrome e Edge foram testados em file:// com navegador offline. Resultados automáticos não comprovam celular real, leitura assistiva, escuta da pronúncia ou zoom nativo.

## Estratégia

1. Antes da fundação, escrever T004–T005 em `tests/alfabeto.spec.mjs`: regras e fluxo integrado, mais detecção/falha de APIs, voz local/remota/ausente/tardia, mute ativo/agendado, foco, cancelamento e movimento reduzido. Somente depois implementar T006–T013. Antes de cada refinamento posterior, escrever seus cenários novos.
2. Usar sorteio determinístico e vozes simuladas apenas no ambiente de testes, sem controles de teste no jogo.
3. Validar no navegador o futuro `apps/alfabeto-divertido/index.html` aberto diretamente por URL de arquivo; observar console e tentativas de rede desde a abertura.
4. Executar conferência manual com rede realmente desativada para voz local, pronúncia, aparência e uso assistivo.
5. Antes da entrega, executar obrigatoriamente a suíte crítica local e, quando houver CI configurada, executá-la também na CI. Registrar comando, ambiente, versão semântica, hash e resultados. Repetir regressão após correções relevantes.

Simulações comprovam chamadas e sequência esperada de fala, não existência de voz instalada. Em cada navegador alvo, o fallback sem voz é obrigatório; quando houver voz local disponível, sua qualidade e funcionamento offline também devem ser conferidos.

## Ambientes e evidências necessárias

| Item | Registrar na execução futura |
| --- | --- |
| Artefato | Nome, data, versão semântica e hash SHA-256 de `apps/alfabeto-divertido/index.html` |
| Máquina de referência | Modelo da CPU, RAM, sistema, modo de energia e identificação não pessoal; registrar antes dos testes e manter o mesmo ambiente durante a série |
| Navegador | Nome, versão e sistema operacional |
| Automação | Ferramenta, versão, comando exato, saída e resultado local; identificar a execução da mesma suíte crítica em CI quando configurada |
| Rede | Desativada para teste offline real; método utilizado |
| Voz | Nome, idioma, origem local, ou ausência de voz disponível |
| Entrada | Toque, mouse, teclado e leitor de tela utilizado |
| Visualização | Dimensões, orientação, zoom e preferência de movimento |
| Resultado | Aprovado, falhou, bloqueado, parcial ou pendente; Não aplicável permitido somente para V015, com inventário e justificativa revisados |
| Revisão | Identidade de ao menos um revisor aprovador, data e referência às evidências revisadas |

Mínimo de aceitação: dois navegadores desktop distintos, um navegador móvel real e um leitor de tela. A matriz de tamanhos pode ser automatizada; ela não substitui o teste de toque e abertura do arquivo no dispositivo móvel. Quando o sistema móvel dificultar acesso a arquivos locais, registrar método de abertura e resultado real, sem alegar que uma emulação comprovou esse comportamento.

## Perfil de desempenho PERF-01

O dispositivo de referência deste perfil é a estação desktop de validação, registrada em T002, executando Chromium com viewport de tablet e CPU desacelerada. É um benchmark reproduzível sobre hardware identificado, não uma alegação de equivalência a qualquer tablet físico.

| Parâmetro | Valor obrigatório |
| --- | --- |
| Ambiente | Mesma máquina registrada em T002; registrar modelo da CPU, RAM, sistema, modo de energia, versões do navegador e runner |
| Navegador | Chromium em primeiro plano, com sessão dedicada, uma página de teste e um worker; sem avanço artificial de relógio |
| CPU | Desaceleração 4×, aplicada pelo mecanismo de emulação do navegador e registrada no relatório |
| Visualização | 768 × 1024 CSS px, escala do dispositivo 1, zoom 100%, movimento normal |
| Conectividade e áudio | Arquivo local carregado, rede desligada, som desligado; não aguardar voz para medir feedback |
| Preparação | Dois acionamentos de aquecimento por cenário, descartados; preparar nova questão/seleção antes de cada amostra |
| Cenários | Inicial correta, inicial errada, encaixe intermediário correto, encaixe errado, palavra concluída e escolha de letra no alfabeto |
| Amostragem | 20 amostras medidas por cenário, 120 no total; sorteio/entradas determinísticos e estado válido |
| Início | Captura do evento de entrada que aciona o botão, usando relógio monotônico da página; a latência de envio do comando externo não entra no cálculo |
| Confirmação visual | Detectar a alteração de DOM que representa o estado esperado e confirmar que está visível na tela ativa; concluir a medição no segundo callback consecutivo de requestAnimationFrame após essa alteração |
| Aprovação | Cada uma das 120 amostras ≤200 ms; registrar valores brutos, máximo e ambiente; não aprovar somente pela média ou descartando amostras lentas |

O segundo callback confirma a passagem por um ciclo de renderização após a atualização e é a referência conservadora adotada para este teste. Ele não mede latência física do monitor. Inspecionar a gravação visual de ao menos uma amostra de cada cenário para conferir o estado esperado. Se o estado esperado não surgir ou não estiver visível, a amostra falha; não omiti-la do resultado. Registrar impedimentos do ambiente como Bloqueado e reexecutar a série completa após resolvê-los.

Medições em dispositivo móvel real complementam este benchmark; a verificação de responsividade/toque desse dispositivo permanece obrigatória em V020. Não alterar hardware, viewport, fator de CPU, relógio ou número de amostras entre execução e reteste sem registrar um novo ambiente e reexecutar a série inteira.

## Escopo incremental dos casos

Durante a implementação, executar apenas o recorte correspondente a atividades já disponíveis. Identificar a história e o escopo em cada evidência. Um recorte aprovado não significa que o caso multimodo completo foi aprovado.

| Marco | Casos disponíveis e limite |
| --- | --- |
| Fundação | Testes das regras e serviços implementados; fluxos completos de modos ainda ausentes têm falha esperada identificada e não são declarados aprovados |
| US1 | V003–V005 e V008; recortes de V001/V002 em menu, inicial e celebração mínima; V006/V007 somente em Primeira Letra; V009 com saída e reinício da mesma atividade; V019 somente nas telas disponíveis |
| US2 | V010–V012; completar V006–V008 nos dois modos avaliados e regressão de US1; não exigir alfabeto antes de US3 |
| US3 | V013–V014; completar os recortes de entrada/troca de modo de V001/V002/V009 nas três atividades |
| US5 e US4 | Completar os casos transversais e estados finais; conferir todos os recortes restantes antes do gate final |
| Aceitação final | Escopo completo dos 28 casos incondicionais, mais V015 quando aplicável; nenhum recorte restante pode ser silenciosamente omitido |

## Aplicabilidade da voz real

V015 é condicional por ambiente: executá-lo quando SpeechSynthesis oferecer voz local PT-BR. Se não houver voz local PT-BR, registrar inventário de vozes reais (ou ausência da API), navegador/sistema, data e aprovação do revisor para classificar somente V015 como **Não aplicável** nesse ambiente.

Não aplicável não é Aprovado e não comprova narração offline. Se uma voz local estiver presente mas o jogo a selecionar ou usar incorretamente, o caso falha. V016, incluindo ausência de voz e rejeição de voz remota, é sempre obrigatório. Problemas de acesso a celular, leitor de tela ou outros recursos obrigatórios continuam Bloqueados; não recebem essa exceção de voz.

## Casos de validação

Parcial indica somente escopo automático aprovado, com verificação manual pendente; não é aprovação integral. Os 28 casos diferentes de V015 são incondicionais. V015 é obrigatório quando houver voz local PT-BR e aceita Não aplicável somente pela regra acima. “Pendente” significa que existe roteiro, mas ainda não há resultado.

| ID | Procedimento e entrada | Resultado esperado | Método | Estado |
| --- | --- | --- | --- | --- |
| V001 | Abrir arquivo local com rede desligada; usar os três modos com som desligado | Menu, figuras, jogo e celebração disponíveis; zero erros de execução e requisições iniciadas pelo jogo | Automação + manual offline | Parcial: offline no navegador; conferência manual pendente |
| V002 | Conferir menu, ordem, título, ícones, descrições e entrada em cada modo | Textos exatos da SPEC; somente três modos; mascote escondido no menu | Visual + integração | Aprovado |
| V003 | Abrir questão de inicial com palavra conhecida, como GATO | Pergunta, 🐱, ?ATO e três letras distintas; G incluído uma vez; opções embaralhadas | Integração determinística | Aprovado |
| V004 | Errar inicial e depois acertar; repetir erro em outra questão | Mesmo índice até acerto; mensagem correta; sem crédito de primeira após qualquer erro | Integração | Aprovado |
| V005 | Acertar inicial com dois acionamentos rápidos e alternar erro/acerto imediatamente | Um resultado e um avanço; nenhuma limpeza atrasada apaga acerto; opções bloqueadas após conclusão | Integração | Aprovado |
| V006 | Concluir dez rodadas de cada modo avaliado | Cada uma tem 8 palavras distintas e termina na oitava, sem nona questão, bloqueio ou avanço duplo | Automação | Aprovado |
| V007 | Exercitar totais de primeira tentativa de 0 a 8 em ambos os modos | 0–4 = 1 estrela; 5–7 = 2; 8 = 3; pontuação por palavra, sem arredondamento incorreto | Regras + integração | Aprovado |
| V008 | Observar progresso antes e depois de cada questão, com e sem erro | Oito indicadores; atual distinguível; sem erro verde, com erro laranja; barra só incrementa na conclusão até 100% | Integração + leitura acessível | Aprovado |
| V009 | Acertar e sair antes do avanço; iniciar outro modo; aguardar além do atraso anterior | Novo modo não sofre avanço antigo, fala residual, troca de tela ou mudança de pontuação | Integração | Aprovado |
| V010 | Montar palavra conhecida de 3 letras e de 4 letras na ordem correta | Um espaço por letra; conjunto exato; consumo individual; próximos espaços destacados; conclusão única | Regras + integração | Aprovado |
| V011 | Montar CASA, BOLO e OVO com ocorrências repetidas; reativar botão usado por teclado e toque | Consumir somente ocorrência escolhida; repetir letra com outra ocorrência; botão usado não pode atuar | Regras + integração + teclado | Aprovado |
| V012 | Errar encaixe antes e depois de letras corretas e concluir palavra | Erro não consome letra nem preenche; fica registrado; encaixe correto limpa orientação de erro; sem crédito de primeira | Integração | Aprovado |
| V013 | No alfabeto, tocar rapidamente A, B e Z; sair durante a fala | Carta, balão e seleção representam Z; callbacks antigos não reaparecem; saída limpa sequência | Integração com fala simulada | Aprovado |
| V014 | Selecionar todas as 26 letras, inclusive K, W, X e Y; repetir a mesma letra | Exemplos exatos; sequência letra + exemplo; modo sem pontuação/rodada; repetição permite ouvir novamente | Integração + visual | Aprovado |
| V015 | Quando houver voz local PT-BR, com rede desativada, ouvir perguntas, erro, acerto, letra e exemplo; caso ausente, registrar inventário e justificativa | Voz inteligível e sequência coerente quando aplicável; somente ausência comprovada admite Não aplicável revisado; não dispensa V016 | Manual auditivo offline, condicional | Pendente: escuta; voz local presente |
| V016 | Simular ausência de SpeechSynthesis, ausência de voz local, voz somente remota e falha de Web Audio | Três modos continuam; instruções e resultados textuais; nenhuma tentativa de voz remota nem erro não tratado | Integração por falha de API | Aprovado |
| V017 | Começar sem vozes e disponibilizar voz local posteriormente; escolher nova letra | Jogo não bloqueia na espera; futuras falas usam voz válida; nenhuma fala de escolha antiga reaparece | Integração com voiceschanged | Aprovado |
| V018 | Usar os controles visíveis de menu, jogo e celebração; desligar durante fala/efeitos, trocar telas e religar | Controles acessíveis nas três telas e sincronizados; interromper fala/sons ativos/agendados; nenhuma retomada residual; regras inalteradas | Integração + auditivo | Parcial: fontes/fala canceladas; escuta pendente |
| V019 | Percorrer todos os modos só com Tab, Enter, Espaço e Escape; usar leitor de tela | Foco visível e coerente; sem foco em telas ocultas; nomes, estados e feedback compreensíveis sem duplicação excessiva | Manual assistivo + automação | Parcial: teclado aprovado; leitor de tela pendente |
| V020 | Testar 320×568, 390×844, 768×1024, 1024×768 e 1366×768, retrato/paisagem quando aplicável | Conteúdo alcançável, rolagem possível, sem corte de controles ou sobreposição visual do ator/balão | Capturas + dispositivo real | Parcial: emulação aprovada; celular real pendente |
| V021 | Aplicar zoom de 200% e navegar até os últimos controles | Textos legíveis; botões alcançáveis; mascote não encobre instrução ou feedback; zoom permitido | Manual visual | Parcial: zoom CSS aprovado; zoom nativo pendente |
| V022 | Ativar movimento reduzido antes de abrir e durante jogo | Sem gradiente em movimento, partículas, pulsos, giros, flash ou saltos; feedback estático completo | Emulação + manual | Aprovado |
| V023 | Observar Rômulo Penha em espera, acerto, erro, alfabeto e menu | Aparência e nome corretos; balão cerca de 2,2 s; felicidade/confusão; canto inferior esquerdo sem capturar interação | Visual + leitura acessível | Aprovado |
| V024 | Encerrar rodadas nas três faixas de estrelas | Três posições; quantidade, títulos e mensagens exatos; ator feliz; confete só com movimento permitido | Integração + capturas | Aprovado |
| V025 | Jogar de novo após cada faixa de resultado | Mesmo modo, novo sorteio e estado zerado; não herda estrelas, tentativas ou palavra parcialmente preenchida | Integração | Aprovado |
| V026 | Executar PERF-01 com ambiente registrado, 20 amostras por cenário e valores brutos; examinar contraste e alvos de toque | Cada uma das 120 amostras ≤200 ms; contraste 4,5:1/3:1 conforme texto e toque ≥44×44 px | PERF-01 + inspeção | Aprovado |
| V027 | Inspecionar arquivo e conteúdos; conferir matriz CHG com movimento normal | Um HTML de entrada sem CSS/JS embutidos, quatro CSS e oito módulos JS locais; 29 palavras, 26 exemplos e 16 marcadores com comportamentos reais; sem fontes remotas, imports externos ou recursos remotos | Revisão estática + visual | Aprovado |
| V028 | Executar dez ciclos de saída/reinício/troca durante feedback, montagem e fala | Nenhum estado antigo contamina novo modo; Escape/menu funcionam em jogo e celebração | Integração | Aprovado |
| V029 | Usar jogo por ao menos 15 min, repetindo acertos, erros e modos; revisar testes e resultados | Sem erros não tratados ou crescimento contínuo de partículas/temporizadores; testes escritos antes dos comportamentos; evidências identificadas | Sessão automática real + revisão | Aprovado: sessão automática real + revisão |

## Rastreabilidade dos requisitos

| Requisitos da SPEC | Casos principais |
| --- | --- |
| FR-001, FR-002, FR-003 | V002, V019 |
| FR-004, FR-005 | V006, V014, V025 |
| FR-006, FR-007 | V009, V018, V019, V025, V028 |
| FR-008, FR-009, FR-010 | V003, V005, V027 |
| FR-011, FR-012 | V004, V005, V009 |
| FR-013, FR-014, FR-015 | V010, V027 |
| FR-016 | V011 |
| FR-017, FR-018, FR-019 | V010, V012, V027 |
| FR-020, FR-021 | V008, V019 |
| FR-022, FR-023 | V004, V007, V012 |
| FR-024 | V024, V025 |
| FR-025, FR-026, FR-027, FR-028 | V013, V014, V027 |
| FR-029, FR-030, FR-031, FR-032 | V020, V021, V023 |
| FR-033, FR-034, FR-035 | V004, V012, V022, V027, V029 |
| FR-036, FR-037, FR-038 | V015, V016, V017, V018 |
| FR-039, FR-040 | V019 |
| FR-041 | V026 |
| FR-042 | V022 |
| FR-043 | V020, V021 |
| DC-001, DC-002, DC-003, DC-005, DC-006 | V001, V027 |
| DC-004 | V015, V016, V017 |
| DC-007 | V002–V028 e revisão de mensagens/conteúdo |
| DC-008 | Revisão documental desta fase: nenhum arquivo de aplicação ou teste executável criado |

| Critério de sucesso | Evidência |
| --- | --- |
| SC-001 | V001 |
| SC-002 | V006 |
| SC-003 | V007 |
| SC-004 | V014, V015 |
| SC-005 | V009, V028 |
| SC-006 | V019 |
| SC-007 | V020, V021 |
| SC-008 | V022, V026 |
| SC-009 | V018 |
| SC-010 | V005, V011, V013, V016, V019, V029 |

## Revisão visual e efeitos

Capturar futuramente: menu; inicial antes da resposta, após erro e após acerto; montagem incompleta, com erro e completa; carta do alfabeto; cada faixa de celebração; tela de 320 px com balão visível; movimento reduzido.

Conferir os 16 marcadores da matriz CHG de animation-spec.md contra o comportamento da página. Comentário presente sem efeito implementado não passa V027. Com movimento reduzido, confirmar equivalente estático em vez de reprovar por ausência intencional do movimento.

## Condições para aceitar a implementação

- Os 28 casos incondicionais executados e aprovados com versão e ambiente identificados; V015 aprovado onde houver voz local ou Não aplicável com inventário e aprovação revisada onde ela não existir. Nenhum caso final pode permanecer pendente, falhado ou bloqueado.
- Suíte crítica automatizada aprovada localmente antes da entrega, com comando e saída registrados; a mesma suíte aprovada na CI quando ela estiver configurada, conforme a constituição 1.0.0.
- Nenhum defeito aberto que impeça modo, pontuação, saída, offline, teclado ou acesso visual a controles.
- Testes simulados e testes reais de voz claramente diferenciados.
- Falta de voz local registrada como cenário de fallback aprovado, não como comprovação de narração offline.
- Revisão do código aprovada por ao menos um revisor identificado antes da entrega; nenhum comentário CHG órfão de comportamento.
- Somente `apps/alfabeto-divertido/index.html` exigido para a criança jogar; testes e documentos não são dependências de execução.

## Registro de execução

Preservar histórico de falhas e correções. Os estados acima correspondem às evidências de execução abaixo; não aprovar partes manuais somente por simulação.

| Data | Versão do artefato | Ambiente | Casos | Resultado | Evidência/observação |
| --- | --- | --- | --- | --- | --- |
| 2026-10-04 | Sem artefato de jogo | Revisão documental | Links, cobertura e consistência do pacote | Documentos revisados | Nenhuma execução do jogo; V001–V029 pendentes |

## Registro de defeitos

| ID | Caso relacionado | Sintoma observado | Impacto | Estado | Correção e reteste |
| --- | --- | --- | --- | --- | --- |
| — | — | Nenhum defeito funcional aberto na automação desktop | Limites manuais registrados | Aguardando aceite manual | Evidências abaixo |

## Ambiente registrado antes da implementação

- CPU: Intel Core i5-13600KF, 20 processadores lógicos; RAM visível: 33375076 KiB.
- Sistema: Windows 10 Pro 10.0.19045; energia: Equilibrado.
- Node 24.16.0; Playwright 1.63.0, somente testes.
- Chrome 154.0.8037.97; Edge 154.0.4258.53.
- Sem Git/CI, Docker, ESLint, Prettier, Terraform, Helm ou publicação npm. Ignores específicos não se aplicam.
- T004/T005 falharam antes do HTML: tests/evidence/red-foundation.txt. Falhas de modos ainda ausentes não foram aprovadas.
- PERF-01: Chromium visível em primeiro plano, CPU 4×, 768×1024/DPR 1, zoom 100%, movimento normal, 120 amostras, rede/som desligados, relógio real.

## Histórico 1.0.0 — Execução da implementação — 2026-10-04

**Artefato**: `apps/alfabeto-divertido/index.html`; versão 1.0.0; 42.614 bytes.

**SHA-256**: `95d43079b6da26a5fb5949729060dcbc173060900381944ab6e10afbf2b5e96d`.

| Verificação | Comando/método | Resultado e evidência |
| --- | --- | --- |
| Suíte Chrome 154.0.8037.97 | `node --test --test-concurrency=1 tests/alfabeto.spec.mjs` | 18 aprovados, zero falhas; tests/evidence/suite-chrome.txt e tests/evidence/chrome/results-chrome.json |
| Suíte Edge 154.0.4258.53 | Definir `$env:BROWSER_CHANNEL='msedge'` e executar o mesmo comando | 18 aprovados, zero falhas; tests/evidence/suite-msedge.txt e tests/evidence/msedge/results-msedge.json |
| Console/rede | Captura desde file://, context offline | Zero erros/exceções e zero requisições HTTP do jogo em toda a suíte |
| Regras/fluxos | Sorteio determinístico, 9 pontuações em ambos os modos, 10 rodadas por modo, 10 ciclos de cancelamento | Passaram; resultados das suítes |
| Vozes reais | SpeechSynthesis em Chrome e Edge | Microsoft Daniel e Microsoft Maria, pt-BR, localService true; voices-*.json em cada pasta de navegador |
| Sequência nativa offline | Acionar Z com API real; observar término | “Z” e “Z de ZEBRA” em pt-BR local terminaram sem erro nos dois navegadores; native-speech-*.json; não avalia inteligibilidade auditiva |
| Fallback/mute | Ausência/falha de APIs/voz, voz remota/tardia, erro de fala; fontes ativas/agendadas | Passou; erro de fala ativa aria-live polite; mute encerra fontes e não retoma fila antiga |
| Layout/movimento | 6 dimensões, incluindo paisagem 568×320; controles, teclado, zoom CSS e mudança real de media query | Passou na emulação; PNGs por navegador; não substitui celular real, zoom nativo ou leitor de tela |
| Contraste | 69 amostras de texto em menu/3 modos/celebração; composição de fundos e limites 4,5/3 | Zero falhas; tests/evidence/contrast-review.json |
| PERF-01 | Definir `$env:RUN_PERF='1'`; `node --test --test-concurrency=1 --test-name-pattern='^performance:' tests/alfabeto.spec.mjs` | 120/120 aprovadas; máximo 28,6 ms na série final; tests/evidence/chrome/perf-01.json e tests/evidence/perf-run.txt |
| Revisão estática/visual | Codex: auto-revisão de fonte, telas, estrelas e mascote; conferir links/CHG/conteúdo | 43 FR, 8 DC, 10 SC, 16 marcadores e links conferidos; tests/evidence/artifact-review.json; aceite final pendente |

PERF-01 foi repetido depois dos refinamentos de fallback. A segunda série ocorreu durante a sessão de duração em outro processo Chrome headless; o benchmark tinha sessão dedicada, uma página e um worker. Essa carga adicional está registrada para não omitir condições de execução. Ambas as séries respeitaram o limite em todas as amostras.

Na suíte regular, desempenho e duração aparecem como ignorados porque são acionados separadamente pelos comandos específicos. Não somá-los como aprovados sem executar esses comandos.

## Limites do aceite atual

- V001: falta conferência manual com conexão do dispositivo realmente desligada; browser offline já foi testado.
- V015: há voz local PT-BR; o caso se aplica e não recebe Não aplicável. Falta escuta da inteligibilidade/perguntas/feedback/exemplos.
- V018: cancelamento de fala/fontes verificado por simulação/API nativa; falta conferência auditiva completa.
- V019: teclado, foco e nomes acessíveis testados; falta leitor de tela real.
- V020: layouts/toque emulados; falta abrir e jogar no celular real.
- V021: zoom CSS de 200% conferido; falta zoom nativo do navegador.
- Gate final T053 não aprovado. T054/T055 receberam atualização informativa antecipada; conclusão formal depende de T053. T056 depende desse gate.
- Nenhuma CI configurada ou execução em CI alegada. A suíte crítica local passou.

A checklist documental permanece intacta: 22 itens revisados não equivalem à aprovação dos testes manuais.

## Histórico 1.0.0 — Resultado do teste de duração

- Comando: definir `$env:RUN_SOAK='1'` e executar `node --test --test-concurrency=1 --test-name-pattern='^soak:' tests/alfabeto.spec.mjs`.
- Duração real: 912.171 s; 71 ciclos pelos três modos; 639 ações de alto nível (respostas de montagem agrupadas).
- 213 verificações após saída: todas com zero temporizadores, fontes de áudio e partículas; zero erros de console/exceções/requisições HTTP na sessão.
- V029 executado como sessão automatizada de tempo real, com revisão dos registros; não usa avanço artificial de relógio. Esse método verifica a repetição/limpeza diretamente e está explicitado em lugar do roteiro manual de duração.
- Evidências: `tests/evidence/chrome/soak.json` e `tests/evidence/soak-run.txt`. T051 concluída.
- Trocas rápidas de tela durante transições passaram nos dois navegadores: `tests/evidence/transitions-chrome.txt` e `tests/evidence/transitions-msedge.txt`.
- Uma cópia em pasta temporária sem arquivos de apoio abriu os três modos offline, sem erros e com SHA-256 idêntico: `tests/evidence/standalone-review.json`. A cópia de teste foi removida; o arquivo de aplicação era único na versão 1.0.0. A versão 2.0.0 distribui a pasta completa.

23 casos incondicionais aprovados; V001/V018/V019/V020/V021 parcialmente verificados, e V015 auditivo pendente. O gate final permanece pendente dessas evidências manuais.

## Refatoração modular — versão 2.0.0 (2026-10-04)

**Distribuição vigente**: a pasta `apps/alfabeto-divertido/`, com 13 arquivos: um HTML de entrada, quatro CSS e oito JS externos locais. Não há blocos CSS/JS embutidos nem dependências de execução instaláveis. Copiar a pasta completa; o teste isolado de um HTML da versão anterior não se aplica a esta distribuição.

**Testes antes da mudança**: `tests/modular.spec.mjs` foi escrito e falhou no contrato de ausência de blocos embutidos antes da extração. A suíte existente foi adaptada para carregar regras externas em VM sem DOM e usar aliases exclusivamente injetados pelo harness. O produto expõe somente o namespace da aplicação.

| Evidência atual | Resultado |
| --- | --- |
| Chrome: `node --test --test-concurrency=1 tests/modular.spec.mjs tests/alfabeto.spec.mjs` | 21 aprovados, 0 falhas; 2 testes opt-in não executados pela suíte regular |
| Edge: mesmo comando com `BROWSER_CHANNEL=msedge` | 21 aprovados, 0 falhas; 2 opt-in ignorados |
| `tests/evidence/modular/chrome/results-chrome.json` e `msedge/results-msedge.json` | 18 casos funcionais por navegador; console sem erros e sem HTTP nas execuções |
| `tests/evidence/modular/relocated-chrome.json` e `relocated-msedge.json` | Cópia da pasta em caminho temporário com espaços; três modos abertos por file://, rede bloqueada, sem erros ou vazamento de `window.state` |
| `tests/modular.spec.mjs` | Contrato de um HTML/quatro CSS/oito scripts defer, arquivos locais, regras de erro persistente, ocorrências independentes e resultado único |
| `tests/evidence/modular/artifact-review.json` | Manifesto de todos os 13 arquivos, tamanho e SHA-256 individual; revisão Codex, aceite humano pendente |
| Capturas em `tests/evidence/modular/chrome/` e `msedge/` | Menu, três modos, três faixas de estrelas, efeitos e seis viewports; revisão visual direta da montagem em 320px e celebração em 1024px |
| Consistência documental | 43 FR, 8 DC e 10 SC preservados; oito specs de domínio; links locais existentes; matriz única dos 16 CHG em animation-spec.md; catálogos transferidos e origem substituída por links |

**Cobertura de cancelamento atual**: sequências de troca de atividade e dez rodadas por modo, respostas rápidas, callback tardio de voz, APIs ausentes/falhas, mute, mudança de movimento reduzido e zero transientes após saída. A duração real de 15 minutos registrada acima pertence à versão 1.0.0 e não foi reexecutada nesta refatoração.

**Aceite humano pendente**: celular real, leitor de tela, escuta/pronúncia PT-BR, rede desativada no dispositivo e zoom nativo de 200%. Simulações de toque, voz e zoom CSS não substituem essas verificações. T063 mantém a revisão final pendente; nenhum aceite foi atribuído ao usuário.

**PERF-01 atual**: 120 amostras válidas (20 em cada um dos seis cenários), todas ≤200 ms; máximo 28.70 ms. Chrome 154.0.8037.97, CPU 4×, viewport 768 × 1024, DPR 1, relógio real, navegador visível, offline e som desligado. Comando: `RUN_PERF=1 node --test --test-concurrency=1 --test-name-pattern='^performance:' tests/alfabeto.spec.mjs`. Valores brutos em `tests/evidence/modular/chrome/perf-01.json`; saída em `perf-run.log`. T057–T062 concluídas; T063 permanece pendente de aceite humano.
