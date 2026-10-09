"""Human approval and runtime verification. Run only after an explicit review."""
import argparse
import hashlib
import json
import shutil
import sys
from datetime import datetime,timezone
from pathlib import Path
from _gemini_client import GeminiError,MODEL
from validate_catalog import validate_image
ROOT=Path(__file__).resolve().parents[4]

def approve(metadata,reviewer,root=ROOT):
    if not reviewer.strip(): raise GeminiError('revisor humano obrigatório')
    metadata=Path(metadata); meta=json.loads(metadata.read_text(encoding='utf-8'))
    required={'conceptId','prompt','model','generatedAt','sha256','mimeType','width','height','file','status'}
    if not required.issubset(meta) or meta['status']!='candidate': raise GeminiError('metadados inválidos')
    source=(metadata.parent/meta['file']).resolve()
    if source.parent!=metadata.parent.resolve(): raise GeminiError('caminho inválido')
    data=source.read_bytes(); validate_image(data)
    if hashlib.sha256(data).hexdigest()!=meta['sha256']: raise GeminiError('hash incompatível')
    catalog_path=Path(root)/'content/images/catalog.json'
    catalog=json.loads(catalog_path.read_text(encoding='utf-8-sig'))
    matches=[c for c in catalog['concepts'] if c['conceptId']==meta['conceptId']]
    if len(matches)!=1 or matches[0]['status']=='approved': raise GeminiError('asset aprovado não pode ser sobrescrito ou conceito ausente')
    destination=Path(root)/'content/images/approved'; destination.mkdir(parents=True,exist_ok=True)
    target=destination/source.name
    if target.exists(): raise GeminiError('arquivo aprovado já existe')
    approval=dict(meta,status='approved',reviewer=reviewer.strip(),reviewedAt=datetime.now(timezone.utc).isoformat())
    shutil.copyfile(source,target)
    target.with_suffix('.json').write_text(json.dumps(approval,ensure_ascii=False,indent=2),encoding='utf-8')
    matches[0]['status']='approved'; matches[0]['approvedImage']='res://assets/images/approved/'+target.name
    catalog_path.write_text(json.dumps(catalog,ensure_ascii=False,indent=2),encoding='utf-8')
    runtime=Path(root)/'godot/assets/images/approved'; runtime.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(target,runtime/target.name); shutil.copyfile(target.with_suffix('.json'),runtime/target.with_suffix('.json').name)
    (Path(root)/'godot/content/catalog_runtime.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2),encoding='utf-8')
    return approval

def verify_runtime(root=ROOT):
    catalog=json.loads((Path(root)/'godot/content/catalog_runtime.json').read_text(encoding='utf-8-sig'))
    for concept in catalog['concepts']:
        if concept['status']!='approved': raise GeminiError('conceito sem aprovação humana: '+concept['conceptId'])
        filename=Path(concept['approvedImage'].removeprefix('res://'))
        image=(Path(root)/'godot'/filename).resolve()
        approved=(Path(root)/'godot/assets/images/approved').resolve()
        if image.parent!=approved: raise GeminiError('imagem fora da pasta aprovada')
        meta=json.loads(image.with_suffix('.json').read_text(encoding='utf-8'))
        data=image.read_bytes(); validate_image(data)
        if meta.get('status')!='approved' or not meta.get('reviewer') or not meta.get('reviewedAt') or meta.get('conceptId')!=concept['conceptId'] or meta.get('sha256')!=hashlib.sha256(data).hexdigest(): raise GeminiError('aprovação/hash inválidos')
    return True

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--candidate',type=Path); parser.add_argument('--reviewer'); parser.add_argument('--verify-runtime',action='store_true'); args=parser.parse_args()
    try:
        if args.verify_runtime: verify_runtime(); print('{"approved":true}')
        elif args.candidate and args.reviewer: print(json.dumps({'approved':approve(args.candidate,args.reviewer)['conceptId']}))
        else: parser.error('use --candidate METADATA --reviewer NOME após revisão humana ou --verify-runtime')
        return 0
    except GeminiError as error: print(str(error),file=sys.stderr); return 1
    except Exception: print('falha na validação de assets aprovados',file=sys.stderr); return 1
if __name__=='__main__': sys.exit(main())
