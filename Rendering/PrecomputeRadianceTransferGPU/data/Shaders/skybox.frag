#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif



uniform sampler2D tex;

uniform vec3 c;

uniform sampler2D skycube1;
uniform sampler2D skycube2;
uniform sampler2D skycube3;
uniform sampler2D skycube4;
uniform sampler2D skycube5;
uniform sampler2D skycube6;

varying vec2 tex_coord;
varying vec3 view_point;
//varying vec4 vColor;


vec3 getSkyCubeColor(vec3 dir){
  float absX = abs(dir.x);
  float absY = abs(dir.y);
  float absZ = abs(dir.z);
  bool isXPositive = dir.x > 0.0 ? true:false;
  bool isYPositive = dir.y > 0.0 ? true:false;
  bool isZPositive = dir.z > 0.0 ? true:false;

  float maxAxis = 0, uc = 0, vc= 0;
  int index;

  if (isXPositive && absX >= absY && absX >= absZ) {
    maxAxis = absX;
    uc = -dir.z;
    vc = dir.y;
    index = 0;
  }
  // NEGATIVE X
  if (!isXPositive && absX >= absY && absX >= absZ) {
    maxAxis = absX;
    uc = dir.z;
    vc = dir.y;
    index = 1;
  }
  // POSITIVE Y
  if (isYPositive && absY >= absX && absY >= absZ) {
    maxAxis = absY;
    uc = dir.x;
    vc = -dir.z;
    index = 2;
  }
  // NEGATIVE Y
  if (!isYPositive && absY >= absX && absY >= absZ) {
    maxAxis = absY;
    uc = dir.x;
    vc = dir.z;
    index = 3;
  }
  // POSITIVE Z
  if (isZPositive && absZ >= absX && absZ >= absY) {
    maxAxis = absZ;
    uc = dir.x;
    vc = dir.y;
    index = 4;
  }
  // NEGATIVE Z
  if (!isZPositive && absZ >= absX && absZ >= absY) {
    maxAxis = absZ;
    uc = -dir.x;
    vc = dir.y;
    index = 5;
  }
  vec2 uv = vec2(0.5  * (uc / maxAxis + 1.0) ,1.0 - ( 0.5 * (vc / maxAxis + 1.0)));
  if(index == 0) return texture(skycube1,uv).rgb;
  if(index == 1) return texture(skycube2,uv).rgb;
  if(index == 2) return texture(skycube3,uv).rgb;
  if(index == 3) return texture(skycube4,uv).rgb;
  if(index == 4) return texture(skycube5,uv).rgb;
  if(index == 5) return texture(skycube6,uv).rgb;
  return vec3(0.0);

}

void main() {  


  vec3 sky_color = getSkyCubeColor(normalize(view_point));

  gl_FragColor = vec4(sky_color,1.0);

}