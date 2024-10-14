#version 330
layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec2 aTexCoordPosition;

uniform mat4 MVP;

out vec2 tex_coord;
out vec4 screen_pos;


void main() {
  // Vertex in clip coordinates
  gl_Position =  MVP * vec4(aVertexPosition,1.0);
  screen_pos = gl_Position;
  tex_coord = aTexCoordPosition;
}