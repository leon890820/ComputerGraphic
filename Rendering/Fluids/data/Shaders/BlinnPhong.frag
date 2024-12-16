#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 albedo;



layout(location = 0) out vec4 fragColor;


void main() {  
  fragColor = vec4(albedo,1.0);
}