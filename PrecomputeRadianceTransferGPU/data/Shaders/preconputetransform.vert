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

//attribute mat4 lightMat;

//uniform mat4 shCofr;
//uniform mat4 shCofg;
//uniform mat4 shCofb;

attribute vec3 aColor;

varying vec4 prt_color;


float dotMat(mat4 a,mat4 b){
  return dot(a[0],b[0]) + dot(a[1],b[1]) + dot(a[2],b[2]) + dot(a[3],b[3]);
}


void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition,1.0);

  prt_color = vec4(aColor,1.0);
}