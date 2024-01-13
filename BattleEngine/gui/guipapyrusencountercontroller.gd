extends guicontroller
class_name guicontrollertp
@onready var tpbar = $Control/Tp/TPbar
@onready var tpinfo = $Control/Tp/TpInfo
@onready var tp = $Control/Tp

func _initextra():
	tp.hide()
	
func refreshtpbar():
	tpbar.value = Game.tpcd*100.0
	tpinfo.text = str(round(Game.tpcd))+" / 3"
