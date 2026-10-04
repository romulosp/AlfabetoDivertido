# Spec: Migração do AlfabetoDivertido para Jogo 3D Mobile com Tutor Tucano e Imagens Geradas por Gemini

## 1. Identificação

**Projeto:** AlfabetoDivertido  
**Repositório local:** `D:\desenvolvimento\ia\jogos\1-infantil-alfabetizacao`  
**Change:** `alfabeto-3d-mobile-tutor-gemini`  
**Objetivo:** criar uma versão 3D mobile do jogo de alfabetização, com cenário explorável, tutor tucano animado, desafios educacionais em 3D e geração controlada de imagens por Gemini/Nano Banana.

Esta change deve preservar o projeto atual em HTML/JavaScript como base de referência e criar uma nova frente 3D em Godot, com assets produzidos ou preparados no Blender.

## 2. Contexto

O jogo atual foi criado com GitHub Spec Kit e já possui uma experiência de alfabetização em navegador. Existe um avatar de tucano que fala e reage, mas ainda não possui animação de bico, expressões ou comportamento 3D.

A nova direção do produto é transformar a experiência em um jogo 3D para Android e iOS. A criança deve poder explorar um cenário, encontrar objetos, resolver desafios de letras, sons e palavras, e receber orientação do tucano. O tucano deve agir como tutor pedagógico: explicar, dar dicas, corrigir com cuidado, celebrar acertos e incentivar a criança a continuar.

## 3. Ferramentas e caminhos locais

Ferramentas principais:

- **Godot:** motor do jogo 3D mobile.
  Caminho local: `D:\desenvolvimento\Godot`

- **Blender 5.2:** criação, rig, animação e exportação de modelos 3D.
  Caminho local: `D:\desenvolvimento\BlenderFoundation\Blender5_2`

- **Android SDK:** build e testes Android.
  Caminho local: `D:\desenvolvimento\ferramentas_android\Sdk`

- **Xcode:** necessário apenas para build iOS em ambiente macOS.

- **Git/GitHub Spec Kit:** fluxo de specs, plano, tarefas e implementação.

Licenciamento desejado:

- Godot é open source, licença MIT.
- Blender é gratuito e open source, licença GPL.
- O projeto deve priorizar ferramentas, bibliotecas e formatos abertos.
- Custos de publicação em lojas, contas Apple/Google e eventuais APIs externas são externos ao código do jogo.
- Nenhuma chave ou segredo deve ser commitado no repositório.

## 4. Skills já instaladas

O projeto já contém skills instaladas em `.agents\skills`:

- `godot`
- `blender-animation`
- `blender-image-to-3d`
- `speckit-specify`
- `speckit-plan`
- `speckit-tasks`
- `speckit-implement`
- demais skills Spec Kit já existentes

A implementação deve usar essas skills quando fizer sentido, especialmente para Godot, Blender e Spec Kit.

## 5. Skill adicional obrigatória: alfabeto-nano-banana

Criar uma skill local para geração de imagens com Gemini/Nano Banana:

**Nome sugerido:** `alfabeto-nano-banana`  
**Destino:** `.agents\skills\alfabeto-nano-banana`

A skill deve orientar o agente a gerar imagens educacionais para o jogo usando a API Gemini, lendo a chave localmente a partir de:

```text
D:\desenvolvimento\chave_des\chave_des.properties
```

Propriedade da chave:

```text
CHAVE_API_GEMININI
```

A grafia da propriedade deve ser usada exatamente como está acima.

A skill deve conter:

- `SKILL.md`
- `scripts/generate_images.py`
- `scripts/validate_catalog.py`
- `scripts/_gemini_client.py`
- `tests/`
- `fixtures/`
- `README.md` opcional

A skill deve seguir a documentação oficial do Gemini CLI para skills:

- [Gemini CLI Agent Skills](https://geminicli.com/docs/cli/using-agent-skills/)
- [Creating Gemini CLI Skills](https://geminicli.com/docs/cli/creating-skills/)

Modelo de imagem sugerido, sujeito à disponibilidade da chave/API:

```text
gemini-3.1-flash-image
```

Referência oficial:

- [Gemini API Image Generation](https://ai.google.dev/gemini-api/docs/image-generation)

A implementação deve validar acesso ao modelo e falhar com mensagem clara se a conta/chave não tiver suporte. Não deve fazer fallback silencioso para outro modelo.

## 6. Comandos para importar/linkar a skill no Gemini CLI

Depois de criada a skill local, usar um dos comandos abaixo dentro da raiz do projeto:

```bat
cd /d D:\desenvolvimento\ia\jogos\1-infantil-alfabetizacao

gemini skills link .agents\skills\alfabeto-nano-banana --scope workspace
gemini skills list
```

Caso a skill esteja em um repositório GitHub:

```bat
cd /d D:\desenvolvimento\ia\jogos\1-infantil-alfabetizacao

gemini skills install usuario-ou-org/repositorio --path skills/alfabeto-nano-banana --scope workspace
gemini skills list
```

Dentro de uma sessão Gemini CLI, recarregar skills com:

```text
/skills reload
/skills list
```

## 7. Regras de segurança para credenciais

A chave Gemini deve ser lida apenas em tempo de execução a partir do arquivo local:

```text
D:\desenvolvimento\chave_des\chave_des.properties
```

Regras obrigatórias:

- Não copiar a chave para `.env`, JSON, YAML, logs ou arquivos do projeto.
- Não imprimir a chave no terminal.
- Não salvar hash da chave.
- Não criar aliases automáticos para a propriedade.
- Não aceitar outro nome de propriedade sem alteração explícita de spec.
- O parser de `.properties` deve suportar BOM, CRLF, comentários com `#` e `!`, separador `=` ou `:`, e divisão apenas na primeira ocorrência do separador.
- Em erro de credencial, exibir apenas: arquivo não encontrado, propriedade ausente, valor vazio ou falha de autenticação.
- Testes devem usar chave falsa.

## 8. Direção de produto

A experiência principal deve ser um cenário 3D explorável para alfabetização infantil.

A criança deve controlar um personagem ou ponto de atenção no cenário. Como padrão inicial, usar navegação simples por toque: tocar no chão ou em objetos interativos para mover/interagir. O tucano acompanha como tutor, não como personagem controlado principal.

A primeira versão 3D deve conter um cenário pequeno e testável, por exemplo uma ilha, praça, jardim, escola lúdica ou trilha de letras. O cenário deve ter objetos relacionados a letras e sons: bola, casa, dado, gato, mala, pato etc.

Cada objeto educacional deve poder iniciar uma atividade. Exemplo: tocar em uma bola abre um desafio da letra B, som /b/ ou palavra “bola”.

## 9. Tutor tucano

O tucano deve atuar como tutor pedagógico 3D.

Comportamentos obrigatórios:

- Apresentar o desafio.
- Dar dicas quando a criança ficar parada ou errar.
- Corrigir erros de forma gentil.
- Celebrar acertos.
- Incentivar o próximo desafio.
- Repetir fala quando solicitado.
- Exibir legenda para toda fala importante.

Estados mínimos:

```text
idle
presenting
waiting
helping
celebrating
transitioning
```

Reações esperadas:

- Acerto: animação positiva, fala curta de incentivo, liberação do próximo passo.
- Erro: reação curiosa e acolhedora, sem expressão triste, punição ou constrangimento.
- Inatividade: dica progressiva.
- Repetição: repetir instrução e destacar o objeto/letra relevante.

A fala deve ser sincronizada com movimento simples do bico. A primeira versão pode usar três poses de bico:

```text
beak_closed
beak_half_open
beak_open
```

Também incluir expressões básicas:

```text
happy
curious
thinking
encouraging
```

Não exigir visemas humanos complexos na primeira versão.

## 10. Áudio, fala e lip sync

A primeira versão deve priorizar áudio pré-gravado ou gerado previamente, empacotado no jogo e funcionando offline.

Formato recomendado:

```text
OGG Vorbis, mono, 44.1kHz, bitrate aproximado de 96kbps
```

O lip sync pode começar com timeline manual ou eventos por trecho de fala. O objetivo mínimo é o bico parecer vivo e coerente com a fala.

Requisitos:

- Legendas sempre disponíveis.
- Botão de repetir fala.
- Volumes separados para voz, efeitos, música e UI.
- Cancelamento seguro de fala anterior quando nova fala começar.
- Nenhum uso obrigatório de internet durante a sessão da criança.

## 11. Geração de imagens com Gemini/Nano Banana

Todas as imagens solicitadas para objetos, referências visuais, cards, texturas-base ou ilustrações auxiliares devem ser geradas pelo Gemini/Nano Banana em etapa de produção.

A geração deve acontecer antes do build, com aprovação humana dos assets. O jogo mobile deve consumir apenas assets aprovados e empacotados localmente.

Fluxo obrigatório:

```text
catalogo de conceitos -> prompt -> candidato gerado -> validação -> aprovação -> integração no Godot
```

As imagens geradas não devem ser automaticamente aprovadas. O pipeline deve salvar candidatos em pasta separada, e somente imagens aprovadas devem entrar no jogo.

Diretórios sugeridos:

```text
content/images/catalog.json
content/images/pending/
content/images/candidates/
content/images/approved/
godot/assets/images/approved/
```

O diretório `candidates` deve ser ignorado pelo Git quando contiver grande volume de experimentos ou arquivos temporários. Assets aprovados podem ser versionados, usando Git LFS se o tamanho justificar.

A geração deve produzir imagens quadradas, preferencialmente `1024x1024`, quando suportado pelo modelo. Não distorcer imagens para caber em formato quadrado; aplicar corte, padding ou composição adequada.

A validação deve checar:

- arquivo realmente decodificável como imagem;
- formato correto;
- dimensão mínima;
- ausência de arquivo vazio;
- metadados do conceito;
- prompt usado;
- modelo usado;
- data de geração;
- hash do arquivo;
- status do asset.

## 12. Catálogo de conteúdo

Criar catálogo versionado para conceitos e atividades.

Arquivo sugerido:

```text
content/images/catalog.json
```

Campos mínimos por conceito:

```json
{
  "conceptId": "bola",
  "namePt": "bola",
  "letter": "B",
  "syllables": ["bo", "la"],
  "pedagogicalGoal": "Reconhecer a letra B e associar ao som inicial da palavra bola.",
  "visualDescription": "bola colorida infantil, simples, alegre, sem texto na imagem",
  "context": "objeto interativo em cenário 3D de alfabetização",
  "status": "pending"
}
```

Regras de nomenclatura:

- `conceptId` em ASCII, `snake_case`.
- cenas Godot em `PascalCase`.
- scripts em `snake_case`.
- sinais/eventos em `snake_case`.
- arquivos gerados com padrão previsível:

```text
conceptId_style_vVersion_candidate_timestamp_unique.png
```

O jogo não deve depender de parsing do nome do arquivo para recuperar metadados. Metadados devem vir do catálogo ou manifesto.

## 13. Arquitetura Godot

Criar nova área do projeto para Godot sem sobrescrever a versão web atual.

Estrutura sugerida:

```text
godot/
godot/project.godot
godot/scenes/
godot/scripts/
godot/assets/
godot/assets/models/
godot/assets/images/approved/
godot/assets/audio/
godot/ui/
godot/content/catalog_runtime.json
```

Autoloads sugeridos:

```text
EventBus
CatalogService
ProgressService
AudioService
SceneRouter
```

Responsabilidades:

- `EventBus`: eventos globais tipados.
- `CatalogService`: carregar catálogo runtime empacotado.
- `ProgressService`: salvar progresso da criança.
- `AudioService`: fala, efeitos, música, legendas e cancelamento.
- `SceneRouter`: transições entre telas e cenas principais.

Fluxo inicial:

```text
boot -> validação de catálogo -> carregamento de progresso -> cena inicial -> cenário explorável -> atividade -> feedback -> próxima atividade
```

A entrada por toque deve respeitar UI primeiro. Controles de interface devem consumir eventos próprios; interações no mundo devem ocorrer apenas quando o toque não foi consumido pela UI.

## 14. Cenário explorável

A primeira entrega deve conter um cenário pequeno, estável e bonito o suficiente para validar a direção 3D.

Requisitos:

- câmera adequada para mobile;
- movimentação simples por toque;
- objetos interativos destacados;
- feedback visual ao tocar em objeto;
- transição para atividade educacional;
- retorno ao cenário;
- tutor tucano acompanhando ou aparecendo em pontos de orientação.

O cenário deve ser leve para mobile. Usar metas iniciais de performance:

```text
30 FPS em dispositivo Android real de referência
carregamento inicial alvo abaixo de 4 segundos
uso de memória acompanhado e documentado
```

Esses números são metas de validação inicial, não garantia sem medição.

## 15. Atividades educacionais

A primeira versão deve conter pelo menos 3 conceitos jogáveis completos.

Exemplo inicial:

```text
B - bola
C - casa
D - dado
```

Cada atividade deve ter:

- apresentação do tucano;
- objetivo claro;
- interação simples;
- resposta correta;
- resposta incorreta;
- dica;
- celebração;
- registro de progresso;
- legenda.

Exemplo de atividade:

```text
O tucano diz: "Vamos encontrar a palavra que começa com B."
A criança escolhe entre objetos ou cartas.
Ao acertar, o tucano comemora: "Muito bem! Bola começa com B. Vamos para o próximo desafio."
Ao errar, o tucano orienta: "Boa tentativa. Escuta comigo: B... bola. Qual objeto começa com esse som?"
```

## 16. Progresso e persistência

Salvar progresso localmente no dispositivo.

Dados mínimos:

```text
schemaVersion
profileId local
completedActivities
conceptProgress
lastScene
audioSettings
accessibilitySettings
updatedAt
```

A escrita deve ser segura:

- salvar em arquivo temporário;
- validar;
- substituir o arquivo principal;
- manter backup válido;
- recuperar de backup em caso de corrupção;
- nunca apagar progresso válido silenciosamente.

Não há requisito de conta, login, nuvem ou sincronização nesta change.

## 17. Acessibilidade

Requisitos mínimos:

- legendas para falas do tucano;
- botão para repetir instrução;
- alvos de toque grandes;
- contraste adequado;
- não depender apenas de cor;
- feedback sonoro e visual;
- interface simples para criança;
- textos curtos e legíveis.

Metas de contraste:

```text
4.5:1 para texto normal
3:1 para texto grande
```

## 18. Blender

Criar ou adaptar modelo 3D do tucano no Blender.

Entregáveis:

```text
blender/tucano/
blender/tucano/tucano.blend
blender/tucano/export_gltf.py
godot/assets/models/tucano.glb
```

O modelo deve ter:

- rig simples;
- animação idle;
- animação de fala;
- animação de celebração;
- animação de pensamento/dica;
- poses de bico;
- expressões básicas.

Orçamento inicial:

```text
até 15k triângulos para o tucano
texturas até 2048px quando necessário
GLB como formato de integração
```

A exportação deve preservar animações, materiais e shape keys ou bones usados pelo bico.

## 19. Build Android

Criar scripts de build reproduzíveis para Android.

Requisitos:

- localizar executável do Godot em `D:\desenvolvimento\Godot`;
- localizar Android SDK em `D:\desenvolvimento\ferramentas_android\Sdk`;
- validar versão do Godot instalada;
- validar templates de exportação compatíveis;
- gerar APK debug;
- preparar AAB release quando assinatura estiver configurada;
- não incluir chaves ou credenciais no export preset.

Saídas sugeridas:

```text
build/android/debug/
build/android/release/
```

O jogo não deve declarar permissão de internet se não houver necessidade runtime. Como a geração Gemini ocorre em etapa de produção, a build mobile inicial deve funcionar offline.

## 20. Build iOS

Preparar estrutura para iOS, mas aceitar que build final exige macOS com Xcode.

Requisitos:

- manter projeto Godot compatível com export iOS;
- documentar passos de exportação;
- não bloquear a entrega Android inicial por ausência de Mac;
- registrar limitações em ADR.

## 21. Documentação obrigatória

Criar documentação em:

```text
docs/
docs/inventory/
docs/adr/
docs/env/
docs/licenses/
docs/costs/
docs/performance/
docs/evidence/
```

Inventários mínimos:

```text
docs/inventory/atividades.md
docs/inventory/imagens.md
docs/inventory/voz-atual.md
docs/inventory/tucano-referencias.md
docs/inventory/progressao.md
docs/inventory/licencas.md
docs/inventory/reaproveitamento.md
```

ADRs mínimos:

```text
docs/adr/0001-godot-blender-mobile.md
docs/adr/0002-gemini-image-generation-production-only.md
docs/adr/0003-offline-child-experience.md
```

## 22. Licenças

O projeto deve manter separação entre:

- código;
- assets gerados;
- assets de terceiros;
- fontes;
- áudio;
- modelos 3D.

Regras:

- código preferencialmente MIT, se compatível com o projeto existente;
- assets de terceiros só podem entrar com licença verificada;
- registrar origem e licença de cada asset;
- assets gerados por Gemini devem registrar prompt, modelo, data e revisão humana;
- não assumir automaticamente que todo asset gerado pode ser redistribuído fora do app sem revisão de termos.

## 23. Testes e validação

Testes obrigatórios:

- parser de credenciais `.properties`;
- validação de catálogo;
- geração de prompt sem expor segredo;
- resposta sem imagem;
- imagem inválida;
- imagem válida;
- não sobrescrever asset aprovado;
- recuperação de progresso corrompido;
- migração de schema;
- carregamento offline do jogo;
- UI consumindo toque antes do mundo 3D;
- cancelamento de fala do tucano;
- build Android debug.

Teste de integração com Gemini deve ser limitado, controlado e documentado, para evitar custo inesperado.

Nenhum teste deve imprimir a chave real.

## 24. Critérios de aceite

A change será aceita quando:

- existir projeto Godot 3D separado da versão web atual;
- cenário 3D inicial rodar;
- criança conseguir explorar e interagir com objetos;
- tucano tutor aparecer e orientar atividades;
- tucano tiver animação básica de bico e reações;
- pelo menos 3 atividades educacionais estiverem completas;
- imagens dos conceitos forem geradas via Gemini/Nano Banana em pipeline de produção;
- apenas assets aprovados entrarem no jogo;
- chave Gemini for lida de `D:\desenvolvimento\chave_des\chave_des.properties`;
- propriedade `CHAVE_API_GEMININI` for usada exatamente;
- chave não aparecer em logs, commits ou arquivos gerados;
- build Android debug for gerada;
- documentação de ambiente, licenças, custos e decisões existir;
- jogo funcionar offline em runtime.

## 25. Fora de escopo desta change

Não incluir nesta primeira change:

- publicação na Google Play;
- publicação na App Store;
- multiplayer;
- login;
- conta infantil;
- sincronização em nuvem;
- analytics;
- anúncios;
- compras internas;
- geração de imagens dentro do dispositivo da criança;
- mundo 3D grande;
- dezenas de atividades;
- dublagem final profissional obrigatória;
- iOS final assinado se não houver ambiente macOS disponível.

## 26. Riscos

Riscos principais:

- API Gemini sem acesso ao modelo de imagem desejado.
- Custo de geração se o pipeline repetir chamadas indevidamente.
- Performance 3D em celulares fracos.
- Necessidade de Mac/Xcode para iOS.
- Integração de animações Blender/Godot perder shape keys ou materiais.
- Assets gerados inadequados para crianças sem revisão humana.
- Progresso local corrompido se escrita não for atômica.

Mitigações:

- geração com limite de lote;
- cache por hash de prompt;
- aprovação manual;
- build Android primeiro;
- testes offline;
- documentação de licenças;
- validação de GLB importado;
- metas de performance medidas em dispositivo real.

## 27. Prompt sugerido para o Codex implementar

Implementar a change `alfabeto-3d-mobile-tutor-gemini` no projeto `D:\desenvolvimento\ia\jogos\1-infantil-alfabetizacao`.

Preserve o jogo web existente e crie uma nova frente Godot 3D para mobile. Use Godot em `D:\desenvolvimento\Godot`, Blender em `D:\desenvolvimento\BlenderFoundation\Blender5_2` e Android SDK em `D:\desenvolvimento\ferramentas_android\Sdk`.

Crie um cenário 3D explorável, com tutor tucano animado, atividades de alfabetização e pipeline de imagens geradas por Gemini/Nano Banana. A geração de imagem deve ser produção-time, não runtime no dispositivo da criança. Leia a chave Gemini somente de `D:\desenvolvimento\chave_des\chave_des.properties`, usando exatamente a propriedade `CHAVE_API_GEMININI`, sem expor ou persistir o segredo.

Crie também a skill local `.agents\skills\alfabeto-nano-banana` para orientar agentes Gemini/Codex na geração e validação de imagens do jogo. A skill deve conter scripts seguros, validação de catálogo, geração controlada, tratamento de erro e testes com chave falsa.

A primeira entrega deve conter pelo menos 3 conceitos jogáveis completos, build Android debug, documentação em `docs/`, ADRs, inventários, validação de catálogo, persistência local segura e tutor tucano com fala, legenda, reação positiva, correção gentil e movimento básico do bico.