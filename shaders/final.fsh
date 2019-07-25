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
uniform sampler2D texture;

uniform sampler2D colortex7;
uniform sampler2D colortex6;
uniform sampler2D colortex5;
uniform sampler2D colortex4;
uniform sampler2D colortex3;

uniform float viewWidth;
uniform float viewHeight;

const int bayer8[64] = int[](
	 0, 32,  8, 40,  2, 34, 10, 42, /* 8x8 Bayer ordered dithering */
	48, 16, 56, 24, 50, 18, 58, 26, /* pattern. Each input pixel */
	12, 44,  4, 36, 14, 46,  6, 38, /* is scaled to the 0..63 range */
	60, 28, 52, 20, 62, 30, 54, 22, /* before looking in this table */
	 3, 35, 11, 43,  1, 33,  9, 41, /* to determine the action. */
	51, 19, 59, 27, 49, 17, 57, 25,
	15, 47,  7, 39, 13, 45,  5, 37,
	63, 31, 55, 23, 61, 29, 53, 21
);

const vec2 pixelSizes[10] = vec2[](
	vec2(1.0),
	vec2(2.0),
	vec2(3.0),
	vec2(4.0),
	vec2(5.0),
	vec2(6.0),
	vec2(7.0),
	vec2(8.0),
	vec2(4.0, 2.0),
	vec2(6.0, 3.0)
);

// quantize coords to low resolution
vec2 pixelize(vec2 uv, vec2 pixelSize) {
	vec2 factor = vec2(pixelSize) / vec2(viewWidth, viewHeight);
	return floor(uv / factor) * factor;
}
vec2 pixelize(vec2 uv, float pixelSize) {
	return pixelize(uv, vec2(pixelSize));
}

// look up target color, LUT is formatted as 4x4 luts of 512x512 each in a standard format with 64x64x64 color resolution
vec3 colorLUT(vec3 color, int palette_id) {
	// this gives me the coordinate for 1 LUT
	vec3 colorspace = clamp(color, 0.0, 1.0);
	colorspace = floor(colorspace*63.0+0.5) / 64.0;
	colorspace = colorspace * vec3(0.125, 0.125, 64.0);
	vec2 lutcoord = vec2(colorspace.r + mod(colorspace.b, 8.0) * 0.125, colorspace.g + floor(colorspace.b / 8.0) * 0.125);

	// this transforms it into the sub-LUT selected
	vec2 paletteOffset = vec2(mod(palette_id, 4.0), floor(palette_id * 0.25)) * 0.25;
	lutcoord *= 0.25;
	lutcoord += paletteOffset;

	return texture2D(colortex7, lutcoord).rgb;
}

// compares both regular color and bayer-altered color for closest match in the palette and returns it
vec3 pickClosest(vec3 color, vec3 bayerColor) {
	vec3 normal = colorLUT(color, s_palette_id);
	vec3 dither = colorLUT(bayerColor, s_palette_id);
	//return color;
	
	// whichever is closest to the LUT wins, weighed by the dither factor
	if(distance(normal, color)*dither_factor < distance(dither, color)*(1-dither_factor))
		return normal;
	return dither;
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

// applies the dithering filter to a color map
vec3 dither8x8(vec2 coord, vec3 color, vec2 pixelSize) {
	// reduces pixel space to the selected pixel size
	vec2 pixelCoord = floor((coord * vec2(viewWidth, viewHeight)) / vec2(pixelSize) + 0.5);

	// applies the bayer matrix filter to the color map
	pixelCoord = mod(pixelCoord, 8.0);
	int index = int(pixelCoord.x + (pixelCoord.y * 8));
	//vec3 bayerColor = color + ((bayer8[index]/128.0)-0.5);
	vec3 bayerColor = (color + vec3(bayer8[index]-31)/256.0);
	
	// returns the best dithered color
	color = pickClosest(color, bayerColor);
	return color;
}
vec3 dither8x8(vec2 coord, vec3 color, float pixelSize) {
	return dither8x8(coord, color, vec2(pixelSize));
}

void main() {
	vec2 newTC = texcoord;
	vec2 psize = pixelSizes[pixel_size];
	
	#ifdef Pixel
		newTC = pixelize(newTC, psize);
	#endif

	vec3 color = texture2D(texture, newTC).rgb;
	color = colorLUT(color, 15);

	#ifdef Preprocess
		// optional step, increasing contrast yields better results in a more limited palette
		color = levels(color, Brightness, Contrast, Gamma);
	#endif

	#ifdef Dither
		color = dither8x8(newTC, color, psize);
	#endif

	gl_FragColor = vec4(color,1.0);
}
