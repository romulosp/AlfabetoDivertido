# Dados

Concept: conceptId ASCII snake_case, namePt, letter, syllables, pedagogicalGoal, visualDescription, context, status. ImageCandidate: conceptId,prompt,model,generatedAt,sha256,mimeType,width,height,file,status. Approval: reviewer,reviewedAt,sha256. Runtime aceita somente approved com hash coincidente.

Progress schema2: profileId, completedActivities, conceptProgress, lastScene, audioSettings (voice/effects/music/ui), accessibilitySettings, updatedAt. Migração1→2 preserva progresso. Esquema futuro não sobrescrito.

Tutor: idle→presenting→waiting→helping/celebrating→transitioning→idle. Nova fala cancela anterior; repetição não altera progresso.
