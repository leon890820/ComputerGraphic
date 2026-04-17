#version 440
#ifdef GL_ES
precision mediump float;
#endif

#define VPL_NUM 128

uniform sampler2D u_AlbedoTexture;
uniform sampler2D u_NormalTexture;
uniform sampler2D u_PositionTexture;
uniform sampler2D u_RSMFluxTexture;
uniform sampler2D u_RSMNormalTexture;		
uniform sampler2D u_RSMPositionTexture;

uniform mat4  u_LightVPMatrixMulInverseCameraViewMatrix;
uniform float u_MaxSampleRadius;
uniform int   u_RSMSize;
uniform int   u_VPLNum;
uniform vec3  u_LightDirInViewSpace;

in vec2 texCoord;



layout (std430,binding = 0) buffer VPLsSampleCoordsAndWeights{
    vec4 u_VPLsSampleCoordsAndWeights[VPL_NUM];
};


layout(location = 0) out vec4 fragColor;

vec3 calcVPLIrradiance(vec3 vVPLFlux, vec3 vVPLNormal, vec3 vVPLPos, vec3 vFragPos, vec3 vFragNormal, float vWeight)
{
	vec3 VPL2Frag = normalize(vFragPos - vVPLPos);
	return vVPLFlux * max(dot(vVPLNormal, VPL2Frag), 0) * max(dot(vFragNormal, -VPL2Frag), 0) * vWeight;
}

void main() {     
    vec3 FragViewNormal = normalize(texture(u_NormalTexture, texCoord).xyz);
	vec3 FragAlbedo = texture(u_AlbedoTexture, texCoord).xyz;
	vec3 FragViewPos = texture(u_PositionTexture, texCoord).xyz;
    
    vec4 FragPosInLightSpace = u_LightVPMatrixMulInverseCameraViewMatrix * vec4(FragViewPos, 1);
    FragPosInLightSpace /= FragPosInLightSpace.w;
    vec2 FragNDCPos4Light = (FragPosInLightSpace.xy + 1) / 2;
    float RSMTexelSize = 1.0 / u_RSMSize;

    vec3 DirectIllumination;
    if(FragPosInLightSpace.z < -1.0f || FragPosInLightSpace.x > 1.0f || FragPosInLightSpace.y > 1.0f || FragPosInLightSpace.x < -1.0f || FragPosInLightSpace.y < -1.0f )
		DirectIllumination = vec3(0.1) * FragAlbedo;
	else
		DirectIllumination = FragAlbedo * max(dot(-u_LightDirInViewSpace, FragViewNormal), 0.1);

    vec3 IndirectIllumination = vec3(0);
	for(int i = 0; i < u_VPLNum; i++){
        vec3 VPLSampleCoordAndWeight = u_VPLsSampleCoordsAndWeights[i].xyz;
        vec2 VPLSamplePos = FragNDCPos4Light + u_MaxSampleRadius * VPLSampleCoordAndWeight.xy * RSMTexelSize;
        vec3 VPLFlux;
        if(VPLSamplePos.x > 1.0f || VPLSamplePos.y > 1.0f || VPLSamplePos.x < 0.0f || VPLSamplePos.y < 0.0f )
            VPLFlux = vec3(0.0);                
        else
            VPLFlux = texture(u_RSMFluxTexture, VPLSamplePos).xyz;
        vec3 VPLNormalInViewSpace = normalize(texture(u_RSMNormalTexture, VPLSamplePos).xyz);
        vec3 VPLPositionInViewSpace = texture(u_RSMPositionTexture, VPLSamplePos).xyz;

        IndirectIllumination += calcVPLIrradiance(VPLFlux, VPLNormalInViewSpace, VPLPositionInViewSpace, FragViewPos, FragViewNormal, VPLSampleCoordAndWeight.z);
	}
    IndirectIllumination *= FragAlbedo;

	vec3 Result = DirectIllumination  + IndirectIllumination / u_VPLNum;

    fragColor = vec4(Result, 1.0);
}