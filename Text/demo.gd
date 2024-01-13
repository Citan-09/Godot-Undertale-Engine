extends GenericTextTyper

var demotext = ["[ul bullet=*]test123. \nnext hi", "hello!!"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	typetext(demotext)

