#version 440
#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926


uniform vec4 camInfo;
uniform vec2 boundary;
in vec2 texcoord;

uniform float kernelRadius;

layout (std430,binding = 0) buffer SSBO_Fluid{
    vec3 fluids[];
};

layout(location = 0) out vec4 fragColor;

float map1(float n,float x1,float x2,float y1,float y2){
    return (n - x1) * (y2 - y1) / (x2 - x1) + y1;
}

float smoothingKernel(float kernelRadius, float dst){
    if(dst > kernelRadius) return 0;
    float volume = PI * pow(kernelRadius , 4) / 6;        
    return (kernelRadius - dst)*(kernelRadius - dst) / volume;     
}

float smoothingKernelDerivative(float kernelRadius, float dst){
    if(dst > kernelRadius) return 0;        
    float scale = 12.0 / (PI * pow(kernelRadius , 4));
    return scale * (dst - kernelRadius);  
}

float calculateDensity(vec3 pos){
    float density = 0.0;
    float mass = 1.0;
    for(int i = 0; i < fluids.length(); i++){
        float dst = sqrt(dot(pos - fluids[i] , pos - fluids[i]));
        float influence = smoothingKernel(kernelRadius,dst);
        density += influence * mass;
    }       
    return density;
}



void main() {  
    vec2 size = vec2(tan(camInfo.w) * camInfo.z) ;
    float x = map1(texcoord.x , 0.0, 1.0, -size.x + camInfo.x, size.x + camInfo.x);
    float y = map1(texcoord.y , 0.0, 1.0, -size.y + camInfo.y, size.y + camInfo.y);

    vec3 pos = vec3(x , y , 0.0);
    float density = calculateDensity(pos);
   
    fragColor = vec4( vec3(density) , 1.0);
  
}