#version 330
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

layout(location = 0) out vec4 fragColor1;
layout(location = 1) out vec4 fragColor2;

in vec2 tex_coord;


void main() {  
  fragColor1 = vec4(1.0,0.0,0.0, 1.0);
  fragColor2 = vec4(1.0,1.0,0.0, 1.0);
}