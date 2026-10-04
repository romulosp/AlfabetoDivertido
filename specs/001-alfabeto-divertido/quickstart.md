# Quickstart — Abrir o Alfabeto Divertido

**Estado**: Jogo implementado; testes desktop aprovados; aceite manual pendente.  
**Validação completa**: [validation.md](validation.md)

## Antes de começar

O jogo está em [apps/alfabeto-divertido/index.html](../../apps/alfabeto-divertido/index.html), relativo à raiz do projeto. Para jogar ou transferir para outro dispositivo, manter a pasta inteira `alfabeto-divertido`, incluindo `styles/` e `js/`, e abrir seu `index.html`. Não copiar apenas o HTML. Para narração offline, o dispositivo precisa oferecer voz brasileira local; a falta dessa voz não impede as atividades.

## Abrir e conferir sem ferramentas

1. Desativar a conexão de rede do dispositivo.
2. Abrir `apps/alfabeto-divertido/index.html` diretamente no navegador. Não iniciar servidor ou instalar dependências para jogar.
3. Confirmar menu com título, três modos e controle de som.
4. Escolher Primeira Letra, concluir oito questões e verificar a celebração. Oito acertos sem erro devem render três estrelas.
5. Voltar ao menu, abrir Monte a Palavra e concluir oito palavras. Letras repetidas devem ter botões independentes.
6. Abrir Brincar com o Alfabeto, tocar em A e Z e verificar ABELHA e ZEBRA; depois selecionar letras rapidamente.
7. Conferir o controle de som em menu, jogo e celebração. Desligar, navegar entre telas e confirmar que continua desligado.
8. Testar Tab, Enter, Espaço e Escape; conferir que Rômulo Penha não esconde controles.

## Verificação de desenvolvimento

A suíte é `tests/alfabeto.spec.mjs`, usando Node 24.16.0 e Playwright 1.63.0, exclusivamente para desenvolvimento. Chrome e Edge foram usados por canal instalado. Esse ambiente não é requisito para abrir o jogo.

Comandos PowerShell, a partir da raiz do projeto:

```powershell
# Preparar somente o ambiente de desenvolvimento, se necessário:
npm.cmd --prefix tests install

# Suíte completa no Chrome:
node --test --test-concurrency=1 tests/modular.spec.mjs tests/alfabeto.spec.mjs

# Suíte completa no Edge:
$env:BROWSER_CHANNEL='msedge'
node --test --test-concurrency=1 tests/modular.spec.mjs tests/alfabeto.spec.mjs
Remove-Item Env:BROWSER_CHANNEL

# PERF-01 com relógio real e Chromium visível:
$env:RUN_PERF='1'
node --test --test-concurrency=1 --test-name-pattern='^performance:' tests/alfabeto.spec.mjs
Remove-Item Env:RUN_PERF

# Duração real de 15 minutos (não usa avanço artificial de relógio):
$env:RUN_SOAK='1'
node --test --test-concurrency=1 --test-name-pattern='^soak:' tests/alfabeto.spec.mjs
Remove-Item Env:RUN_SOAK
```

O runner usa sorteio e APIs simuladas em casos específicos e testa também as APIs nativas separadamente. As saídas, imagens e valores brutos ficam em `tests/evidence/modular/chrome/` e `tests/evidence/modular/msedge/`; evidências anteriores são históricas. Os testes de duração/desempenho são separados e aparecem como ignorados na suíte regular, por serem acionados pelos comandos acima.

Os testes navegam para o arquivo local e verificam console, ausência de requisições, pontuação determinística, cliques rápidos e fallback de APIs. A suíte crítica local passou nos dois navegadores. CI não está configurada. Comandos, ambiente, versão e hash são registrados em [validation.md](validation.md).

A medição de 200 ms segue PERF-01. V015 só é executado onde houver voz local PT-BR; na ausência comprovada, registrar Não aplicável revisado, mantendo V016 obrigatório. A conferência rápida não dispensa os testes incondicionais.

## Resultado esperado

Os três modos podem ser usados sem internet, sem erros e com texto suficiente para brincar sem som. Rodadas terminam após oito questões e as estrelas correspondem à SPEC. A conferência rápida não substitui os 29 casos completos nem a revisão visual.

Ainda falta registrar uso em celular real, leitor de tela, escuta de voz PT-BR e zoom nativo de 200%. A simulação de voz e o zoom CSS não são aprovação desses testes manuais. T054 fica pendente de T053; este roteiro foi atualizado antecipadamente para permitir a conferência do artefato real.
