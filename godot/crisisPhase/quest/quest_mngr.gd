extends Node
class_name EMC_Quest_Mngr

class Quest:
	var goal: Dictionary
	
class Action:
	var condition: Dictionary
	var effect: Dictionary


# static vs. dynamic Quest
# static quest can be implemented via Vervain "easily"
# need either an always viable option or preevaluation
# [[Meta]]
# [Start] friedel_weg
# [Type] quest
# [Import] abc
#
# [[Quest]] friedel_weg
# [jump] pop_gerhard
# 
# [[PopUp]] pop_gerhard
# [text] 
# Gerhard klopf an der Tür.
# Vielleicht braucht er hilfe. 
# [Choice]
# - [open] Tür öffnen
# - [end] Klopfen ingonrieren
#
# [[Node]] end
# [action] end_quest friedel_weg
#
# [[Dialoge]] open
# [action] move_npc gerhard home
# [Actors] gerhard avatar.flipped
# [Text]
# Gerhard: Friedel ist weg kannst du mir helfen ihn zu suchen?
# ....
# [jump] open_city
#
# [[Quest]] open_city
# [icon] home exit
# 
# dynamic quest need some action rework
