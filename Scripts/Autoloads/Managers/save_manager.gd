extends Node

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

const SAVE_PATH = "user://SaveFile.json"


@export var PlayerArmy : Array[CharacterData]

@export var PlayerCharacters : Array[CharacterData]

@export var Levels: Array[LevelData]
@export var Events: Array[EventData]

######################
#     SCRIPT-WIDE    #
######################

var Data : Dictionary

##############################################################
#                      2.0 Functions                         #
##############################################################
func SaveData():
	var temp_data : Dictionary
	
	temp_data["PlayerArmy"] = PlayerArmy
	
	for character in PlayerCharacters:
		temp_data[character.Name] = character.CharacterLevel
	
	for level in Levels:
		temp_data[level.LevelName] = level.Cleared
	for event in Events:
		temp_data[event.EventName] = event.Cleared
	
	Data = temp_data

func LoadData():
	
	PlayerArmy = Data.get("PlayerArmy")
	GameData.PlayerArmy = PlayerArmy
	
	for character in PlayerCharacters:
		if Data.has(character.Name):
			character.CharacterLevel = Data.get(character.Name)
	
	for level in Levels:
		if Data.has(level.LevelName):
			level.Cleared = Data.get(level.LevelName)
	for event in Events:
		if Data.has(event.EventName):
			event.Cleared = Data.get(event.EventName)

func Save():
	SaveData()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	# Convert the 'Data' dictionary into a text-based JSON string.
	# The "\t" argument makes the saved file indented and easy to read.
	var json_data = JSON.stringify(Data, "\t")
	# Store the text string in the file.
	file.store_string(json_data)
	#file.store_var(Data)
	file.close()

func Load():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	# Read the entire file content as a single text string.
	var json_data = file.get_as_text()
	#var data = file.get_var()
	file.close()
	# Parse the JSON string to convert it back into a Godot Dictionary.
	var gdscript_data = JSON.parse_string(json_data)
	
	# Check if parsing was successful and the result is a dictionary.
	# This prevents errors if the save file is empty or corrupted.
	if gdscript_data is Dictionary:
		Data = gdscript_data.duplicate()
		LoadData()
	else:
		print("Error parsing save file or file is not a valid dictionary.")
	
	#Data = data.duplicate()
	#LoadData()

func DeleteData():
	if FileAccess.file_exists(SAVE_PATH):
		var error_check = DirAccess.remove_absolute(SAVE_PATH)
		if error_check == OK:
			Data.clear()
			print("Save data deleted successfully.")

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
