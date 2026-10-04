# Mascote e créditos — correção de 2026-10-04

A instrução mais recente do usuário exige animação produzida no Blender, restauração do nome do mascote e crédito de desenvolvimento somente na primeira tela. Essa instrução substitui a regra anterior de crédito em todas as telas.

Preservar a identidade original do tucano: **Rômulo Penha**, corpo escuro, barriga clara, asa turquesa e bico laranja. Nome visível inclusive em paisagem compacta; descrição acessível identificando o mascote. Não exibir no menu e não capturar toque ou foco.

Fonte editável: `assets/blender/romulo-penha.blend`, criada por `tools/godot/animate_mascot.py` no Blender 5.2.2 LTS. O arquivo contém geometria plana, câmera ortográfica, ações com keyframes de corpo/asa e marcadores de espera, acerto e tentativa. Não houve substituição por um modelo 3D diferente.

Exportação: 34 quadros PNG transparentes, 220 × 240, em `apps/alfabeto-godot/assets/mascot`, com SpriteFrames. Espera: ciclo de 4 s; acerto: salto e asa em 0,8 s; tentativa: inclinação suave em 0,6 s. Godot reproduz os quadros e volta à espera ao concluir reações. Movimento reduzido conserva a pose estática.

Crédito da primeira tela: `Jogo desenvolvido por "Rômulo Penha"`. Nas atividades e celebração, o nome junto à imagem identifica o personagem; não é o crédito do desenvolvedor.

Reprodução da fonte: execute `D:\desenvolvimento\BlenderFoundation\Blender5_2\blender.exe --background --factory-startup --python tools/godot/animate_mascot.py` na raiz. Reimporte os recursos Godot, execute os testes e gere novamente o APK.
