#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;

varying vec3 vertNormal;
varying vec3 worldVertex;

void main() {  

  vec3 color;
  vec3 ambient = albedo * ambient_light;
  vec3 ld = normalize(light_dir);
  vec3 diffuse = 0.8 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.8 * light_color * pow(max(0.0,dot(vertNormal , h)),32);

  color = ambient + diffuse + specular;
  gl_FragColor = vec4(color,1.0);
}