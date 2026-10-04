# Research — Decisões para implementação

**Data**: 2026-10-04  
**Estado**: Decisões aplicadas; ambiente e execuções em validation.md.  
**Contexto**: [SPEC](spec.md), [Design](Design.md)

As fontes primárias abaixo descrevem as capacidades utilizadas. As decisões sobre seu uso no jogo são inferências de projeto orientadas pelas restrições do usuário. Não há promessa de disponibilidade universal de voz ou ferramenta de testes.

## R01 — Artefato e organização (atualizado para 2.0.0)

**Decisão**: Um HTML de entrada, quatro CSS por camada e oito módulos JS coesos externos locais. Distribuição da pasta completa, sem framework, servidor ou compilação.

**Justificativa**: O pedido de refatoração substituiu o formato anterior em um arquivo. Scripts clássicos `defer` com IIFEs e namespace único atendem à separação e à abertura direta. `defer` preserva a ordem declarada e executa após o parsing; módulos nativos podem causar CORS em `file://`. Fontes primárias: [MDN: JavaScript modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules) e [MDN: script/defer](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/script). A opção por IIFEs é uma decisão do projeto a partir desses contratos.

**Alternativas**: ESM com servidor, bundler ou loader acrescentariam requisitos que o usuário excluiu. Manter tudo embutido contraria o novo escopo. Não há evidência de menor custo de renderização só por modularizar; medir PERF-01 novamente.

**Fontes normativas**: DC-001–DC-003 e [environment-spec.md](environment-spec.md). Histórico: versão 1.0.0 usava um HTML com recursos internos.

## R02 — Voz brasileira offline

**Decisão**: Consultar vozes na abertura e em `voiceschanged`, escolher voz local `pt-BR` e manter texto como fallback quando ela não existir ou falhar. Não escolher voz remota como alternativa offline.

**Justificativa**: A lista de vozes vem do ambiente; `localService` distingue serviço local de remoto. Não se pode prometer voz brasileira instalada. [MDN: getVoices](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis/getVoices), [MDN: localService](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisVoice/localService), [MDN: voiceschanged](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis/voiceschanged_event).

**Alternativas consideradas**: Usar voz padrão sem verificar idioma/origem ou baixar voz. Poderiam narrar em outro idioma ou exigir conexão.

## R03 — Sequência e interrupção da narração

**Decisão**: No alfabeto, pronunciar a letra e iniciar o exemplo após o término da letra; tratar erro sem bloquear o jogo. Cancelar a fila ao silenciar ou trocar de contexto e ignorar retornos de contextos invalidados.

**Justificativa**: O tempo de fala depende da voz; um atraso fixo pode cortar a própria letra. `cancel()` limpa a fila e interrompe a fala. [MDN: end](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisUtterance/end_event), [MDN: error](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisUtterance/error_event), [MDN: cancel](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis/cancel).

**Alternativas consideradas**: Aguardar sempre 800 ms ou deixar falas antigas em fila. Não garantem correspondência entre seleção e narração.

O avanço das questões segue o tempo visual da SPEC e não depende do término da fala. Uma falha da API não pode criar espera indefinida.

## R04 — Efeitos sonoros locais e mute

**Decisão**: Gerar efeitos com Web Audio após interação permitida; controlar fontes ativas e agendadas para interrompê-las ao silenciar ou abandonar a atividade.

**Justificativa**: Sons podem ser sintetizados sem arquivos externos. Suspender um contexto sozinho não equivale a descartar fontes antigas. [MDN: boas práticas](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Best_practices), [MDN: stop](https://developer.mozilla.org/en-US/docs/Web/API/AudioScheduledSourceNode/stop), [MDN: suspend](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/suspend).

**Alternativas consideradas**: Arquivos remotos ou mudar apenas um booleano. A primeira exige rede; a segunda pode deixar sons ativos tocando.

## R05 — Telas inativas e foco

**Decisão**: Retirar telas inativas da interação e da árvore acessível, usando `hidden` após a transição e `inert` na saída enquanto visível. Transferir foco para ponto lógico da tela ativa e evitar ocultar o elemento que ainda mantém foco.

**Justificativa**: Opacidade e bloqueio de ponteiro não retiram controles da navegação por teclado. [MDN: hidden](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/hidden), [MDN: inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert), [W3C: ordem de foco](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html).

**Alternativas consideradas**: Apenas opacidade, `pointer-events` ou `aria-hidden`. Não cobrem sozinhos visual, foco e leitura assistiva.

## R06 — Movimento reduzido

**Decisão**: Consultar a preferência no estilo e na criação de efeitos; responder a mudanças durante a sessão. Não gerar partículas quando movimentos estiverem reduzidos.

**Justificativa**: Desativar somente animação CSS não impede a criação de partículas. A preferência precisa orientar a experiência inteira. [MDN: prefers-reduced-motion](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/%40media/prefers-reduced-motion).

**Alternativas consideradas**: Considerar animação de 350 ms acessível por ser curta. A duração não atende, por si só, a preferência do usuário.

## R07 — Validação externa ao jogo

**Decisão**: Planejar testes de desenvolvimento em `tests/alfabeto.spec.mjs` com Playwright. A ferramenta pertence somente à validação; o jogo entregue continua sendo exclusivamente `apps/alfabeto-divertido/index.html`, sem importá-la ou requerê-la.

**Justificativa**: A constituição pede testes antes da implementação. Inicialização controlada permite simular vozes, falhas e sorteio sem controles de teste na interface. A documentação define `page.addInitScript`; a suíte oficial inclui navegação para arquivos locais. [Playwright: addInitScript](https://playwright.dev/docs/api/class-page#page-add-init-script), [Playwright: navegação local](https://github.com/microsoft/playwright/blob/main/tests/page/page-goto.spec.ts).

**Alternativas consideradas**: Testes dentro do HTML entregue ou somente cliques manuais. A primeira polui a entrega; a segunda não reproduz precisamente todos os casos de cancelamento e falha de APIs.

**Limites**: Simulação de fala não comprova pronúncia real ou voz offline instalada; exigir escuta manual com rede desativada. As ferramentas foram instaladas na etapa de implementação. O inventário e a sequência nativa PT-BR foram verificados; a avaliação auditiva continua pendente.

**Aplicação do gate**: Conforme a constituição 1.0.0, a suíte crítica deve passar localmente antes da entrega e também em CI quando houver CI configurada. V015 depende de voz local PT-BR e aceita Não aplicável apenas com inventário e aprovação revisada; os testes de fallback permanecem obrigatórios. Os testes dessas responsabilidades comuns devem ser escritos em T005, antes do serviço de áudio de T012.

## R08 — Sorteio e estado

**Decisão**: Sortear cópia do banco e retirar oito palavras sem repetição; identificar ocorrências de letras; registrar conclusão antes dos efeitos; vincular esperas à atividade atual.

**Justificativa**: Preserva as regras e previne consumo duplo, salto de questões e contaminação entre rodadas.

**Alternativas consideradas**: Sorteio com reposição, identidade apenas pela letra ou bloqueio baseado somente em animação. Não preservam as invariantes do [modelo](data-model.md).

## R09 — Medição de desempenho reproduzível

**Decisão**: Fixar o perfil PERF-01 em validation.md, com máquina registrada antes dos testes, Chromium, viewport de tablet, CPU desacelerada 4×, relógio real e 20 amostras para cada um dos seis cenários de entrada. Cada amostra deve respeitar o limite de 200 ms.

**Justificativa**: Substitui “condições normais” por uma medição definida. A desaceleração de CPU é recurso de desenvolvimento documentado; sua escolha em 4× é uma decisão deste projeto e não representa um modelo específico de tablet. [Chrome for Developers: análise de desempenho](https://developer.chrome.com/docs/devtools/performance).

**Alternativas consideradas**: Medir somente a média no computador mais rápido disponível ou declarar equivalência a um dispositivo móvel sem testá-lo. A primeira permite ocultar respostas lentas; a segunda não produz evidência real de uso móvel.

**Limite da medição**: O segundo callback de renderização após a mudança visível é o ponto conservador de confirmação definido para a série, não uma medição física do monitor. O teste de dispositivo móvel real permanece separado.

## Pendências

Não há decisão de produto bloqueante. Ambiente, versões e resultados reais estão em validation.md. Os testes manuais restantes estão separados das evidências automáticas.
