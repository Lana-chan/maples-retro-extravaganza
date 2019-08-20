#version 120

/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

#include "shaders.settings"

varying vec2 texcoord;
uniform sampler2D colortex0;
uniform float viewWidth, viewHeight;

#include "fragment/crt.glsl"
#include "lib/utils.glsl"

void main() {
	vec2 newTC = texcoord;
	vec3 color;
	
	#ifdef CRT
		newTC = crtDistort(texcoord, crt_depth * vec2(0.05, 0.075));
	#endif

	if(newTC.x < 0.0 || newTC.x > 1.0 || newTC.y < 0.0 || newTC.y > 1.0)
		color = vec3(0.0, 0.0, 0.0);
	else
		color = texture2D(colortex0, newTC).rgb;

	gl_FragData[0] = vec4(color, 1.0);
}