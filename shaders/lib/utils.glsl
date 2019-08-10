/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

uniform float near;
uniform float far;
// wherever you are

// return highest component of vec3
float max3(vec3 v) {
  return max(max(v.x, v.y), v.z);
}

// linearize depth
float ld(float depth) {
  return (2.0 * near) / (far + near - depth * (far - near));
}

// adjust brightness, contrast and gamma levels of a color
vec3 levels(vec3 color, float brightness, float contrast, vec3 gamma) {
	vec3 value = (color - 0.5) * contrast + 0.5;
	value = clamp(value + brightness, 0.0, 1.0);
	return clamp(vec3(pow(abs(value.r), gamma.x),pow(abs(value.g), gamma.y),pow(abs(value.b), gamma.z)), 0.0, 1.0);
}
vec3 levels(vec3 color, float brightness, float contrast, float gamma) { 
	return levels(color, brightness, contrast, vec3(gamma));
}