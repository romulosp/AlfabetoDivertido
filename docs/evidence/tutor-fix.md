# Correção do tutor e dos launches

O emulador 5584 estava executando `com.romulopenha.alfabetodivertido`, a versão 2D. Os launches existentes agora recebem `--3d` e usam a tarefa de build 3D. O launcher do emulador aceita caminho e pacote, assim como o deploy no celular.

Na versão 3D o painel ocultava o tutor. Um retrato 3D separado mantém o personagem visível ao lado da pergunta. O bico é controlado por SkeletonModifier3D após a animação, preservando a rotação de repouso importada do GLB. Abertura usa o tempo de reprodução do áudio; interrupção fecha o bico. Não é sincronização por fonemas.

Capturas: `tutor-mouth-closed.png`, `tutor-mouth-open.png` e `3d-bola.png`. As imagens Nano Banana continuam pendentes por quota 429; as formas do cenário são provisórias e não foram geradas pelo Gemini.

Validação final: 10 testes Python e 32 verificações Godot passaram, incluindo mudança do bico durante reprodução real e fechamento ao interromper. APK 0.2.1 instalado e aberto pelo launcher no emulador 5584 (abertura fria 2299 ms). Captura Android: `android-tutor-fix.png`. SHA-256: `a3cfe5efe2f2c76802b0cc9bd75978d0bf1d2d266b1084c6abca6f6ae3818e9a`.
