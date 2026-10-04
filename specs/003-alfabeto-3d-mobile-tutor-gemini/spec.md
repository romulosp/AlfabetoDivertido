# Feature Specification: Alfabeto 3D mobile com tutor

**Feature Branch**: `feature/migracao-blender-3D` (ramo atual, sem troca)
**Created**: 2026-10-04
**Status**: Em implementação; aceitação humana pendente
**Input**: Change `alfabeto-3d-mobile-tutor-gemini`, anexo integral em `request.md`.

## User Scenarios & Testing

### User Story 1 — Explorar e aprender (P1)

A criança explora um jardim tocando no chão e nos objetos bola, casa e dado. Cada objeto abre uma atividade com três alternativas, dica, correção gentil, celebração e retorno ao jardim.

**Independent Test**: completar cada atividade, incluindo tentativa incorreta, repetir fala, voltar e reabrir o aplicativo offline.
**Acceptance Scenarios**: tocar na UI não move o personagem; tocar no chão move dentro dos limites; tocar em objeto abre apenas sua atividade; acertar registra progresso persistente sem punição por erro.

### User Story 2 — Tutor acessível (P1)

Rômulo Penha acompanha a criança, apresenta atividades, dá dicas progressivas e celebra. Todas as falas têm legenda e podem ser repetidas. O bico acompanha áudio empacotado offline.

**Independent Test**: percorrer presenting, waiting, helping, celebrating, transitioning e idle; cancelar uma fala com outra; modificar volumes e preferência de movimento.
**Acceptance Scenarios**: erro mantém alternativas disponíveis e produz incentivo; inatividade oferece dica; repetir destaca o conceito; desativar voz mantém legenda.

### User Story 3 — Produção controlada de imagens (P1)

O produtor gera candidatos quadrados de bola/casa/dado, revisa e aprova individualmente. Somente imagens aprovadas são empacotadas. Credenciais locais nunca aparecem nos artefatos.

**Independent Test**: gerar até três candidatos, validar metadados/imagem, tentar integrar sem aprovação (deve falhar), registrar aprovação humana e integrar sem sobrescrever versão aprovada.
**Acceptance Scenarios**: chave ausente/vazia/inválida falha sem segredo; modelo indisponível falha sem trocar de modelo; resposta sem imagem e arquivos inválidos são rejeitados.

### Edge Cases

Progresso corrompido recupera backup válido; ambos inválidos são preservados para diagnóstico. Esquema desconhecido não é sobrescrito. Saída durante fala cancela áudio/bico. Android desconectado falha sem instalar em emulador. Candidato não aprovado nunca entra no build.

## Requirements

FR-001: criar frente 3D separada preservando web e Godot 2D. FR-002: três conceitos completos B/bola, C/casa, D/dado. FR-003: interação por toque respeita UI primeiro. FR-004: tutor tem seis estados e quatro expressões, bico fechado/meio/aberto. FR-005: fala offline, legenda e repetição. FR-006: quatro volumes e cancelamento seguro. FR-007: progresso local com temporário validado, backup e migração. FR-008: pipeline com candidato, validação, revisão humana e integração exclusiva de aprovados. FR-009: ler apenas `CHAVE_API_GEMININI` do arquivo local definido no anexo; não gravar/logar segredo ou hash. FR-010: modelo explicitamente selecionado, sem fallback. FR-011: limites de lote e cache de prompt. FR-012: skill local e testes com chave falsa. FR-013: modelo Blender editável e GLB animado com orçamento 15 mil triângulos. FR-014: Android debug offline, landscape/fullscreen; estrutura iOS sem assinatura. FR-015: créditos somente na primeira tela e nome do tutor preservado. FR-016: documentação de licenças, custos e medições reais.

## Key Entities

Concept, ImageCandidate, HumanApproval, ActivityProgress, LocalProfile, AudioSettings, AccessibilitySettings, TutorState, SpeechCue.

## Success Criteria

Três atividades completáveis sem rede; progresso preservado após reiniciar; nenhuma interação UI altera destino no mundo; nenhuma imagem não aprovada empacotada; nenhuma chave em log/artefato. Alvos medidos: 30 FPS e carregamento abaixo de 4 s no Android de referência, memória registrada. Aceitação visual, pedagógica e de assets exige revisão humana.

## Assumptions

Jardim pequeno com câmera isométrica; Android primeiro; perfil local anônimo; narração provisória Maria pt-BR; preservação da identidade visual do tucano. Conta/API Gemini pode limitar geração. Mac/Xcode e assinatura não estão disponíveis neste ambiente. Publicação, analytics e contas infantis fora do escopo.
