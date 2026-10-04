(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  const {TOTAL,ALPHABET} = game.content;
  function shuffle(values, random = Math.random) {
    const copy = [...values];
    for(let i=copy.length-1;i>0;i--) {const j=Math.floor(random()*(i+1));[copy[i],copy[j]]=[copy[j],copy[i]];}
    return copy;
  }
  function drawRound(bank, random = Math.random) {
    if(new Set(bank.map(item=>item.word)).size<TOTAL)throw new Error('O banco precisa de oito palavras distintas.');
    return shuffle([...new Map(bank.map(item=>[item.word,item])).values()],random).slice(0,TOTAL);
  }
  function makeChoices(letter, random = Math.random) {return shuffle([letter,...shuffle([...ALPHABET].filter(x=>x!==letter),random).slice(0,2)],random);}
  function makeOccurrences(word, random = Math.random) {return shuffle([...word].map((letter,id)=>({letter,id,used:false})),random);}
  function consumeOccurrence(occurrences,id,expected) {
    const item=occurrences.find(x=>x.id===id);
    if(!item||item.used||item.letter!==expected)return false;
    item.used=true;return true;
  }
  function starsFor(first) {return first===8?3:first>=5?2:1;}
  function sessionIsCurrent(captured,current) {return captured===current;}


  function prepareQuestion(state) {
    state.question={...state.questions[state.index],error:false,done:false,position:0,occurrences:[]};
    if(state.mode==='montePalavra')state.question.occurrences=makeOccurrences(state.question.word);
    return state.question;
  }
  function chooseInitial(question,letter) {
    if(question.done)return 'ignored';
    if(letter!==question.word[0]) {question.error=true;return 'wrong';}
    return 'complete';
  }
  function chooseOccurrence(question,id) {
    const item=question.occurrences.find(x=>x.id===id);
    if(question.done||!item||item.used)return 'ignored';
    if(!consumeOccurrence(question.occurrences,id,question.word[question.position])) {question.error=true;return 'wrong';}
    question.position++;
    return question.position===question.word.length?'complete':'placed';
  }
  function completeQuestion(state) {
    const question=state.question;
    if(question.done)return false;
    question.done=true;state.results.push(!question.error);if(!question.error)state.first++;
    return true;
  }
  game.rounds=Object.freeze({shuffle,drawRound,makeChoices,makeOccurrences,consumeOccurrence,starsFor,sessionIsCurrent,prepareQuestion,chooseInitial,chooseOccurrence,completeQuestion});

})();
