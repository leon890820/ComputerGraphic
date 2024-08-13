// Toon shader using per-pixel lighting. Based on the glsl 
// tutorial from lighthouse 3D:
// http://www.lighthouse3d.com/tutorials/glsl-tutorial/toon-shader-version-ii/

#define PROCESSING_LIGHT_SHADER




uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;
uniform mat4 light_MVP;


attribute vec4 vertex;
attribute vec3 normal;
attribute vec4 texCoord;

varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec3 lightVertex;
varying vec2 tex_coord;



void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vertex;
  vec4 lv = light_MVP * vertex;
  lightVertex = lv.xyz / lv.w;
  tex_coord = texCoord.xy;

  vertNormal = normalize((modelMatrix * vec4(normal,0.0)).xyz);
  worldVertex = (modelMatrix * vertex).xyz;
}