#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;

uniform sampler2D sdfTexture;

uniform vec2 brushPos;
uniform float brushRadius;
uniform vec3 brushColour;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;



float sdfBox(vec2 p, vec2 b) {
  vec2 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdfCircle(vec2 p, float r) {
    return length(p) - r;
}


void main() {  
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec2 pixelCoords = gl_FragCoord.xy - resolution.xy / 2.0;

  vec4 texel = texture2D(sdfTexture, uv);

  vec3 lightColour = vec3(0.0, 1.0, 1.0);
  float lightDist = sdfBox(pixelCoords - vec2(0.0), vec2(20.0));

  vec3 colour = mix(texel.xyz, lightColour, smoothstep(0.0, 1.0, texel.w));
  float dist = min(texel.w, lightDist);

  vec2 brushCoords = (brushPos - 0.5) * resolution;
  float brushDist = sdfCircle((pixelCoords - brushCoords), brushRadius * 0.5);

  colour = mix(colour, brushColour, smoothstep(1.0, 0.0, brushDist));
  dist = min(dist, brushDist);

  fragColor = vec4(colour , dist);
}