#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D albedo;
uniform sampler2D worldPos;
uniform sampler2D worldNormal;
uniform sampler2D shadowMap;

uniform mat4 lightSpaceMatrix;

uniform vec3 light_dir;
uniform vec3 light_pos;
uniform vec3 view_pos;
uniform float lightFar;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


float ShadowCalculation(vec3 worldVertex,vec3 N, vec3 L)
{
    vec4 fragPosLightSpace = lightSpaceMatrix * vec4(worldVertex, 1.0);
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;

    if (projCoords.x < 0.0 || projCoords.x > 1.0 ||
        projCoords.y < 0.0 || projCoords.y > 1.0 ||
        projCoords.z > 1.0)
    {
        return 0.0;
    }

    float closestDepth = (texture(shadowMap, projCoords.xy).r) * lightFar;
    vec3 fragToLight = worldVertex - light_pos;

    float currentDepth = length(fragToLight);

    float bias = max(0.15 * (1.0 - dot(N, L)), 0.15);    
    float shadow = currentDepth - 0.15 > closestDepth ? 0.7 : 0.0;
    return shadow;
}

void main() {  

  vec3 texture_color = texture(albedo, texcoord).rgb;
  vec3 worldVertex = texture(worldPos, texcoord).rgb;
  vec3 N = texture(worldNormal, texcoord).rgb;
  vec3 L = normalize(-light_dir);

  float shadow = ShadowCalculation(worldVertex, N, L);
  vec3 color = texture_color * (1.0 - shadow) ;

  
  fragColor = vec4(color, 1.0);
}