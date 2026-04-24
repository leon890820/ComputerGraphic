#version 330 core
#ifdef GL_ES
precision mediump float;
#endif

in vec3 FragWorldPos;

uniform vec3 lightPos;
uniform float lightFar;

void main() {
    float lightDistance = length(FragWorldPos - lightPos);
    lightDistance = lightDistance / lightFar;

    // 寫進 depth cubemap
    gl_FragDepth = lightDistance;
}