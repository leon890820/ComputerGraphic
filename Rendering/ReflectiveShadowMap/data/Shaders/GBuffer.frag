#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D tex;

in vec3 viewPosition;
in vec3 viewNormal;
in vec2 texCoord;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragNormal;
layout(location = 2) out vec4 fragPosition;

void main() {  
    vec4 Albedo = texture(tex, texCoord);
    fragColor = Albedo;
    fragNormal = vec4(viewNormal,1.0);
    fragPosition = vec4(viewPosition,1.0);
}