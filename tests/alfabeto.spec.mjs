// Development only: the delivered HTML never imports this suite or Playwright.
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, mkdirSync, writeFileSync} from 'node:fs';
import {fileURLToPath, pathToFileURL} from 'node:url';
import vm from 'node:vm';
import {chromium} from 'playwright';

const artifact = fileURLToPath(new URL('../apps/alfabeto-divertido/index.html', import.meta.url));
const url = pathToFileURL(artifact).href;
const channel = process.env.BROWSER_CHANNEL || 'chrome';
const evidence = fileURLToPath(new URL(`./evidence/modular/${channel}/`, import.meta.url));
mkdirSync(evidence, {recursive:true});
const groups = process.env.TEST_GROUP || '';
const checks = [];
function caseTest(name, fn) {
  test(name, {skip:!!groups && !name.startsWith(groups)}, async()=> {
    const start = Date.now();
    try {await fn(); checks.push({name,status:'passed',ms:Date.now()-start});}
    catch(e) {checks.push({name,status:'failed',error:e.message});throw e;}
    finally {
      const file=evidence+`/results-${channel}.json`;
      let previous=[];try {previous=JSON.parse(readFileSync(file,'utf8'));}catch (_) {}
      const merged=[...new Map([...previous,...checks].map(item=>[item.name,item])).values()];
      writeFileSync(file,JSON.stringify(merged,null,2));
    }
  });
}
function rules() {
  const js=['js/data/content.js','js/game/rounds.js'].map(path=>readFileSync(new URL('../apps/alfabeto-divertido/'+path,import.meta.url),'utf8')).join('\n');
  return vm.runInNewContext(js+'\n({...window.AlfabetoDivertido.content,...window.AlfabetoDivertido.rounds})',{window:{}});
}
async function open(options={}) {
  const browser=await chromium.launch({channel,headless:!options.headed});
  const context=await browser.newContext({viewport:options.viewport||{width:1024,height:768},offline:true,reducedMotion:options.reduced||'reduce',hasTouch:!!options.touch});
  const page=await context.newPage();
  page.setDefaultTimeout(5000);
  const errors=[],requests=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  page.on('request',r=>{if(/^https?:/.test(r.url()))requests.push(r.url());});
  // Test-only aliases: production exposes one namespace, no global state/test controls.
  await page.addInitScript(()=>{
    const access={state:()=>AlfabetoDivertido.app.store.state,WORDS:()=>AlfabetoDivertido.content.WORDS,renderQuestion:()=>AlfabetoDivertido.app.renderActivity,start:()=>AlfabetoDivertido.app.start,timers:()=>({size:AlfabetoDivertido.app.store.pendingCount}),sources:()=>({size:AlfabetoDivertido.app.audio.activeSourceCount})};
    for(const [name,get] of Object.entries(access))Object.defineProperty(window,name,{get,configurable:true});
  });
  if(!options.realAudio) await page.addInitScript(({voiceMode})=>{
    let seed=17; Math.random=()=>((seed=seed*16807%2147483647)-1)/2147483646;
    window.mock={utterances:[],canceled:0,voices:voiceMode==='absent'?[]:[{name:'Teste brasileiro',lang:'pt-BR',localService:voiceMode!=='remote'}],sources:[]};
    class Utterance {constructor(text){this.text=text;}}
    const synth={getVoices:()=>window.mock.voices,cancel:()=>{window.mock.canceled++;},speak:u=>window.mock.utterances.push(u),addEventListener:(name,fn)=>{window.mock.changed=fn;}};
    Object.defineProperty(window,'speechSynthesis',{value:voiceMode==='apiMissing'?undefined:synth,configurable:true});
    Object.defineProperty(window,'SpeechSynthesisUtterance',{value:Utterance,configurable:true});
    class Audio {constructor(){this.currentTime=0;this.state='running';this.destination={};}
      resume(){return Promise.resolve();}
      createGain(){return {gain:{setValueAtTime(){},exponentialRampToValueAtTime(){}},connect(){},disconnect(){}};}
      createOscillator(){const s={frequency:{setValueAtTime(){}},connect(){},disconnect(){},start(){s.started=true;},stops:[],stop(at){s.stops.push(at??'now');s.stopped=at===undefined;}};window.mock.sources.push(s);return s;}
    }
    Object.defineProperty(window,'AudioContext',{value:voiceMode==='failure'?class {constructor(){throw Error('denied');}}:Audio,configurable:true});
  },{voiceMode:options.voiceMode||'local'});
  if(options.clock!==false) await page.clock.install();
  try {await page.goto(url);}
  catch(e) {await browser.close();throw e;}
  return {page,browser,context,errors,requests};
}
async function use(options,fn) {
  const env=await open(options);
  try {await fn(env.page,env);assert.deepEqual(env.errors,[]);assert.deepEqual(env.requests,[]);}
  finally {await env.browser.close();}
}
async function start(page, mode='primeiraLetra') {
  if(await page.locator('#screen-menu').isHidden())await page.keyboard.press('Escape');
  await page.locator(`[data-mode="${mode}"]`).click();
}
async function word(page) {return page.locator('#question-word').textContent();}
async function answer(page,wrong=false) {
  const value=await word(page);
  const pool=page.locator('#pool');
  if(await pool.count()) {
    if(wrong) {
      const b=page.locator('#pool button:not([disabled])').filter({hasNotText:value[0]}).first();
      await b.click();
    }
    for(const letter of value)await page.locator(`#pool button[data-letter="${letter}"]:not([disabled])`).first().click();
  } else {
    if(wrong)await page.locator(`#choices button:not([data-letter="${value[0]}"])`).first().click();
    await page.locator(`#choices button[data-letter="${value[0]}"]`).click();
  }
}
async function advance(page,ms=1850) {await page.clock.fastForward(ms);}
async function round(page,mode,first=8) {
  await start(page,mode);
  const words=[];
  for(let i=0;i<8;i++) {words.push(await word(page));await answer(page,i>=first);await advance(page);}
  assert.equal(new Set(words).size,8);
  assert.ok(await page.locator('#screen-celebration').isVisible());
  assert.equal(await page.locator('.star.earned').count(),first===8?3:first>=5?2:1);
}

// T004: written before any application code.
caseTest('foundation: pure rules and immutable inputs', ()=>{
  const r=rules(); assert.equal(r.WORDS.length,29);assert.equal(Object.keys(r.EXAMPLES).length,26);
  for(let i=0;i<100;i++) {
    const result=r.drawRound(r.WORDS);
    assert.equal(result.length,8);assert.equal(new Set(result.map(x=>x.word)).size,8);
    for(const w of result){const c=r.makeChoices(w.word[0]);assert.equal(c.length,3);assert.equal(new Set(c).size,3);assert.ok(c.includes(w.word[0]));}
  }
  assert.equal(r.WORDS.length,29);
  assert.throws(()=>r.drawRound([]));
  assert.deepEqual(Array.from({length:9},(_,n)=>r.starsFor(n)),[1,1,1,1,1,2,2,2,3]);
  const occurrences=r.makeOccurrences('CASA');
  assert.equal(new Set(occurrences.map(x=>x.id)).size,4);
  const a=occurrences.find(x=>x.letter==='A');
  assert.equal(r.consumeOccurrence(occurrences,a.id,'C'),false);
  assert.equal(a.used,false);
  assert.equal(r.consumeOccurrence(occurrences,a.id,'A'),true);
  assert.equal(r.consumeOccurrence(occurrences,a.id,'A'),false);
  assert.equal(occurrences.filter(x=>x.letter==='A'&&!x.used).length,1);
  assert.equal(r.sessionIsCurrent(1,2),false);assert.equal(r.sessionIsCurrent(2,2),true);
});
// T005: shared responsibilities tested before the foundation implementation.
caseTest('foundation: screens, sound, inactive focus and optional API failures',async()=>{
  for(const voiceMode of ['local','remote','absent','apiMissing','failure'])await use({voiceMode},async page=>{
    assert.equal(await page.locator('#screen-menu [data-mode]').count(),3);
    assert.ok(await page.locator('#mascote-romulo').isHidden());
    await page.locator('#sound-toggle').click();
    await start(page);
    assert.equal(await page.locator('#sound-toggle-game').getAttribute('aria-pressed'),'false');
    assert.ok(await page.locator('#screen-menu').isHidden());
    assert.ok(await page.locator('#screen-celebration').isHidden());
    assert.equal(await page.locator('#progress [role="progressbar"]').getAttribute('aria-valuemax'),'8');
    await page.keyboard.press('Escape');
    assert.ok(await page.locator('#screen-menu').isVisible());
    assert.equal(await page.evaluate(()=>document.activeElement.dataset.mode),'primeiraLetra');
  });
});
caseTest('foundation: voice locality, late voice, sequence and cancellation',async()=>{
  for(const voiceMode of ['local','remote','absent','apiMissing','failure'])await use({voiceMode},async page=>{
    await start(page,'alfabeto');
    await page.locator('[data-alpha="A"]').click();
    const spoken=await page.evaluate(()=>mock.utterances.map(u=>({text:u.text,lang:u.lang,local:u.voice?.localService})));
    if(['remote','absent','apiMissing'].includes(voiceMode))assert.equal(spoken.length,0);
    else {assert.equal(spoken.at(-1).text,'A');assert.equal(spoken.at(-1).lang,'pt-BR');assert.equal(spoken.at(-1).local,true);}
    if(voiceMode==='local') {
      await page.evaluate(()=>mock.utterances.at(-1).onend());
      assert.equal(await page.evaluate(()=>mock.utterances.at(-1).text),'A de ABELHA');
      await page.locator('[data-alpha="B"]').click();
      await page.locator('[data-alpha="Z"]').click();
      const before=await page.evaluate(()=>mock.utterances.length);
      await page.evaluate(()=>mock.utterances.find(u=>u.text==='B').onend());
      assert.equal(await page.evaluate(()=>mock.utterances.length),before);
      await page.locator('#sound-toggle-game').click();
      assert.ok(await page.evaluate(()=>mock.sources.every(s=>s.stopped)));
      await page.evaluate(()=>mock.utterances.at(-1).onend());
      assert.equal(await page.evaluate(()=>mock.utterances.length),before);
    }
    if(voiceMode==='absent') {
      await page.evaluate(()=>{mock.voices=[{lang:'pt-BR',localService:true,name:'Tardia'}];mock.changed();});
      await page.locator('[data-alpha="Z"]').click();
      assert.equal(await page.evaluate(()=>mock.utterances.at(-1).text),'Z');
    }
  });
});
caseTest('foundation: old advance and reduced motion cannot change new activity',async()=>use({},async page=>{
  await start(page);await answer(page);
  await page.keyboard.press('Escape');await start(page,'alfabeto');
  await advance(page,3000);
  assert.ok(await page.locator('[data-alpha="Z"]').isVisible());
  assert.equal(await page.locator('#particles > *').count(),0);
  assert.ok(await page.locator('#progress').isHidden());
}));

// T014: initial recognition behavior before its renderer/handlers.
caseTest('initial: hint, distinct alternatives, wrong then right and duplicate input',async()=>use({},async page=>{
  await start(page);const value=await word(page);
  assert.equal(await page.locator('#hint').textContent(),'?'+value.slice(1));
  const choices=await page.locator('#choices button').evaluateAll(bs=>bs.map(b=>b.dataset.letter));
  assert.equal(new Set(choices).size,3);assert.ok(choices.includes(value[0]));
  await page.locator('#choices button').filter({hasNotText:value[0]}).first().click();
  assert.equal(await page.locator('#feedback').textContent(),'Quase! Tente outra letra 🤔');
  assert.equal(await word(page),value);
  await page.locator(`#choices button[data-letter="${value[0]}"]`).evaluate(b=>{b.click();b.click();});
  assert.equal(await page.locator('#hint').textContent(),value);
  assert.equal(await page.locator('#choices button:disabled').count(),3);
  assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'1');
  assert.equal(await page.locator('.dot.retry').count(),1);
  await page.clock.fastForward(1590);assert.equal(await word(page),value);
  await page.clock.fastForward(20);assert.notEqual(await word(page),value);
  assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'1');
}));
caseTest('initial: eight questions and first-attempt star boundaries',async()=>use({},async page=>{
  for(const first of [0,4,5,7,8])await round(page,'primeiraLetra',first);
  assert.equal(await page.locator('#sound-toggle-celebration').getAttribute('aria-pressed'),'true');
  await page.locator('#sound-toggle-celebration').click();
  await page.locator('#replay').click();
  assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'0');
  assert.equal(await page.locator('#sound-toggle-game').getAttribute('aria-pressed'),'false');
}));

// T021: word assembly checks before its implementation.
caseTest('word: repeated occurrences, incorrect input and consumed-button protection',async()=>use({},async page=>{
  await start(page,'montePalavra');
  for(const value of ['CASA','BOLO','OVO']) {
    await page.evaluate(value=>{state.questions[0]=WORDS.find(x=>x.word===value);state.index=0;state.results=[];state.first=0;renderQuestion();},value);
    assert.equal(await word(page),value);
    assert.equal(await page.locator('#slots .slot').count(),value.length);
    assert.equal(await page.locator('#pool button').count(),value.length);
    const wrong=page.locator(`#pool button:not([data-letter="${value[0]}"])`).first();
    await wrong.click();
    assert.equal(await page.locator('#feedback').textContent(),'A próxima letra é outra. Tente de novo 🤔');
    assert.equal(await page.locator('#slots .filled').count(),0);
    for(let i=0;i<value.length;i++) {
      const b=page.locator(`#pool button[data-letter="${value[i]}"]:not([disabled])`).first();
      await b.click();
      assert.equal(await page.locator('#slots .filled').count(),i+1);
      await page.locator('#pool button.used').first().evaluate(b=>b.click());
      assert.equal(await page.locator('#slots .filled').count(),i+1);
      if(i<value.length-1) {
        assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'0');
        assert.equal(await page.locator('#feedback').textContent(),'Muito bem! Continue montando!');
      }
    }
    assert.equal(await page.locator('.dot.retry').count(),1);
    assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'1');
    await page.keyboard.press('Escape');await start(page,'montePalavra');
  }
}));
caseTest('word: whole-word first attempt and eight questions',async()=>use({},async page=>{
  for(const first of [0,4,5,7,8])await round(page,'montePalavra',first);
}));

// T028: free exploration before its renderer.
caseTest('alphabet: all examples, latest selection, repeated selection and speech error',async()=>use({},async page=>{
  const examples=['ABELHA','BOLA','CASA','DADO','ELEFANTE','FLOR','GATO','HIPOPÓTAMO','ILHA','JACARÉ','KIWI','LUA','MACACO','NAVIO','OVO','PATO','QUEIJO','RATO','SAPO','TREM','UVA','VACA','WIFI','XÍCARA','YOUTUBE','ZEBRA'];
  await start(page,'alfabeto');
  assert.equal(await page.locator('[data-alpha]').count(),26);
  assert.ok(await page.locator('#progress').isHidden());
  for(let i=0;i<26;i++) {
    const letter=String.fromCharCode(65+i);
    await page.locator(`[data-alpha="${letter}"]`).click();
    assert.equal(await page.locator('.example-word').textContent(),examples[i]);
    assert.equal(await page.locator('[data-alpha][aria-pressed="true"]').count(),1);
    await page.evaluate(()=>mock.utterances.at(-1).onend());
    assert.equal(await page.evaluate(()=>mock.utterances.at(-1).text),`${letter} de ${examples[i]}`);
  }
  const before=await page.evaluate(()=>mock.utterances.length);
  await page.locator('[data-alpha="Z"]').click();
  assert.equal(await page.evaluate(()=>mock.utterances.length),before+1);
  await page.evaluate(()=>mock.utterances.at(-1).onerror());
  assert.equal(await page.locator('.example-word').textContent(),'ZEBRA');
  assert.equal(await page.locator('#stars .star').count(),0);
  await page.keyboard.press('Escape');await advance(page,3000);
  assert.ok(await page.locator('#screen-menu').isVisible());
}));

// T034: new cross-mode checks before refinement of layout/accessibility.
caseTest('inclusive: normal motion cancellation and changing motion preference',async()=>use({reduced:'no-preference',clock:false},async page=>{
  // Cancel transitions before their 350 ms cleanup, then re-enter each screen.
  for(let i=0;i<10;i++)await page.evaluate(()=>{
    document.querySelector('[data-mode="primeiraLetra"]').click();
    document.getElementById('game-menu').click();
    document.querySelector('[data-mode="alfabeto"]').click();
    document.getElementById('game-menu').click();
  });
  await page.waitForTimeout(400);
  const centered=await page.locator('#screen-menu').boundingBox();
  assert.ok(centered.x>=0&&centered.x+centered.width<=1025);
  assert.equal(await page.locator('#screen-menu').getAttribute('style'),null);
  await start(page);await page.waitForTimeout(400);
  await answer(page);
  assert.ok(await page.locator('#particles > *').count()>0);
  await page.emulateMedia({reducedMotion:'reduce'});
  await page.waitForFunction(()=>document.getElementById('particles').children.length===0,{},{polling:25});
  assert.equal(await page.locator('#particles > *').count(),0);
  assert.equal(await page.locator('body').evaluate(el=>getComputedStyle(el).animationName),'none');
  await page.keyboard.press('Escape');await page.waitForTimeout(450);
  await start(page,'alfabeto');await page.waitForTimeout(450);
  await page.keyboard.press('Escape');await page.waitForTimeout(450);
  const box=await page.locator('#screen-menu').boundingBox();
  assert.ok(box.x>=0 && box.x+box.width<=1025,'menu remains centered after interrupted transitions');
}));
caseTest('inclusive: viewport, control sizes, actor clearance and screen captures',async()=>{
  for(const [width,height] of [[320,568],[390,844],[768,1024],[1024,768],[1366,768],[568,320]])await use({viewport:{width,height},touch:true},async page=>{
    await page.screenshot({path:evidence+`/menu-${width}x${height}.png`,fullPage:true});
    for(const mode of ['primeiraLetra','montePalavra','alfabeto']) {
      await start(page,mode);
      if(mode==='alfabeto')await page.locator('[data-alpha="Z"]').click();
      const sizes=await page.locator('#screen-game button').evaluateAll(bs=>bs.filter(b=>!b.disabled).map(b=>{const r=b.getBoundingClientRect();return [r.width,r.height];}));
      assert.ok(sizes.every(([w,h])=>w>=44&&h>=44),`${width}: controls >=44px`);
      for(const selector of ['#game-menu','#sound-toggle-game',mode==='alfabeto'?'[data-alpha="Z"]':mode==='montePalavra'?'#pool button:last-child':'#choices button:last-child']) {
        await page.locator(selector).evaluate(el=>el.scrollIntoView({block:'center'}));
        const covered=await page.locator(selector).evaluate(el=>{
          const b=el.getBoundingClientRect();const a=document.getElementById('mascote-romulo').getBoundingClientRect();const bubble=document.getElementById('mascote-balao').getBoundingClientRect();
          const overlaps=r=>b.left<r.right&&b.right>r.left&&b.top<r.bottom&&b.bottom>r.top;
          return overlaps(a)||overlaps(bubble);
        });
        assert.equal(covered,false,`${width}x${height}: ${selector} clear of actor/bubble`);
      }
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);
      await page.screenshot({path:evidence+`/${mode}-${width}x${height}.png`,fullPage:true});
      await page.keyboard.press('Escape');
    }
  });
});
caseTest('inclusive: native keyboard, focus and zoom 200 percent',async()=>use({},async page=>{
  await page.locator('[data-mode="primeiraLetra"]').focus();await page.keyboard.press('Enter');
  assert.equal(await page.evaluate(()=>document.activeElement.id),'question');
  for(let i=0;i<8;i++) {
    const value=await word(page);await page.locator(`#choices [data-letter="${value[0]}"]`).focus();await page.keyboard.press('Space');await advance(page);
  }
  assert.equal(await page.evaluate(()=>document.activeElement.id),'celebration-title');
  await page.keyboard.press('Tab');assert.equal(await page.evaluate(()=>document.activeElement.id),'replay');
  await page.keyboard.press('Enter');assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'0');
  await page.keyboard.press('Escape');
  await start(page,'montePalavra');
  const value=await word(page);
  for(const letter of value){await page.locator(`#pool [data-letter="${letter}"]:not([disabled])`).first().focus();await page.keyboard.press('Enter');}
  assert.equal(await page.locator('.slot.filled').count(),value.length);
  await page.keyboard.press('Escape');await start(page,'alfabeto');
  await page.locator('[data-alpha="Z"]').focus();await page.keyboard.press('Space');assert.equal(await page.locator('.example-word').textContent(),'ZEBRA');
  // CSS zoom models a 200% layout; real browser zoom remains a manual acceptance check.
  await page.evaluate(()=>document.documentElement.style.zoom='2');
  await page.locator('[data-alpha="Z"]').evaluate(el=>el.scrollIntoView({block:'center'}));
  assert.ok(await page.locator('[data-alpha="Z"]').isVisible());
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);
  await page.screenshot({path:evidence+'/zoom-200-layout.png',fullPage:true});
}));
caseTest('inclusive: offline packaging, exact CHG markers and text contrast',async()=>use({},async page=>{
  const html=readFileSync(artifact,'utf8');
  const paths=[...html.matchAll(/(?:src|href)="((?:styles|js)\/[^\"]+)"/g)].map(x=>x[1]);
  const source=html+paths.map(path=>readFileSync(new URL('../apps/alfabeto-divertido/'+path,import.meta.url),'utf8')).join('\n');
  assert.equal(new Set(source.match(/CHG-\d{3}/g)).size,16);
  assert.ok(!/<(?:script|link|img)[^>]+(?:src|href)\s*=\s*["']https?:/i.test(html));
  assert.ok(!/\b(?:fetch\(|XMLHttpRequest|@import|https?:\/\/)/.test(html));
  assert.equal(await page.locator('svg title').textContent(),'Rômulo Penha, o tucano mascote');
  const failures=await page.locator('.mode').evaluateAll(buttons=>{
    const luminance=s=>{
      const rgb=s.match(/[\d.]+/g).slice(0,3).map(Number).map(x=>x/255).map(x=>x<=.04045?x/12.92:((x+.055)/1.055)**2.4);
      return rgb[0]*.2126+rgb[1]*.7152+rgb[2]*.0722;
    };
    return buttons.map(b=>{const bg=luminance(getComputedStyle(b).backgroundColor);const fg=luminance(getComputedStyle(b.querySelector('small')).color);return {text:b.textContent,ratio:(Math.max(bg,fg)+.05)/(Math.min(bg,fg)+.05)};}).filter(x=>x.ratio<4.5);
  });
  assert.deepEqual(failures,[]);
}));

caseTest('inclusive: speech failure restores live text and mute cancels scheduled sources',async()=>use({},async page=>{
  await start(page,'alfabeto');await page.locator('[data-alpha="A"]').click();
  assert.ok(await page.evaluate(()=>mock.sources.some(s=>!s.stopped)));
  await page.evaluate(()=>mock.utterances.at(-1).onerror());
  assert.equal(await page.locator('#feedback').getAttribute('aria-live'),'polite');
  await page.locator('#sound-toggle-game').click();
  assert.ok(await page.evaluate(()=>mock.sources.every(s=>s.stopped&&s.stops.includes('now'))));
  const count=await page.evaluate(()=>mock.utterances.length);
  await page.locator('[data-alpha="Z"]').click();
  assert.equal(await page.evaluate(()=>mock.utterances.length),count);
  assert.equal(await page.locator('.example-word').textContent(),'ZEBRA');
  await page.locator('#sound-toggle-game').click();
  assert.equal(await page.evaluate(()=>mock.utterances.length),count);
}));

caseTest('inclusive: real native API inventory and sound cleanup',async()=>use({realAudio:true,clock:false},async(page)=>{
  await page.waitForTimeout(1200);
  const voices=await page.evaluate(()=>window.speechSynthesis?.getVoices().map(v=>({name:v.name,lang:v.lang,localService:v.localService}))||[]);
  writeFileSync(evidence+`/voices-${channel}.json`,JSON.stringify({channel,voices,localPtBR:voices.some(v=>/^pt[-_]BR$/i.test(v.lang)&&v.localService)},null,2));
  if(voices.some(v=>/^pt[-_]BR$/i.test(v.lang)&&v.localService)) {
    await page.evaluate(()=>{
      window.nativeSpeech=[];const original=speechSynthesis.speak.bind(speechSynthesis);
      speechSynthesis.speak=u=>{const item={text:u.text,lang:u.lang,voice:u.voice?.name,local:u.voice?.localService,status:'started'};nativeSpeech.push(item);u.addEventListener('end',()=>item.status='ended');u.addEventListener('error',e=>{item.status='error';item.error=e.error;});original(u);};
    });
    await start(page,'alfabeto');await page.locator('[data-alpha="Z"]').click();
    await page.waitForFunction(()=>nativeSpeech.length===2&&nativeSpeech.every(x=>x.status!=='started'),{},{timeout:12000,polling:100});
    const result=await page.evaluate(()=>nativeSpeech);
    writeFileSync(evidence+`/native-speech-${channel}.json`,JSON.stringify(result,null,2));
    assert.deepEqual(result.map(x=>[x.text,x.lang,x.local,x.status]),[['Z','pt-BR',true,'ended'],['Z de ZEBRA','pt-BR',true,'ended']]);
  }
  await start(page);await answer(page);
  await page.locator('#sound-toggle-game').click();
  assert.equal(await page.evaluate(()=>sources.size),0);
  await page.waitForTimeout(1900);
  assert.equal(await page.locator('#sound-toggle-game').getAttribute('aria-pressed'),'false');
  assert.equal(await page.evaluate(()=>sources.size),0);
}));
caseTest('inclusive: normal visual effects, reactions and touch input',async()=>use({clock:false,reduced:'no-preference',touch:true},async page=>{
  await start(page);await page.waitForTimeout(400);const value=await word(page);
  await page.locator(`#choices button:not([data-letter="${value[0]}"])`).first().tap();
  assert.ok(await page.locator('.error-flash').count()>0);
  assert.ok(await page.locator('#mascote-romulo').evaluate(el=>el.classList.contains('confused')));
  await page.screenshot({path:evidence+'/initial-error-motion.png'});
  await page.locator(`#choices button[data-letter="${value[0]}"]`).tap();
  assert.ok(await page.locator('.letter.correct.wave').count()>0);
  assert.equal(await page.locator('.burst-star').count(),8);
  assert.equal(await page.locator('.confetti').count(),18);
  assert.equal(await page.locator('#question-emoji').evaluate(el=>el.classList.contains('happy')),true);
  assert.equal(await page.locator('#mascote-romulo').evaluate(el=>el.classList.contains('happy')),true);
  await page.screenshot({path:evidence+'/initial-correct-motion.png'});
  await page.keyboard.press('Escape');await page.waitForTimeout(400);
  await start(page,'montePalavra');await page.waitForTimeout(400);
  const w=await word(page);await page.locator(`#pool [data-letter="${w[0]}"]`).first().tap();
  assert.equal(await page.locator('.slot.filled').count(),1);
  await page.locator('#pool button.used').first().tap({force:true});
  assert.equal(await page.locator('.slot.filled').count(),1);
  await page.screenshot({path:evidence+'/word-partial-motion.png'});
  await page.keyboard.press('Escape');await page.waitForTimeout(400);
  await start(page,'alfabeto');await page.waitForTimeout(400);await page.locator('[data-alpha="Z"]').tap();
  assert.equal(await page.locator('.alpha-letter.glow').count(),1);
  await page.waitForTimeout(2400);
  assert.equal(await page.locator('.alpha-letter.glow').count(),0);
  assert.ok(await page.locator('#mascote-balao').isHidden());
  assert.equal(await page.evaluate(()=>timers.size),0);
}));

// T044: celebration/replay refinements and complete boundary regression.
caseTest('final: nine scores in both modes, exact messages and replay cleanup',async()=>use({},async page=>{
  const titles=['Boa! Continue!','Muito bem!','Uau! Que incrível!'];
  for(const mode of ['primeiraLetra','montePalavra'])for(let first=0;first<=8;first++) {
    await round(page,mode,first);const n=first===8?3:first>=5?2:1;
    assert.equal(await page.locator('#celebration-title').textContent(),titles[n-1]);
    assert.equal(await page.locator('#star-result').textContent(),`${n} de 3 estrelas`);
    assert.equal(await page.locator('#stars .star').count(),3);
    if([0,5,8].includes(first))await page.screenshot({path:evidence+`/celebration-${mode}-${n}-stars.png`,fullPage:true});
    await page.locator('#replay').click();
    assert.equal(await page.locator('[role="progressbar"]').getAttribute('aria-valuenow'),'0');
    assert.equal(await page.locator('.dot.good,.dot.retry,.star').count(),0);
    if(mode==='montePalavra')assert.equal(await page.locator('.slot.filled').count(),0);
  }
}));
caseTest('final: ten rounds per evaluated mode and ten activity cancellation cycles',async()=>use({},async page=>{
  for(const mode of ['primeiraLetra','montePalavra'])for(let i=0;i<10;i++)await round(page,mode,i%9);
  for(let i=0;i<10;i++) {
    await start(page,'montePalavra');const value=await word(page);
    await page.locator(`#pool [data-letter="${value[0]}"]`).first().click();
    await page.keyboard.press('Escape');await start(page);await answer(page);
    await page.keyboard.press('Escape');await start(page,'alfabeto');
    await page.locator('[data-alpha="A"]').click();await page.locator('[data-alpha="Z"]').click();
    await advance(page,3000);
    assert.equal(await page.locator('.example-word').textContent(),'ZEBRA');
    assert.ok(await page.locator('#progress').isHidden());
    await page.keyboard.press('Escape');await advance(page,3000);
    assert.ok(await page.locator('#mascote-romulo').isHidden());
    assert.equal(await page.evaluate(()=>timers.size),0);
    assert.equal(await page.evaluate(()=>sources.size),0);
  }
}));

// Supplemental real-time endurance: no fake clock, 15 minutes of repeated UI use.
test('soak: fifteen minutes with real timers', {skip:!process.env.RUN_SOAK},async()=>use({clock:false,reduced:'no-preference'},async(page)=>{
  const began=Date.now(),record={started:new Date().toISOString(),clock:'real',events:0,cycles:0,samples:[]};
  await page.locator('#sound-toggle').click();
  while(Date.now()-began<900000) {
    for(const mode of ['primeiraLetra','montePalavra','alfabeto']) {
      await start(page,mode);record.events++;
      if(mode==='alfabeto') {
        for(const letter of ['A','B','Z','Z']) {await page.locator(`[data-alpha="${letter}"]`).click();record.events++;}
      } else {await answer(page,true);record.events++;await page.waitForTimeout(1950);}
      await page.keyboard.press('Escape');
      await page.waitForTimeout(2400);
      const sample=await page.evaluate(()=>({timers:timers.size,sources:sources.size,particles:document.getElementById('particles').children.length}));
      assert.deepEqual(sample,{timers:0,sources:0,particles:0});
      record.samples.push({elapsedMs:Date.now()-began,...sample});
    }
    record.cycles++;record.elapsedMs=Date.now()-began;
    writeFileSync(evidence+'/soak.json',JSON.stringify(record,null,2));
    if(record.cycles%5===0)console.log('SOAK',Math.floor(record.elapsedMs/1000)+'s',record.cycles+' cycles');
  }
  record.completed=new Date().toISOString();record.elapsedMs=Date.now()-began;
  writeFileSync(evidence+'/soak.json',JSON.stringify(record,null,2));
}));

test('performance: PERF-01 real-clock benchmark', {skip:!process.env.RUN_PERF},async()=>use({clock:false,headed:true,viewport:{width:768,height:1024},reduced:'no-preference'},async(page,{context})=>{
  const cdp=await context.newCDPSession(page);
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:4});
  await page.bringToFront();await page.locator('#sound-toggle').click();
  const scenarios=['initial-correct','initial-wrong','word-intermediate','word-wrong','word-final','alphabet-selection'];
  const record={profile:'PERF-01',clock:'real',cpu:4,viewport:[768,1024],deviceScaleFactor:1,zoom:100,offline:true,sound:false,channel,browser:page.context().browser().version(),warmups:2,samples:[],started:new Date().toISOString()};
  for(const scenario of scenarios)for(let sample=-2;sample<20;sample++) {
    const mode=scenario.startsWith('initial')?'primeiraLetra':scenario.startsWith('word')?'montePalavra':'alfabeto';
    await start(page,mode);
    await page.waitForTimeout(400);
    let selector,expected;
    if(mode==='alfabeto') {selector='[data-alpha="Z"]';expected='Z de ZEBRA';}
    else {
      const value=await word(page);
      if(scenario==='word-final') {
        for(const letter of value.slice(0,-1))await page.locator(`#pool button[data-letter="${letter}"]:not([disabled])`).first().click();
        selector=`#pool button[data-letter="${value.at(-1)}"]:not([disabled])`;expected=`🎉 Isso! ${value}!`;
      } else if(scenario==='word-intermediate') {selector=`#pool button[data-letter="${value[0]}"]`;expected='Muito bem! Continue montando!';}
      else if(scenario==='word-wrong') {selector=`#pool button:not([data-letter="${value[0]}"])`;expected='A próxima letra é outra. Tente de novo 🤔';}
      else if(scenario==='initial-correct') {selector=`#choices button[data-letter="${value[0]}"]`;expected=`🎉 ${value[0]} de ${value}!`;}
      else {selector=`#choices button:not([data-letter="${value[0]}"])`;expected='Quase! Tente outra letra 🤔';}
    }
    await page.evaluate(expected=>{
      window.perfSample=null;
      document.addEventListener('click',()=>{
        const begin=performance.now();
        requestAnimationFrame(()=>requestAnimationFrame(()=>{
          const el=document.getElementById('feedback'),rect=el.getBoundingClientRect();
          window.perfSample={ms:performance.now()-begin,valid:el.textContent===expected&&!document.getElementById('screen-game').hidden&&rect.width>0&&rect.height>0&&rect.bottom>0&&rect.top<innerHeight};
        }));
      },{capture:true,once:true});
    },expected);
    await page.locator(selector).first().click();
    await page.waitForFunction(()=>window.perfSample!==null,{},{polling:10});
    const result=await page.evaluate(()=>window.perfSample);
    assert.ok(result.valid,scenario+' expected feedback must be visible');
    if(sample>=0) {record.samples.push({scenario,sample:sample+1,...result});assert.ok(result.ms<=200,`${scenario}: ${result.ms} ms exceeds 200`);}
    writeFileSync(evidence+'/perf-01.json',JSON.stringify(record,null,2));
    if(sample===0)await page.screenshot({path:evidence+'/perf-'+scenario+'.png'});
    if(sample===19)console.log('PERF',scenario,'max',Math.max(...record.samples.filter(x=>x.scenario===scenario).map(x=>x.ms)).toFixed(2)+'ms');
  }
  assert.equal(record.samples.length,120);record.completed=new Date().toISOString();record.max=Math.max(...record.samples.map(x=>x.ms));
  writeFileSync(evidence+'/perf-01.json',JSON.stringify(record,null,2));
}));
