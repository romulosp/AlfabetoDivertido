# Validação do protótipo 0.2.0

Passaram 10 testes Python e 25 verificações Godot. Cinco capturas locais foram produzidas. Importação do GLB e exportação Android concluídas.

APK SHA-256: `11f18f87f11588eed8f0dd222f3188359cf216996b33e441930b5a8ac1021f23`.

Instalação e abertura no emulador Android com GPU host passaram; abertura fria medida pelo ADB: 2501 ms. Métricas de desempenho e instalação no celular ainda dependem de reconectá-lo. O emulador com GPU por software apresentou erro de uniformes do Godot: sua tela vazia e FPS não são evidência de aceitação.

Gemini: preflight passou, Interactions retornou 400, generateContent com o mesmo modelo retornou 429 por quota. A integração usa explicitamente generateContent, sem fallback ou repetição automática. Nenhum candidato foi produzido. A skill foi vinculada ao Gemini CLI, mas sua descoberta depende de tornar o workspace confiável no CLI.

Modelo Blender é um rascunho; revisão visual, aprovação das imagens e aceitação pedagógica permanecem pendentes.
