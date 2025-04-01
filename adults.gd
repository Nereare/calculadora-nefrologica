extends Window

signal egfr_update
signal message_update
signal volume_update

const VOLUME_SMALL = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 20, 20, 20, 21, 22, 24, 25, 27, 28, 30, 31, 33, 34, 36, 37, 39, 40, 42, 43, 45, 45, 45, 45, 45, 45, 50, 50, 50, 50, 50, 55, 55, 55, 55, 55, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90]
const VOLUME_MEDIUM = [0, 2.3, 4.5, 7, 9, 11, 14, 16, 18, 20, 23, 23, 23, 23, 24, 25, 27, 28, 30, 32, 34, 35, 37, 39, 40, 42, 44, 45, 47, 49, 50, 50, 50, 50, 50, 50, 55, 55, 55, 55, 55, 60, 60, 60, 60, 60, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 105, 105, 105, 105, 105, 105, 105, 105, 105, 105, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 135]
const VOLUME_HIGH = [0, 2.6, 5, 8, 10, 13, 16, 18, 20, 23, 26, 26, 26, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 60, 60, 60, 60, 60, 65, 65, 65, 65, 65, 70, 70, 70, 70, 70, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 130, 130, 130, 130, 130, 130, 130, 130, 130, 130, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 150]

func _on_context_item_selected(index: int) -> void:
	var max_time = 0
	if index == 2:
		max_time = 30
	else:
		max_time = 2
	$Container/CreatTimeContainer/CreatTime.text = str(max_time) + " dias"
	message_update.emit()

# eGFR-related fields
func _on_sex_item_selected(_index: int) -> void:
	egfr_update.emit()
func _on_weight_text_changed(_new_text: String) -> void:
	egfr_update.emit()
	volume_update.emit()
func _on_age_text_changed(_new_text: String) -> void:
	egfr_update.emit()
func _on_creat_text_changed(_new_text: String) -> void:
	egfr_update.emit()

# Volume-related fields/events
func _on_type_item_selected(_index: int) -> void:
	volume_update.emit()

func round_to_dec(num, digit) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _on_egfr_update() -> void:
	var cockroft:float = calculate_cockroft()
	if cockroft != 0.0:
		$Container/CockroftContainer/Cockroft.text = str(cockroft) + "mL/min"
		message_update.emit()
		volume_update.emit()
	var ckd:float = calculate_ckd()
	if ckd != 0.0:
		$Container/CKDContainer/CKD.text = str(ckd) + "mL/min/1.73m²"
		message_update.emit()
		volume_update.emit()
func calculate_cockroft() -> float:
	var sex = $Container/SexContainer/Sex.get_selected_id()
	var age = $Container/AgeContainer/Age.text
	var weight = $Container/WeightContainer/Weight.text
	var cr = $Container/CreatContainer/Creat.text
	var egfr:float
	if sex > -1 and age != "" and weight != "" and cr != "":
		var sex_mod:float = 1.0 if sex == 0 else 0.85
		egfr = (((140.0-float(age))*float(weight))/(72.0*float(cr)))*sex_mod
	else:
		egfr = 0.0
	return round_to_dec(egfr, 1)
func get_a(is_male) -> float:
	if is_male:
		return 0.9
	else:
		return 0.7
func get_b(is_male, cr) -> float:
	cr = float(cr)
	if is_male:
		if cr > 0.9:
			return -1.2
		else:
			return -0.302
	else:
		if cr > 0.7:
			return -1.2
		else:
			return -0.241
func calculate_ckd() -> float:
	var sex = $Container/SexContainer/Sex.get_selected_id()
	var age = $Container/AgeContainer/Age.text
	var cr = $Container/CreatContainer/Creat.text
	var egfr:float
	if sex > -1 and age != "" and cr != "":
		var a = get_a(sex == 0)
		var b = get_b(sex == 0, cr)
		var sex_mod = 1.0 if sex == 0 else 1.012
		egfr = 142 * pow(float(cr)/a,b) * pow(0.9938,float(age)) * sex_mod
	else:
		egfr = 0.0
	return round_to_dec(egfr, 1)

func _on_message_update() -> void:
	var context = $Container/ContextContainer/Context.get_selected_id()
	var cockroft = $Container/CockroftContainer/Cockroft.text
	var ckd = $Container/CKDContainer/CKD.text
	var egfr:float = 0.0
	if context == 2:
		# Outpatient
		if ckd != "":
			egfr = float(ckd)
	else:
		# Inpatient
		if cockroft != "":
			egfr = float(cockroft)
	if  egfr == 0.0:
		$Container/Warning.text = "..."
	else:
		if egfr > 60.0:
			$Container/Warning.text = "Sem contraindicação"
		elif egfr > 30.0:
			$Container/Warning.text = "Realizar 500mL SF0,9% IV após exame"
		else:
			$Container/Warning.text = "Exame contraindicado"

func _on_volume_update() -> void:
	var type = $Container/TypeContainer/Type.get_selected_id()
	var weight = $Container/WeightContainer/Weight.text
	var volume:Array
	if type < 0 or weight == "":
		$Container/VolumeContainer/Volume.text = ""
	else:
		weight = int(weight)
		weight = weight if weight <= 106 else 106
		if weight < 1:
			$Container/VolumeContainer/Volume.text = "??"
		else:
			if type >= 0 and type <= 2:
				volume = VOLUME_MEDIUM
			elif type >= 3 and type <= 4:
				volume = VOLUME_HIGH
			else:
				volume = VOLUME_SMALL
		$Container/VolumeContainer/Volume.text = str(volume[weight])

# Clear everything
func _on_clear_pressed() -> void:
	$Container/SexContainer/Sex.selected = -1
	$Container/WeightContainer/Weight.text = ""
	$Container/AgeContainer/Age.text = ""
	$Container/CreatContainer/Creat.text = ""
	$Container/ContextContainer/Context.selected = -1
	$Container/CreatTimeContainer/CreatTime.text = ""
	$Container/TypeContainer/Type.selected = -1
	egfr_update.emit()
	message_update.emit()
	volume_update.emit()
