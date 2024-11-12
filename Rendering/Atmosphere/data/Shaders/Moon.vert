uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;



attribute vec3 aVertexPosition;
attribute vec3 aNormalPosition;
attribute vec3 aTangentPosition;


varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec3 modelVertex;
varying vec3 tangent;



void main() {
  // Vertex in clip coordinates
  gl_Position =  MVP * vec4(aVertexPosition,1.0);

  modelVertex = aVertexPosition;
  tangent = aTangentPosition;
  vertNormal = normalize((modelMatrix * vec4(aNormalPosition,0.0)).xyz);
  worldVertex = (modelMatrix * vec4(aVertexPosition,1.0)).xyz;
}