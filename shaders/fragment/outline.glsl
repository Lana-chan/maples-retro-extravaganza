/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

// outline.glsl -- functions for depth edge detection to make outlines

uniform sampler2D depthtex0;
uniform float near;
uniform float far;
// wherever you are

// sobel matrices for edge detection
mat3 sobel_y = mat3( 
	1.0, 0.0, -1.0, 
	2.0, 0.0, -2.0, 
	1.0, 0.0, -1.0 
);

mat3 sobel_x = mat3( 
	1.0, 2.0, 1.0, 
	0.0, 0.0, 0.0, 
-1.0, -2.0, -1.0 
);

// technique taken from https://gamedev.stackexchange.com/questions/159585/sobel-edge-detection-on-depth-texture

float ld(float depth) {
   return (2.0 * near) / (far + near - depth * (far - near));
}
// returns the monochrome map of an outline based on the depth map of the scene
float outline(vec2 coord, vec2 pixelSize) {
	vec2 pixelCoord = 1.0 / vec2(viewWidth, viewHeight) * pixelSize / 2;

	mat3 I;
	for (int i=0; i<3; i++) {
		for (int j=0; j<3; j++) {
			float depth = ld(texture2D(depthtex0, coord + vec2(i-1, j-1) * pixelCoord).r);
			I[i][j] = depth; 
		}
	}

	float gx = dot(sobel_x[0], I[0]) + dot(sobel_x[1], I[1]) + dot(sobel_x[2], I[2]); 
	float gy = dot(sobel_y[0], I[0]) + dot(sobel_y[1], I[1]) + dot(sobel_y[2], I[2]);

	float g = sqrt(pow(gx, 2.0)+pow(gy, 2.0));

	g = (g > 0.05 ? 1.0 : 0.0);

	return g;
}