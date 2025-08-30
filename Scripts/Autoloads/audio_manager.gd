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

func SetBGMVolume(volume_percent: float) -> void:
	BGMPlayer.volume_db = linear_to_db(volume_percent)

func SetSFXVolume(volume_percent: float) -> void:
	SFXPlayer.volume_db = linear_to_db(volume_percent)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
