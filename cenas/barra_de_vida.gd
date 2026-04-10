extends ProgressBar

var parent
var max_value_amont
var min_value_amont

func _ready():
	parent = get_parent()
	
	max_value_amont = parent.vida_max
	min_value_amont = parent.vida_min

func _process(delta: float):
	self.value = parent.vida
	if parent.vida != max_value_amont:
		self.visible = true
		if parent.vida == min_value_amont:
			self.visible = false
	else:
		self.visible = false
