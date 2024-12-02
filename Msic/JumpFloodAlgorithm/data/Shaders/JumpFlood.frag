#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D JFAOriginal;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


void main() {  

  vec3 color = texture(JFAOriginal , texcoord).rgb;

  if(color != vec3(0,0,0)){
    fragColor = vec4( -1.0,-1.0, 0.0, 1.0);
  }else{
    fragColor = vec4( texcoord , 0.0, 1.0);
  }

}