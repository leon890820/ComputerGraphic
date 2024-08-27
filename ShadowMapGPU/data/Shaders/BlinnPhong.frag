#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec3 light_dir;
uniform vec3 light_pos;
uniform vec3 albedo;
uniform vec3 ambient_light;
uniform vec3 light_color;
uniform vec3 view_pos;
uniform vec3 resolution;

uniform sampler2D light_depth_tex;
uniform sampler2D tex;


varying vec3 vertNormal;
varying vec3 worldVertex;
varying vec2 tex_coord;
varying vec4 lightVertex;


#define EPS 1e-3
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define NUM_SAMPLES 100
#define BLOCKER_SEARCH_NUM_SAMPLES NUM_SAMPLES
#define PCF_NUM_SAMPLES NUM_SAMPLES
#define NUM_RINGS 10
#define NEAR_PLANE 1
#define LIGHT_WORLD_SIZE 5.

varying vec4 vPositionFromLight;

highp float rand_1to1(highp float x ) { 
  // -1 -1
  return fract(sin(x)*10000.0);
}

highp float rand_2to1(vec2 uv ) { 
  // 0 - 1
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract(sin(sn) * c);
}


vec2 poissonDisk[NUM_SAMPLES];

void poissonDiskSamples( const in vec2 randomSeed ) {

  float ANGLE_STEP = PI2 * float( NUM_RINGS ) / float( NUM_SAMPLES );
  float INV_NUM_SAMPLES = 1.0 / float( NUM_SAMPLES );

  float angle = rand_2to1( randomSeed ) * PI2;
  float radius = INV_NUM_SAMPLES;
  float radiusStep = radius;

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( cos( angle ), sin( angle ) ) * pow( radius, 0.75 );
    radius += radiusStep;
    angle += ANGLE_STEP;
  }
}

void uniformDiskSamples( const in vec2 randomSeed ) {

  float randNum = rand_2to1(randomSeed);
  float sampleX = rand_1to1( randNum ) ;
  float sampleY = rand_1to1( sampleX ) ;

  float angle = sampleX * PI2;
  float radius = sqrt(sampleY);

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( radius * cos(angle) , radius * sin(angle)  );

    sampleX = rand_1to1( sampleY ) ;
    sampleY = rand_1to1( sampleX ) ;

    angle = sampleX * PI2;
    radius = sqrt(sampleY);
  }
}


float getShadowBias(float c, float filterRadiusUV){
  vec3 normal = normalize(vertNormal);
  vec3 lightDir = normalize(light_pos - worldVertex);
  float fragSize = (1. + ceil(filterRadiusUV)) * (200.0 / resolution.y / 2.);
  return max(fragSize, fragSize * (1.0 - dot(normal, lightDir))) * c;
}


float shadow_map(vec3 coord){

  float bias = getShadowBias(0.2, 0.0);
  vec2 light_tex_coord = coord.xy;
  light_tex_coord.y = (1.0 - light_tex_coord.y);
  float depth = texture(light_depth_tex,light_tex_coord).r;
  float shadow = coord.z - depth >  0.1 ? 0.0 : 1.0;
  return shadow;
}

float PCF(vec3 coord , float biasC, float filterRadiusUV){

  poissonDiskSamples(coord.xy);
  float bias = getShadowBias(biasC, filterRadiusUV);
  vec2 light_tex_coord = coord.xy;
  light_tex_coord.y = (1.0 - light_tex_coord.y);
  vec3 step = 1.0 / resolution;

  float shadow_sum = 0.0;

  for(int i = 0; i < NUM_SAMPLES; i++){
    
      vec2 bias_coord = poissonDisk[i] * filterRadiusUV + light_tex_coord;
      float depth = texture(light_depth_tex,bias_coord).r;
      float shadow = coord.z - depth > bias ? 0.0 : 1.0;
      shadow_sum += shadow;
    
  }

  
  return shadow_sum / NUM_SAMPLES;
}

float findBlocker(vec3 coord,float zReceiver) {
  int blockerNum = 0;
  float blockDepth = 0.;

  float posZFromLight = lightVertex.z *0.5 + 0.5;
  vec2 light_tex_coord = coord.xy;
  light_tex_coord.y = (1.0 - light_tex_coord.y);

  float searchRadius = LIGHT_WORLD_SIZE / 600.0 * (posZFromLight + 1) / (posZFromLight);
  
  poissonDiskSamples(coord.xy);
  for(int i = 0; i < NUM_SAMPLES; i++){
    vec2 bias_coord = light_tex_coord + poissonDisk[i] * searchRadius;
    float shadowDepth = texture(light_depth_tex,bias_coord).r;
    if(zReceiver > shadowDepth){
      blockerNum++;
      blockDepth += shadowDepth;
    }   
  }

  if(blockerNum == 0)
    return -1.;
  else
    return blockDepth / float(blockerNum);
}

float PCSS(vec3 coord,float biasC){
  float zReceiver = coord.z;

  // STEP 1: avgblocker depth 
  vec2 light_tex_coord = coord.xy;
  light_tex_coord.y = (1.0 - light_tex_coord.y);
  float avgBlockerDepth = findBlocker(coord,zReceiver);

  if(avgBlockerDepth < -EPS)
    return 1.0;

  // STEP 2: penumbra size
  float penumbra = (zReceiver - avgBlockerDepth) * LIGHT_WORLD_SIZE / 400.0 / avgBlockerDepth;

  // STEP 3: filtering
  return PCF(coord,biasC, penumbra);
}






void main() {  
  vec3 coord = (lightVertex.xyz / lightVertex.w) * 0.5 + 0.5;
  float sw;
  //sw = shadow_map(coord);
  //sw = PCF(coord,0.05,4.0 / resolution.y);
  sw = PCSS(coord,0.05);

  vec3 color;
  vec3 texture_color = texture(tex,tex_coord).rgb;
 
  vec3 ambient =  (texture_color) * ambient_light;
  vec3 ld = normalize(-light_dir);
  vec3 diffuse = 0.8 * light_color * max(0.0, dot( vertNormal , ld ));

  vec3 view_dir = normalize(view_pos - worldVertex);
  vec3 h = normalize(ld + view_dir);
  vec3 specular = 0.8 * light_color * pow(max(0.0,dot(vertNormal , h)),32);

  color = ambient + (diffuse + specular) * sw;

  gl_FragColor = vec4(tex_coord,0.0,1.0);
}