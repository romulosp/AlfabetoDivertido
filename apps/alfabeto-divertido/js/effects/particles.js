(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  game.createEffects = (store,motion) => {
  const $=id=>document.getElementById(id);
  const {later}=store;
  function reactEmoji(kind) {
    const emoji=$('question-emoji');if(!emoji)return;
    emoji.className='question-emoji';void emoji.offsetWidth;emoji.classList.add(kind);
  }
  // CHG-301-EFEITO-CONFETE-FORMAS
  function confetti(count) {
    if(motion.matches)return;
    const colors=['#ff6b9d','#4ecdc4','#ffe66d','#a78bfa','#ff9f43'];
    for(let i=0;i<count;i++) {
      const piece=document.createElement('span');const shape=i%5;
      piece.className='confetti '+(['square','circle','triangle','symbol','symbol'][shape]);
      if(shape===3)piece.textContent='★';if(shape===4)piece.textContent='♥';
      piece.style.left=Math.random()*100+'%';piece.style.background=colors[i%5];piece.style.color=colors[i%5];piece.style.animationDelay=Math.random()*.25+'s';piece.style.setProperty('--drift',(Math.random()-.5)*180+'px');
      $('particles').append(piece);later(()=>piece.remove(),2100);
    }
  }
  // CHG-302-EFEITO-EXPLOSAO-ESTRELAS
  function burstStars(button) {
    if(motion.matches)return;
    const rect=button.getBoundingClientRect();
    for(let i=0;i<8;i++) {
      const star=document.createElement('span');star.className='burst-star';star.textContent='★';
      star.style.left=(rect.left+rect.width/2-10)+'px';star.style.top=(rect.top+rect.height/2-10)+'px';
      const angle=i*Math.PI/4;star.style.setProperty('--dx',Math.cos(angle)*85+'px');star.style.setProperty('--dy',Math.sin(angle)*85+'px');
      $('particles').append(star);later(()=>star.remove(),1050);
    }
  }

  function clearFlash() {document.querySelectorAll('.error-flash').forEach(el=>el.remove());}
  function flash() {
    if(motion.matches)return;
    const element=document.createElement('div');element.className='error-flash';element.setAttribute('aria-hidden','true');document.body.append(element);later(()=>element.remove(),300);
  }
  function clear() {$('particles').replaceChildren();clearFlash();}
  return {reactEmoji,confetti,burstStars,flash,clearFlash,clear};
  };
})();
