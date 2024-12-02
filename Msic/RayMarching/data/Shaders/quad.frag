#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D tex;
uniform float size;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


float dist2(vec2 a, vec2 b){
  return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y); 

}


void main() {  

  float step = 1.0 / size;
  bool inside = texture(tex , texcoord).a == 0.0 ? false : true;
  float record = 100000;
  

  for(int i = 0; i < size; i++) for(int j = 0; j < size; j++){
      vec2 sample_coord = vec2(j , i) * step;
      float edge = texture(tex , sample_coord).a;    
      bool s_inside = edge == 0.0 ? !inside : inside;
      if(s_inside) continue;
      record = min(record, dist2(sample_coord , texcoord));
  }
  
  record = sqrt(record);
  if(!inside) fragColor = vec4(vec3(record , 0.0 , 0.0) , 1.0);
  else fragColor = vec4(vec3(0.0, 0.0, record) , 1.0);
}