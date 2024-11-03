#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform vec3 cam_position;
uniform mat4 VP;


uniform sampler2D depth_tex;
uniform sampler2D kds_tex;
uniform sampler2D normal_tex;
uniform sampler2D worldPos_tex;
uniform sampler2D shadow_tex;
uniform float time;

in vec4 screenPos;
in vec4 worldPos;

layout(location = 0) out vec4 fragColor;


vec3 getScreenPos(vec3 wp){
  vec4 sp = VP * vec4(wp , 1.0);
  return (sp.xyz / sp.w) * 0.5 + 0.5;
}

bool inSamePixel(vec3 a, vec3 b){
  int ax = int(a.x * 900);
  int ay = int(a.y * 900);
  int bx = int(b.x * 900);
  int by = int(b.y * 900);
  return ax == ay && bx == by;
}


bool rayMarching(vec3 pos , vec3 dir, out vec3 hit_pos){
  float step_size = 0.01;
  int max_size = 500;

  for(int i = 1; i < max_size; i++){
    vec3 wp = pos + dir * float(i) * step_size;
    vec3 sp = getScreenPos(wp);
    if(sp.x < 0.0 || sp.x > 1.0 || sp.y < 0.0 || sp.y > 1.0 || sp.z < 0.0 || sp.z > 1.0) return false;
    float d = texture(depth_tex,sp.xy).z; 
    d = d < 0.01 ? 1000 : d * 0.5 + 0.5;
    
    if(sp.z - d > 0.01) {
      hit_pos = vec3(sp.z - d);
      return true;
    }

  }
  return false;

}

vec3 reflect(vec3 l, vec3 n){
  return 2 * dot(l,n) * n - l;

}


void main() {  

  vec3 color = vec3(0.0);
  vec2 coord = screenPos.xy / screenPos.w * 0.5 + 0.5 ;

  
  
  vec3 kds = texture(kds_tex,coord).rgb;
  vec3 normal = texture(normal_tex,coord).rgb;

  


  vec3 dir =  cam_position - worldPos.xyz;
  vec3 r = reflect(normalize(dir) , normalize(normal));
  vec3 hit_pos;  
  //if(rayMarching(worldPos.xyz , r, hit_pos)){
  //  color = hit_pos;
  //}

  vec3 sp = getScreenPos(worldPos.xyz  + r * 2);
  vec4 depth = texture(depth_tex,coord); 
  depth = depth * 0.5 + 0.5;
  fragColor = vec4( vec3(sp.z),1.0);


  
}