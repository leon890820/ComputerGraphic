#version 330
#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 fragColor;
uniform vec3 albedo;


void main() {    
  fragColor = vec4( albedo , 1.0); 
}