# Alfabeto Divertido — Godot Android

Versão 0.1.0 com três modos: letra inicial, montar palavras e explorar o alfabeto. Inclui narração em português dentro do aplicativo, sem conexão à internet.

O mascote Rômulo Penha usa animações de espera, acerto e tentativa produzidas no Blender. O arquivo editável está em `../../assets/blender/romulo-penha.blend`; a documentação está em `../../specs/002-godot-android/mascot.md`. Seu nome aparece junto ao personagem. O crédito de desenvolvimento aparece somente no menu inicial.

Abre em tela cheia, com orientação paisagem e barras do Android ocultas. Os elementos se ajustam à área disponível sem rolagem. O botão Voltar retorna ao menu durante uma atividade.

Abra `project.godot` no Godot 4.7.2 e pressione F5. O APK de teste fica em `../../builds/android/alfabeto-divertido-debug.apk`. Requer Android 7 ou posterior; inclui ARMv7, ARM64 e x86_64.

Para abrir o APK pelo VS Code, abra a raiz do repositório, pressione Ctrl+Shift+D, selecione **Android: abrir APK no emulador** e pressione F5. A opção **Android: gerar APK e abrir no emulador** recompila antes de instalar. Essas configurações executam o aplicativo; a depuração do GDScript continua no editor Godot. O launcher usa Node.js e PowerShell já instalados e o AVD `Medium_Tablet`, na porta 5584. Ele aguarda o Android iniciar, instala o APK e abre a atividade em paisagem. A instância usa um disco temporário e não modifica os dados salvos do AVD.

Também é possível executar **Terminal → Executar Tarefa → Android: abrir APK no emulador**. Para escolher outro AVD pela linha de comando, use `./tools/godot/launch_android.ps1 -Avd NomeDoAVD`.

Para instalar no celular USB, selecione **Android: gerar APK e deploy no celular** e pressione F5. Para reaproveitar o APK, selecione **Android: deploy APK existente no celular**. O script lê `PORTA_CELULAR` do ambiente do VS Code ou das variáveis de usuário/sistema.

Os launches e a tarefa de deploy leem `PORTA_CELULAR` automaticamente, sem identificador fixo. A cada execução, o script consulta primeiro as variáveis salvas do usuário no Windows, depois as do sistema e, se ausentes, o ambiente do processo. Assim, alterações salvas nas configurações do Windows funcionam mesmo com o VS Code aberto. Defina o serial listado por `D:\desenvolvimento\ferramentas_android\Sdk\platform-tools\adb.exe devices` (por exemplo, `RQCT504WC1W`) e confirme os diálogos com **OK**. O deploy usa `adb -s` com esse valor, mesmo com emuladores conectados. Ative a depuração USB e autorize o computador na tela do celular. Portas COM são rejeitadas.

O script também aceita `IP:porta` em `PORTA_CELULAR`, ou uma porta TCP numérica com `IP_CELULAR`, para conexão sem fio previamente pareada. A instalação atualiza o aplicativo existente e o abre em tela cheia e paisagem.

Se o Windows mostra o Samsung como dispositivo portátil e COM, mas o ADB não lista o aparelho, ative **Configurações → Sobre o telefone → Informações do software → Número de compilação** (toque sete vezes) e depois **Opções do desenvolvedor → Depuração USB**. Reconecte o cabo com o celular desbloqueado e aceite a autorização de depuração. Se ainda não aparecer, instale o [driver USB oficial da Samsung](https://developer.samsung.com/android-usb-driver). Baixar outra cópia do platform-tools não instala esse driver. As duas cópias locais do ADB foram conferidas em 2026-10-04 e tinham a mesma versão 37.0.1.

Na raiz do repositório, execute no PowerShell:

```powershell
./tools/godot/test.ps1 -Capture
./tools/godot/build_android.ps1
```

O build usa Godot em `D:\desenvolvimento\Godot`, SDK em `D:\desenvolvimento\ferramentas_android\Sdk` e Java do Android Studio em `D:\desenvolvimento\ferramentas_android\Nova pasta\AndroidStudio\jbr`. O template debug está em `D:\desenvolvimento\Godot\export_templates\4.7.2.stable\android_debug.apk`.

As regras, integração, áudio e limites de layout têm testes automatizados. As capturas estão em `../../tests/evidence/godot`. A aceitação no celular real e a avaliação humana da pronúncia ainda estão pendentes.

Créditos e licenças: [assets/ATTRIBUTION.md](assets/ATTRIBUTION.md).
