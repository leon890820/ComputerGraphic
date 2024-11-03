#version 330
#ifdef GL_ES
precision mediump float;
#endif



uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;
uniform sampler2D tex;
uniform mat4 uLightMV;
uniform sampler2D light_depth_tex;

in vec3 vertNormal;
in vec3 worldVertex;
in vec2 texcoord;
in vec4 screenPos;


layout(location = 0) out vec4 kds;
layout(location = 1) out vec4 normal;
layout(location = 2) out vec4 worldPos;
layout(location = 3) out vec4 depth;
layout(location = 4) out vec4 shadow;

vec3 getColor(){
  vec3 color;
  vec3 texture_color = texture(tex,texcoord).rgb;
  vec3 normal = normalize(vertNormal);
  vec3 ambient = (texture_color) * 0.7;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.3 * light_color * max(0.0, dot( normal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.2 * light_color * pow(max(0.0,dot(normal , h)),64);

  color = ambient + diffuse;

  return color;

}


void main() {  

  vec4 d = uLightMV * vec4(worldVertex , 1.0);

  kds = vec4(getColor(), 1.0);
  normal = vec4(normalize(vertNormal), 1.0);
  worldPos = vec4(worldVertex , 1.0); 
  vec3 r_depth = d.xyz / d.w  * 0.5 + 0.5;

  vec3 light_depth = texture(light_depth_tex,r_depth.xy).rgb;
  if(r_depth.z - light_depth.z > 0.0001) shadow = vec4(0.0);
  else shadow = vec4(1.0);

  depth = vec4(vec3(screenPos.z / screenPos.w),1.0);
  
}