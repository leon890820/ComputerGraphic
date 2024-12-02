#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D JFATexture;
uniform sampler2D JFATexture2;
uniform float step;
uniform bool first;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


void main() {  


  
  float record = 1000000;
  vec2 record_uv = vec2(-1,-1);
  for(int i = -1; i <= 1; i++){
    for(int j = -1; j <= 1; j++){
      vec2 offset_uv = texcoord + vec2(j , i) * step;
      vec2 distValue = first ? texture(JFATexture , offset_uv).xy : texture(JFATexture2 , offset_uv).xy;
      if(distValue == vec2(0.0,0.0))distValue = vec2(-1.0,-1.0);
      float dist = length(distValue - texcoord);
      if(distValue.x >= 0 && distValue.y >= 0 && dist < record){
        record = dist;
        record_uv = distValue;
      }
    }
  }

  
  if(!first) fragColor = vec4(texture(JFATexture2, texcoord));
  else fragColor = vec4(record_uv, 0.0 , 1.0);
}