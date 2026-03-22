shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0);
instance uniform float max_dist: hint_range(0.0, 2.1);
uniform vec2 center = vec2(0.5, 0.5);

void vertex() {
	// Called for every vertex the material is visible on.
}

float circleSDF(vec2 d) {
		 float dist = distance(d, center) - radius;
	return dist;
}
//incredibly ugly shader that for some reason stretches and I hate it but whatever
//I have no idea how to make shaders anyway
//and I refuse to watch a tutorial
void fragment() {
	float d = circleSDF(UV);
	COLOR.a = smoothstep(max_dist, 0.0, d);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
