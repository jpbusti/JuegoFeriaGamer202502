class_name ScoreList
extends RefCounted

class ScoreNode:
	var player_name: String
	var score: int
	var next: ScoreNode = null 
	
	func _init(p_name: String, p_score: int):
		player_name = p_name
		score = p_score

var head: ScoreNode = null 
var size: int = 0


func insert_sorted(p_name: String, p_score: int) -> void:
	var new_node = ScoreNode.new(p_name, p_score)
	
	if head == null or p_score > head.score:
		new_node.next = head
		head = new_node
		size += 1
		return

	var current = head
	while current.next != null and current.next.score >= p_score:
		current = current.next
	
	new_node.next = current.next
	current.next = new_node
	size += 1
	
	if size > 10:
		_remove_last()

func _remove_last():
	if head == null: return
	if head.next == null:
		head = null
		size = 0
		return
		
	var current = head
	while current.next.next != null:
		current = current.next
	current.next = null
	size -= 1

func clear():
	head = null
	size = 0


func to_array() -> Array:
	var result = []
	var current = head
	while current != null:
		result.append({"name": current.player_name, "score": current.score})
		current = current.next
	return result
