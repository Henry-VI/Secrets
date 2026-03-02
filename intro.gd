extends VideoStreamPlayer

func _on_finished() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip cutscene"):
		get_tree().change_scene_to_file("res://main.tscn")
