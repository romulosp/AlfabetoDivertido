# Áudio local PT-BR — Alfabeto Divertido

**Versão**: 2.0.0 · **Data**: 2026-10-04

Fonte normativa deste domínio. Requisitos gerais em [spec.md](spec.md); integração em [Design.md](Design.md). Conteúdo transferido da referência anterior, sem alterar as regras.

**Perfil de voz da referência**: Fala geral em ritmo calmo, aproximadamente 0,9, com entonação amigável, aproximadamente 1,15. Acertos e celebração podem elevar a entonação para aproximadamente 1,3. A letra isolada do alfabeto usa ritmo aproximado de 0,75 e entonação de 1,2. Valores podem ser ajustados somente para manter a clareza na voz disponível.

**Efeitos sonoros**: Toque breve no encaixe ou exploração; sequência ascendente curta no acerto; sequência descendente suave no erro; sequência ascendente de celebração no encerramento. Nenhum deles é requisito para compreender ou concluir a atividade.

## Voz, interrupção e fallback

Consultar vozes ao iniciar e no evento `voiceschanged`; escolher somente voz `pt-BR` com `localService === true`. Sem voz local ou API de fala, manter textos e região acessível de feedback. Não baixar arquivos ou escolher voz remota. Fala do alfabeto encadeia exemplo pelo `onend` da letra, nunca por atraso fixo. Falha interrompe a sequência e restaura anúncio textual sem bloquear controles.

Som tem estado único compartilhado entre menu, jogo e celebração. Mute cancela fila de fala e osciladores ativos ou agendados. Religá-lo não retoma uma fila antiga. Saída, reinício e troca invalidam callbacks de áudio. Contexto suspenso pode ser retomado após ação; a resolução tardia confirma sessão, versão e som antes de tocar.

Web Audio é opcional: sintetiza efeitos suaves localmente; nenhuma regra depende deles. Falha de construtor, permissão, resume ou fala é tratada. Coordenar `aria-live` com narração: se a voz local está narrando, evitar anúncio duplicado do mesmo feedback; desligado ou indisponível, usar anúncio moderado.

## Implementação e validação

`js/audio/speech.js` contém seleção de voz, fala, Web Audio, cancelamento e contagem de fontes. Falha notifica a renderização por callback, sem manipular DOM. Textos de narração estão em [scene-spec.md](scene-spec.md). Validar ausência/remota/tardia/falha, mutes e seleção rápida; qualidade auditiva exige conferência humana com voz local.
