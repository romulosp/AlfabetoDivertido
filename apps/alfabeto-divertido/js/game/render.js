(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  game.createRenderer = (store,audio,motion,actions) => {
  const {state,later}=store;
  const {TOTAL,ALPHABET}=game.content;
  const {makeChoices,sessionIsCurrent}=game.rounds;
  const {speak}=audio;
  const $=id=>document.getElementById(id);
  const soundButtons=['sound-toggle','sound-toggle-game','sound-toggle-celebration'].map($);
  function updateSound() {
    for(const button of soundButtons) {button.textContent=state.sound?'🔊':'🔇';button.setAttribute('aria-pressed',String(state.sound));button.setAttribute('aria-label',state.sound?'Desligar som':'Ligar som');}
  }
  function focusOn(element) {element?.focus({preventScroll:true});}
  function showScreen(name,focus) {
    state.screen=name;
    const target=$('screen-'+name);
    for(const screen of document.querySelectorAll('.screen')) {
      screen.classList.remove('enter','exit');
      if(screen===target) {screen.removeAttribute('style');screen.hidden=false;screen.inert=false;}
      else {screen.inert=true;if(!screen.hidden) {if(motion.matches)screen.hidden=true;else {screen.classList.add('exit');screen.style.position='absolute';screen.style.top='0';screen.style.left='0';screen.style.right='0';later(()=>{screen.hidden=true;screen.classList.remove('exit');screen.removeAttribute('style');},350);}}}
    }
    $('mascote-romulo').hidden=name==='menu';
    if(!motion.matches)target.classList.add('enter');
    focusOn(focus);
    window.scrollTo({top:0,behavior:'instant'});
  }
  function feedback(text,kind='') {
    const element=$('feedback');element.className='feedback '+kind;
    // Native narration already announces this feedback when a usable voice is present.
    element.setAttribute('aria-live',state.sound&&audio.hasVoice?'off':'polite');
    element.textContent=text;
  }
  function renderProgress() {
    const free=state.mode==='alfabeto';$('progress').hidden=free;
    if(free) {$('progress').replaceChildren();return;}
    const dots=document.createElement('ol');dots.className='dots';dots.setAttribute('aria-label','Questões da rodada');
    for(let i=0;i<TOTAL;i++) {
      const result=state.results[i],dot=document.createElement('li');
      dot.className='dot '+(result===true?'good':result===false?'retry':i===state.index?'current':'');
      dot.textContent=result===true?'✓':result===false?'↻':'';
      dot.setAttribute('aria-label',`Questão ${i+1}: ${result===true?'concluída sem erro':result===false?'concluída após tentativa':i===state.index?'atual':'pendente'}`);
      if(i===state.index&&result===undefined)dot.setAttribute('aria-current','step');
      dots.append(dot);
    }
    const track=document.createElement('div');track.className='progress-track';track.setAttribute('role','progressbar');track.setAttribute('aria-label','Questões concluídas');track.setAttribute('aria-valuemin','0');track.setAttribute('aria-valuemax','8');track.setAttribute('aria-valuenow',String(state.results.length));track.setAttribute('aria-valuetext',`${state.results.length} de 8 questões concluídas`);
    const fill=document.createElement('div');fill.className='progress-fill';fill.style.width=(state.results.length/TOTAL*100)+'%';track.append(fill);
    $('progress').replaceChildren(dots,track);
  }
  function letterButton(letter,id) {
    const button=document.createElement('button');button.type='button';button.className='letter';button.dataset.letter=letter;
    if(id!==undefined)button.dataset.occurrence=String(id);
    button.setAttribute('aria-label',`Letra ${letter}`);
    const eyes=document.createElement('span');eyes.className='eyes';eyes.setAttribute('aria-hidden','true');eyes.innerHTML='<i></i><i></i>';
    button.append(eyes,document.createTextNode(letter));return button;
  }
  function renderQuestion() {
    const item=state.questions[state.index];
    feedback('');renderProgress();
    if(state.mode==='montePalavra') {renderWord();return;}
    $('game-body').innerHTML=`<h2 id="question" class="question" tabindex="-1">Qual é a primeira letra de <strong id="question-word">${item.word}</strong>?</h2><div id="question-emoji" class="question-emoji" aria-hidden="true">${item.emoji}</div><div id="hint" class="hint" aria-label="Pista: a primeira letra está faltando"><span class="missing">?</span>${item.word.slice(1)}</div><div id="choices" class="choices" role="group" aria-label="Escolha a primeira letra"></div>`;
    const captured=state.session,question=state.question;
    for(const letter of makeChoices(item.word[0])) {
      const button=letterButton(letter);
      button.addEventListener('click',()=>{
        if(!sessionIsCurrent(captured,state.session)||state.screen!=='game'||question!==state.question||question.done)return;
        actions.initial(button,letter);
      });$('choices').append(button);
    }
    focusOn($('question'));speak(`Qual é a primeira letra de ${item.word}?`);
  }
  function renderWord() {
    const question=state.question,captured=state.session;
    $('game-body').innerHTML=`<h2 id="question" class="question" tabindex="-1">Monte a palavra: <strong id="question-word">${question.word}</strong></h2><div id="question-emoji" class="question-emoji" aria-hidden="true">${question.emoji}</div><div id="slots" class="slots" role="group" aria-label="Espaços da palavra"></div><div id="pool" class="pool" role="group" aria-label="Letras para montar a palavra"></div>`;
    [...question.word].forEach((_,i)=>{
      const slot=document.createElement('span');slot.className='slot'+(i===0?' next':'');slot.setAttribute('aria-label',`Posição ${i+1}: vazia`);$('slots').append(slot);
    });
    for(const item of question.occurrences) {
      const button=letterButton(item.letter,item.id);
      button.addEventListener('click',()=>{
        if(!sessionIsCurrent(captured,state.session)||state.screen!=='game'||state.question!==question||question.done||item.used)return;
        actions.occurrence(button,item);
      });$('pool').append(button);
    }
    focusOn($('question'));speak(`Monte a palavra ${question.word}.`);
  }
  function renderAlphabet() {
    $('game-body').innerHTML='<h2 id="question" class="question" tabindex="-1">Brincar com o Alfabeto</h2><p class="alpha-instruction">Toque em uma letra para ouvir 👇</p><div id="alpha-card-wrap" class="alpha-card-wrap"><span class="alpha-placeholder" aria-hidden="true">🌈</span></div><div id="alpha-grid" class="alpha-grid" role="group" aria-label="Letras do alfabeto"></div>';
    const captured=state.session;
    for(const letter of ALPHABET) {
      const button=document.createElement('button');button.type='button';button.className='alpha-letter';button.dataset.alpha=letter;button.textContent=letter;button.setAttribute('aria-label',`Letra ${letter}`);button.setAttribute('aria-pressed','false');
      button.addEventListener('click',()=>{
        if(!sessionIsCurrent(captured,state.session)||state.mode!=='alfabeto'||state.screen!=='game')return;
        actions.alphabet(button,letter);
      });$('alpha-grid').append(button);
    }
  }
  function renderCelebration(n) {
    const titles=['','Boa! Continue!','Muito bem!','Uau! Que incrível!'];
    const messages=['','Cada tentativa te deixa mais forte. Vamos de novo?','Você está aprendendo muito rápido!','Você acertou quase tudo de primeira. Que memória boa!'];
    $('stars').replaceChildren(...Array.from({length:3},(_,i)=>{const star=document.createElement('span');star.className='star'+(i<n?' earned':'');star.style.setProperty('--delay',i*.25+'s');star.textContent='★';return star;}));
    $('celebration-title').textContent=titles[n];$('celebration-title').setAttribute('aria-describedby','star-result');
    $('star-result').textContent=`${n} de 3 estrelas`;$('celebration-message').textContent=messages[n];
  }

  function completeHint(word) {$('hint').textContent=word;$('hint').setAttribute('aria-label',`Palavra completa: ${word}`);}
  function placeOccurrence(button,item,question) {
    const slot=$('slots').children[question.position-1];slot.textContent=item.letter;slot.className='slot filled';slot.setAttribute('aria-label',`Posição ${question.position}: ${item.letter}`);
    button.disabled=true;button.classList.remove('wrong');button.classList.add('used');button.setAttribute('aria-label',`Letra ${item.letter}, usada`);
    if(question.position<question.word.length)$('slots').children[question.position].classList.add('next');
  }
  function focusAvailableLetter() {focusOn([...$('pool').children].find(el=>!el.disabled));}
  function selectAlphabet(button,letter,example) {
    for(const old of $('alpha-grid').children) {old.setAttribute('aria-pressed',String(old===button));old.classList.remove('glow');}
    if(!motion.matches)button.classList.add('glow');
    $('alpha-card-wrap').innerHTML=`<div class="alpha-card"><div class="big-letter">${letter}</div><div class="example-emoji" aria-hidden="true">${example.emoji}</div><p class="example-word">${example.word}</p></div>`;
  }
  function lockResponses(button) {
    document.querySelectorAll('#choices button,#pool button').forEach(el=>{el.disabled=true;el.classList.remove('wrong');});
    button.classList.add('correct');if(!motion.matches)button.classList.add('wave');
  }
  function resetTransitions() {document.querySelectorAll('.screen.exit').forEach(el=>{el.hidden=true;el.classList.remove('exit');el.removeAttribute('style');});}
  function fallback() {const element=$('feedback'),text=element.textContent;element.setAttribute('aria-live','polite');element.textContent='';element.textContent=text;}
  return {$,focusOn,showScreen,feedback,renderProgress,renderQuestion,renderAlphabet,updateSound,renderCelebration,resetTransitions,fallback,completeHint,placeOccurrence,focusAvailableLetter,selectAlphabet,lockResponses};
  };
})();
