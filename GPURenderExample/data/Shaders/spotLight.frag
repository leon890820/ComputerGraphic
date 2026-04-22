#version 330
#ifdef GL_ES
precision mediump float;
#endif


uniform sampler2D albedo;
uniform sampler2D worldPos;
uniform sampler2D worldNormal;
uniform sampler2D shadowMap;

uniform mat4 lightSpaceMatrix;
uniform float lightFar;
uniform float lightNear;

uniform vec3 light_dir;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;

float toLinear(float depth){

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

    float bias = max(0.0015 * (1.0 - dot(N, L)), 0.00015);
    

    float shadow = currentDepth - bias > closestDepth ? 1.0 : 0.0;
    return shadow;
}

void main() {  

  vec3 texture_color = texture(albedo, texcoord).rgb;
  vec3 worldVertex = texture(worldPos, texcoord).rgb;
  vec3 N = texture(worldNormal, texcoord).rgb;
  vec3 L = normalize(-light_dir);


  vec4 fragPosLightSpace = lightSpaceMatrix * vec4(worldVertex, 1.0);
  float shadow = ShadowCalculation(fragPosLightSpace, N, L);
  vec3 color = texture_color * (1.0 - shadow) ;

  fragColor = vec4(color , 1.0);
}