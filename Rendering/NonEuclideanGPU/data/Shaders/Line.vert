#version 330
layout(location = 0) in vec3 aVertexPosition;

uniform mat4 MVP;

void main() {
  // Vertex in clip coordinates
  gl_Position =  MVP * vec4(aVertexPosition,1.0);
}