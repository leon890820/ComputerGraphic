#version 330

uniform mat4 MVP;
uniform mat4 modelMatrix;
uniform mat3 normalMatrix;

layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec3 aNormalPosition;
layout(location = 2) in vec2 aTexCoordPosition;

out vec3 worldNormal;
out vec3 worldVertex;
out vec2 texCoord;

void main() {
    vec4 worldPos = modelMatrix * vec4(aVertexPosition, 1.0);

    gl_Position = MVP * vec4(aVertexPosition, 1.0);

    worldNormal = normalize(normalMatrix * aNormalPosition);
    worldVertex = worldPos.xyz;
    texCoord = aTexCoordPosition;
}