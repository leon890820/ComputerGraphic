#version 440
#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926

uniform sampler2D tex;
uniform sampler2D densityTex;
uniform vec4 camInfo;
uniform vec2 boundary;
in vec2 texcoord;

uniform float kernelRadius;
uniform float targetDensity;
uniform float pressureMutiplyer;

layout (std430,binding = 0) buffer SSBO_Fluid{
    vec3 fluids[];
};

layout(location = 0) out vec4 fragColor;

float map1(float n,float x1,float x2,float y1,float y2){
    return (n - x1) * (y2 - y1) / (x2 - x1) + y1;
}

bool outOfBoundary(float x, float y){
    vec2 halfBoundary = boundary * 0.5;
    if(abs(x) > halfBoundary.x  + 0.1 || abs(y) > halfBoundary.y  + 0.1) return true;
    return false;
}

float exampleFunction(vec3 pos){
    return cos(pos.y - 3 + sin(pos.x));
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


float calculateProperty(vec3 pos){
    float property = 0.0;
    float mass = 1.0;
    vec2 size = vec2(tan(camInfo.w) * camInfo.z) ;
    for(int i = 0; i < fluids.length(); i++){
        float dst = sqrt(dot(pos - fluids[i] , pos - fluids[i]));
        float influence = smoothingKernel(kernelRadius,dst);
        float x = map1(fluids[i].x ,  -size.x + camInfo.x, size.x + camInfo.x,0.0, 1.0);
        float y = map1(fluids[i].y ,  -size.y + camInfo.y, size.y + camInfo.y,0.0, 1.0);
        float density = texture(densityTex,vec2(x,y)).x;
        property += exampleFunction(pos)* mass / density * influence;
    }       
    return property;
}

float getDensity(vec2 pos){
    vec2 size = vec2(tan(camInfo.w) * camInfo.z) ;
    float x = map1(pos.x ,  -size.x + camInfo.x, size.x + camInfo.x,0.0, 1.0);
    float y = map1(pos.y ,  -size.y + camInfo.y, size.y + camInfo.y,0.0, 1.0);   
    return texture(densityTex,vec2(x,y)).x;
}

vec2 calculatePropertyGradient(vec3 pos){
    vec2 propertyGradient = vec2(0.0);
    float mass = 1.0;
    for(int i = 0; i < fluids.length(); i++){
        float dst = sqrt(dot(pos - fluids[i] , pos - fluids[i]));
        float slope = smoothingKernelDerivative(kernelRadius,dst);
        float density = getDensity(fluids[i].xy);
        vec2 dir = (pos.xy - fluids[i].xy) / dst;
        propertyGradient += exampleFunction(pos) * dir * slope * mass / density;
    }       
    return propertyGradient;
}

float convertDensityToPressure(float density){
    float densityError = density - targetDensity;
    float pressure = densityError ;
    return pressure;
}

void main() {  
    vec2 size = vec2(tan(camInfo.w) * camInfo.z) ;
    float x = map1(texcoord.x , 0.0, 1.0, -size.x + camInfo.x, size.x + camInfo.x);
    float y = map1(texcoord.y , 0.0, 1.0, -size.y + camInfo.y, size.y + camInfo.y);

    vec3 pos = vec3(x , y , 0.0);
    
    float ep = calculateProperty(pos);
    vec2 gradient = calculatePropertyGradient(pos);
    vec4 color = texture(tex , texcoord);
    vec4 fcolor = vec4(color.rgb * color.a , 0.0);

    float density = texture(densityTex, texcoord).x;
    float pressure = convertDensityToPressure(density);
          

    //if(!outOfBoundary(x,y)) fragColor = vec4( gradient, 0.0 , 1.0);
    //else fragColor = vec4(0.0,0.0,0.0,1.0);

    if(!outOfBoundary(x,y)){
        if(pressure > 0.2) fragColor = fcolor + vec4(0.83,0.29,0.20,1.0);
        else if(pressure < -0.2) fragColor = fcolor + vec4( 0.1,0.53,0.68,1.0);
        else fragColor = fcolor + vec4(0.9,0.9,0.9,1.0);
    }
}