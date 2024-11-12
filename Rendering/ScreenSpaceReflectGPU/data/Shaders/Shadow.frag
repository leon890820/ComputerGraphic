#version 330
#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 fragColor;


void main() {  
  fragColor = vec4(vec3(gl_FragCoord.z),1.0);
}