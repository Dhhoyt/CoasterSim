extends Object

var points: PackedVector3Array = []

var samples: PackedVector3Array = []
var coefficients: Array = []
var distances: PackedFloat64Array = []

func bulk_sample(num_samples) -> void:
	if len(points) < 2:
		return
	update()
	samples = []
	distances = []
	for i in range(num_samples - 1):
		var t: float = float(i)/(float(num_samples) - 1.0)
		samples.append(get_sample(t))
	samples.append(points[len(points) - 1])
	
	distances.append(0)
	var running_length = 0
	for i in range(num_samples -1):
		running_length += (samples[i] - samples[i + 1]).length()
		distances.append(running_length)
	print(running_length)

func get_sample(t: float) -> Vector3:
	t *= float(len(points)) - 1.0
	var segment = int(t)
	t -= float(floor(t))
	var res = coefficients[segment][0] +\
		(t * coefficients[segment][1]) +\
		(t * t * coefficients[segment][2]) +\
		(t * t * t * coefficients[segment][3])
	res /= 6
	return res

func get_tangent(t: float) -> Vector3:
	t *= float(len(points)) - 1.0
	var segment = int(t)
	t -= float(floor(t))
	var res = coefficients[segment][1] +\
		(coefficients[segment][2] * 2 * t) +\
		(coefficients[segment][2] * 3 * t * t)
	return res

func dist_to_t(dist: float) -> float:
	if dist > 

func update():
	coefficients = []
	points.insert(0, (2 * points[0]) - points[1])
	points.append((2 * points[len(points) - 1]) - points[len(points) - 2])
	for i in range(len(points) - 3):
		var p0 = points[i]
		var p1 = points[i + 1]
		var p2 = points[i + 2]
		var p3 = points[i + 3]
		var res = []
		res.append(p0 + (p1 * 4) + p2)
		res.append((-3 * p0) + (3 * p2))
		res.append(((3 * p0) + (-6 * p1) + (3 * p2)))
		res.append((-1 * p0) + (3 * p1) + (-3 * p2) + p3)
		coefficients.append(res)
	points.remove_at(len(points) - 1)
	points.remove_at(0)
