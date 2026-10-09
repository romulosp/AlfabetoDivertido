import base64
import io
import json
import sys
import tempfile
import unittest
from unittest.mock import patch
import urllib.error
from pathlib import Path
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from _gemini_client import read_key, extract_image, GeminiError, request
from validate_catalog import validate_catalog, validate_image
from generate_images import build_prompt, save_candidate
from approve_images import approve, verify_runtime

class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.concept = dict(conceptId='bola', namePt='bola', letter='B', syllables=['bo','la'], pedagogicalGoal='Reconhecer B', visualDescription='bola colorida', context='jardim', status='pending')
    def tearDown(self): self.tmp.cleanup()
    def png(self, size=(1024,1024)):
        out = io.BytesIO()
        Image.new('RGB', size, 'red').save(out, format='PNG')
        return out.getvalue()
    def test_properties_bom_comments_separators(self):
        file = self.root/'key.properties'
        file.write_bytes(b'\xef\xbb\xbf# comment\r\n! comment\r\nCHAVE_API_GEMININI: fake=value:other\r\n')
        self.assertEqual(read_key(file), 'fake=value:other')
    def test_exact_key_no_alias(self):
        file=self.root/'key'; file.write_text('GEMINI_API_KEY=fake')
        with self.assertRaisesRegex(GeminiError, '^propriedade ausente$'): read_key(file)
    def test_missing_empty(self):
        with self.assertRaisesRegex(GeminiError,'arquivo não encontrado'): read_key(self.root/'missing')
        file=self.root/'key'; file.write_text('CHAVE_API_GEMININI= ')
        with self.assertRaisesRegex(GeminiError,'valor vazio'): read_key(file)
    def test_catalog(self):
        self.assertEqual(validate_catalog({'schemaVersion':1,'concepts':[self.concept]}), [])
        bad=dict(self.concept, conceptId='Bola!', letter='C')
        self.assertTrue(validate_catalog({'schemaVersion':1,'concepts':[bad,bad]}))
    def test_no_image_or_invalid(self):
        with self.assertRaises(GeminiError): extract_image({'status':'completed','steps':[]})
        with self.assertRaises(GeminiError): validate_image(b'not an image')
        with self.assertRaises(GeminiError): validate_image(self.png((64,64)))
    def test_valid_response(self):
        data=self.png()
        response={'status':'completed','steps':[{'type':'model_output','content':[{'type':'image','mime_type':'image/png','data':base64.b64encode(data).decode()}]}]}
        self.assertEqual(extract_image(response), data)
        self.assertEqual(validate_image(data), (1024,1024))
    def test_prompt_and_candidate_integration(self):
        prompt=build_prompt(self.concept)
        self.assertIn('bola',prompt)
        self.assertNotIn('fake-secret',prompt)
        meta=save_candidate(self.root,self.concept,prompt,'gemini-3.1-flash-image',self.png())
        self.assertEqual(meta['status'],'candidate')
        self.assertTrue((self.root/meta['file']).is_file())
        self.assertNotIn('api_key',json.dumps(meta))
        with self.assertRaises(GeminiError): save_candidate(self.root,dict(self.concept,status='approved'),prompt,'gemini-3.1-flash-image',self.png())
    def test_generatecontent_response(self):
        data=self.png()
        self.assertEqual(extract_image({'candidates':[{'content':{'parts':[{'inlineData':{'mimeType':'image/png','data':base64.b64encode(data).decode()}}]}}]}),data)
    def test_auth_error_never_exposes_secret(self):
        error=urllib.error.HTTPError('https://example.test',403,'fake-secret',{},None)
        with patch('urllib.request.urlopen',side_effect=error):
            with self.assertRaisesRegex(GeminiError,'^falha de autenticação$'): request('fake-secret','/models/test')
    def test_human_approval_and_runtime_gate(self):
        catalog=self.root/'content/images/catalog.json'; catalog.parent.mkdir(parents=True)
        catalog.write_text(json.dumps({'schemaVersion':1,'concepts':[self.concept]}))
        runtime=self.root/'godot/content'; runtime.mkdir(parents=True)
        (runtime/'catalog_runtime.json').write_text(catalog.read_text())
        with self.assertRaises(GeminiError): verify_runtime(self.root)
        candidates=self.root/'content/images/candidates'
        meta=save_candidate(candidates,self.concept,build_prompt(self.concept),'gemini-3.1-flash-image',self.png())
        file=candidates/Path(meta['file']).with_suffix('.json')
        with self.assertRaises(GeminiError): approve(file,'',self.root)
        approve(file,'Fixture reviewer',self.root)
        self.assertTrue(verify_runtime(self.root))
        with self.assertRaises(GeminiError): approve(file,'Fixture reviewer',self.root)
        image=next((self.root/'godot/assets/images/approved').glob('*.png'))
        image.write_bytes(b'corrupted')
        with self.assertRaises(GeminiError): verify_runtime(self.root)

if __name__=='__main__': unittest.main()
