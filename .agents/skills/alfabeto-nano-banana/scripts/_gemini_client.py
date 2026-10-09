"""Credential-safe REST client. Never include API bodies/headers in errors."""
import base64
import json
import re
import urllib.error
import urllib.request
from pathlib import Path

KEY_FILE = Path(r'D:\desenvolvimento\chave_des\chave_des.properties')
MODEL = 'gemini-3.1-flash-image'
BASE = 'https://generativelanguage.googleapis.com/v1beta'

class GeminiError(Exception): pass

def read_key(path=KEY_FILE):
    try: text=Path(path).read_text(encoding='utf-8-sig')
    except OSError: raise GeminiError('arquivo não encontrado') from None
    for line in text.splitlines():
        line=line.strip()
        if not line or line.startswith(('#','!')): continue
        parts=re.split(r'[=:]',line,maxsplit=1)
        if parts[0].strip() == 'CHAVE_API_GEMININI' and len(parts)==2:
            if not parts[1].strip(): raise GeminiError('valor vazio')
            return parts[1].strip()
    raise GeminiError('propriedade ausente')

def request(key, route, payload=None):
    data=None if payload is None else json.dumps(payload).encode()
    req=urllib.request.Request(BASE+route,data=data,headers={'x-goog-api-key':key,'Content-Type':'application/json'})
    try:
        with urllib.request.urlopen(req,timeout=180) as result: return json.load(result)
    except urllib.error.HTTPError as error:
        error.close()
        if error.code in (401,403): raise GeminiError('falha de autenticação') from None
        if error.code==404: raise GeminiError('modelo indisponível; nenhum fallback foi usado') from None
        if error.code==429: raise GeminiError('limite ou quota da API atingido; geração interrompida') from None
        raise GeminiError(f'API falhou (HTTP {error.code}); nenhuma repetição automática') from None
    except (OSError,ValueError): raise GeminiError('falha de conexão ou resposta inválida; nenhuma repetição automática') from None

def check_access(key,model):
    if not re.fullmatch(r'[a-zA-Z0-9_.-]+',model): raise GeminiError('modelo inválido')
    result=request(key,'/models/'+model)
    if not result.get('name'): raise GeminiError('modelo indisponível')
    return result['name']

def extract_image(response):
    if 'candidates' in response:
        for candidate in response['candidates']:
            for part in candidate.get('content',{}).get('parts',[]):
                inline=part.get('inlineData',{})
                if inline.get('mimeType')=='image/png' and not part.get('thought',False):
                    try: return base64.b64decode(inline['data'],validate=True)
                    except (ValueError,TypeError,KeyError): raise GeminiError('imagem inválida') from None
        raise GeminiError('resposta sem imagem final PNG')
    if response.get('status')!='completed': raise GeminiError('geração não concluída')
    for step in response.get('steps',[]):
        if step.get('type')!='model_output': continue
        for part in step.get('content',[]):
            if part.get('type')=='image' and part.get('mime_type')=='image/png' and part.get('data'):
                try: return base64.b64decode(part['data'],validate=True)
                except (ValueError,TypeError): raise GeminiError('imagem inválida') from None
    raise GeminiError('resposta sem imagem final PNG')

def generate(key,model,prompt):
    # Explicit generateContent transport advertised by GET models for this account.
    # Same requested model; no fallback or retry to another endpoint/model.
    response=request(key,'/models/'+model+':generateContent',{'contents':[{'parts':[{'text':prompt}]}],
        'generationConfig':{'responseModalities':['TEXT','IMAGE'],'imageConfig':{'aspectRatio':'1:1','imageSize':'1K'}}})
    return extract_image(response)
