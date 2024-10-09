#version 330
#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 fragColor;

uniform sampler2D main_tex;
uniform sampler2D depth_tex;


uniform float numInScateringPoints;
uniform float numOpticalDepthPoints;
uniform float densityFalloff;
uniform float atmosphereRadius;
uniform float radius;
uniform vec3 cam_pos;
uniform vec3 light_dir;
uniform vec3 lambda;



in vec2 tex_coord;
in vec3 viewVector;


vec3 lambdaCof;

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

float densityAtPoint(vec3 point){
  float h = length(point - vec3(0.0)) - radius;
  float h01 = h / (atmosphereRadius - radius);
  return exp(-h01 * densityFalloff) * (1 - h01);
}

vec3 phase(vec3 lam , float c, float h){
  return pow( 400.0 / lam , vec3(4.0)) * 5.0;

}

float opticalDepth(vec3 origin ,vec3 dir , float rayLength){
  vec3 densitySamplePoint = origin;
  float stepSize = rayLength / numOpticalDepthPoints;
  float opticalDepth = 0.0;

  for(int i = 0; i < numOpticalDepthPoints + 1; i++){
    float localDensity = densityAtPoint(densitySamplePoint);
    opticalDepth += localDensity * stepSize;
    densitySamplePoint += dir * stepSize;
  }
  return opticalDepth;
}



vec3 caculateLight(vec3 origin , vec3 dir, float rayLength,vec3 originCol){
  vec3 inScatterPoint = origin;
  float stepSize = rayLength / numInScateringPoints;
  vec3 inScatteredLight = vec3(0.0);
  vec3 dirToSun = normalize(-light_dir);
  float viewRayOpticalDepth = 0.0;

  for(int i = 0; i < numInScateringPoints + 1; i++){
    float sunRayLength = RaySphereDst(vec3(0.0) , atmosphereRadius , inScatterPoint , dirToSun).y;
    float sunRayOpticalDepth = opticalDepth(inScatterPoint, dirToSun ,sunRayLength);
    viewRayOpticalDepth = opticalDepth(inScatterPoint, -dir , stepSize * float(i));

    vec3 transmittance = exp(-(sunRayOpticalDepth + viewRayOpticalDepth) * lambdaCof);
    float localDensity = densityAtPoint(inScatterPoint);

    inScatteredLight += localDensity * transmittance * lambdaCof * stepSize;
    inScatterPoint += dir * stepSize;
  }
  float originColTransmittance = exp(-viewRayOpticalDepth);

  return originCol * originColTransmittance + inScatteredLight;

}


void main() {  
  vec3 col = texture(main_tex, tex_coord).xyz;
  vec3 rayDir = normalize(viewVector);
  float depth =  readDepth(depth_tex,tex_coord) * length(viewVector);

  lambdaCof = phase(lambda, 0.0, 0.0);

  vec2 rayAtmosphereInfo = RaySphereDst(vec3(0.0) ,atmosphereRadius , cam_pos ,rayDir);
  vec2 rayOceanInfo = RaySphereDst(vec3(0.0) , radius , cam_pos ,rayDir);
  float dstToSurface = min(depth , rayOceanInfo.x);

  float dstToAtmosphere = rayAtmosphereInfo.x;
  float dstThroughAtmosphere = min(rayAtmosphereInfo.y, depth - dstToAtmosphere);

  if(dstThroughAtmosphere > 0){
    vec3 pointInAtmosphere = cam_pos + rayDir * (dstToAtmosphere + 0.0001);
    vec3 light = caculateLight(pointInAtmosphere , rayDir , dstThroughAtmosphere, col);
    fragColor = vec4(light , 1.0);
  }else{
    fragColor = vec4(col , 1.0);
  }

  


  
}