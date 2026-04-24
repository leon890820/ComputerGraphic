#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D albedo;
uniform sampler2D worldPos;
uniform sampler2D worldNormal;

uniform samplerCube shadowCubeMap;

uniform vec3 light_pos;
uniform vec3 light_color;
uniform vec3 view_pos;

uniform float lightFar;
uniform float lightNear;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


float toLinear(float depth){

    // Perspective depth: [0,1] -> [-1,1]
    float z = depth * 2.0 - 1.0;
    float linearDepth = (2.0 * lightNear * lightFar) /
                        (lightFar + lightNear - z * (lightFar - lightNear));

    return linearDepth / lightFar;
}

float ShadowCalculationPoint(vec3 fragPos, vec3 N, vec3 L)
{
    vec3 fragToLight = fragPos - light_pos;

    float currentDepth = length(fragToLight);

    float closestDepth = texture(shadowCubeMap, fragToLight).r;
    closestDepth *= lightFar;

    float bias = max(0.5 * (1.0 - dot(N, L)), 0.5);

    float shadow = currentDepth - 0.15 > closestDepth ? 0.7 : 0.0;
    return shadow;
}

void main() {  
    vec3 texture_color = texture(albedo, texcoord).rgb;
    vec3 worldVertex = texture(worldPos, texcoord).rgb;
    vec3 N = normalize(texture(worldNormal, texcoord).rgb);

    vec3 lightVec = light_pos - worldVertex;
    float dist = length(lightVec);

    vec3 L = normalize(lightVec);

    float shadow = ShadowCalculationPoint(worldVertex, N, L);

    vec3 color = (1.0 - shadow) * texture_color;

    fragColor = vec4(color, 1.0);
}