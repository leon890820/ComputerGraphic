// Toon shader using per-pixel lighting. Based on the glsl 
// tutorial from lighthouse 3D:
// http://www.lighthouse3d.com/tutorials/glsl-tutorial/toon-shader-version-ii/

#define PROCESSING_LIGHT_SHADER




uniform mat4 MVP;

attribute vec3 aVertexPosition;

void main() {
  // Vertex in clip coordinates
  gl_Position =  MVP * vec4(aVertexPosition,1.0);
}