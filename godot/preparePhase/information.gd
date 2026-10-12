extends Control
class_name EMC_Information

# Nadja: hier noch die aktuelle bbk-Broschüre einfügen und das Icon ändern: https://www.bbk.bund.de/SharedDocs/Downloads/DE/Mediathek/Publikationen/Buergerinformationen/Ratgeber/BBK-Vorsorgen-fuer-Krisen-und-Katastrophen.pdf?__blob=publicationFile&v=40


const BBK_BROCHURE_LINK := "https://www.bbk.bund.de/SharedDocs/Downloads/DE/Mediathek/Publikationen/Buergerinformationen/Ratgeber/BBK-Vorsorgen-fuer-Krisen-und-Katastrophen.pdf?__blob=publicationFile&v=40"
const COOKING_LINK := "https://www.bbk.bund.de/DE/Warnung-Vorsorge/Vorsorge/Stromausfall/Kochen-ohne-Strom/kochen-ohne-strom_node.html"

func open() -> void:
	show()


func close() -> void:
	hide()

static func open_bbk_brochure() -> void:
	OS.shell_open(BBK_BROCHURE_LINK)


func _on_texture_button_pressed() -> void:
	hide()
	Global.goto_scene("res://preparePhase/main_menu.tscn")


## TODO: Name could be improved: "cooking" sounds like the in-game mechanic
func _on_cooking_button_pressed() -> void:
	OS.shell_open(COOKING_LINK)


func _on_bbk_button_pressed() -> void:
	open_bbk_brochure()
