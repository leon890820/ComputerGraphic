#version 330

layout(location = 0) in vec3 aVertexPosition;
layout(location = 2) in vec2 aTexCoordPosition;


out vec2 texCoord;


void main() {
  // Vertex in clip coordinates
  gl_Position = vec4(aVertexPosition,1.0);
  texCoord = aTexCoordPosition;
}