#version 440
#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926

uniform vec3 camPos;
uniform mat4 invProject;
uniform mat4 camToWorld;
uniform vec2 resolution;
uniform float rbias;
uniform sampler2D lastFrame;
uniform sampler2D earth;
uniform bool dark;
in vec2 texcoord;

layout(location = 0) out vec4 fragColor;

vec2 ranIndex;

float Rand1(inout float p) {
  p = fract(p * .1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

vec2 Rand2(inout float p) {
  return vec2(Rand1(p), Rand1(p));
}

vec3 Rand3(vec3 p) {
  return vec3(Rand1(p.x), Rand1(p.y),Rand1(p.z));
}

float InitRand(vec2 uv) {
  vec3 p3  = fract(vec3(uv.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}


float Random1DTo1D(float value,float a,float b){
	//make value more random by making it bigger
	float random = fract(sin(value+b)*a);
        return random;
}



vec3 Random1DTo3D(float value){
    return vec3(
        Random1DTo1D(value,14375.5964,0.546),
        Random1DTo1D(value,18694.2233,0.153),
        Random1DTo1D(value,19663.6565,0.327)
    );
}

float Random3DTo1D(vec3 value,float a,vec3 b)
{			
	vec3 smallValue = sin(value);
	float  random = dot(smallValue,b);
	random = fract(sin(random) * a);
	return random;
}


vec3 Random3DTo3D(vec3 value){
	return vec3(
		Random3DTo1D(value,14375.5964, vec3(15.637,76.243,37.168)),
		Random3DTo1D(value,14684.6034,vec3(45.366, 23.168,65.918)),
		Random3DTo1D(value,17635.1739,vec3(62.654, 88.467,25.111))
	);
}

float random(float x)
{
    float y = fract(sin(x)*100000.0);
    return y;
}
float rand(float co){
    return fract(sin( (co)*12.9898 * 43758.5453));
}

vec3 random(vec3 v){
   return Random3DTo3D(v);
}


vec3 randomValueNormalDistribution(vec3 co){
    float phi = 2 * 3.1415926 * Random3DTo1D(co , 5.210 , vec3(48.366, 21.168,45.918));
    float theta = acos(Random3DTo1D(co , 2.51451 , vec3(12.657,53.243,27.178)) * 2.0 - 1.0);
    return vec3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
}



vec3 randomOnHemisphere(vec3 co,vec3 noraml){
    vec3 rd = randomValueNormalDistribution(co.yyz * co.yxz);
    if( dot(rd , noraml) > 0.0) return rd;
    else return -rd;
}




float map1(float n,float x1,float x2,float y1,float y2){

    return (n - x1) * (y2 - y1) / (x2 - x1) + y1;
}

float lerp(float f1,float f2,float t){
    return f1 * (1 - t) + f2 * t;
}

vec3 lerp(vec3 c1,vec3 c2,float t){
    return vec3(lerp(c1.x, c2.x, t), lerp(c1.y, c2.y, t), lerp(c1.z, c2.z, t));
}

vec2 get_sphere_uv(vec3 p){
    float theta = acos(-p.y);
    float phi = atan(-p.z, p.x) + PI;
    return vec2(phi / (2.0 * PI) , 1.0 - theta / PI);
}



struct Ray{
    vec3 origin;
    vec3 dir;
    vec3 at(float t){
        return origin + dir * t;
    }
};




struct Material{
    // type 0 : lambertian
    // type 1 : metal
    float type;
    vec3 albedo;    
    float fuzz;
    float refraction_index;
};


struct HitRecord{
    vec3 pos;
    vec3 normal;
    vec3 albedo;
    vec2 uv;
    Material mat;
    float t;
    bool front_face;
    void set_face_normal(Ray r, vec3 outward_normal) {
        front_face = dot(r.dir, outward_normal) < 0;
        normal = front_face ? outward_normal : -outward_normal;
    }
};

struct Triangle{
    vec3 T0;
    vec3 T1;
    vec3 T2;
    Material mat;
};

struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};


layout (std430,binding = 0) buffer SSBO_TriangleData{
    Triangle triangle[];
};


layout (std430,binding = 1) buffer SSBO_SphereData{
    Sphere sphere[];
};




vec3 reflect(vec3 v, vec3 n) {
    return v - 2*dot(v,n)*n;
}

vec3 refract(vec3 uv, vec3 n, float etai_over_etat) {
    float cos_theta = min(dot(-uv, n), 1.0);
    vec3 r_out_perp =  etai_over_etat * (uv + cos_theta*n);
    vec3 r_out_parallel = -sqrt(abs(1.0 - dot(r_out_perp,r_out_perp))) * n;
    return r_out_perp + r_out_parallel;
}

float reflectance(float cosine, float refraction_index) {
    // Use Schlick's approximation for reflectance.
    float r0 = (1.0 - refraction_index) / (1.0 + refraction_index);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * pow((1 - cosine) , 5);
}

bool scatter(inout Ray ray ,inout HitRecord record){
    if(record.mat.type < 0.5){
        vec3 dir = randomOnHemisphere( record.pos * 6.16541 + record.normal * 0.3245 * (rbias + 1.51), record.normal);
        record.albedo = record.mat.albedo;
        ray = Ray(record.pos , dir);
        return true;
    }else if(record.mat.type < 1.5){
        vec3 dir = reflect(ray.dir , record.normal) + randomValueNormalDistribution(record.pos * 6.16541 + record.normal * 0.3245 * (rbias + 1.51)) * record.mat.fuzz;
        ray = Ray(record.pos , dir);
        record.albedo = record.mat.albedo;
        return dot(dir, record.normal) > 0.0;
    }else if(record.mat.type < 2.5){
        record.albedo = vec3(1.0, 1.0, 1.0);
        float ri = record.front_face ? (1.0 / record.mat.refraction_index) : record.mat.refraction_index;
        vec3 unit_direction = normalize(ray.dir);
        float cos_theta = min(dot(-unit_direction, record.normal), 1.0);
        float sin_theta = sqrt(1.0 - cos_theta * cos_theta);

        bool cannot_refract = ri * sin_theta > 1.0;
        vec3 direction;
        if (cannot_refract || reflectance(cos_theta, ri) > random(rbias * 5.621 + 10)) direction = reflect(unit_direction, record.normal);
        else direction = refract(unit_direction, record.normal, ri);
        ray = Ray(record.pos, direction);
        return true;

    }else if(record.mat.type < 3.5){
        record.albedo =  record.mat.albedo;
        return false;
    }
    return false;
}




vec3 backroundColor(vec3 dir){
    float t = map1(dir.y, -1.0 , 1.0, 0.0, 1.0);
    t = clamp(t , 0.0 , 1.0);
    if(!dark)return lerp(vec3(1.0,1.0,1.0),vec3(0.5,0.7,1.0),t);
    return vec3(0.0);
}

bool rayTriangle(Ray ray, Triangle tri,float min_r, float max_r,inout HitRecord record){
    vec3 e1 = tri.T1 - tri.T0;
    vec3 e2 = tri.T2 - tri.T0;
    vec3 s = ray.origin - tri.T0;
    vec3 s1 = cross(ray.dir , e2);
    vec3 s2 = cross(s , e1);

    float se = dot(s1,e1);
    float t = dot(s2 , e2) / se;
    if( t < min_r || t > max_r) return false;
    float b1 = dot(s1, s) / se;
    float b2 = dot(s2, ray.dir) / se;
    float b0 = 1 - b1 - b2;
    if(b1 < 0.0 || b1 > 1.0 || b2 < 0.0 || b2 > 1.0 || b0 < 0.0 || b1 > 1.0) return false;
    record.pos = ray.at(t);
    record.t = t;
    vec3 normal = cross(e1, e2);
    record.set_face_normal(ray , normal);   
    record.mat = tri.mat;
    
    return true;

}

bool raySphere(Ray ray, Sphere s,float min_r, float max_r,inout HitRecord record){
    vec3 oc = ray.origin - s.center;
    float a = dot(ray.dir, ray.dir);
    float b = 2 * dot(ray.dir, oc);
    float c = dot(oc, oc) - s.radius * s.radius;
    float d = b * b - 4 * a * c;
    if(d > 0.0 ) {
        float t1 = (-b - sqrt(d)) / (2 * a) ;
        float t2 = (-b + sqrt(d)) / (2 * a) ;
        if(t1 > max_r || t2 < min_r) return false;
        vec3 pos = t1 < 0 ? ray.at(t2) :  ray.at(t1);
        record.pos = pos;
        record.t = t1 < 0 ? t2 : t1;
        vec3 normal = normalize(pos - s.center);   
        record.set_face_normal(ray , normal);    
        record.mat = s.mat;       
        record.uv = get_sphere_uv(record.normal);
        return true;
    }

    return false;
}


vec3 rayColor(Ray ray, inout HitRecord record){ 
    vec3 color = vec3(1.0);
    int MAX_DEPTH = 10;
    for(int k = 0; k < MAX_DEPTH; k++){
        if(k == MAX_DEPTH - 1){
            color *= vec3(0.0);
            break;
        }
        float min_drecord = 100000.0;
        record.t = 0.0;
        for(int i = 0; i < sphere.length(); i++){
            if(raySphere(ray , sphere[i] , 0.001 , min_drecord , record)) {
                min_drecord = record.t;
            }
        }
        for(int i = 0; i < triangle.length(); i++){
            if(rayTriangle(ray , triangle[i] , 0.001 , min_drecord , record)){
                min_drecord = record.t;
            }
        }
        if(record.t > 0) {        
            if(scatter(ray , record)){
                color *= record.albedo;
            }else{
                color *= record.albedo;
                break;
            }
        }else{
            color *= backroundColor(ray.dir);
            break;
        }
    } 
    return color;
}


vec3 getSampleViewVector(){
    
    float ran = random((rbias + 1) * texcoord.x * texcoord.y + texcoord.y * 5.5121);
    vec2 coord = texcoord + ran / resolution;
    vec4 viewV = invProject * vec4(coord * 2.0 - 1.0 , 0.0 , 1.0);
    return (camToWorld * vec4(viewV.xyz,0.0)).xyz;
}


void main() {  
    int sampleNum = 1;
    
    HitRecord record;
    
    //setScence(2);
    vec3 lastColor = texture(lastFrame , texcoord).rgb;

    vec3 color = vec3(0.0);
    for(int i = 0; i < sampleNum; i++){
        vec3 viewVector = getSampleViewVector();
        vec3 rayDir = normalize(viewVector);
        Ray camRay = Ray(camPos , rayDir);
        color += rayColor(camRay , record);
    }
    color /= sampleNum;
    color = (color + lastColor * rbias) / (rbias + 1);



    fragColor = vec4(color , 1.0);

  
}