#version 330
uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;



layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec3 aNormalPosition;
layout(location = 2) in vec2 aTexCoordPosition;

out vec4 screenPos;
out vec4 worldPos;

void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition,1.0);
  screenPos = MVP * vec4(aVertexPosition,1.0);
  worldPos = modelMatrix * vec4(aVertexPosition,1.0);
 
}