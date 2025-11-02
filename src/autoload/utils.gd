extends Node


func delay(seconds: float):
	# use it like this await delay(2.0)
	return await get_tree().create_timer(seconds).timeout


func array_has_index(array: Array, index: int) -> bool:
	return index >= 0 and index < array.size()
