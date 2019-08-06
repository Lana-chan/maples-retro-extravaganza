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
uniform sampler2D colortex2;
uniform sampler2D colortex7;
uniform sampler2D colortex6;
uniform float viewWidth, viewHeight;

#include "fragment/outline.glsl"
#include "fragment/pixel.glsl"
#include "fragment/crt.glsl"

// pixel aspect ratios mapped to setting
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

void main() {
	vec2 newTC = texcoord;
	vec2 psize = pixelSizes[pixel_size];
	
	#ifdef Pixel
		newTC = pixelize(newTC, psize);
	#endif

	vec3 color = texture2D(texture, newTC).rgb;
	color = colorLUT(color, colortex7, 15);

	#ifdef Preprocess
		// optional step, increasing contrast yields better results in a more limited palette
		color = levels(color, Brightness, Contrast, Gamma);
	#endif

	#ifdef Outlines
		float outl = outline(newTC, psize);

		#if (outline_mode == 0) // invert
			color = (outl == 1.0 ? 1-color : color);
		#endif
		#if (outline_mode == 1) // white
			color = (outl == 1.0 ? vec3(1.0) : color);
		#endif
		#if (outline_mode == 2) // black
			color = (outl == 1.0 ? vec3(0.0) : color);
		#endif
	#endif

	#ifdef Dither
		color = dither8x8(newTC, color, psize, colortex7, s_palette_id);
	#endif

	#ifdef NTSC
		float ntsc_strength = 0.3;
		float ntscFilter = ntsc(color, newTC, psize, ntsc_strength);
		color *= ntscFilter;
	#endif

	#ifdef Scanlines
		color -= scanline(texcoord, psize, sl_thickness, sl_strength);
		//color = levels(color, sl_strength/2.0, 1.0, 1.0);
	#endif

	gl_FragData[0] = vec4(color, 1.0);
}