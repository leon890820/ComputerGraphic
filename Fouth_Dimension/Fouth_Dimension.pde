Camera cam;

void setup(){
    cam = new Camera(new Vector4(-12,1,0,0));
    cam.lookAt(new Vector4(0,0,0,0));
    println(cam.oriented);
    println(cam.oriented[0].dot(cam.oriented[1]));
    println(cam.oriented[0].dot(cam.oriented[2]));
    println(cam.oriented[0].dot(cam.oriented[3]));
    println(cam.oriented[1].dot(cam.oriented[2]));
    println(cam.oriented[1].dot(cam.oriented[3]));
    println(cam.oriented[2].dot(cam.oriented[3]));
    
}
