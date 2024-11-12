// Toon shader using per-pixel lighting. Based on the glsl 
// tutorial from lighthouse 3D:
// http://www.lighthouse3d.com/tutorials/glsl-tutorial/toon-shader-version-ii/

#define PROCESSING_LIGHT_SHADER




uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;



attribute vec4 vertex;
attribute vec3 normal;

varying vec3 vertNormal;
varying vec3 worldVertex;


void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vertex;
  
  // Normal vector in eye coordinates is passed
  // to the fragment shader
  vertNormal = normalize((modelMatrix * vec4(normal,0.0)).xyz);
  //vertNormal.y *= -1.0;
  worldVertex = (modelMatrix * vertex).xyz;
}