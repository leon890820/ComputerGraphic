#version 330
#ifdef GL_ES
precision mediump float;
#endif

#define EPSILON 0.00001
uniform sampler2D sdf_tex;
uniform sampler2D light_tex;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;

vec3 raymarch(vec2 pix, vec2 dir) {
    for(int i = 0; i < 1000; i ++) {
        float dist = texture(sdf_tex, pix).r;
        pix += dir * dist;        
	      if (dist < EPSILON){
	        return texture(light_tex, pix + ( dir * 0.01)).rgb;
          //return vec3(1.0);
        }
    }
    return vec3(0.0);
}



void main() {  

  float dist = texture(sdf_tex, texcoord).r;
  vec3 light = texture(light_tex,texcoord).rgb;
  float brightness = max(light.r, max(light.g, light.b));

  if(dist > EPSILON){
    
    for(int i = 0 ;i < 1; i++){
      float angle = i * 3.14159 / 180.0;
      vec2 ray_angle = vec2(cos(angle), sin(angle));
      vec3 hit_color = raymarch(texcoord, ray_angle);
      light += hit_color;
      brightness += max(hit_color.r, max(hit_color.g, hit_color.b));

    }

    light = (light / brightness) * (brightness / 1.0);
  }

  fragColor = vec4(light , 1.0);
}