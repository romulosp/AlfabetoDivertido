# Correções da análise — Alfabeto Divertido

**Data**: 2026-10-04  
**Autorização**: Pedido do usuário para corrigir todos os problemas levantados, com speckit-specify e speckit-clarify.  
**Escopo**: Documentos da feature existente e atualização explícita da constituição; nenhum código de aplicação ou teste executável.

## Registro dos achados

| ID | Achado original | Correção aplicada | Onde conferir | Estado documental |
| --- | --- | --- | --- | --- |
| C1 | Áudio implementado antes de seus testes específicos | T004/T005 cobrem regras e responsabilidades comuns antes de T006–T013; T034 amplia/reexecuta a cobertura já existente | [tasks.md](tasks.md), fundação e US5; [plan.md](plan.md), Phase 2 | Resolvido |
| C2 | CI exigida pela constituição e adiada pelo plano | Atualização explícita para constituição 1.0.0: testes automatizados locais obrigatórios antes da entrega; mesma suíte em CI quando configurada; comando, ambiente, versão/hash e revisão registrados | [constituição](../../.specify/memory/constitution.md), Integration Coverage; T050/T053; gate final do plano | Resolvido |
| I1 | Gate de US1 exige modos ainda não implementados | Recortes por história e modo disponível; casos multimodo só recebem aprovação integral depois de todo o escopo executado; falhas esperadas de modos ausentes não são aprovação nem bloqueio da criação desses modos | [validation.md](validation.md), Escopo incremental; [plan.md](plan.md), Phase 3; T020 | Resolvido |
| A1 | Limite de 200 ms sem perfil ou método | PERF-01 fixa ambiente previamente registrado, viewport, CPU, amostra, início/fim e aprovação por amostra; 20 por cenário, 120 no total, sem aprovação pela média | SC-008 na [SPEC](spec.md); PERF-01 e V026; T002/T043 | Resolvido |
| I2 | Controle de som ambíguo na celebração | Exigir controle visível/acessível em menu, jogo e celebração, com o mesmo estado | FR-006/FR-037, [Design.md](Design.md), [contrato](contracts/ui-contract.md), V018, T013/T036 | Resolvido |
| A2 | Voz opcional tratada como teste sempre obrigatório | V015 condicionado a voz local PT-BR; Não aplicável exige inventário e revisão; V016 e outros 27 casos permanecem obrigatórios | SC-004, Aplicabilidade da voz real e gate de [validation.md](validation.md), T042/T053 | Resolvido |
| U1 | Template duplicado e placeholders na constituição | Remover todo o scaffold duplicado; manter uma constituição efetiva com versão/data únicas e Sync Impact Report da alteração | [constituição](../../.specify/memory/constitution.md) | Resolvido |

## Decisões e impacto

- Nenhuma pergunta nova foi necessária; o refinamento usa o escopo e a autorização já fornecidos. As decisões estão documentadas em Clarifications na SPEC, sem inventar respostas de usuário.
- A constituição passou de 0.1.0 para 1.0.0 porque o escopo de CI e o procedimento de alteração para trabalho local foram redefinidos. A obrigatoriedade de testes antes do código e revisão antes da entrega permanece.
- Os 56 IDs de tarefas foram preservados. Todos continuam desmarcados; a correção de uma tarefa não equivale à sua execução.
- Foram preservados três modos, oito questões por rodada avaliada, regras de estrelas, 29 palavras, 26 exemplos e os 16 marcadores CHG. O nome oficial do ator continua Rômulo Penha.
- O benchmark é uma referência registrada de validação, sem alegar que a emulação comprova desempenho em um tablet físico específico.
- A condição de voz não autoriza dispensar celular real, leitor de tela, fallback ou outro caso obrigatório. Impedimentos desses testes continuam bloqueios de aceitação do jogo.

## Conferência de regressão documental

Conferir links locais, IDs e contagem de requisitos/tarefas/casos; procurar frases antigas incompatíveis com as correções; validar a ausência de placeholders na constituição; confirmar que T005 precede os comportamentos comuns; confirmar que nenhum arquivo de aplicação foi criado.

O resultado da conferência é documental. Não é aprovação de V001–V029 nem evidência de funcionamento do jogo. A checklist de qualidade da SPEC permanece com 22/22 critérios satisfeitos, sem tarefas de implementação marcadas.

## Próximo passo

O pacote corrigido pode ser submetido novamente a `$speckit-analyze` e, depois, a `$speckit-implement`. Esta correção não executa a implementação automaticamente.
