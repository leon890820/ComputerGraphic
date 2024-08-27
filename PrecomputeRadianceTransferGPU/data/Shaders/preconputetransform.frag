#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif



varying vec4 prt_color;


void main() {  

  vec3 final_color = pow(prt_color.xyz, vec3(1.0 / 2.2));
  gl_FragColor = vec4(final_color,1.0);
}