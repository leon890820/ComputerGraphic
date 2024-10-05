#version 330
layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec2 aTexCoordPosition;

uniform mat4 invProject;
uniform mat4 camToWorld;

out vec2 tex_coord;
out vec3 viewVector;


void main() {
  // Vertex in clip coordinates
  gl_Position =   vec4(aVertexPosition,1.0);
  tex_coord = aTexCoordPosition;

  vec4 viewV = invProject * vec4(aTexCoordPosition * 2.0 - 1.0 , 0.0 , 1.0);
  viewVector = (camToWorld * vec4(viewV.xyz,0.0)).xyz;

}