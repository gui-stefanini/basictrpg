class_name VFX
extends Node2D

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var MyRotationTracker : Node2D
@export var MySprite2D : Sprite2D
@export var MyAnimationPlayer : AnimationPlayer
@export var Data : VFXData
######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func SetData(vfx_data: VFXData):
	Data = vfx_data
	MySprite2D.texture = Data.MyTexture
	MySprite2D.hframes = Data.HFrames
	MySprite2D.vframes = Data.VFrames
	MyAnimationPlayer.add_animation_library("vfx", Data.Library)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
