#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;

uniform sampler2D light_depth_tex;
uniform sampler2D tex;

varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec2 tex_coord;
varying vec3 lightVertex;

void main() {  

  vec3 color;

  vec3 texture_color = texture(tex,tex_coord).rgb;

  vec2 light_tex_coord = lightVertex.xy * 0.5 + 0.5;
  light_tex_coord.y = (1.0 - light_tex_coord.y);
  float depth = texture(light_depth_tex,light_tex_coord).r;
  float shadow = lightVertex.z * 0.5 + 0.5 - depth > 0.005 ? 0.0 : 1.0;
  vec3 ambient =  (texture_color) * ambient_light;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.8 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.8 * light_color * pow(max(0.0,dot(vertNormal , h)),32);

  color = ambient + (diffuse + specular) * shadow;

 

  gl_FragColor = vec4(color,1.0);
}