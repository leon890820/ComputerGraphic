#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 light_dir;
uniform vec3 light_pos;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;

uniform sampler2D tex;

in vec3 vertNormal;
in vec3 worldVertex;
in vec2 tex_coord;
in float depth;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragNormal;

void main() {  
    vec2 coord = vec2(tex_coord.x, 1.0 - tex_coord.y);
    vec3 texture_color = texture(tex, coord).rgb;

    vec3 N = normalize(vertNormal);
    vec3 L = normalize(light_pos - worldVertex);
    vec3 V = normalize(view_pos - worldVertex);
    vec3 H = normalize(L + V);

    vec3 ambient = texture_color * ambient_light;
    vec3 diffuse = texture_color * 0.7 * light_color * max(0.0, dot(N, L));
    vec3 specular = 0.3 * light_color * pow(max(0.0, dot(N, H)), 64.0);

    vec3 color = ambient + diffuse + specular;

    fragColor = vec4(color, 1.0);
    fragNormal = vec4(N, 1.0);
}