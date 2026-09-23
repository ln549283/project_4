extends Control

const ContractLoader = preload("res://src/core/contract_loader.gd")

@onready var status: Label = $Status

func _ready() -> void:
	var result: Dictionary = ContractLoader.load_and_validate()
	if not result.get("ok", false):
		var errors: Array = result.get("errors", [])
		var message := "Contrats invalides:\n" + "\n".join(errors)
		status.text = message
		push_error(message)
		if DisplayServer.get_name() == "headless":
			get_tree().quit(2)
		return
	print("T01 BOOT PASS: contracts 1.1 validated")
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0)
		return
	var session_result: Dictionary = Session.initialize()
	if not session_result.get("ok", false):
		status.text = "Impossible d'initialiser la session."
		return
	Session.navigate("s00", false)
