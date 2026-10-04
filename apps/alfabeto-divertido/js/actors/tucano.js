(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  game.createTucano = (store,motion) => {
  const $=id=>document.getElementById(id);
  const {later}=store;
  let mascotVersion=0;
  function mascot(reaction,text) {
    const version=++mascotVersion,actor=$('mascote-romulo'),bubble=$('mascote-balao');
    actor.className='mascot '+reaction;
    bubble.textContent=text;bubble.hidden=false;bubble.classList.remove('fading');
    later(()=>{if(version===mascotVersion)actor.className='mascot idle';},reaction==='confused'?600:800);
    later(()=>{if(version!==mascotVersion)return;bubble.classList.add('fading');later(()=>{if(version===mascotVersion)bubble.hidden=true;},motion.matches?0:200);},2200);
  }
  function clear() {mascotVersion++;$('mascote-balao').hidden=true;$('mascote-balao').classList.remove('fading');$('mascote-romulo').className='mascot idle';}
  return {react:mascot,clear};
  };
})();
