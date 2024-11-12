#version 330
layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec3 aNormalPosition;

uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;


out vec3 vertNormal;
out vec3 worldVertex;


void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition,1.0);

  

  vertNormal = normalize((modelMatrix * vec4(aNormalPosition,0.0)).xyz);
  worldVertex = (modelMatrix * vec4(aVertexPosition,1.0)).xyz;
}