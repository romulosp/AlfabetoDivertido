(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  const store=game.createSession();
  const {state,later}=store;
  const motion=window.matchMedia('(prefers-reduced-motion: reduce)');
  const {TOTAL,WORDS,EXAMPLES,modeNames}=game.content;
  const {drawRound,starsFor,prepareQuestion,chooseInitial,chooseOccurrence,completeQuestion}=game.rounds;
  const audio=game.createAudio(store,()=>renderer.fallback());
  const {stopAudio,speak,say,sound}=audio;
  const actor=game.createTucano(store,motion),effects=game.createEffects(store,motion);
  const mascot=actor.react;
  const {reactEmoji,confetti,burstStars}=effects;
  const renderer=game.createRenderer(store,audio,motion,{initial,occurrence,alphabet});
  const {$,showScreen,focusOn,feedback,renderProgress,updateSound}=renderer;
  const soundButtons=['sound-toggle','sound-toggle-game','sound-toggle-celebration'].map($);
  function invalidate() {store.invalidate();stopAudio();effects.clear();actor.clear();renderer.resetTransitions();}
  function renderQuestion() {prepareQuestion(state);renderer.renderQuestion();}
  function renderActivity() {if(state.mode==='alfabeto')renderer.renderAlphabet();else renderQuestion();}
  function start(mode) {
    invalidate();state.mode=mode;state.index=0;state.first=0;state.results=[];state.question=null;
    state.questions=mode==='alfabeto'?[]:drawRound(mode==='montePalavra'?WORDS.filter(x=>x.word.length>=3&&x.word.length<=4):WORDS);
    $('stars').replaceChildren();$('mode-caption').textContent=modeNames[mode];feedback('');
    renderProgress();renderActivity();showScreen('game',$('question'));
    mascot('idle',mode==='alfabeto'?'Toca numa letra!':'Vamos brincar!');
  }
  function backToMenu() {
    const mode=state.mode;invalidate();state.question=null;feedback('');
    showScreen('menu',document.querySelector(`[data-mode="${mode||'primeiraLetra'}"]`));
  }
  function celebrate() {
    invalidate();const n=starsFor(state.first);
    renderer.renderCelebration(n);
    showScreen('celebration',$('celebration-title'));mascot('happy',n===3?'Você é fera!':'Mandou bem!');
    speak(n===3?'Uau! Que incrível!':'Muito bem! Parabéns!',{pitch:1.3});sound('celebrate');confetti(48);
  }
  function wrongAnswer(button) {
    const wordMode=state.mode==='montePalavra';
    feedback(wordMode?'A próxima letra é outra. Tente de novo 🤔':'Quase! Tente outra letra 🤔','bad');
    button.classList.add('wrong');const question=state.question;
    later(()=>{if(state.question===question&&!question.done)button.classList.remove('wrong');},400);
    reactEmoji('confused');mascot('confused',wordMode?'Tenta de novo!':'Tenta outra!');
    speak(wordMode?'Tente outra letra.':'Quase! Tente de novo.');sound('wrong');
    effects.flash();
  }
  function finishQuestion(button,text,spoken,bubble,delay) {
    const question=state.question;if(!completeQuestion(state))return;
    renderer.lockResponses(button);effects.clearFlash();
    feedback(text,'good');renderProgress();reactEmoji('happy');mascot('happy',bubble);
    speak(spoken,{pitch:1.3});sound('correct');burstStars(button);confetti(18);
    later(()=>{
      if(state.question!==question||state.screen!=='game')return;
      if(state.index===TOTAL-1)celebrate();else {state.index++;renderQuestion();}
    },delay);
  }
  function initial(button,letter) {
    const question=state.question,result=chooseInitial(question,letter);
    if(result==='ignored')return;
        if(result==='wrong') {wrongAnswer(button);return;}
        renderer.completeHint(question.word);
        finishQuestion(button,`🎉 ${letter} de ${question.word}!`,`${letter}. ${question.word}! Muito bem!`,'Isso!',1600);
  }
  function occurrence(button,item) {
    const question=state.question,result=chooseOccurrence(question,item.id);
    if(result==='ignored')return;
        if(result==='wrong'){wrongAnswer(button);return;}
        renderer.placeOccurrence(button,item,question);
        if(question.position===question.word.length) {
          finishQuestion(button,`🎉 Isso! ${question.word}!`,`${question.word}! Muito bem!`,'Montou tudinho!',1800);
        } else {
          feedback('Muito bem! Continue montando!','good');mascot('happy','Continua!');sound('tap');
          // The consumed native button cannot keep the keyboard user stranded.
          renderer.focusAvailableLetter();
        }
  }
  function alphabet(button,letter) {
        state.selection++;stopAudio();const selection=state.selection;
        const example=EXAMPLES[letter];
        renderer.selectAlphabet(button,letter,example);
        feedback(`${letter} de ${example.word}`);mascot('happy',`${letter} de ${example.word}`);
        say(letter,{rate:.75,pitch:1.2,onend:()=>say(`${letter} de ${example.word}`)});sound('tap');
        later(()=>{if(selection===state.selection)button.classList.remove('glow');},1000);
  }
  for(const button of document.querySelectorAll('[data-mode]'))button.addEventListener('click',()=>{if(state.screen==='menu')start(button.dataset.mode);});
  for(const button of soundButtons)button.addEventListener('click',()=>{state.sound=!state.sound;if(!state.sound)stopAudio();updateSound();feedback($('feedback').textContent,$('feedback').classList.contains('bad')?'bad':$('feedback').classList.contains('good')?'good':'');});
  $('game-menu').addEventListener('click',backToMenu);$('celebration-menu').addEventListener('click',backToMenu);
  $('replay').addEventListener('click',()=>{if(state.screen==='celebration')start(state.mode);});
  document.addEventListener('keydown',event=>{if(event.key==='Escape'&&state.screen!=='menu'){event.preventDefault();backToMenu();}});
  motion.addEventListener('change',()=>{if(motion.matches){effects.clear();renderer.resetTransitions();}});
  window.addEventListener('pagehide',invalidate);
  updateSound();
  game.app={store,audio,start,backToMenu,renderActivity};
})();
