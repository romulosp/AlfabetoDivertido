"""Prepare shared captions and speech IDs. Convert SAPI WAV files to OGG later."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
lines={'welcome':{'text':'Bem-vindo ao Jardim das Letras! Toque no chão para passear. Toque na bola, na casa ou no dado para brincar.'}}
for word,letter in [('bola','B'),('casa','C'),('dado','D')]:
    names={'B':'bê','C':'cê','D':'dê'}
    for suffix,text in {
        'prompt':f'Vamos brincar! Qual letra começa a palavra {word}?',
        'wrong':f'Boa tentativa! Escute comigo: {word}. Vamos tentar outra letra?',
        'hint1':f'Escute o começo da palavra: {word}. Procure a letra {names[letter]}.',
        'hint2':f'{word.capitalize()} começa com {names[letter]}. Toque na letra {names[letter]}.',
        'correct':f'Muito bem! {word.capitalize()} começa com {names[letter]}! Vamos descobrir outro objeto no jardim.'
    }.items(): lines[word+'_'+suffix]={'text':text}
for ident,line in lines.items(): line['file']='res://assets/audio/'+ident+'.ogg'
(ROOT/'godot/content/speech.json').write_text(json.dumps(lines,ensure_ascii=False,indent=2),encoding='utf-8')
if (ROOT/'godot/assets/audio/welcome.wav').is_file():
    import soundfile as sf
    for ident in lines:
        source=ROOT/'godot/assets/audio'/f'{ident}.wav'
        samples,rate=sf.read(source)
        sf.write(source.with_suffix('.ogg'),samples,rate,format='OGG',subtype='VORBIS')
