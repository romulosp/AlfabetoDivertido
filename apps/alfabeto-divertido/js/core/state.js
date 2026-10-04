(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  game.createSession = () => {
    const state={screen:'menu',mode:null,session:0,selection:0,sound:true,questions:[],index:0,results:[],first:0,question:null};
    const timers=new Set();
    function later(fn,delay) {
      const captured=state.session;
      const id=setTimeout(()=>{timers.delete(id);if(captured===state.session)fn();},delay);
      timers.add(id);return id;
    }
    function cancelTimer(id) {clearTimeout(id);timers.delete(id);}
    function invalidate() {
      state.session++;state.selection++;
      for(const id of timers)clearTimeout(id);timers.clear();
    }
    return {state,later,cancelTimer,invalidate,get pendingCount(){return timers.size;}};
  };
})();
