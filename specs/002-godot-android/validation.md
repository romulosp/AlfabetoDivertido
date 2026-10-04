# Validação — Godot Android 0.1.0

Data: 2026-10-04. Motor: Godot 4.7.2.stable.official.ed1daf0bf. Ambiente: Windows, OpenGL NVIDIA RTX 3060; emulador Android Medium_Tablet.

Escopo autorizado: portar os três modos para Godot/Android, incluir áudio offline e abrir em tela cheia na orientação paisagem, sem rolagem.

Testes de regras e integração foram escritos antes da implementação; a primeira execução falhou por ausência dos scripts. A implementação passou em `tools/godot/test.ps1 -Capture`: regras (1555 verificações nessa execução), integração (58), áudio (354), layout (1124) e captura visual (1162, incluindo 35 capturas em sete resoluções). A quantidade das regras varia com as palavras sorteadas.

O menu e a atividade de letra inicial abriram no emulador Android com Wi-Fi desligado, em paisagem, ocupando 2560 × 1600 sem barras do sistema. Evidências: `tests/evidence/godot/android-menu.png` e `android-initial.png`. A verificação dos demais modos no emulador foi limitada por falhas do backend gráfico do emulador; seus fluxos foram cobertos na integração Godot e nas capturas do desktop.

APK debug: `builds/android/alfabeto-divertido-debug.apk`, 91.843.747 bytes. SHA256: `d6a865244aad5aaeb0552373cca75d9a74fd333a6aa8bbddd9bf11dedf3477b5`. O manifesto de build registra a versão e configuração. A exportação foi concluída após as alterações de tela cheia, paisagem e navegação Voltar.

Limitação conhecida: o teste de integração pode emitir avisos de recursos retidos no encerramento rápido do processo; uma execução verbose posterior não reproduziu o aviso. Nenhuma asserção funcional falhou.

Aceitação humana ainda pendente: instalação no celular real, pronúncia, compreensão infantil, legibilidade e uso com tecnologias assistivas. Não há aprovação humana registrada.

## Correção do mascote e dos créditos

Em 2026-10-04, foram integrados 34 quadros transparentes produzidos no Blender 5.2.2 LTS, preservando a aparência original. Nome visível em todos os layouts de atividades/celebração; crédito de desenvolvimento restrito ao menu. Testes após a correção: regras 1559, integração 72, áudio 354, layout 1107 e captura visual 1148, sem falhas nas asserções. Foram verificadas presença/ausência dos créditos, identidade do mascote, reprodução, retorno à espera e pose com movimento reduzido. Os avisos de encerramento da integração descritos acima continuam ocorrendo.

O novo APK substitui o anterior: 92.612.977 bytes, SHA256 `d7089d4800f75a6fc6bb6a2336182064b011074afe0b3adec5d178708f0dcead`. Fonte e reprodução documentadas em `mascot.md`.
