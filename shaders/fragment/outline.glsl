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
			float depth = texture2D(colortex2, coord + vec2(i-1, j-1) * pixelCoord).r;
			I[i][j] = depth; 
		}
	}

	float gx = dot(sobel_x[0], I[0]) + dot(sobel_x[1], I[1]) + dot(sobel_x[2], I[2]); 
	float gy = dot(sobel_y[0], I[0]) + dot(sobel_y[1], I[1]) + dot(sobel_y[2], I[2]);

	float g = sqrt(pow(gx, 2.0)+pow(gy, 2.0));

	g = (g > 0.05 ? 1.0 : 0.0);

	return g;
}

/*float outline(vec2 coord, vec2 pixelSize) {
	vec2 d = 1.0 / vec2(viewWidth, viewHeight) * pixelSize / 2;
  //float dx = 1.0 / uResolution.x;
  //float dy = 1.0 / uResolution.y;

  vec3 center = texture2D( colortex2, vec2(0.0, 0.0) ).rgb;

  // sampling just these 3 neighboring fragments keeps the outline thin.
  vec3 top = texture2D( colortex2, vec2(0.0, d.y) ).rgb;
  vec3 topRight = texture2D( colortex2, vec2(d.x, d.y) ).rgb;
  vec3 right = texture2D( colortex2, vec2(d.x, 0.0) ).rgb;

  // the rest is pretty arbitrary, but seemed to give me the
  // best-looking results for whatever reason.

  vec3 t = center - top;
  vec3 r = center - right;
  vec3 tr = center - topRight;

  t = abs( t );
  r = abs( r );
  tr = abs( tr );

  float n;
  n = max( n, t.x );
  n = max( n, t.y );
  n = max( n, t.z );
  n = max( n, r.x );
  n = max( n, r.y );
  n = max( n, r.z );
  n = max( n, tr.x );
  n = max( n, tr.y );
  n = max( n, tr.z );

  // threshold and scale.
  n = 1.0 - clamp( clamp((n * 2.0) - 0.8, 0.0, 1.0) * 1.5, 0.0, 1.0 );

	return n;
}*/