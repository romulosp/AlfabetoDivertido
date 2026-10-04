(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  game.createAudio = (store,onFallback) => {
  const {state}=store;
  const {sessionIsCurrent}=game.rounds;
  const sources=new Set();
  let context=null,voice=null,speechVersion=0;
  function stopAudio() {
    speechVersion++;
    try {window.speechSynthesis?.cancel();} catch (_) {/* Optional browser service. */}
    for(const source of sources) {try {source.stop();source.disconnect();}catch (_) {} }
    sources.clear();
  }
  function refreshVoice() {
    try {voice=window.speechSynthesis?.getVoices().find(v=>/^pt[-_]BR$/i.test(v.lang)&&v.localService===true)||null;}
    catch (_) {voice=null;}
  }
  refreshVoice();
  try {window.speechSynthesis?.addEventListener('voiceschanged',refreshVoice);}catch (_) {}
  function say(text,options={}) {
    if(!state.sound||!voice||!window.SpeechSynthesisUtterance)return;
    const token=speechVersion,captured=state.session,selection=state.selection;
    try {
      const utterance=new window.SpeechSynthesisUtterance(text);
      utterance.lang='pt-BR';utterance.voice=voice;utterance.rate=options.rate??.9;utterance.pitch=options.pitch??1.15;
      utterance.onend=()=>{
        if(state.sound&&token===speechVersion&&sessionIsCurrent(captured,state.session)&&selection===state.selection)options.onend?.();
      };
      utterance.onerror=()=>{
        if(token===speechVersion&&sessionIsCurrent(captured,state.session)&&selection===state.selection)speechFallback();
      };
      window.speechSynthesis.speak(utterance);
    } catch (_) {speechFallback();}
  }
  function speechFallback() {
    voice=null;
    onFallback();
  }
  function speak(text,options) {stopAudio();say(text,options);}
  function sound(kind) {
    if(!state.sound)return;
    const notes={tap:[520],correct:[523,659,784],wrong:[300,220],celebrate:[523,659,784,1047]}[kind]||[520];
    try {
      const Audio=window.AudioContext||window.webkitAudioContext;
      if(!Audio)return;
      if(!context)context=new Audio();
      const token=speechVersion,captured=state.session;
      const play=()=>{
        if(!state.sound||token!==speechVersion||!sessionIsCurrent(captured,state.session))return;
        notes.forEach((frequency,index)=>{
          const oscillator=context.createOscillator(),gain=context.createGain();
          const start=context.currentTime+index*.12;
          oscillator.type='sine';oscillator.frequency.setValueAtTime(frequency,start);
          gain.gain.setValueAtTime(.0001,start);gain.gain.exponentialRampToValueAtTime(.07,start+.015);gain.gain.exponentialRampToValueAtTime(.0001,start+.14);
          oscillator.connect(gain);gain.connect(context.destination);sources.add(oscillator);
          oscillator.onended=()=>{sources.delete(oscillator);try {oscillator.disconnect();gain.disconnect();}catch (_) {}};
          oscillator.start(start);oscillator.stop(start+.16);
        });
      };
      if(context.state==='suspended')Promise.resolve(context.resume()).then(play).catch(()=>{});else play();
    } catch (_) {/* Web Audio is optional, including permissions or constructor failure. */}
  }
  return {stopAudio,refreshVoice,say,speak,sound,get hasVoice(){return !!voice;},get activeSourceCount(){return sources.size;}};
  };
})();
