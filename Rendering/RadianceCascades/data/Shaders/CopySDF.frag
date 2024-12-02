#version 330
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;

uniform sampler2D sdfSource;

uniform vec2 brushPos1;
uniform vec2 brushPos2;
uniform float brushRadius;
uniform vec3 brushColour;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;


float sdfCircle(vec2 p, float r) {
    return length(p) - r;
}

void main() {  
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec2 pixelCoords = gl_FragCoord.xy - resolution.xy / 2.0;

  vec4 texel = texture2D(sdfSource, texcoord);

  vec2 brushCoords1 = (brushPos1 - 0.5) * resolution;
  vec2 brushCoords2 = (brushPos2 - 0.5) * resolution;

  float distBetweenBrushes = distance(brushCoords1, brushCoords2);
  float steps = ceil(distBetweenBrushes);

  for (float i = 0.0; i < steps; ++i) {
    vec2 brushCoords = mix(brushCoords1, brushCoords2, i / steps);
    float dist = sdfCircle(pixelCoords - brushCoords, brushRadius * 0.5);

    texel.w = min(texel.w, dist);
    texel.xyz = mix(texel.xyz, brushColour, smoothstep(1.0, 0.0, dist));
  }


  fragColor = texel;
}