#version 330
#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 fragColor;

uniform sampler2D main_tex;
in vec2 tex_coord;
in vec4 screen_pos;


void main() {    
  vec2 screen_coord = (screen_pos.xy / screen_pos.w) * 0.5 + 0.5;
  vec3 col = texture(main_tex, screen_coord).xyz; 
  fragColor = vec4( col , 1.0);
  
}