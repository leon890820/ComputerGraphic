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
uniform sampler2D shadowMap;

uniform mat4 lightSpaceMatrix;
uniform float lightNear;
uniform float lightFar;
uniform int lightType; // 0 : direction, 1 : spot, 2 : point

in vec3 worldNormal;
in vec3 worldVertex;
in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

float toLinear(float depth){
    // Directional light (ortho) depth 本來近似線性
    if(lightType == 0) return depth;

    // Perspective depth: [0,1] -> [-1,1]
    float z = depth * 2.0 - 1.0;
    float linearDepth = (2.0 * lightNear * lightFar) /
                        (lightFar + lightNear - z * (lightFar - lightNear));

    return linearDepth / lightFar;
}

float ShadowCalculation(vec4 fragPosLightSpace, vec3 N, vec3 L)
{
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;

    if (projCoords.x < 0.0 || projCoords.x > 1.0 ||
        projCoords.y < 0.0 || projCoords.y > 1.0 ||
        projCoords.z > 1.0)
    {
        return 0.0;
    }

    float currentDepth = toLinear(projCoords.z);
    float closestDepth = toLinear(texture(shadowMap, projCoords.xy).r);

    float bias;
    if (lightType == 0) {
        bias = max(0.0005 * (1.0 - dot(N, L)), 0.00005);
    } else {
        bias = max(0.0015 * (1.0 - dot(N, L)), 0.00015);
    }

    float shadow = currentDepth - bias > closestDepth ? 1.0 : 0.0;
    return shadow;
}

void main() {  
    vec3 texture_color = texture(tex, texCoord).rgb;

    vec3 N = normalize(worldNormal);
    vec3 L = normalize(-light_dir);
    vec3 V = normalize(view_pos - worldVertex);
    vec3 H = normalize(L + V);

    vec3 ambient = texture_color * ambient_light;
    vec3 diffuse = texture_color * 0.7 * light_color * max(0.0, dot(N, L));
    vec3 specular = 0.3 * light_color * pow(max(0.0, dot(N, H)), 64.0);

    vec4 fragPosLightSpace = lightSpaceMatrix * vec4(worldVertex, 1.0);
    float shadow = ShadowCalculation(fragPosLightSpace, N, L);

    vec3 color = ambient + (1.0 - shadow) * (diffuse + specular);

    fragColor = vec4(color, 1.0);
}