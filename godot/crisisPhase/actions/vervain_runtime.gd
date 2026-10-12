extends Node
class_name EMC_VervainExecuter

signal next(instruction: Array)

@export var _gui_mngr: EMC_GUIMngr
@export var gsi: EMC_GSI

func run(script: VRV_Script) -> void:
	pass
	#script.gsi = gsi
	#
	#var running: bool = true
	#while running:
		#var instruction: Array = script.get_next()
		#if instruction[0] == VRV_Script.NODE:
			#if instruction[1] != "Node":
				#_gui_mngr.request_gui(instruction[1])
		#
		#if instruction[0] == VRV_Script.CHOICE:
			#await script.decided
		#
		#if instruction[0] == VRV_Script.END:
			#running = false
		#
		#next.emit(instruction)
