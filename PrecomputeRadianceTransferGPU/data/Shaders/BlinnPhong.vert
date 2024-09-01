// Toon shader using per-pixel lighting. Based on the glsl 
// tutorial from lighthouse 3D:
// http://www.lighthouse3d.com/tutorials/glsl-tutorial/toon-shader-version-ii/

#define PROCESSING_LIGHT_SHADER




uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat4 light_MVP;


attribute vec3 aVertexPosition;
attribute vec3 aNormalPosition;
attribute vec2 aTextureCoord;

varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec4 lightVertex;
varying vec2 tex_coord;





void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition,1.0);
  lightVertex = light_MVP * vec4(aVertexPosition,1.0);
  //lightVertex = lv.xyz;
  tex_coord = aTextureCoord;

  vertNormal = normalize((modelMatrix * vec4(aNormalPosition,0.0)).xyz);
  worldVertex = (modelMatrix * vec4(aVertexPosition,1.0)).xyz;
}