import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, existsSync, mkdtempSync, cpSync, rmSync, mkdirSync, writeFileSync} from 'node:fs';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {tmpdir} from 'node:os';
import {join, resolve, sep} from 'node:path';
import vm from 'node:vm';
import {chromium} from 'playwright';

const root = new URL('../apps/alfabeto-divertido/', import.meta.url);
test('modular: one entry, four CSS layers and eight cohesive local scripts', () => {
  const html = readFileSync(new URL('index.html', root), 'utf8');
  assert.doesNotMatch(html, /<style\b|<script\b(?![^>]*\bsrc=)|\son\w+=/i);
  const styles = [...html.matchAll(/<link[^>]+href="([^"]+)"/g)].map(x=>x[1]);
  const scripts = [...html.matchAll(/<script[^>]+src="([^"]+)"[^>]*><\/script>/g)].map(x=>x[1]);
  assert.deepEqual(styles, ['styles/base.css','styles/theme.css','styles/components.css','styles/animations.css']);
  assert.equal(scripts.length, 8);
  assert.equal([...html.matchAll(/<script defer src=/g)].length, 8);
  for (const path of [...styles,...scripts]) {
    assert.match(path, /^(styles|js)\/[a-z/]+\.(css|js)$/);
    assert.ok(existsSync(fileURLToPath(new URL(path, root))), path);
    assert.doesNotMatch(readFileSync(new URL(path, root),'utf8'), /\bfetch\s*\(|\bimport\s*\(|https?:\/\//);
  }
});

test('modular: domain decisions preserve errors, independent occurrences and single completion', () => {
  const code=['js/data/content.js','js/game/rounds.js'].map(path=>readFileSync(new URL(path,root),'utf8')).join('\n');
  const r=vm.runInNewContext(code+'\nwindow.AlfabetoDivertido.rounds',{window:{}});
  const state={mode:'montePalavra',questions:[{word:'CASA',emoji:'🏠'}],index:0,results:[],first:0};
  const q=r.prepareQuestion(state);
  const take=letter=>q.occurrences.find(item=>item.letter===letter&&!item.used);
  assert.equal(r.chooseOccurrence(q,take('A').id),'wrong');
  assert.equal(q.position,0);
  const c=take('C');assert.equal(r.chooseOccurrence(q,c.id),'placed');
  assert.equal(r.chooseOccurrence(q,c.id),'ignored');
  assert.equal(r.chooseOccurrence(q,take('A').id),'placed');
  assert.equal(r.chooseOccurrence(q,take('S').id),'placed');
  assert.equal(r.chooseOccurrence(q,take('A').id),'complete');
  assert.equal(r.completeQuestion(state),true);
  assert.equal(r.completeQuestion(state),false);
  assert.equal(state.results.length,1);assert.equal(state.first,0);
  assert.equal(q.error,true);
});

test('modular: relocated folder opens every mode over file protocol without network or leaked globals', async () => {
  const temporary=mkdtempSync(join(tmpdir(),'alfabeto-modular-'));
  const target=join(temporary,'pasta com espaços','alfabeto-divertido');
  let browser;
  try {
    cpSync(fileURLToPath(root),target,{recursive:true});
    browser=await chromium.launch({channel:process.env.BROWSER_CHANNEL||'chrome'});
    const context=await browser.newContext({offline:true,reducedMotion:'reduce'});
    const page=await context.newPage();const errors=[],requests=[];
    page.on('pageerror',e=>errors.push(e.message));
    page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
    page.on('request',r=>{if(/^https?:/.test(r.url()))requests.push(r.url());});
    await page.goto(pathToFileURL(join(target,'index.html')).href);
    assert.equal(await page.evaluate(()=>typeof window.state),'undefined');
    for(const mode of ['primeiraLetra','montePalavra','alfabeto']) {
      await page.locator(`[data-mode="${mode}"]`).click();
      await page.locator('#question').waitFor({state:'visible'});
      assert.equal(await page.evaluate(()=>AlfabetoDivertido.app.store.state.mode),mode);
      await page.keyboard.press('Escape');
      assert.equal(await page.evaluate(()=>AlfabetoDivertido.app.store.pendingCount),0);
    }
    assert.deepEqual(errors,[]);assert.deepEqual(requests,[]);
    const evidence=new URL('./evidence/modular/',import.meta.url);
    mkdirSync(evidence,{recursive:true});
    writeFileSync(new URL(`relocated-${process.env.BROWSER_CHANNEL||'chrome'}.json`,evidence),JSON.stringify({version:'2.0.0',protocol:'file:',modes:3,errors,requests,relocated:true},null,2));
  } finally {
    await browser?.close();
    // Verify the resolved temporary target before recursive removal on Windows.
    assert.ok(resolve(temporary).startsWith(resolve(tmpdir())+sep));
    assert.ok(temporary.split(sep).at(-1).startsWith('alfabeto-modular-'));
    rmSync(temporary,{recursive:true,force:true});
  }
});
