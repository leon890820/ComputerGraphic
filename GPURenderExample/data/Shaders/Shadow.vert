#version 330 core

uniform mat4 modelMatrix;
uniform mat4 shadowMatrix;

layout(location = 0) in vec3 aVertexPosition;

out vec3 FragWorldPos;

void main() {
    vec4 worldPos = modelMatrix * vec4(aVertexPosition, 1.0);
    FragWorldPos = worldPos.xyz;
    gl_Position = shadowMatrix * worldPos;
}