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

var PlayerCharacters : Array[CharacterData]

var Locations: Array[LocationData]

######################
#     SCRIPT-WIDE    #
######################

var Data : Dictionary

##############################################################
#                      2.0 Functions                         #
##############################################################
func GetArrays():
	PlayerCharacters.assign(CharacterList.AllCharacters) 
	Locations = LocationList.AllLevels + LocationList.AllEvents

func SaveData():
	var temp_data : Dictionary
	var player_army: Array[String]
	for character in GameData.PlayerArmy:
		player_army.append(character.resource_path)
	
	temp_data["PlayerArmy"] = player_army
	
	GetArrays()
	
	for character in PlayerCharacters:
		temp_data[character.Name] = character.InfoToSave
		
		for variable_name in character.InfoToSave:
			temp_data["%s: %s" % [character.Name, variable_name]] = character.get(variable_name)
	
	for location in Locations:
		temp_data["%s: Locked" % [location.Name]] = location.Locked
		temp_data["%s: Cleared" % [location.Name]] = location.Cleared
	
	Data = temp_data

func LoadData():
	var player_army = Data.get("PlayerArmy")
	
	for character_path in player_army:
		GameData.PlayerArmy.append(load(character_path))
	
	GetArrays()
	
	for character in PlayerCharacters:
		if Data.has(character.Name):
			var info_to_load = Data.get(character.Name)
			for variable_name in info_to_load:
				var value = Data.get("%s: %s" % [character.Name, variable_name])
				character.set(variable_name, value) 
	
	for location in Locations:
		if Data.has("%s: Locked" % [location.Name]):
			location.Locked = Data.get("%s: Locked" % [location.Name])
		if Data.has("%s: Cleared" % [location.Name]):
			location.Cleared = Data.get("%s: Cleared" % [location.Name])

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
