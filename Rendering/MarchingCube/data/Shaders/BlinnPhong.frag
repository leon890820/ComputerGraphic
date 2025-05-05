#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;


in vec3 vertNormal;
in vec3 worldVertex;
in float depth;

layout(location = 0) out vec4 fragColor;


void main() {  

  vec3 color;
  //vec3 texture_color = texture(tex,tex_coord).rgb;
 
  vec3 ambient =  albedo;//(texture_color) * ambient_light;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.7 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.3 * light_color * pow(max(0.0,dot(vertNormal , h)),64);

  color = ambient + (diffuse + specular);

  fragColor = vec4(color,1.0);


}