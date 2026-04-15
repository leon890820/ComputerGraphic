#version 330
#ifdef GL_ES
precision mediump float;
#endif



in vec2 texcoord;
uniform float strength;
uniform float offset;
uniform sampler2D worleyNoiseTex;

layout(location = 0) out vec4 fragColor;


void main() {  

  vec2 uv = texcoord * 2.0 - 1.0; 

  float radius = length(uv);
  float angle = atan(uv.y, uv.x);


  angle += radius * strength + offset;

  vec2 twirledUV = vec2(cos(angle), sin(angle)) * radius;
  twirledUV = twirledUV * 0.5 + 0.5; 


  vec3 worley = texture(worleyNoiseTex,twirledUV).rgb;

  fragColor = vec4(twirledUV , 0.0 ,1.0);

}