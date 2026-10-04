import {readFile, writeFile, mkdir} from 'node:fs/promises';
import {resolve, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';

const root = resolve(fileURLToPath(new URL('../../', import.meta.url)));
const target = join(root, 'apps', 'alfabeto-godot');
const source = await readFile(join(root, 'apps', 'alfabeto-divertido', 'js', 'data', 'content.js'), 'utf8');
const content = vm.runInNewContext(source + '\nwindow.AlfabetoDivertido.content', {window: {}});
const svgDir = join(target, 'assets', 'illustrations');
await mkdir(svgDir, {recursive: true});
await mkdir(join(target, 'data'), {recursive: true});
await mkdir(join(target, 'assets', 'fonts'), {recursive: true});
const emojiCode = emoji => [...emoji].map(c => c.codePointAt(0)).filter(c => c !== 0xfe0f).map(c => c.toString(16)).join('-');
const cards = [...content.WORDS.map(card => ({...card, letter: card.word[0]})),
  ...Object.entries(content.EXAMPLES).map(([letter, card]) => ({...card, letter}))];
const codes = [...new Set(cards.map(card => emojiCode(card.emoji)))];
async function download(url, path) {
  const response = await fetch(url);
  if (!response.ok) throw Error(`HTTP ${response.status}: ${url}`);
  let data = Buffer.from(await response.arrayBuffer());
  if (path.endsWith('.svg') && path.includes('illustrations')) {
    data = Buffer.from(data.toString('utf8').replace('<svg ', '<svg width="288" height="288" '));
  }
  await writeFile(path, data);
}
for (let index = 0; index < codes.length; index += 8) {
  await Promise.all(codes.slice(index, index + 8).map(code => download(
    `https://raw.githubusercontent.com/twitter/twemoji/v14.0.2/assets/svg/${code}.svg`, join(svgDir, `${code}.svg`))));
}
await download('https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito%5Bwght%5D.ttf', join(target, 'assets', 'fonts', 'nunito.ttf'));
await download('https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/OFL.txt', join(target, 'assets', 'fonts', 'OFL.txt'));
const html = await readFile(join(root, 'apps', 'alfabeto-divertido', 'index.html'), 'utf8');
const mascot = html.match(/<svg viewBox="0 0 110 120"[\s\S]*?<\/svg>/)[0]
  .replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" width="220" height="240" ')
  .replace(/<title[\s\S]*?<\/title>/, '').replace(/<path class="eyebrow-line"[^>]*\/>/, '');
await writeFile(join(target, 'assets', 'tucano.svg'), mascot);
const ext = [
  '[ext_resource type="Script" path="res://scripts/content_catalog.gd" id="catalog"]',
  '[ext_resource type="Script" path="res://scripts/word_card.gd" id="entry"]',
  ...codes.map((code, i) => `[ext_resource type="Texture2D" path="res://assets/illustrations/${code}.svg" id="image_${i}"]`),
];
const sub = cards.map((card, i) => `[sub_resource type="Resource" id="card_${i}"]\nscript = ExtResource("entry")\nletter = ${JSON.stringify(card.letter)}\nword = ${JSON.stringify(card.word)}\nillustration = ExtResource("image_${codes.indexOf(emojiCode(card.emoji))}")`);
const list = (start, count) => `Array[ExtResource("entry")]([${Array.from({length: count}, (_, i) => `SubResource("card_${start + i}")`).join(', ')}])`;
await writeFile(join(target, 'data', 'content_catalog.tres'),
  `[gd_resource type="Resource" script_class="ContentCatalog" load_steps=${ext.length + sub.length + 1} format=3]\n\n${ext.join('\n')}\n\n${sub.join('\n\n')}\n\n[resource]\nscript = ExtResource("catalog")\nrounds = ${list(0, 29)}\nexamples = ${list(29, 26)}\n`);
const names = ['á', 'bê', 'cê', 'dê', 'é', 'efe', 'gê', 'agá', 'i', 'jota', 'cá', 'ele', 'eme', 'ene', 'ó', 'pê', 'quê', 'erre', 'esse', 'tê', 'u', 'vê', 'dáblio', 'xis', 'ípsilon', 'zê'];
const narration = new Map();
const speak = (key, spoken = key.toLowerCase()) => narration.set(key, spoken);
for (const {word} of content.WORDS) {
  speak(`Qual é a primeira letra de ${word}?`);
  speak(`Monte a palavra ${word}.`);
  speak(`${word[0]}. ${word}! Muito bem!`, `${names[word.charCodeAt(0) - 65]}. ${word.toLowerCase()}! Muito bem!`);
  speak(`${word}! Muito bem!`);
}
for (const [letter, {word}] of Object.entries(content.EXAMPLES)) {
  speak(letter, names[letter.charCodeAt(0) - 65]);
  speak(`${letter} de ${word}`, `${names[letter.charCodeAt(0) - 65]} de ${word.toLowerCase()}`);
}
for (const phrase of ['Toque em uma letra para ouvir.', 'Tente outra letra.', 'Quase! Tente de novo.', 'Uau! Que incrível!', 'Muito bem! Parabéns!']) speak(phrase);
await writeFile(join(root, 'tools', 'godot', 'narration_manifest.json'), JSON.stringify([...narration].map(([text, spoken], index) => ({text, spoken, file: `clip_${index.toString().padStart(3, '0')}.wav`})), null, 2));
console.log(JSON.stringify({rounds: 29, examples: 26, illustrations: codes.length, target}));
