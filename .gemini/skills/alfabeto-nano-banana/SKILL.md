---
name: alfabeto-nano-banana
description: Gerar e validar candidatos educacionais do AlfabetoDivertido com Gemini/Nano Banana em produção, antes do build; usar para catálogo, prompts e revisão de imagens, nunca para geração no runtime infantil.
---

# Imagens educacionais Gemini

Use scripts locais com Python e Pillow. Leia a chave somente em runtime de `D:\desenvolvimento\chave_des\chave_des.properties`, propriedade exata `CHAVE_API_GEMININI`. Nunca imprima/cop ie/registre segredo, nem seu hash; não use aliases ou .env. Testes usam fixtures falsas.

Execute `scripts/validate_catalog.py --catalog content/images/catalog.json`, depois `scripts/generate_images.py --catalog content/images/catalog.json --check-access`. GET de modelo valida autenticação/metadata, não garantequota. Geração inicial no máximo3 conceitos, um candidato por conceito, modelo explícito `gemini-3.1-flash-image`. Sem fallback e sem retryautomáticoPOST (timeout pode ter custo). Modelo não disponível deve falhar claramente.

Prompt infantil simples, semtexto/logos, quadrado1024, identidade consistente. Candidatos têm metadados/prompt/modelo/data/hash/dimensões/status. Cache usa prompt+modelo, nuncacredencial. Não sobrescrever aprovados. Nunca aprovar automaticamente: mostrar candidatos concretos para revisão humana e registrar reviewer/decisão antes de integrar. Use `scripts/approve_images.py` somente depois da aprovação expressa do usuário. O jogo e build deprodução sóconsomem approved.

Documentação oficial: https://ai.google.dev/gemini-api/docs/image-generation, https://geminicli.com/docs/cli/creating-skills/, https://geminicli.com/docs/cli/using-agent-skills/.

Testes: `python -m unittest discover -s .agents/skills/alfabeto-nano-banana/tests`. Link: `gemini skills link .agents/skills/alfabeto-nano-banana --scope workspace`; `gemini skills list`; sessão `/skills reload`.
