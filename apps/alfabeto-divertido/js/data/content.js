(() => {
  'use strict';
  const game = window.AlfabetoDivertido ||= {};
  const TOTAL = 8;
  const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const WORDS = [
    ['GATO','🐱'],['PATO','🦆'],['BOLA','⚽'],['CASA','🏠'],['SAPO','🐸'],['RATO','🐭'],
    ['DADO','🎲'],['FACA','🔪'],['VACA','🐄'],['LOBO','🐺'],['URSO','🐻'],['FLOR','🌸'],
    ['FOGO','🔥'],['MESA','🪑'],['CAMA','🛏️'],['PIPA','🪁'],['ROSA','🌹'],['TREM','🚂'],
    ['MAPA','🗺️'],['BOLO','🎂'],['MOTO','🏍️'],['VELA','🕯️'],['SOL','☀️'],['MAR','🌊'],
    ['UVA','🍇'],['OVO','🥚'],['LUA','🌙'],['BOI','🐂'],['MEL','🍯']
  ].map(([word,emoji])=>Object.freeze({word,emoji}));
  const EXAMPLES = Object.fromEntries([
    ['A','ABELHA','🐝'],['B','BOLA','⚽'],['C','CASA','🏠'],['D','DADO','🎲'],['E','ELEFANTE','🐘'],
    ['F','FLOR','🌸'],['G','GATO','🐱'],['H','HIPOPÓTAMO','🦛'],['I','ILHA','🏝️'],['J','JACARÉ','🐊'],
    ['K','KIWI','🥝'],['L','LUA','🌙'],['M','MACACO','🐵'],['N','NAVIO','🚢'],['O','OVO','🥚'],
    ['P','PATO','🦆'],['Q','QUEIJO','🧀'],['R','RATO','🐭'],['S','SAPO','🐸'],['T','TREM','🚂'],
    ['U','UVA','🍇'],['V','VACA','🐄'],['W','WIFI','📶'],['X','XÍCARA','☕'],['Y','YOUTUBE','▶️'],['Z','ZEBRA','🦓']
  ].map(([letter,word,emoji])=>[letter,Object.freeze({word,emoji})]));
  const modeNames = {primeiraLetra:'Primeira Letra',montePalavra:'Monte a Palavra',alfabeto:'Brincar com o Alfabeto'};
  game.content = Object.freeze({TOTAL, ALPHABET, WORDS:Object.freeze(WORDS), EXAMPLES:Object.freeze(EXAMPLES), modeNames:Object.freeze(modeNames)});
})();
