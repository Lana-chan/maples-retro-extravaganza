/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

// pixel.glsl -- functions for screen pixel downscaling and dither palettization filter

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

// quantize coords to low resolution
vec2 pixelize(vec2 uv, vec2 pixelSize) {
	vec2 factor = vec2(pixelSize) / vec2(viewWidth, viewHeight);
	return floor(uv / factor) * factor;
}
vec2 pixelize(vec2 uv, float pixelSize) {
	return pixelize(uv, vec2(pixelSize));
}

// look up target color, LUT is formatted as 4x4 luts of 512x512 each in a standard format with 64x64x64 color resolution
vec3 colorLUT(vec3 color, sampler2D lut, int palette_id) {
	// this gives me the coordinate for 1 LUT
	vec3 colorspace = clamp(color, 0.0, 1.0);
	colorspace = floor(colorspace*63.0+0.5) / 64.0;
	colorspace = colorspace * vec3(0.125, 0.125, 64.0);
	vec2 lutcoord = vec2(colorspace.r + mod(colorspace.b, 8.0) * 0.125, colorspace.g + floor(colorspace.b / 8.0) * 0.125);

	// this transforms it into the sub-LUT selected
	vec2 paletteOffset = vec2(mod(palette_id, 4.0), floor(palette_id * 0.25)) * 0.25;
	lutcoord *= 0.25;
	lutcoord += paletteOffset;

	return texture2D(lut, lutcoord).rgb;
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
vec3 dither8x8(vec2 coord, vec3 color, vec2 pixelSize, sampler2D lut, int palette_id) {
	// reduces pixel space to the selected pixel size
	vec2 pixelCoord = floor((coord * vec2(viewWidth, viewHeight)) / vec2(pixelSize) + 0.5);

	// applies the bayer matrix filter to the color map
	pixelCoord = mod(pixelCoord, 8.0);
	int index = int(pixelCoord.x + (pixelCoord.y * 8));
	vec3 bayerColor = (color + (vec3(bayer8[index]-31)/32.0) * (dither_factor / 8.0));
	// limits it to the selected palette
	color = colorLUT(bayerColor, lut, palette_id);

	return color;
}
vec3 dither8x8(vec2 coord, vec3 color, float pixelSize, sampler2D lut, int palette_id) {
	return dither8x8(coord, color, vec2(pixelSize), lut, palette_id);
}