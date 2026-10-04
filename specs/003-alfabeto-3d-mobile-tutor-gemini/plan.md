# Implementation Plan: Alfabeto 3D

## Summary
Nova aplicação em godot/, jardim 3D com bola/casa/dado, personagem por toque, tutor Blender GLB, atividades offline e pipeline Gemini em skill local. Preservar web e Godot2D.

## Technical Context
Godot4.7.2/GDScript tipado Compatibility; Blender5.2.2 bpy; Python3.14/Pillow; RESTGemini chave local header. AndroidSDK/Java/template existentes. PNG1024, OGGmono44100, GLB. Pacote com.romulopenha.alfabeto3d versão0.2.0, fullscreen/paisagem.

## Constitution Check
Testes parser/catalog/pipeline/progresso antes da implementação e integração offline. Serviços separados, CLIJSON/exitcodes. Aceitação humana separada, sem declarar métricas antes de medir. Nenhum hook configurado.

## Project Structure
 godot/{scenes,scripts,assets,content}, blender/tucano, .agents/skills/alfabeto-nano-banana/{scripts,tests,fixtures}, content/images, tools/3d, tests/3d, docs/{inventory,adr,env,licenses,costs,performance,evidence}.

## Design
Autoloads EventBus,CatalogService,ProgressService,AudioService,SceneRouter. UI48px e mundo em _unhandled_input. Progresso schema2 migra1, temporário/backup validados. TutorGLB posesbico e áudiooffline. Aprovação humana com hash antes de integrar imagens. Build técnico pode usar geometria autoral; aceite depende de imagens aprovadas.

## Delivery
Pipeline e testes → serviços → jardim/atividades → tutor/áudio → APK/ADB/métricas. Limite inicial3 imagens semretryautomático, semfallbackmodelo. iOSdocumentado semMac.
