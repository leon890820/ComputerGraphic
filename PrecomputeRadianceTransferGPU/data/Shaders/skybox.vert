// Toon shader using per-pixel lighting. Based on the glsl 
// tutorial from lighthouse 3D:
// http://www.lighthouse3d.com/tutorials/glsl-tutorial/toon-shader-version-ii/

#define PROCESSING_LIGHT_SHADER


attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;
//attribute vec4 aColor;

varying vec2 tex_coord;
varying vec3 view_point;
//varying vec4 vColor;

uniform mat4 MV;
uniform float z;

void main() {
  // Vertex in clip coordinates
  gl_Position = vec4(aVertexPosition.xy,1.0,1.0);
  view_point = (MV * vec4(aTextureCoord * 2.0 - 1.0, -z, 0.0)).xyz;
  tex_coord = aTextureCoord;
}