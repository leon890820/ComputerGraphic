#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

void main() {  
  gl_FragColor = vec4(vec3(gl_FragCoord.z),1.0);
}