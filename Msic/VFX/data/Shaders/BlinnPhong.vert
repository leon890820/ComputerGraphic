#version 330
uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;



layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec3 aNormalPosition;


out vec3 vertNormal;
out vec3 worldVertex;
out float depth;

void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition,1.0);
  depth = gl_Position.z / gl_Position.w;
  

  vertNormal = normalize((modelMatrix * vec4(aNormalPosition,0.0)).xyz);
  worldVertex = (modelMatrix * vec4(aVertexPosition,1.0)).xyz;
}