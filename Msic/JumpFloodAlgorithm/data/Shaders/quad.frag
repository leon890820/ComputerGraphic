#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D tex;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


void main() {  

  vec3 color = texture(tex , texcoord).rgb;
  fragColor = vec4(color , 1.0);
}