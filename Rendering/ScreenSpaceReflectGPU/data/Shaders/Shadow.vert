#version 330




uniform mat4 MVP;
layout(location = 0) in vec3 aVertexPosition;

void main() {
  // Vertex in clip coordinates
  gl_Position = MVP * vec4(aVertexPosition, 1.0);
}