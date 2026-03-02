extends Control


var started := false
var day = 1
var time_left = 0
var starting_time: float = 300
var opened_file = ""
var censored_words = []
var completed_files = 0
var quota = 2
var mistakes = 0
var rebel_alliance = false


func array_unique(array: Array) -> Array:
	var unique: Array = []

	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func copy_letter(letter_name: String):
	DirAccess.open("user://letters").copy("res://letters".path_join(letter_name), "user://letters".path_join(letter_name))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DirAccess.make_dir_absolute("user://letters")
	copy_letter("1.txt")
	copy_letter("2.txt")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$input.grab_focus()
	if started: 
		time_left -= delta
		$clock.text = "SECONDS LEFT: " + str(roundi(time_left))
		if time_left > starting_time/2:
			$clock.add_theme_color_override("font_color", Color(0, 255, 0))
		elif time_left > starting_time/5:
			$clock.add_theme_color_override("font_color", Color(255, 255, 0))
		else:
			$clock.add_theme_color_override("font_color", Color(255, 0, 0))
		if time_left <= 0:
			started = false 
			$AnimationPlayer.play("death")



		$quota.text = "DAILY QUOTA:\n" + str(completed_files) + "/" + str(quota) + " LETTERS COMPLETE\nMISTAKES: " + str(mistakes) + "/9"



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		var payload: String = $input.text
		$input.text = ""
		match payload.split(" ")[0]:
			"fillquota":
				completed_files = quota
			"rm":
				if started && payload.right(-3):
					var file = payload.right(-3)
					if FileAccess.file_exists("user://letters".path_join(file)):
						DirAccess.remove_absolute("user://letters".path_join(file))
						mistakes += 1 
						completed_files += 1 
						if file == "6.txt":
							rebel_alliance = true
						$mistakes.text += "\nFile improperly removed"
						if completed_files == quota:
							$Console.text += "\n\nDAY COMPLETE.\n\ntype 'shutdown' to end the day."
						if mistakes >= 9:
							time_left = 0
					else:
						$Console.text += "\nrm: cannot remove '" + file + "': No such file or directory"
				else:
					$Console.text += "\nrm: missing operand"
			"shutdown":
				if completed_files >= quota:
					day += 1
					completed_files = 0
					$day.text = "WEEK " + str(day)
					$AnimationPlayer.play("new day")
					$Console.text = "Rules have been updated. Please review."
					starting_time *= 0.9
					starting_time = int(starting_time)
					time_left = starting_time
					if day == 2:
						quota = 5
						copy_letter("3.txt")
						copy_letter("4.txt")
						copy_letter("5.txt")
						copy_letter("6.txt")
						copy_letter("7.txt")
						$rules.text += "\n3. Fully censor messages with hidden codes"
					if day == 3:
						quota = 7
						copy_letter("8.txt")
						copy_letter("9.txt")
						copy_letter("10.txt")
						copy_letter("11.txt")
						copy_letter("12.txt")
						copy_letter("13.txt")
						copy_letter("14.txt")
						$rules.text += "\n4. Fully censor messages in other\nlanguages"
					if day == 4:
						quota = 6
						if rebel_alliance:
							DirAccess.open("user://letters").copy("res://letters/alt-15.txt", "user://letters/15.txt")
						else:
							copy_letter("15.txt")
						copy_letter("16.txt")
						copy_letter("17.txt")
						copy_letter("18.txt")
						copy_letter("19.txt")
						copy_letter("20.txt")
						$rules.text += "\n5. Fully censor messages without the\nphrase 'Glory to the leader'."
					if day == 5:
						quota = 1 
						if rebel_alliance:
							DirAccess.open("user://letters").copy("res://letters/alt-21.txt", "user://letters/21.txt")
						else:
							copy_letter("21.txt")
						$rules.text += "\n6. Censor all messages under all\ncircumstances."
					if day == 6:
						if rebel_alliance:
							get_tree().change_scene_to_file("res://ending_antifa.tscn")
						else:
							get_tree().change_scene_to_file("res://ending_job.tscn")

			"help":
				$Console.text += """\nBourne Shell

cat <file name>  		 prints the contents of a file.
censor <num>     		 censors a word in the most recently printed file.
censorall                censors all words in the most recently printed file.
censorrange <num>-<num>  censors a range of words in the most recently printed file.
clear					 clears the console.
echo <string>   		 prints the given string.
exit			 		 closes the game.
ls               		 lists all files.
mount            		 starts the program.
push             		 upload the current working document.
shutdown         		 turn off the computer.
rm <file name>   		 deletes a file.
"""
			"clear":
				$Console.text = ""
			"echo":
				if payload.right(-5) != "":
					$Console.text += "\n" + payload.right(-5)
			"cat":
				if started:
					if payload.right(-4) != "":
						var file_name = payload.right(-4)
						print(file_name)
						if FileAccess.file_exists("user://letters".path_join(file_name)):
							opened_file = file_name
							print(opened_file)
							$Console.text += "\n" + str(FileAccess.open("user://letters/" + file_name, FileAccess.READ).get_as_text())
						else:
							$Console.text += "\ncat: " + payload.right(-4) + ": no such file or directory"
					else:
						$Console.text += "\ncat: missing file operand"
			"ls":
				if started:
					for file in DirAccess.get_files_at("user://letters/"):
						$Console.text += "\n" + file
			"mount":
				if !started:
					started = true
					$rules.show()
					time_left = starting_time
					$Console.text = "We've begun! type \"ls\" to list the letters, and \"cat <file name>\" to print the output of a file. Use \"help\" to learn how to censor the files."

			"exit":
				get_tree().quit()
			"censor":
				if started && opened_file && payload.right(-7):
					var word_num = payload.right(-7)
					if word_num.is_valid_int():
						censored_words.append(word_num.to_int())
						var file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.READ)
						var pointer := 1
						var censored_text = ""
						
						# split the thing with multiple delimiters
						var words = file.get_as_text().split("\n", false)
						var words_split_twice = []
						for item in words:
							words_split_twice.append_array(item.split(" ", false))
						words = words_split_twice
						print(words)

						for x in words:
							if pointer == word_num.to_int():
								censored_text += "*** "
							else:
								if x.strip_edges():
									censored_text += x + " "
							pointer += 1
						file.close()
						file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.WRITE)
						$Console.text += "\n" + censored_text
						file.store_string(censored_text)
						file.close()
					print(censored_words)
			"censorall":
				if started && opened_file:
					var file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.READ)
					# split the thing with multiple delimiters
					var words = file.get_as_text().split("\n", false)
					var words_split_twice = []
					for item in words:
						words_split_twice.append_array(item.split(" ", false))
					words = words_split_twice
					var words_censored = ""
					var pointer := 1
					for word in words:
						words_censored += "*** "
						censored_words.append(pointer)
						pointer += 1
					file.close()
					file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.WRITE)
					$Console.text += "\n" + words_censored
					file.store_string(words_censored)
					file.close()
			"censorrange": # at this point we've given up on error handling
				if started && opened_file && payload.right(-12):
					var ranges = payload.right(-12).split("-")
					print(ranges.size())
					print(ranges)
					if ranges.size() <= 1:
						$Console.text += "\ncensorrange: " + payload.right(-12) + ": incomprehensible input"
						return
					for i in range(ranges[0].to_int(), ranges[1].to_int() + 1):
						censored_words.append(i)
						var file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.READ)
						var pointer := 1
						var censored_text = ""
						
						# split the thing with multiple delimiters
						var words = file.get_as_text().split("\n", false)
						var words_split_twice = []
						for item in words:
							words_split_twice.append_array(item.split(" ", false))
						words = words_split_twice
						print(words)

						for x in words:
							if pointer == i:
								censored_text += "*** "
							else:
								if x.strip_edges():
									censored_text += x + " "
							pointer += 1
						file.close()
						file = FileAccess.open("user://letters".path_join(opened_file), FileAccess.WRITE)
						file.store_string(censored_text)
						file.close()
					$Console.text += "\n" + FileAccess.open("user://letters".path_join(opened_file), FileAccess.READ).get_as_text()

			"push":
				if started:
					if opened_file:
						if opened_file == '1.txt':
							completed_files += 1
							if [8, 9, 10, 11, 12, 13, 14].all(func(value: int): return value in censored_words):
								if array_unique(censored_words).size() == 7:
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nOvercensored file."
									mistakes += 1
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/1.txt")
						if opened_file == "2.txt":
							completed_files += 1 
							if [29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50].all(func(value: int): return value in censored_words):
								if array_unique(censored_words).size() == 22:
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nOvercensored file."
									mistakes += 1
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/2.txt")
						if opened_file == "3.txt":
							completed_files += 1 
							if [48,49,50,51,52,53,54,55,56,57,58,59,60].all(func(value: int): return value in censored_words):
								if array_unique(censored_words).size() == 13:
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nOvercensored file."
									mistakes += 1
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1 
							DirAccess.remove_absolute("user://letters/3.txt")
						if opened_file == "4.txt":
							completed_files += 1 
							if censored_words.is_empty():
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nOvercensored file."
								mistakes += 1 
							DirAccess.remove_absolute("user://letters/4.txt")
						if opened_file == "5.txt":
							completed_files += 1 
							if censored_words.is_empty():
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nOvercensored file."
								mistakes += 1 
							DirAccess.remove_absolute("user://letters/5.txt")
						if opened_file == "6.txt":
							completed_files += 1
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/6.txt")
						if opened_file == "7.txt":
							completed_files += 1
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/7.txt")
						if opened_file == "8.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
								rebel_alliance = false
							elif censored_words.is_empty():
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
								rebel_alliance = true
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/8.txt")
						if opened_file == "9.txt":
							completed_files += 1 
							if censored_words.is_empty():
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nOvercensored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/9.txt")
						if opened_file == "10.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/10.txt")
						if opened_file == "11.txt":
							completed_files += 1 
							if censored_words.is_empty():
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nOvercensored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/11.txt")
						if opened_file == "12.txt":
							completed_files += 1 
							if [20,21,22,23,24,25,26,27,28].all(func(value: int): return value in censored_words):
								if array_unique(censored_words).size() == 11:
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nOvercensored file."
									mistakes += 1
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1 
							DirAccess.remove_absolute("user://letters/12.txt")
						if opened_file == "13.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/13.txt")
						if opened_file == "14.txt":
							completed_files += 1
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/14.txt")
						if opened_file == "15.txt":
							completed_files += 1 
							if !rebel_alliance:
								if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38].all(func(value: int): return value in censored_words):
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nImproperly censored file."
									mistakes += 1
							else:
								if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47].all(func(value: int): return value in censored_words):
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nImproperly censored file."
									mistakes += 1
							rebel_alliance = false
							DirAccess.remove_absolute("user://letters/15.txt")
						if opened_file == "16.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/16.txt")
						if opened_file == "17.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/17.txt")
						if opened_file == "18.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/18.txt")
						if opened_file == "19.txt":
							completed_files += 1 
							if censored_words.is_empty():
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nOvercensored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/19.txt")
						if opened_file == "20.txt":
							completed_files += 1 
							if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27].all(func(value: int): return value in censored_words):
								$mistakes.text += "\nSuccessful file."
							else:
								$mistakes.text += "\nImproperly censored file."
								mistakes += 1
							DirAccess.remove_absolute("user://letters/20.txt")
						if opened_file == "21.txt":
							completed_files += 1 
							if !rebel_alliance:
								if censored_words.is_empty():
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nImproperly censored file."
							else:
								if [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26].all(func(value: int): return value in censored_words):
									$mistakes.text += "\nSuccessful file."
								else:
									$mistakes.text += "\nImproperly censored file."
									mistakes += 1
							rebel_alliance = false
							DirAccess.remove_absolute("user://letters/21.txt")




							
					opened_file = ""
					censored_words = []
					if completed_files == quota:
						$Console.text += "\n\nDAY COMPLETE.\n\ntype 'shutdown' to end the day."
					if mistakes >= 9:
						time_left = 0
			_:
				$Console.text += "\nsh: Unknown command: " + payload.split(" ")[0]


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		get_tree().quit()
