#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;


uniform vec3 shoreLow;
uniform vec3 shoreHigh;
uniform vec3 flatLowA;
uniform vec3 flatHighA;
uniform vec3 flatLowB;
uniform vec3 flatHighB;

uniform vec3 steepLow;
uniform vec3 steepHigh;

uniform vec3 heightMinMax;
uniform float maxFlatHeight;


in vec3 vertNormal;
in vec3 worldVertex;
in float depth;

layout(location = 0) out vec4 fragColor;

float lerp(float a,float b,float t){
  return (1.0 - t) * a + t * b;
}

vec3 lerp(vec3 a,vec3 b,float t){
  return vec3( lerp(a.x, b.x, t) , lerp(a.y, b.y, t) , lerp(a.z, b.z, t) );
}

float remap01(float t,float x,float y){
  return (t - x) / (y - x);
}

float smoothstep(float a, float b, float x) {
  x = clamp((x - a) / (b - a), 0.0, 1.0); 
  return x * x * (3.0 - 2.0 * x);
}


float blend(float startHeight, float blendDst, float height) {
    return smoothstep(startHeight - blendDst / 2.0, startHeight + blendDst / 2.0, height);
}


void main() {  

  vec3 color;
  //vec3 texture_color = texture(tex,tex_coord).rgb;
 
  

  vec3 sphereNormal = normalize(worldVertex);
  float steepness = 1 - dot (sphereNormal, vertNormal);
  steepness = remap01(steepness, 0.0, 0.65);

  float terrainHeight = length(worldVertex);
  float shoreHeight = lerp(heightMinMax.x, 1.0, 1.0);
  float aboveShoreHeight01 = remap01(terrainHeight, shoreHeight, heightMinMax.y);
  float flatHeight01 = remap01(aboveShoreHeight01, 0.0, maxFlatHeight);

  float flatColBlendWeight = blend(0, 1.5, (flatHeight01-0.5));
  vec3 flatTerrainColA = lerp(flatLowA, flatHighA, flatColBlendWeight);
  vec3 flatTerrainColB = lerp(flatLowB, flatHighB, flatColBlendWeight); 
  vec3 flatTerrainCol = lerp(flatTerrainColA, flatTerrainColB, 0.5);

  float shoreBlendWeight = 1-blend(0.15, 0.08, flatHeight01);
  vec3 shoreCol = lerp(shoreLow, shoreHigh, remap01(aboveShoreHeight01, 0, 0.15));
  flatTerrainCol = lerp(flatTerrainCol, shoreCol, shoreBlendWeight);

  vec3 sphereTangent = normalize(vec3(-sphereNormal.z, 0, sphereNormal.x));
  vec3 normalTangent = normalize(vertNormal - sphereNormal * dot(vertNormal, sphereNormal));
  float banding = dot(sphereTangent, normalTangent) * 0.5 + .5;
  banding = int((banding * (8.0 + 1.0)) / 8);
  banding = (abs(banding - 0.5) * 2.0 - 0.5) * 0.5;
  vec3 steepTerrainCol = lerp(steepLow, steepHigh, aboveShoreHeight01 + banding);

  float flatBlendNoise = 0.0;
  float flatStrength = 1 - blend(0.9 + flatBlendNoise, 0.051, steepness);
  float flatHeightFalloff = 1 - blend(0.52 + flatBlendNoise, 0.051, aboveShoreHeight01);
  flatStrength *= flatHeightFalloff;

  vec3 compositeCol = lerp(steepTerrainCol, flatTerrainCol, flatStrength);


  vec3 ambient =  compositeCol;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.6 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.1 * light_color * pow(max(0.0,dot(vertNormal , h)),64);

  color = ambient * 0.7 + (diffuse + specular);

  fragColor = vec4(color,1.0);

}