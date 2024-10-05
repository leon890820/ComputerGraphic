#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 light_dir;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;

uniform sampler2D main_tex;
uniform sampler2D normal_tex1;
uniform sampler2D normal_tex2;

uniform vec3 heightMinMax;
uniform vec3 primaryA;
uniform vec3 primaryB;
uniform vec3 secondaryA;
uniform vec3 secondaryB;

uniform float normal_bias;

uniform vec4 randomBiomeValues;



varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec3 modelVertex;
varying vec3 tangent;


float smoothstep(float a, float b, float x) {
  x = clamp((x - a) / (b - a), 0.0, 1.0); 
  return x * x * (3.0 - 2.0 * x);
}


float blend(float startHeight, float blendDst, float height) {
    return smoothstep(startHeight - blendDst / 2.0, startHeight + blendDst / 2.0, height);
}

float lerp(float a,float b,float t){
  return (1.0 - t) * a + t * b;
}

vec3 lerp(vec3 a,vec3 b,float t){
  return vec3( lerp(a.x, b.x, t) , lerp(a.y, b.y, t) , lerp(a.z, b.z, t) );
}


float remap01(float t,float x,float y){
  return (t - x) / (y - x);
}

vec3 tangentToObject(vec3 v, vec3 tangent,vec3 binormal, vec3 normal){
  return vec3(-dot(v , tangent) , dot(v , binormal) , dot(v , normal));
  //return vec3(-v.x * tangent.x + v.y * binormal.x + v.z * normal.x,
  //            -v.x * tangent.y + v.y * binormal.y + v.z * normal.y,
  //            -v.x * tangent.z + v.y * binormal.z + v.z * normal.z);
}

vec4 triplaner(vec3 pos,vec3 normal,sampler2D tex, float scale){
  vec4 colX = texture(tex, (pos.zy * scale) * 0.5 + 0.5);
  vec4 colY = texture(tex, (pos.xz * scale) * 0.5 + 0.5);
  vec4 colZ = texture(tex, (pos.xy * scale) * 0.5 + 0.5);

  vec3 blenderWeight = pow(abs(normal), vec3(2.0));
  blenderWeight /= dot(blenderWeight , vec3(1.0));
 
  return (colX * blenderWeight.x + colY * blenderWeight.y + colZ * blenderWeight.z) ;
}


void main() {  

  vec3 color;
  vec3 normal = normalize(vertNormal);
  vec3 pos = modelVertex;

  float warpNoise = 1.0;
  
  float steepness = 1.0 - dot(normal , normalize(pos));
  steepness = remap01(steepness , 0 , 0.3);

  vec4 texNoise = triplaner(pos , normal , main_tex , 2.0);
  vec3 tex_normal = triplaner(pos , normal , normal_tex1 , 15.0).xyz * 2.0 - 1.0;
  vec3 tex_normal2 = triplaner(pos , normal , normal_tex2 , 15.0).xyz * 2.0 - 1.0;

  tex_normal.xy = tex_normal.xy * normal_bias;
  tex_normal2.xy = tex_normal2.xy * normal_bias;

  vec3 binormal = cross(normalize(tangent) , normalize(normal));
  vec3 onormal = tangentToObject(normalize(lerp(tex_normal ,tex_normal2,0.5)) , normalize(tangent),normalize(binormal) , normalize(normal));


  float height01 = remap01(length(modelVertex) , heightMinMax.x , heightMinMax.y);

  float heightNoiseA = -texNoise.g * steepness - (texNoise.b - 0.5) * 0.7 + (texNoise.a - 0.5) * randomBiomeValues.x;
  float heightNoiseB = (texNoise.g - 0.5) * randomBiomeValues.y + (texNoise.r - 0.5) * randomBiomeValues.z;
  float heightBlendWeightA = blend(0.5, 0.6, height01 + heightNoiseA) * warpNoise;
  float heightBlendWeightB = blend(0.5, 0.6, height01 + heightNoiseB) * warpNoise;
  vec3 colBiomeA = lerp(primaryA, secondaryA, heightBlendWeightA);
  vec3 colBiomeB = lerp(primaryB, secondaryB, heightBlendWeightB);

  float biomeNoise = dot(texNoise.ga - 0.5, randomBiomeValues.zw) * 4.0;
  float biomeWeight = blend(2.0 * 0.8 + 0.0 * 6.08, 1.37 + warpNoise * 15, 1.0 + biomeNoise);
  vec3 biomeCol = lerp(colBiomeA, colBiomeB, biomeWeight);


  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.7 * light_color * max(0.0, dot( onormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.1 * light_color * pow(max(0.0,dot(onormal , h)),64);

  color =  biomeCol * ambient_light * 0.6 + diffuse + specular;

  gl_FragColor = vec4(color,1.0);
}

