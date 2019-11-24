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
varying vec2 lmcoord;
varying vec4 color;
varying mat3 TBN;
varying vec3 vNormal;
attribute vec4 at_tangent;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// all of this was adapted from an older shader. don't understand all of it yet
// but the main goal with this whole file is to only pass everything no different than default rendering
// except for the addition of normal map to final

void main() {
	vec3 normal   = gl_NormalMatrix * gl_Normal;
	vec3 tangent  = gl_NormalMatrix * (at_tangent.xyz / at_tangent.w);
	TBN = mat3(tangent, cross(tangent, normal), normal);
	vNormal = normalize(vec3(vec4(normal, 0.0) * transpose(gbufferModelViewInverse)));

	//gl_Position = ftransform();
	//color = gl_Color;

	texcoord = mat2(gl_TextureMatrix[0]) * gl_MultiTexCoord0.st + gl_TextureMatrix[0][3].xy;
	//texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	
	position = gbufferModelViewInverse * position;
	vec3 worldpos = position.xyz;

	position = gbufferModelView * position;
	gl_Position = gl_ProjectionMatrix * position;
	color = gl_Color;
	//texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	lmcoord = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st + gl_TextureMatrix[1][3].xy;
	//lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
	gl_FogFragCoord = gl_Position.z;
}