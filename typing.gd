extends Node2D


func copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source);
	
	for filename in source_dir.get_files():
		source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		self.copy_dir_recursively(source + dir + "/", destination + dir + "/")

func remove_recursive(directory: String) -> void:
	for dir_name in DirAccess.get_directories_at(directory):
		remove_recursive(directory.path_join(dir_name))
	for file_name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file_name))

	DirAccess.remove_absolute(directory)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DirAccess.dir_exists_absolute("user://letters"):
		remove_recursive("user://letters")
	#copy_dir_recursively("res://letters/", "user://letters/")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$input.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		if $input.text == "mount":
			get_tree().change_scene_to_file("res://intro.tscn")
		$input.text = ""
