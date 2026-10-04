extends SceneTree

const Session = preload("res://scripts/game_session.gd")
const CATALOG = preload("res://data/content_catalog.tres")

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session: Session = Session.new(CATALOG)
	_check(CATALOG.rounds.size() == 29, "29 palavras originais")
	_check(CATALOG.examples.size() == 26, "26 exemplos originais")
	for score: int in range(9):
		_check(Session.stars_for(score) == (3 if score == 8 else 2 if score >= 5 else 1), "estrelas %d" % score)
	for mode: int in [Session.Mode.INITIAL, Session.Mode.WORD]:
		for score: int in range(9):
			session.start(mode)
			var seen: PackedStringArray = []
			for index: int in range(8):
				var word: String = session.current_card().word
				_check(not seen.has(word), "sorteio sem repetição")
				seen.append(word)
				if mode == Session.Mode.INITIAL:
					_check(session.choices.size() == 3, "três alternativas")
					_check(session.choices.has(word[0]), "inicial correta disponível")
					_check(session.choices[0] != session.choices[1] and session.choices[1] != session.choices[2] and session.choices[0] != session.choices[2], "alternativas distintas")
					if index >= score:
						_check(session.choose_initial("?wrong") == Session.Answer.WRONG, "erro não conclui")
					_check(session.choose_initial(word[0]) == Session.Answer.COMPLETE, "inicial conclui")
					_check(session.choose_initial(word[0]) == Session.Answer.IGNORED, "duplo acerto ignorado")
				else:
					_check(word.length() >= 3 and word.length() <= 4, "montagem elegível")
					if index >= score:
						for occurrence: int in range(session.occurrences.size()):
							if session.occurrences[occurrence] != word[0]:
								_check(session.choose_occurrence(occurrence) == Session.Answer.WRONG, "erro mantém espaços")
								_check(session.position == 0 and not session.used[occurrence], "erro não consome")
								break
					for letter: String in word:
						for occurrence: int in range(session.occurrences.size()):
							if session.occurrences[occurrence] == letter and not session.used[occurrence]:
								var result: int = session.choose_occurrence(occurrence)
								_check(result == (Session.Answer.COMPLETE if session.position == word.length() else Session.Answer.PLACED), "consumo individual")
								_check(session.choose_occurrence(occurrence) == Session.Answer.IGNORED, "letra usada não reativa")
								break
				_check(session.results.size() == index + 1, "uma conclusão por questão")
				_check(session.advance() == (index < 7), "oitava questão encerra")
			_check(session.first_attempts == score, "pontuação por palavra sem erro")
			_check(session.results.size() == 8, "oito questões exatas")
	session.start(Session.Mode.ALPHABET)
	_check(session.questions.is_empty() and session.results.is_empty(), "alfabeto livre sem rodada")
	_check(session.first_attempts == 0 and session.position == 0, "reinício limpa resultados")
	print(JSON.stringify({"suite": "godot_rules", "checks": _checks, "failures": _failures}))
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
		push_error(description)
