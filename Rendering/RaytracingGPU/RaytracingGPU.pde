PShader rayTracing;

void setup(){
    size(900,900,P2D);
    noStroke();
    rayTracing = loadShader("raytracing.glsl");
    rayTracing.set("resolution", float(width), float(height));   

    rayTracing.set("rbias", random(1)*100000); 
    rayTracing.set("camPosition", 0.0,0.0,-10.0);   
    shader(rayTracing); 
    
    rect(0, 0, width, height);
}

//void draw(){
//    background(0);
//    rayTracing.set("rbias", random(1)*100000); 

//    shader(rayTracing); 
    
//    rect(0, 0, width, height);
//}
