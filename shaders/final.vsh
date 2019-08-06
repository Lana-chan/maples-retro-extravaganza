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

varying vec2 texcoord;
varying vec4 color;

void main() {
	
	gl_Position = ftransform();
	
	texcoord = (gl_MultiTexCoord0).xy;

	color = gl_Color;
}
