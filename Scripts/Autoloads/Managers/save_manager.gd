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

@export var PlayerCharacters : Array[CharacterData]
@export var Levels: Array[LevelData]

######################
#     SCRIPT-WIDE    #
######################

var Data : Dictionary

##############################################################
#                      2.0 Functions                         #
##############################################################
func SaveData():
	Data.clear()
	
	for character in PlayerCharacters:
		Data[character.Name] = character.CharacterLevel
	
	for level in Levels:
		Data[level.LevelName] = level.Cleared

func LoadData():
	for character in PlayerCharacters:
		if Data.has(character.Name):
			character.CharacterLevel = Data.get(character.Name)
	
	for level in Levels:
		if Data.has(level.LevelName):
			level.Cleared = Data.get(level.LevelName)

func Save():
	SaveData()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(Data)
	file.close()

func Load():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()
	
	Data = data.duplicate()
	LoadData()

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
