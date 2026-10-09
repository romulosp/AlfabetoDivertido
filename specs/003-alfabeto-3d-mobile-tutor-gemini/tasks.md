# Tasks: Alfabeto 3D

## Setup
- [x] T001 Registrar request/spec/plan/research em specs/003-alfabeto-3d-mobile-tutor-gemini.
- [x] T002 [US3] Escrever e executar testes RED da skill em .agents/skills/alfabeto-nano-banana/tests.
- [x] T003 [US3] Implementar parser, cliente, catálogo e geração segura em scripts da skill.
- [ ] T004 [US3] Gerar até3 candidatos Gemini em content/images/candidates e validar.
- [ ] T005 [US3] Obter aprovação humana e integrar imagens em godot/assets/images/approved.
## Runtime
- [x] T006 [US1] Testes RED de progresso/regras/integração em tests/3d.
- [x] T007 [US1] Serviços, persistência backup/migração e catálogo em godot/scripts.
- [x] T008 [US1] Jardim, toqueUI/mundo, três atividades e telas em godot/scenes.
- [ ] T009 [US2] Tutor Blender GLB rig/animações/bico, fonte em blender/tucano.
- [x] T010 [US2] ÁudioOGG offline, legendas, repetir, volumes/dicas em godot.
## Validation
- [x] T011 Testes locais e importação/exportação GLB/Godot em docs/evidence.
- [x] T012 Androiddebug/launchADB em tools/3d e .vscode.
- [x] T013 Inventários, ADRs, ambiente/licenças/custos/iOS em docs.
- [ ] T014 Medir FPS/carga/memória no Androidreal em docs/performance.
- [ ] T015 Revisão humana visual/pedagógica e aceitação final.

Dependências: T001→T002→T003→T004→T005; T006→T007→T008; T009+T010→T011→T012→T014. T005 eT015 gateshumanos. T013 pode ocorrer durante runtime. Estratégia: validar unidadeantesdeUI, produzir candidatos antesde pedir aprovação. Oportunidadeparalela: pesquisaGemini independente de docs/modelo (skillplan); implementaçãoordenada para evitar conflitos.

Estado: T004 bloqueada por Gemini HTTP 429; T005 depende dos candidatos. T009 possui GLB funcional e rig testado, mas aguarda revisão visual. T014 depende de reconectar o celular. T015 permanece pendente. Evidência atual: docs/evidence/validation-final.md.
