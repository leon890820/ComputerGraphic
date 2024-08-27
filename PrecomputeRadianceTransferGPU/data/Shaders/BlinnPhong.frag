#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 light_dir;
uniform vec3 light_pos;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;
uniform vec3 resolution;

uniform sampler2D tex;


varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec2 tex_coord;


void main() {  

  vec3 color;
  vec2 tc = vec2(tex_coord.x, 1 - tex_coord.y);
  vec3 texture_color = texture(tex,tc).rgb;
 
  vec3 ambient =  (texture_color) * ambient_light;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.8 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.8 * light_color * pow(max(0.0,dot(vertNormal , h)),32);

  color = ambient + (diffuse + specular) + albedo * 0.2;

  gl_FragColor = vec4(color,1.0);
}