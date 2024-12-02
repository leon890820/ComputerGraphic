#version 330
#ifdef GL_ES
precision mediump float;
#endif

#define USE_OKLAB
in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


uniform sampler2D radianceTexture;
uniform sampler2D sceneTexture;
uniform sampler2D sdfTexture;
uniform vec2 resolution;

const mat3 fwdA = mat3(1.0, 1.0, 1.0,
                       0.3963377774, -0.1055613458, -0.0894841775,
                       0.2158037573, -0.0638541728, -1.2914855480);
                       
const mat3 fwdB = mat3( 4.0767245293, -1.2681437731, -0.0041119885,
                       -3.3072168827, 2.6093323231, -0.7034763098,
                        0.2307590544, -0.3411344290,  1.7068625689);

const mat3 invB = mat3(0.4121656120, 0.2118591070, 0.0883097947,
                       0.5362752080, 0.6807189584, 0.2818474174,
                       0.0514575653, 0.1074065790, 0.6302613616);
                       
const mat3 invA = mat3( 0.2104542553, 1.9779984951, 0.0259040371,
                        0.7936177850, -2.4285922050, 0.7827717662,
                       -0.0040720468, 0.4505937099, -0.8086757660);

vec3 oklabToRGB(vec3 c) {
  vec3 lms = c;
  
  return fwdB * (lms * lms * lms);    
}
vec3 rgbToOklab(vec3 c) {
  vec3 lms = invB * c;

  return (sign(lms)*pow(abs(lms), vec3(0.3333333333333)));   
}

#ifndef USE_OKLAB
#define col3 vec3
#else
vec3 col3(float r, float g, float b) {
  return rgbToOklab(vec3(r, g, b));
}

vec3 col3(vec3 v) {
  return rgbToOklab(v);
}

vec3 col3(float v) {
  return rgbToOklab(vec3(v));
}
#endif
float hash(vec2 p)  // replace this by something better
{
    p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
    return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}

float hash(vec3 p)  // replace this by something better
{
    p  = 50.0*fract( p*0.3183099 + vec3(0.71, 0.113, 0.5231));
    return -1.0+2.0*fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

vec3 aces_tonemap(vec3 color){	
	mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
	);
	mat3 m2 = mat3(
        1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
	);
	vec3 v = m1 * color;    
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return pow(clamp(m2 * (a / b), 0.0, 1.0), vec3(1.0 / 2.2));	
}


vec3 BackgroundColour() {
  return col3(1.0);
}

vec3 drawGrid(vec2 pixelCoords, vec3 colour, vec3 lineColour, float cellSpacing, float lineWidth, float pixelSize) {
  vec2 cellPosition = abs(fract(pixelCoords / vec2(cellSpacing)) - 0.5);
  float distToEdge = (0.5 - max(cellPosition.x, cellPosition.y)) * cellSpacing;
  float lines = smoothstep(lineWidth - pixelSize, lineWidth, distToEdge);

  colour = mix(lineColour, colour, lines);

  return colour;
}

vec3 drawGraphBackground_Ex(vec2 pixelCoords, float scale) {
  float pixelSize = 1.0 / scale;
  vec2 cellPosition = floor(pixelCoords / vec2(100.0));
  vec2 cellID = vec2(floor(cellPosition.x), floor(cellPosition.y));
  vec3 checkerboard = col3(mod(cellID.x + cellID.y, 2.0));

  vec3 colour = BackgroundColour();
  colour = mix(colour, checkerboard, 0.05);

  colour = drawGrid(pixelCoords, colour, col3(0.5), 10.0, 1.0, pixelSize);
  colour = drawGrid(pixelCoords, colour, col3(0.25), 100.0, 2.5, pixelSize);
  colour = (col3(0.95) + hash(pixelCoords) * 0.01) * colour;

  return colour;
}

vec3 drawGraphBackground(vec2 pixelCoords) {
  return drawGraphBackground_Ex(pixelCoords, 1.0);
}

void main() {
  vec2 pixelCoords = (texcoord - 0.5) * resolution;

  vec2 uv = texcoord;

  vec4 radiance = texture(radianceTexture, uv);

  vec4 scene = texture2D(sceneTexture, uv);
  vec4 sdf = texture2D(sdfTexture, uv);
  vec3 bg = drawGraphBackground(pixelCoords);

  vec3 colour = mix(bg, col3(sdf.xyz), smoothstep(1.0, 0.0, sdf.w));

  colour = oklabToRGB(colour);

  colour *= radiance.xyz;
  colour = aces_tonemap(colour);

  fragColor = vec4(colour, 1.0);
}
