"""Record the actual local implementation and external validation gates."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
docs={
'inventory/atividades.md':'''# Atividades
| ID | Objetivo | Interação | Dica | Progresso |
|---|---|---|---|---|
| bola | B inicial de bola | escolher B/C/D | duas dicas progressivas | completedActivities |
| casa | C inicial de casa | escolher B/C/D | duas dicas progressivas | completedActivities |
| dado | D inicial de dado | escolher B/C/D | duas dicas progressivas | completedActivities |
Erros acolhedores, sem penalização; botão repetir e legenda. Retorno ao jardim é explícito após celebração.
''',
'inventory/imagens.md':'''# Imagens
Catálogo: content/images/catalog.json, três conceitos pending. Gemini GETmodelo autenticado com sucesso; Interactions HTTP400 response_format não suportado, generateContent modeloexato HTTP429 quota. Nenhum candidato gerado, nenhum aprovado ou integrado. Não houve fallback.
Objetos de protótipo são geometria autoral Godot, não imagens substitutas Gemini. Tarefa de aceite de imagens permanece aberta.
''',
'inventory/voz-atual.md':'''# Voz
16 narracoes provisórias Maria Desktop pt-BR, SAPI Windows, OGG Vorbis mono44100 offline. Captions e IDs em godot/content/speech.json; source tools/3d/generate_speech.ps1. Conversão soundfile/libsndfile. Vorbisquality padrão; bitrate aproximado dependeconteúdo, nãofoiforçado96kbps. Repetição cancela anterior. Pronúncia/fonemas exigem revisão pedagógica; a voz fala nomes de letras, não dublagemfonéticafinal.
''',
'inventory/tucano-referencias.md':'''# Tutor
Referência original em blender/tucano/ref/original.png. Nome Rômulo Penha. Draft3Drigde6bones,11clips idle/talk/celebrate/think/bico3poses/4expressões. 6400triângulosupperbound. Corpopreto,barrigaclara,asas turquesa,bico laranja. Laterais/profundidade/costas inferidas. Vistas em blender/tucano/review; revisãohumana e comparação de silhueta de produção pendentes. Draft técnico não é modelo aprovado final.
''',
'inventory/progressao.md':'''# Progressão
Perfil local anônimo. Três descobertas independentes; sem login/coleta. Schema2 em user://progress.json, backup .bak e temporário .tmp. Migração1→2, esquema futuro protegido, primário corrompido preservado. Se ambos inválidos, jogo podeexplorar mas escrita bloqueada; nuncaapagarprogresso silenciosamente.
''',
'inventory/licencas.md':'''# Inventário de licenças
Godotmotor MIT; Blenderferramenta GPL; formatos GLB/OGG/PNG abertos. Fonte Nunito OFL1.1, licença em godot/assets/fonts/OFL.txt. Modelodraft e geometrias autoraisdoprojeto; conservaratribuiçãoRômuloPenha. ÁudioMaria gerado local: direito redistribuição deve ser conferidoantesdepublicação. Nenhuma imagemGemini integrada; termos de redistribuição devemserrevisados com asset e aprovação. CódigoexistingsemLICENSE: não imporMITautomaticamente.
''',
'inventory/reaproveitamento.md':'''# Reaproveitamento
Web apps/alfabeto-divertido preservado; Godot2D apps/alfabeto-godot preservado. Reaproveitados identidadepalette, nome, fonteNunito, SAPI narração, pathsSDK/Java/templates e launcherADB agora parametrizado APK/pacote. Nova frente godot/ tem pacoteAndroid próprio semsubstituir aplicativo2D.
''',
'adr/0001-godot-blender-mobile.md':'''# ADR0001 — Godot/Blender
Aceita técnicamente. Godot4.7.2Compatibility, Blender5.2.2GLB. Android primeiro; renderer maisprevisível eassetsleves. Alternativaweb3D nãoescolhida porqueusuárioexigiu motorGodot/Blender. DraftGLB mantémsourceeditável; aprovaçãohumana éseparada.
''',
'adr/0002-gemini-image-generation-production-only.md':'''# ADR0002 — Gemini somenteprodução
Gemini modeloexato gemini-3.1-flash-image, chaveempropriedadeCHAVE_API_GEMININI local. generateContent endpoint explícito anunciado em metadata da conta. Interactionsdocnovo retornou400 formatoimagemnãosuportado; não aplicar fallbackautomático nemtrocar modelo. Cacheprompt/modelo, máximo3imagens por execução. API429 interrompe. Candidate→revisãohumana→approved. Build -RequireApproved falha se revisão incompleta.
''',
'adr/0003-offline-child-experience.md':'''# ADR0003 — Runtime offline
Aplicativo não contém clienteGemini,chave,requests ou permissãointernet. Catálogo/áudio/modeloslocais. Sem analytics/contas. Fontes/candidatos ficamfora runtime. Progresso local; semnuvem. Essa separação preservasessãoinfantilmesmo semrede.
''',
'adr/0004-ios-environment.md':'''# ADR0004 — iOS
ProjetoCompatibility/GLB/OGG compartilha código comiOS; export assinado requerMac/Xcode. AmbienteatualWindows, nenhumIPAgerado. Androidnãoébloqueado porisso. iOSprecisarevisãodetouch/performance/safearea emdeviceApple.
''',
'env/windows.md':'''# Ambiente
Windows10; Godot4.7.2console em D:/desenvolvimento/Godot; Blender5.2.2 em D:/desenvolvimento/BlenderFoundation/Blender5_2; SDKemD:/desenvolvimento/ferramentas_android/Sdk; JavaAndroidStudiojbr. Python3.14/Pillow12.3/soundfile/PyYAML. npxGeminiCLI para link se ausentePATH.
PORTA_CELULAR lida a cadaexecução: usuárioWindows→sistema→processo. SerialADB, nuncaCOM. Launchnovo Android3Dbuild/deploy; existentespreservados. ChaveGemini jamais copiar para configuração do projeto.
''',
'env/ios.md':'''# Export iOS
EmMac comGodotcompatível, instalartemplates, Xcode eSDKiOS. Abrir godot/project.godot, adicionarpresetiOS, bundleIDcom.romulopenha.alfabeto3d, configurarteam/assinaturalocalforaGit, exportarXcodeproject, build/testemdevice. Nãohásegredoassinaturacommitado. Nenhuma validaçãoiOSreal foi realizada.
''',
'licenses/README.md':'''# Origem e direitos
Inventárioem../inventory/licencas.md. EngineMIT/ferramentaGPLnão definem licença dosassets nemdojogo. Nenhuma licença depublicaçãocriada automaticamente. Geminiassets exigem provenance prompt/model/data/hash/reviewer e revisão dostermos antesdaredistribuição.
''',
'costs/gemini.md':'''# Custo controlado
Consultahttps://ai.google.dev/gemini-api/docs/pricing:1Kimagemgemini-3.1-flash-image≈US$0,067;3≈US$0,201 maisinput/thinkingtokens. Não hágratuidadegarantida. GETmodeloconsultado; POST400/429 não produziuimage. CobrançafinalédaAPI;nenhuma afirmaçãodecustozeroreal. SemretryautomáticoPOST; limitemáximo3,cachehashprompt. Quota atualimpediucandidatos, requerajusteexternonaconta antesdenovageração.
''',
'performance/README.md':'''# Metas e medição
Metas iniciais:30FPS,cargainicial<4s, memóriaregistrada. Motorloga garden_ready eperformance_sample nos10primeirossegundos. Esse intervalonão garanteperformance durantejogolongonememcelularesfracos. Usaradb logcat filtradopackage/godot, amstart-W e dumpsysmeminfo; registrarcondições/amostra. Resultadosreaisemandroid-measurement.txt quandoobtidos. Semgarantiaalémdoaparelhomedido.
''',
'evidence/validation.md':'''# Validação técnica0.2.0
Specoriginalcapturadaemspecs/003-alfabeto-3d-mobile-tutor-gemini/request.md. Testfirst: pipelinefalhousem_gemini_client; runtimefalhousemProgress/AudioService. Depoisimplementação:10testesPython,21assertionsGodot. Capturas5telasPNG. ImportGodot/GLB eexportdebug locais.
Avisosderesourcesnoencerramentodos testesaudiorápidos foramresolvidos aguardando0.4s paralimpeza do mixer. APIreal:GETsucesso;Interations400;generateContent429quota. Nenhuma chave impressa oupersistida. Candidatosnãoaprovadosnãoempacotados.
Reviewhumana/modelos/imagens/pedagogia eaceitefinalpendentes. Build éprotótipotécnico, não entrega aprovadafinal. Dadoshash/versãoem build/android/debug/manifest.json. Logsarquivadosnesta pasta.
'''
}
docs = {
'inventory/atividades.md': '# Atividades\n\nB/bola, C/casa e D/dado: escolher a letra inicial entre B/C/D. Cada atividade tem apresentação, duas dicas, correção gentil, celebração, repetição com legenda e progresso local. Erros sem penalização. Voltar ao jardim permite continuar.\n',
'inventory/imagens.md': '# Imagens\n\nTrês conceitos pending. GET do modelo autenticado; Interactions HTTP400; generateContent com mesmo modelo HTTP429 quota. Nenhum candidato gerado/aprovado/integrado. Geometria autoral permite testar; não substitui o requisito Gemini para aceitação final.\n',
'inventory/voz-atual.md': '# Voz atual\n\n16 falas provisórias Maria Desktop pt-BR via SAPI, OGG Vorbis mono44100. Captions/IDs em godot/content/speech.json. Conversão soundfile/libsndfile com qualidade padrão; bitrate96kbps não foi imposto. Pronúncia e adequação pedagógica precisam de revisão. Repetir cancela a fala anterior.\n',
'inventory/tucano-referencias.md': '# Tutor\n\nReferência em blender/tucano/ref/original.png. Rômulo Penha preserva corpo escuro, barriga clara, asas turquesa e bico laranja. Modelo de revisão com seis bones, onze clips e orçamento superior de6400 triângulos. Costas, profundidade e lado oposto inferidos. Vistas em blender/tucano/review; revisão humana e comparação final de silhueta pendentes.\n',
'inventory/progressao.md': '# Progressão\n\nPerfil local anônimo, três atividades independentes. Schema2 em user://progress.json; backup.bak e temporário.tmp. Migração1→2 preserva atividades. Esquema futuro não é sobrescrito. Backup válido recupera corrupção. Se ambos inválidos, escrita bloqueada para evitar perda silenciosa.\n',
'inventory/licencas.md': '# Licenças\n\nGodot MIT, Blender GPL como ferramenta, Nunito OFL1.1 incluída. Modelos/geometrias autorais. Conferir direitos de redistribuição do áudio Maria antes de publicar. Gemini exige revisão dos termos/proveniência. Código existente sem licença declarada: não impor MIT automaticamente.\n',
'inventory/reaproveitamento.md': '# Reaproveitamento\n\nWeb e Godot2D preservados. Reaproveitados nome/cores, Nunito, SAPI e SDK/Java/templates. Launcher ADB parametrizado para APK/pacote. Nova frente godot/ usa pacote distinto com.romulopenha.alfabeto3d.\n',
'adr/0001-godot-blender-mobile.md': '# ADR0001 — Godot/Blender\n\nGodot4.7.2 Compatibility e Blender5.2.2 GLB. Android primeiro, geometria leve e fontes editáveis. Modelo está em revisão; aprovação técnica não é aprovação visual final.\n',
'adr/0002-gemini-image-generation-production-only.md': '# ADR0002 — Imagens em produção\n\nModelo exato gemini-3.1-flash-image. Chave externa CHAVE_API_GEMININI. generateContent configurado explicitamente após metadata anunciar esse método; Interactions rejeitou formato. Sem troca de modelo ou fallback. Limite3, cache prompt/modelo e nenhum retryPOST. HTTP429 interrompe. Candidato→revisão humana→aprovado. Build -RequireApproved exige três assets revisados.\n',
'adr/0003-offline-child-experience.md': '# ADR0003 — Runtime offline\n\nCliente Gemini e chave não entram no APK. Catálogo, voz e modelos locais. Sem permissão Internet, analytics ou login. Progresso no aparelho. Candidatos fora do projeto Godot.\n',
'adr/0004-ios-environment.md': '# ADR0004 — iOS\n\nCompatibility, GLB e OGG permitem compartilhar código. Export assinado exige Mac/Xcode; nenhum IPA gerado no Windows. Validar toque, safe area e performance em aparelho Apple. Não bloquear Android por ausência de Mac.\n',
'env/windows.md': '# Ambiente\n\nGodot4.7.2 e Blender5.2.2 nos caminhos AGENTS.md; Android SDK/Java locais. Python3.14, Pillow12.3, soundfile e PyYAML. PORTA_CELULAR: usuário Windows→sistema→processo; serial ADB, nunca COM. Deploy aguarda até15s após iniciar servidor. Chave nunca copiada ao projeto.\n',
'env/ios.md': '# iOS\n\nEm Mac, instalar Godot/templates compatíveis e Xcode. Adicionar preset iOS, bundleID com.romulopenha.alfabeto3d, team/assinatura local fora do Git; exportar projeto Xcode e testar no aparelho. Nenhuma validação real iOS realizada.\n',
'licenses/README.md': '# Direitos\n\nVer ../inventory/licencas.md. Licença da ferramenta não define licença dos assets. Gemini exige prompt/modelo/data/hash/revisor e revisão dos termos. Não foi criada licença automática para o código existente.\n',
'costs/gemini.md': '# Custo controlado\n\nFonte https://ai.google.dev/gemini-api/docs/pricing: imagem1K≈US$0,067; três≈US$0,201 mais tokens. Sem gratuidade garantida. Chamadas400/429 não produziram imagem; conferir cobrança na conta. Teto3, cache e nenhum retryPOST. Quota impediu candidatos e precisa ser resolvida externamente.\n',
'performance/README.md': '# Performance\n\nMetas30FPS/início<4s/memória registrada. Motor registra garden_ready e performance_sample nos primeiros10s. Isso não comprova jogo longo nem celulares fracos. Usar am start -W, logcat e dumpsys meminfo. Aparelho desconectado na tentativa atual; nenhuma métrica real aprovada.\n',
'evidence/validation.md': '# Validação0.2.0\n\nTest first: pipeline falhou sem cliente; runtime sem serviços. Depois:10 testes Python e21 verificações Godot passaram. Cinco capturas. Import GLB e APKdebug concluídos. Avisos no encerramento dos testes resolvidos aguardando limpeza do mixer.\n\nAPI GETsucesso/Interactions400/generateContent429. Nenhum candidato/aprovado; segredo não impresso/persistido. Celular desconectado: deploy3D e métricas reais pendentes. Modelo/imagens/pedagogia aguardam revisão humana. Hash/versão no manifesto do APK. Aceitação final não declarada.\n',
}
for name,text in docs.items():
    path=ROOT/'docs'/name; path.parent.mkdir(parents=True,exist_ok=True); path.write_text(text,encoding='utf-8')
