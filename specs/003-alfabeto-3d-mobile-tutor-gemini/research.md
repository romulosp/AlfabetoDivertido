# Pesquisa

Decisão: Godot Compatibility para Android inicial, GLB de Blender com keyframes bakeados, áudio offline Maria provisório. Justificativa: ferramentas instaladas e perfil simples mobile; alternative Vulkan mais custosa neste cenário.

Decisão: Gemini `gemini-3.1-flash-image`, generateContent REST, responseModalities TEXT/IMAGE, aspectRatio 1:1, imageSize 1K. GETmodels é preflight, não garantequota. Sem fallback nem retryautomático POST. Referências: https://ai.google.dev/gemini-api/docs/image-generation e https://ai.google.dev/api/interactions-api.

Decisão: skillfrontmatter name/description e scripts Python testáveis, conforme https://geminicli.com/docs/cli/creating-skills/ e https://geminicli.com/docs/cli/using-agent-skills/. CLI não encontrado no PATH; documentação de link será entregue.

Custo inicial estimado3 imagens1K≈US$0,201 mais tokens, conforme https://ai.google.dev/gemini-api/docs/pricing. Teto3 chamadas, cache, semprometergratuidade.

Validação: Interactions retornou 400 nesta conta. generateContent foi selecionado explicitamente conforme os métodos anunciados pelo modelo e retornou 429 por quota. Sem candidatos. O link da skill no Gemini CLI passou; descoberta depende de workspace confiável no CLI.
