import argparse
import hashlib
import json
import sys
import uuid
from datetime import datetime,timezone
from pathlib import Path
from _gemini_client import MODEL, GeminiError, read_key, check_access, generate
from validate_catalog import validate_catalog, validate_image

def build_prompt(concept):
    return f"Ilustração educacional infantil, um único objeto: {concept['namePt']}. {concept['visualDescription']}. Estilo 3D cartoon suave, cores alegres, fundo creme simples, centralizado, objeto inteiro e facilmente reconhecível, proporções naturais, sem texto, letras, pessoas, logos ou marcas. Imagem quadrada 1024x1024. Contexto: {concept['context']}."

def save_candidate(root,concept,prompt,model,data):
    if concept.get('status')=='approved': raise GeminiError('asset aprovado não pode ser sobrescrito')
    width,height=validate_image(data)
    now=datetime.now(timezone.utc)
    stem=f"{concept['conceptId']}_cartoon_v1_candidate_{now.strftime('%Y%m%dT%H%M%S')}_{uuid.uuid4().hex[:8]}"
    root=Path(root); root.mkdir(parents=True,exist_ok=True)
    file=root/(stem+'.png')
    with file.open('xb') as out: out.write(data)
    meta={'conceptId':concept['conceptId'],'prompt':prompt,'model':model,'generatedAt':now.isoformat(),'sha256':hashlib.sha256(data).hexdigest(),'mimeType':'image/png','width':width,'height':height,'file':file.name,'status':'candidate','promptHash':hashlib.sha256((model+'\n'+prompt).encode()).hexdigest()}
    file.with_suffix('.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
    return meta

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--catalog',type=Path,required=True); parser.add_argument('--concept',action='append'); parser.add_argument('--model',default=MODEL); parser.add_argument('--limit',type=int,default=3); parser.add_argument('--check-access',action='store_true'); args=parser.parse_args()
    try:
        catalog=json.loads(args.catalog.read_text(encoding='utf-8-sig'))
        if validate_catalog(catalog): raise GeminiError('catálogo inválido')
        if not 1<=args.limit<=3: raise GeminiError('limite deve ser1..3')
        concepts=[c for c in catalog['concepts'] if not args.concept or c['conceptId'] in args.concept]
        if not concepts or len(concepts)>args.limit: raise GeminiError('conceitos excedem limite ou seleção vazia')
        key=read_key(); available=check_access(key,args.model)
        if args.check_access: print(json.dumps({'model':available,'generationNotGuaranteed':True})); return 0
        root=args.catalog.parent/'candidates'; root.mkdir(exist_ok=True)
        for concept in concepts:
            if concept['status']=='approved': raise GeminiError('asset aprovado não pode ser sobrescrito')
            prompt=build_prompt(concept); cache=hashlib.sha256((args.model+'\n'+prompt).encode()).hexdigest()
            cached=None
            for file in root.glob('*.json'):
                meta=json.loads(file.read_text(encoding='utf-8'))
                if meta.get('promptHash')==cache and (root/meta['file']).is_file():
                    data=(root/meta['file']).read_bytes(); validate_image(data)
                    if hashlib.sha256(data).hexdigest()==meta['sha256']: cached=meta; break
            meta=cached or save_candidate(root,concept,prompt,args.model,generate(key,args.model,prompt))
            print(json.dumps({'conceptId':concept['conceptId'],'candidate':meta['file'],'cached':cached is not None}))
        return 0
    except GeminiError as error: print(str(error),file=sys.stderr); return 1
    except Exception: print('falha local no pipeline; detalhes sensíveis suprimidos',file=sys.stderr); return 1
if __name__=='__main__': sys.exit(main())
