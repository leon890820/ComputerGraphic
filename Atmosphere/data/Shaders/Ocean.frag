#version 330
#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 fragColor;


uniform float radius;
uniform float depthMultiplier;
uniform float alphaMultiplier;
uniform vec3 colA;
uniform vec3 colB;
uniform float smoothness;
uniform float waveStrength;
uniform float waveScale;
uniform float time;
uniform float waveSpeed;
uniform vec3 specularCol;

uniform vec3 cam_pos;
uniform vec3 light_dir;
uniform sampler2D main_tex;
uniform sampler2D depth_tex;

uniform sampler2D waveA;
uniform sampler2D waveB;


in vec2 tex_coord;
in vec3 viewVector;

float lerp(float a,float b,float t){
  return (1.0 - t) * a + t * b;
}

vec3 lerp(vec3 a,vec3 b,float t){
  return vec3( lerp(a.x, b.x, t) , lerp(a.y, b.y, t) , lerp(a.z, b.z, t) );
}

float saturate(float a){
  return max(0.0 , min(a , 1.0));
}

vec3 saturate(vec3 v){
  return vec3(saturate(v.x),saturate(v.y),saturate(v.z));
}

vec3 blend_rnm(vec3 n1, vec3 n2)
{
	n1.z += 1.0;
	n2.xy = -n2.xy;

	return n1 * dot(n1, n2) / n1.z - n2;
}

// Sample normal map with triplanar coordinates
// Returned normal will be in obj/world space (depending whether pos/normal are given in obj or world space)
// Based on: medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a
vec3 triplanarNormal(vec3 vertPos, vec3 normal, float scale, vec2 offset, sampler2D normalMap) {
	vec3 absNormal = abs(normal);

	// Calculate triplanar blend
	vec3 blendWeight = saturate(pow(normal, vec3(4.0)));
	// Divide blend weight by the sum of its components. This will make x + y + z = 1
	blendWeight /= dot(blendWeight, vec3(1.0));

	// Calculate triplanar coordinates
	vec2 uvX = vertPos.zy * scale + offset;
	vec2 uvY = vertPos.xz * scale + offset;
	vec2 uvZ = vertPos.xy * scale + offset;

	// Sample tangent space normal maps
	// UnpackNormal puts values in range [-1, 1] (and accounts for DXT5nm compression)
	vec3 tangentNormalX = texture(normalMap, uvX).xyz * 2.0 - 1.0;
	vec3 tangentNormalY = texture(normalMap, uvY).xyz * 2.0 - 1.0;
	vec3 tangentNormalZ = texture(normalMap, uvZ).xyz * 2.0 - 1.0;

	// Swizzle normals to match tangent space and apply reoriented normal mapping blend
	tangentNormalX = blend_rnm(vec3(normal.zy, absNormal.x), tangentNormalX);
	tangentNormalY = blend_rnm(vec3(normal.xz, absNormal.y), tangentNormalY);
	tangentNormalZ = blend_rnm(vec3(normal.xy, absNormal.z), tangentNormalZ);

	// Apply input normal sign to tangent space Z
	vec3 axisSign = sign(normal);
	tangentNormalX.z *= axisSign.x;
	tangentNormalY.z *= axisSign.y;
	tangentNormalZ.z *= axisSign.z;

	// Swizzle tangent normals to match input normal and blend together
	vec3 outputNormal = normalize(
		tangentNormalX.zyx * blendWeight.x +
		tangentNormalY.xzy * blendWeight.y +
		tangentNormalZ.xyz * blendWeight.z
	);

	return outputNormal;
}


vec4 triplaner(vec3 pos,vec3 normal,sampler2D tex, float scale){
  vec4 colX = texture(tex, (pos.zy * scale) * 0.5 + 0.5);
  vec4 colY = texture(tex, (pos.xz * scale) * 0.5 + 0.5);
  vec4 colZ = texture(tex, (pos.xy * scale) * 0.5 + 0.5);

  vec3 blenderWeight = pow(abs(normal), vec3(2.0));
  blenderWeight /= dot(blenderWeight , vec3(1.0));
 
  return (colX * blenderWeight.x + colY * blenderWeight.y + colZ * blenderWeight.z) ;
}



float perspectiveDepthToViewZ(float z, float near, float far) {
  return 1.0 / ((near - far)/(far * near)* z + 1.0 / near);
}

float perspectiveDepthToViewZ01(float z, float near, float far) {
  return 1.0 / ((near - far)/(near)* z + far / near);
}



float readDepth( sampler2D depthSampler, vec2 coord ) {
  float cameraNear = 0.1;
  float cameraFar = 1000.0;
  float fragCoordZ = texture( depthSampler, coord ).x;
  float viewZ = perspectiveDepthToViewZ( fragCoordZ, cameraNear, cameraFar ); 
  return viewZ;
}


vec2 RaySphereDst(vec3 sphereCenter, float sphereRadius, vec3 pos, vec3 rayDir)
{
    vec3 oc = pos - sphereCenter;
    float b = dot(rayDir, oc);
    float c = dot(oc, oc) - sphereRadius * sphereRadius;
    float t = b * b - c;

    float delta = sqrt(max(t, 0.0));
    float dstToSphere = max(-b - delta, 0.0);
    float dstInSphere = max(-b + delta - dstToSphere, 0.0);
    return vec2(dstToSphere, dstInSphere);
}


void main() {  
  vec3 col = texture(main_tex, tex_coord).xyz;
  vec3 rayDir = normalize(viewVector);
  float depth =  readDepth(depth_tex,tex_coord) * length(viewVector);

  vec2 raySphereInfo = RaySphereDst(vec3(0.0) , radius , cam_pos ,rayDir);
  float dstToOcean = raySphereInfo.x;
  float dstThroughOcean = raySphereInfo.y;
  vec3 rayOceanIntersectPos = cam_pos + rayDir * dstToOcean;
  vec3 dirToSun = normalize(-light_dir);

  float oceanViewDepth = min(dstThroughOcean , depth - dstToOcean);

  if(oceanViewDepth > 0.0){
    float opticalDepth01 = 1.0 - exp(- oceanViewDepth * depthMultiplier);
    float alpha = 1 - exp(-oceanViewDepth * alphaMultiplier);
    vec3 oceanCol = lerp(colA, colB, opticalDepth01);
    
    vec3 oceanSphereNormal = normalize(rayOceanIntersectPos);

    

    vec2 waveOffsetA = vec2(time * waveSpeed, time * waveSpeed * 0.8);
    vec2 waveOffsetB = vec2(time * waveSpeed * - 0.8, time * waveSpeed * -0.3);

    vec3 waveNormal = triplanarNormal(rayOceanIntersectPos, oceanSphereNormal, waveScale, waveOffsetA, waveA);
    waveNormal = triplanarNormal(rayOceanIntersectPos, waveNormal, waveScale, waveOffsetB, waveB);
    waveNormal = normalize(lerp(oceanSphereNormal, waveNormal, waveStrength));


    float diffuseLighting = saturate(dot(oceanSphereNormal, dirToSun));
    float specularAngle = acos(dot(normalize(dirToSun - rayDir), waveNormal));
    float specularExponent = specularAngle / (1.0 - smoothness);
    float specularHighlight = exp(-specularExponent * specularExponent);



    oceanCol = oceanCol * diffuseLighting + specularHighlight * specularCol;
    oceanCol = lerp(col , oceanCol , alpha);

    fragColor = vec4(oceanCol, 1.0);
  }else{
    fragColor = vec4(col, 1.0);
  }

  
}