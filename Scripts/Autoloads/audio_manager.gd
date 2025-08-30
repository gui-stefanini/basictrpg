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
@export var BGMPlayer: AudioStreamPlayer
@export var SFXPlayer: AudioStreamPlayer
######################
#     SCRIPT-WIDE    #
######################
var BGMBusIndex : int
var SFXBusIndex : int
##############################################################
#                      2.0 Functions                         #
##############################################################

func PlayBGM(audio_stream: AudioStream) -> void:
	if not audio_stream:
		BGMPlayer.stop()
		return
	
	BGMPlayer.stream = audio_stream
	BGMPlayer.play()
	# Make sure the BGM loops
	BGMPlayer.finished.connect(func(): BGMPlayer.play())

func PlaySFX(audio_stream: AudioStream) -> void:
	SFXPlayer.stream = audio_stream
	SFXPlayer.play()

func SetBGMVolume(volume: float) -> void:
	AudioServer.set_bus_volume_db(BGMBusIndex, linear_to_db(volume * volume))

func SetSFXVolume(volume: float) -> void:
	AudioServer.set_bus_volume_db(SFXBusIndex, linear_to_db(volume * volume))

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
func _ready():
	BGMBusIndex = AudioServer.get_bus_index("BGM")
	SFXBusIndex = AudioServer.get_bus_index("SFX")
