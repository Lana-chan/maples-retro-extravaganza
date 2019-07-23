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

// quantize coords to resolution
vec2 pixelize(vec2 uv, vec2 pixelSize) {
	vec2 factor = vec2(pixelSize) / vec2(viewWidth, viewHeight);
	return floor(uv / factor) * factor;
}
vec2 pixelize(vec2 uv, float pixelSize) {
	return pixelize(uv, vec2(pixelSize));
}

vec3 colorLUT(vec3 color) {
	color = clamp(color, 0.0, 1.0);
	// i don't understand why i can't floor it multiplied by 64 and i think this is causing some color mismatch
	color = floor(color*63.9) / 64.0;
	vec3 colorspace = color * vec3(0.125, 0.125, 64.0);
	vec2 lutcoord = vec2(colorspace.r + mod(colorspace.b, 8.0) * 0.125, colorspace.g + floor(colorspace.b / 8.0) * 0.125);

	#if (palette==0)
		return texture2D(colortex7, lutcoord).rgb;
	#endif
	#if (palette==1)
		return texture2D(colortex6, lutcoord).rgb;
	#endif
	#if (palette==2)
		return texture2D(colortex5, lutcoord).rgb;
	#endif
	#if (palette==3)
		return texture2D(colortex4, lutcoord).rgb;
	#endif
	#if (palette==4)
		return texture2D(colortex3, lutcoord).rgb;
	#endif
}

// compares both regular color and bayer-altered color for closest match in the palette and returns it
vec3 pickClosest(vec3 color, vec3 bayerColor) {
	/*vec3 palcolor = palette[0];
	float dist = distance(color, palcolor);
	int index = 0;
	float tdist;
	
	for(int i = 1; i < paletteSize; i++) {
		palcolor = palette[i];
		tdist = distance(color, palcolor);
		if(tdist < dist) {
			dist = tdist;
			index = i;
		}
		tdist = distance(bayerColor, palcolor);
		if(tdist < dist) {
			dist = tdist;
			index = i;
		}
	}

	return palette[index];*/

	vec3 normal = colorLUT(color);
	vec3 dither = colorLUT(bayerColor);
	
	if(distance(normal, color)*dither_factor < distance(dither, bayerColor)*(1-dither_factor))
		return normal;
	return dither;
}

vec3 levels(vec3 color, float brightness, float contrast, vec3 gamma) {
	vec3 value = (color - 0.5) * contrast + 0.5;
	value = clamp(value + brightness, 0.0, 1.0);
	return clamp(vec3(pow(abs(value.r), gamma.x),pow(abs(value.g), gamma.y),pow(abs(value.b), gamma.z)), 0.0, 1.0);
}
vec3 levels(vec3 color, float brightness, float contrast, float gamma) { 
	return levels(color, brightness, contrast, vec3(gamma));
}

vec3 dither8x8(vec2 coord, vec3 color, vec2 pixelSize) {
	vec2 pixelCoord = round((coord * vec2(viewWidth, viewHeight)) / vec2(pixelSize));

	color = levels(color, Brightness, Contrast, Gamma);
	pixelCoord = mod(pixelCoord, 8.0);
	int index = int(pixelCoord.x + (pixelCoord.y * 8));
	vec3 bayerColor = (color + vec3(bayer8[index]-31)/128.0);
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

	#ifdef Dither
		color = dither8x8(newTC, color, psize);
	#endif

	gl_FragColor = vec4(color,1.0);
}
