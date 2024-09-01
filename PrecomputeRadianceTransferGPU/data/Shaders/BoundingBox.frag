#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif


uniform vec3 albedo;
uniform int hit;

void main() {  

  vec3 color = albedo;
  if(hit == 0) gl_FragColor = vec4(albedo,1.0);
  else gl_FragColor = vec4(1.0,1.0,1.0,1.0);
}