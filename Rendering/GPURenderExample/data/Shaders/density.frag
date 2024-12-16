#version 440
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D tex;
uniform vec3 albedo;


in vec2 texcoord;

layout(location = 0) out vec4 fragColor;



void main() {  

  fragColor = vec4(albedo, 1.0);
}