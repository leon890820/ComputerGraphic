#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 albedo;
uniform vec3 velosity;

vec3 col1 = vec3(0.09,0.278,0.639);
vec3 col2 = vec3(0.329,0.992,0.58);
vec3 col3 = vec3(0.988,0.937,0.023);
vec3 col4 = vec3(0.941,0.29,0.054);

layout(location = 0) out vec4 fragColor;

float lerp(float a, float b, float t){
  return (1.0 - t) * a + t * b;
}

vec3 lerp(vec3 a, vec3 b, float t){
  return vec3(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t));
}



void main() {  

  float v = clamp( sqrt(dot(velosity,velosity)) / 10.0, 0.0, 1.0);
  if(v < 0.5) fragColor = vec4(lerp(col1, col2, v), 1.0);
  else if(v < 0.7) fragColor = vec4(lerp(col2, col3, v), 1.0);
  else fragColor = vec4(lerp(col3, col4, v), 1.0);

}