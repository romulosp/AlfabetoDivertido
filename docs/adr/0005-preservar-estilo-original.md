# Preservar o estilo e as atividades originais

Decisão do usuário: restaurar o personagem e o estilo de `apps/alfabeto-godot`. O jardim 3D experimental foi rejeitado. Nano Banana fica suspenso; não fazer chamadas de geração.

Os launches principais voltam ao APK `builds/android/alfabeto-divertido-debug.apk`, pacote `com.romulopenha.alfabetodivertido`. O experimento permanece isolado como material de estudo.

Integração proposta para Blender: preservar interface, ilustrações, câmera e atividades originais. Trabalhar somente o mascote, usando o desenho anterior como referência. Renderizar poses e animações com fundo transparente no Blender e exibir esses frames no mesmo componente 2D. A cena atual já utiliza frames produzidos pelo Blender em `assets/blender/romulo-penha.blend`.

Antes de substituir o personagem: comparar uma prévia do novo modelo com o anterior e obter aprovação visual. A aprovação é necessária para evitar repetir a mudança estética rejeitada. Uma integração GLB com SubViewport pode ser avaliada depois; não é necessária para obter iluminação, volume e animação feitos no Blender.
