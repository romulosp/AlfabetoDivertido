class_name GameSession
extends RefCounted

## Rules have no scene dependencies; occurrence IDs preserve repeated letters.

enum Mode {
	INITIAL,
	WORD,
	ALPHABET,
}

enum Answer {
	IGNORED,
	WRONG,
	PLACED,
	COMPLETE,
}

const ROUND_SIZE: int = 8
const ALPHABET: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var mode: int = Mode.INITIAL
var questions: Array[WordCard] = []
var results: Array[bool] = []
var choices: PackedStringArray = []
var occurrences: PackedStringArray = []
var used: Array[bool] = []
var index: int = 0
var position: int = 0
var first_attempts: int = 0
var had_error: bool = false
var is_complete: bool = false
var _catalog: ContentCatalog
var _random: RandomNumberGenerator = RandomNumberGenerator.new()


static func stars_for(score: int) -> int:
	return 3 if score >= ROUND_SIZE else 2 if score >= 5 else 1


func _init(catalog: ContentCatalog) -> void:
	_catalog = catalog
	_random.randomize()


func start(new_mode: int) -> void:
	mode = new_mode
	index = 0
	first_attempts = 0
	position = 0
	had_error = false
	is_complete = false
	questions.clear()
	results.clear()
	choices.clear()
	occurrences.clear()
	used.clear()
	if mode == Mode.ALPHABET:
		return
	var eligible: Array[WordCard] = []
	for card: WordCard in _catalog.rounds:
		if mode != Mode.WORD or card.word.length() in [3, 4]:
			eligible.append(card)
	for count: int in range(ROUND_SIZE):
		var pick: int = _random.randi_range(0, eligible.size() - 1)
		questions.append(eligible.pop_at(pick))
	_prepare_question()


func current_card() -> WordCard:
	if questions.is_empty():
		return null
	return questions[index]


func choose_initial(letter: String) -> int:
	if mode != Mode.INITIAL or is_complete or questions.is_empty():
		return Answer.IGNORED
	if letter != current_card().word[0]:
		had_error = true
		return Answer.WRONG
	_complete_question()
	return Answer.COMPLETE


func choose_occurrence(occurrence: int) -> int:
	if (
			mode != Mode.WORD or is_complete
			or occurrence < 0 or occurrence >= used.size() or used[occurrence]
	):
		return Answer.IGNORED
	if occurrences[occurrence] != current_card().word[position]:
		had_error = true
		return Answer.WRONG
	used[occurrence] = true
	position += 1
	if position == current_card().word.length():
		_complete_question()
		return Answer.COMPLETE
	return Answer.PLACED


func advance() -> bool:
	if not is_complete or index >= ROUND_SIZE - 1:
		return false
	index += 1
	_prepare_question()
	return true


func _prepare_question() -> void:
	position = 0
	had_error = false
	is_complete = false
	choices.clear()
	occurrences.clear()
	used.clear()
	var word: String = current_card().word
	if mode == Mode.INITIAL:
		choices.append(word[0])
		while choices.size() < 3:
			var letter: String = ALPHABET[_random.randi_range(0, 25)]
			if not choices.has(letter):
				choices.append(letter)
		_shuffle(choices)
	else:
		for letter: String in word:
			occurrences.append(letter)
		_shuffle(occurrences)
		used.resize(occurrences.size())
		used.fill(false)


func _shuffle(items: PackedStringArray) -> void:
	for offset: int in range(items.size() - 1, 0, -1):
		var pick: int = _random.randi_range(0, offset)
		var temporary: String = items[offset]
		items[offset] = items[pick]
		items[pick] = temporary


func _complete_question() -> void:
	is_complete = true
	results.append(not had_error)
	if not had_error:
		first_attempts += 1
