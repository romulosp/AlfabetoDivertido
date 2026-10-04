# Pesquisa

Decisão: Godot Compatibility para Android inicial, GLB de Blender com keyframes bakeados, áudio offline Maria provisório. Justificativa: ferramentas instaladas e perfil simples mobile; alternative Vulkan mais custosa neste cenário.

Decisão: Gemini `gemini-3.1-flash-image`, Interactions REST, response_format image/png, aspect_ratio1:1, image_size1K, storefalse. GETmodels é preflight, não garantequota. Sem fallback nem retryautomático POST. Referências: https://ai.google.dev/gemini-api/docs/image-generation e https://ai.google.dev/api/interactions-api.

Decisão: skillfrontmatter name/description e scripts Python testáveis, conforme https://geminicli.com/docs/cli/creating-skills/ e https://geminicli.com/docs/cli/using-agent-skills/. CLI não encontrado no PATH; documentação de link será entregue.

Custo inicial estimado3 imagens1K≈US$0,201 mais tokens, conforme https://ai.google.dev/gemini-api/docs/pricing. Teto3 chamadas, cache, semprometergratuidade.
