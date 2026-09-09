class_name CharacterList
extends Resource


@export var characters: Dictionary[String, PackedScene] = {}


func keys() -> Array[String]:
	var list: Array[String] = []
	for key in characters:
		list.append(key)
	list.sort()

	return list
