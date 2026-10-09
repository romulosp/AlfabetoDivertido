import argparse
import io
import json
import re
import sys
from pathlib import Path
from PIL import Image
from _gemini_client import GeminiError

def validate_catalog(catalog):
    errors=[]; ids=set()
    if catalog.get('schemaVersion')!=1 or not isinstance(catalog.get('concepts'),list): return ['schema inválido']
    for concept in catalog['concepts']:
        ident=concept.get('conceptId','')
        if not re.fullmatch(r'[a-z][a-z0-9_]*',ident) or ident in ids: errors.append('conceptId inválido/duplicado')
        ids.add(ident)
        for field in ('namePt','letter','pedagogicalGoal','visualDescription','context'):
            if not isinstance(concept.get(field),str) or not concept[field].strip(): errors.append(f'{ident}: {field} ausente')
        if concept.get('letter')!=concept.get('namePt','')[:1].upper(): errors.append(f'{ident}: letra incompatível')
        if not isinstance(concept.get('syllables'),list) or ''.join(concept['syllables'])!=concept.get('namePt'): errors.append(f'{ident}: sílabas inválidas')
        if concept.get('status') not in ('pending','candidate','approved'): errors.append(f'{ident}: status inválido')
    return errors

def validate_image(data):
    if not data: raise GeminiError('imagem vazia')
    try:
        with Image.open(io.BytesIO(data)) as image:
            image.load(); size=image.size
            if image.format!='PNG' or min(size)<1024 or size[0]!=size[1]: raise GeminiError('imagem deve ser PNG quadrada, mínimo1024')
            return size
    except GeminiError: raise
    except Exception: raise GeminiError('imagem inválida') from None

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--catalog',type=Path,required=True); args=parser.parse_args()
    try:
        errors=validate_catalog(json.loads(args.catalog.read_text(encoding='utf-8-sig')))
        print(json.dumps({'valid':not errors,'errors':errors},ensure_ascii=False))
        return 1 if errors else 0
    except (OSError,ValueError): print('catálogo ilegível',file=sys.stderr); return 1
if __name__=='__main__': sys.exit(main())
