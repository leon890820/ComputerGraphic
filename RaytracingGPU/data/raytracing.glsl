#ifdef GL_ES
precision highp float;
#endif

// Type of shader expected by Processing
#define PROCESSING_COLOR_SHADER

// Processing specific input
uniform float time;
uniform vec2 resolution;
uniform vec3 camPosition;
uniform float rbias;



// Layer between Processing and Shadertoy uniforms
vec3 iResolution = vec3(resolution,0.0);
uint pixelIndex = uint(gl_FragCoord.y * iResolution.x + gl_FragCoord.x) + int(rbias);


struct Material{
    vec3 color;
};

struct Ray{
    vec3 origin;
    vec3 dir;
};

struct Sphere{
    vec3 center;
    float radius;
    vec3 color;
};

struct HitRecord{
    vec3 hit_point;
    vec3 hit_normal;
    vec3 hit_color;
    float t;
};


Sphere sphere[2];

float random(inout uint state){
    state = state * 747796405 + 2891336453;
    uint result = ((state >> ((state >> 28) + 4)) ^ state) * 277803737;
    result = (result >> 22) ^ result;
    return result / 4294967295.0;

}



float randomValueNormalDistribution(inout uint state){
    float theta = 2 * 3.1415926 * random(state);
    float rho = sqrt( -2 * log(random(state)));
    return rho * cos(theta);
}

vec3 randomDirection(inout uint state){
    float x = randomValueNormalDistribution(state);
    float y = randomValueNormalDistribution(state);
    float z = randomValueNormalDistribution(state);
    return normalize(vec3(x,y,z));
}

vec3 randomOnHemisphere(inout uint state,vec3 noraml){
    vec3 rd = randomDirection(state);
    if( dot(rd,noraml) > 0.0) return rd;
    else return -rd;
}

float map1(float n,float x1,float x2,float y1,float y2){

    return (n - x1) * (y2 - y1) / (x2 - x1) + y1;
}

float lerp(float f1,float f2,float t){
    return f1 * (1 - t) + f2 * t;
}

vec3 lerp(vec3 c1,vec3 c2,float t){
    return vec3(lerp(c1.x,c2.x,t), lerp(c1.y,c2.y,t), lerp(c1.z,c2.z,t));
}

vec3 set_face_normal(Ray r,vec3 n){
    bool front_face = dot(r.dir,n) < 0;
    return front_face? n : -n;

}


bool hitSphere(Ray r,Sphere s,float min_r,float max_r,inout HitRecord rec){
    vec3 oc = r.origin - s.center;
    float a = dot(r.dir,r.dir);
    float b = 2 * dot(r.dir,oc);
    float c = dot(oc,oc) - s.radius*s.radius;
    if(b*b-4*a*c > 0.0 ) {
        float t = (-b + sqrt(b*b - 4*a*c)) / 2*a;
        if(t < min_r || t > max_r) return false;
        rec.hit_point = r.origin + r.dir * t;
        rec.hit_normal =  normalize(rec.hit_point - s.center);
        rec.hit_color = s.color;
        rec.t = t;
        return true;
    }
    
    return false;
}

vec3 reflectr(vec3 v, vec3 n) {
    return v - 2*dot(v,n)*n;
}

void setScence(){
    Sphere s1 = Sphere(vec3(0.0,2.5,1.0),2.5,vec3(1.0,0.2,0.0));
    Sphere s2 = Sphere(vec3(0.0,-2.5,1.0),2.5,vec3(0.0,1.0,0.2));
    sphere[0] = s1;
    sphere[1] = s2;
}

vec3 rayColor(Ray ray){

    HitRecord rec;
    bool hit_anything = false;
    float mr = 100000000;
    int MAX_DEPTH = 10;
    vec3 final_color = vec3(1.0);
    float t = map1(ray.dir.y,-1,1,0,1);

    for(int k = 0 ; k < MAX_DEPTH; k++){

        hit_anything = false;
        mr = 100000000;
        //rec.t = mr;

        for(int i=0;i<2;i++){
            if(hitSphere(ray,sphere[i],0.001,mr,rec)){
                hit_anything = true;
                mr = rec.t;
            }
        }
        if(hit_anything){
            vec3 rd = rec.hit_point + rec.hit_normal + randomDirection(pixelIndex);
            vec3 r = reflectr( -ray.dir,rec.hit_normal);
            ray = Ray(rec.hit_point,r);
            final_color *= rec.hit_color;
        }else{
            
            final_color *= lerp(vec3(1.0,1.0,1.0),vec3(0.5,0.7,1.0),t);
            break;
        }
        

    }

    return final_color;//hit_anything == false ? vec3(1.0) : vec3(0.0);

}

void main(void)
{
    vec2 xy = -1 + 2 * gl_FragCoord.xy / iResolution.xy;
    int sampleCount = 100 ;
    //uint pixelIndex = uint(gl_FragCoord.y * iResolution.x + gl_FragCoord.x) + int(rbias);
    vec3 viewDir = vec3(xy,-9) - camPosition;


    setScence();

    vec3 color = vec3(0.0);
    for(int i = 0; i < sampleCount; i++){
        vec3 sample_square = vec3((random(pixelIndex) - 0.5) / iResolution.x, (random(pixelIndex) - 0.5) / iResolution.y,0.0);
        Ray camRay = Ray(camPosition,normalize(viewDir + sample_square));        
        color += rayColor(camRay);
    }
    color /= sampleCount;
    gl_FragColor = vec4(color,1.0);
	//else gl_FragColor=vec4(lerp(color1,color2,t),1.0);
}
