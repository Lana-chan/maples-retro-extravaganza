/*
 * ------------------------------------------------------------
 * "THE BEERWARE LICENSE" (Revision 42):
 * maple <maple@maple.pet> wrote this code. As long as you retain this 
 * notice, you can do whatever you want with this stuff. If we
 * meet someday, and you think this stuff is worth it, you can
 * buy me a beer in return.
 * ------------------------------------------------------------
 */

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying mat3 TBN;

uniform sampler2D normals;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform int fogMode;
uniform vec4 entityColor;
uniform int isEyeInWater;

void main() {
	vec4 normalTex = texture2D(normals, texcoord) * 2.0 - 1.0;
	vec4 albedo;
	
	albedo = texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;

	// avoids broken sky
	#ifdef BASIC
		albedo = color;
	#endif

	// entity color effect, hurt mob etc
	#ifdef ENTITIES
		albedo += entityColor;
	#endif

	// underwater treatment
	// makes it darker off into the distance and gives blue tint
	if(isEyeInWater == 1)
		albedo *= vec4(vec3(1.0-pow(gl_FragCoord.z, 128.0) + 1.0-pow(gl_FragCoord.z, 16.0)), 1.0) * vec4(0.5, 0.6, 1.0, 1.0);

	// color/albedo map
	gl_FragData[0] = albedo;
	// depth map
	gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);
	
	// don't pass normals for weather (since normals are only used for outlines, this makes rain/snow not have outlines)
	#ifndef WEATHER
		gl_FragData[2] = vec4(normalize(TBN * normalTex.xyz) * 0.5 + 0.5, 1);
	#endif
	
	// taken from another shader, not sure what it's doing but it affects fog and entity shadow sprites
	if (fogMode == GL_EXP) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	} else if (fogMode == GL_LINEAR) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0));
	}
}