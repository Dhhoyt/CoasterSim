extends Object

var points: PackedVector2Array = []

var num_samples: int = 100

var samples: PackedVector2Array = []

func evaluate() -> void:
	if len(points) < 2:
		return
	
	samples = []
	points.insert(0, (2 * points[0]) - points[1])
	points.append((2 * points[len(points) - 1]) - points[len(points) - 2])
	
	var prev_segment: int = 0
	
	var p0: Vector2 = points[0]
	var p1: Vector2 = points[1]
	var p2: Vector2 = points[2]
	var p3: Vector2 = points[3]
	
	var coefficients = _get_coefficients(p0, p1, p2, p3)
	
	for i in range(num_samples - 1):
		var t: float = float(i)/(float(num_samples) - 1.0)
		t *= float(len(points)) - 3.0
		
		if(prev_segment != int(t)):
			prev_segment = int(t)
			p0 = points[prev_segment]
			p1 = points[prev_segment + 1]
			p2 = points[prev_segment + 2]
			p3 = points[prev_segment + 3]
			coefficients = _get_coefficients(p0, p1, p2, p3)
		
		t -= float(floor(t))
		var res = coefficients[0] +\
			(t * coefficients[1]) +\
			(t * t * coefficients[2]) +\
			(t * t * t * coefficients[3])
		samples.append(res/6)
		
	points.remove_at(0)
	points.remove_at(len(points) - 1)
	samples.append(points[len(points) - 1])

func _get_coefficients(p0, p1, p2, p3) -> PackedVector2Array:
	var res: PackedVector2Array = []
	res.append(p0 + (p1 * 4) + p2)
	res.append((-3 * p0) + (3 * p2))
	res.append(((3 * p0) + (-6 * p1) + (3 * p2)))
	res.append((-1 * p0) + (3 * p1) + (-3 * p2) + p3)
	return res
