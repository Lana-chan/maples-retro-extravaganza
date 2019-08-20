/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

// crt.glsl -- functions for scanline and crt filters

uniform int frameCounter;

vec3 rgb[] = vec3[3](
	vec3(0.0, 1.0, 0.0),
	vec3(1.0, 0.0, 0.0),
	vec3(0.0, 0.0, 1.0)
);

// gaussian blur 5px
uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

// generates scanlines
float scanline(vec2 newTC, vec2 pixelSize, float thickness, float strength) {
	vec2 screenTC = floor(newTC * vec2(viewWidth, viewHeight));
	float linespace = pixelSize.y;
	if(linespace <= 1.0)
		linespace = 2.0;
	return (mod(screenTC.y, linespace) < thickness ? strength : 0.0);
}

// generates temporal dot-crawl artifacting
float ntsc(vec3 color, vec2 TC, vec2 pixelSize, float strength) {
	vec2 pixelCoord = floor((TC * vec2(viewWidth, viewHeight)) / vec2(pixelSize) + 0.5);
	float ntscColor = dot(color, rgb[int(mod(pixelCoord.x + pixelCoord.y + frameCounter, 3.0))]);

	ntscColor = (ntscColor * strength) + (1-strength);

	return ntscColor;
}

// warps texcoord to crt shape
vec2 crtDistort(vec2 TC, vec2 distortStrength) {
	vec2 t = TC * 2.0 - 1.0; // texture coordinate, x and y both in -1 to 1
	float r = dot(t, t); // length squared of t
	t *= (1 + distortStrength.xy * r * r);
	return t / 2 + 0.5;
}