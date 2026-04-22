#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 light_dir;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;

uniform sampler2D tex;

in vec3 worldNormal;
in vec3 worldVertex;
in vec2 texCoord;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragNormal;
layout(location = 2) out vec4 fragWorldPos;


void main() {  
    vec3 texture_color = texture(tex, texCoord).rgb;

    vec3 N = normalize(worldNormal);
    vec3 L = normalize(-light_dir);
    vec3 V = normalize(view_pos - worldVertex);
    vec3 H = normalize(L + V);

    vec3 ambient = texture_color * ambient_light;
    vec3 diffuse = texture_color * 0.7 * light_color * max(0.0, dot(N, L));
    vec3 specular = 0.3 * light_color * pow(max(0.0, dot(N, H)), 64.0);

    vec3 color = ambient + (diffuse + specular);

    fragColor = vec4(color, 1.0);
    fragNormal = vec4(worldNormal, 1.0);
    fragWorldPos = vec4(worldVertex, 1.0);
}