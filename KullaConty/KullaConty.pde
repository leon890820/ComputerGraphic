//Graphics
static boolean GH_START_FULLSCREEN = false;
static boolean GH_HIDE_MOUSE = true;
static boolean GH_USE_SKY = true;
static int GH_SCREEN_WIDTH = 1280;
static int GH_SCREEN_HEIGHT = 720;
static int GH_SCREEN_X = 50;
static int GH_SCREEN_Y = 50;
static float GH_FOV = 45.0f;
static float GH_NEAR_MIN = 1e-3f;
static float GH_NEAR_MAX = 1e-1f;
static float GH_FAR = 1000.0f;
static float GH_MIN_CLIPPING=0.1f;
static int GH_FBO_SIZE = 2048;
static int GH_MAX_RECURSION = 4;
float INV_PI = 1/PI;
float INV_TWO_PI = 1/TWO_PI;

//Gameplay
static float GH_MOUSE_SENSITIVITY = 0.01f;
static float GH_MOUSE_SMOOTH = 0.5f;
static float GH_WALK_SPEED = 1.7f;
static float GH_WALK_ACCEL = 50.0f;
static float GH_BOB_FREQ = 8.0f;
static float GH_BOB_OFFS = 0.015f;
static float GH_BOB_DAMP = 0.08f;
static float GH_BOB_MIN = 0.1f;
static float GH_DT = 0.01f;
static int GH_MAX_STEPS = 30;
static float GH_PLAYER_HEIGHT = 1.5f;
static float GH_PLAYER_RADIUS = 0.2f;
static float GH_GRAVITY = 0;//-9.8f;

static Vector3 AMBIENT_LIGHT=new Vector3(0.5, 0.5, 0.5);

boolean[] key_input={false, false, false, false};
Engine engine;
Camera main_cam;
float[] zBuffer;
int[] colorBuffer;
float rx, ry;
float px, py;
Light light;
float angle = -PI/4;
Vector3 pos = new Vector3(0,2,-5);

void setup() {
    size(1000, 1000);
    background(0);
    light=new Light(new Vector3(5, 5, -5), new Vector3(0, 0, 0), new Vector3(1, 1, 1));
    //light=new Light(new Vector3(-5,-5,5),new Vector3(1,1,-1),new Vector3(1,1,1));
    engine=new Engine();
    main_cam=new Camera();    
    initZBuffer();


}



void draw() {
    //angle+=0.1;

    //light=new Light(new Vector3(10*cos(angle),-5,10*sin(angle)),new Vector3(-cos(angle),1,-sin(angle)),new Vector3(1,1,1));

    GH_DT=1/frameRate;
    initZBuffer();
    setSky();    
    
    rx+=map(mouseX-pmouseX,0,10,0,0.1);
    ry+=map(mouseY-pmouseY,0,10,0,0.1);
  
     //main_cam.setPositionOrientation(new Vector3(5,5,5),ry,rx);
    // main_cam.setSize(width,height,0.1,GH_FAR);
    //println(ry,rx);
    engine.run();

    drawBuffer();
    //drawDepthBuffer();
    
    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
    //noLoop();
}



void keyPressed() {
    if (key=='W'||key=='w') {
        key_input[0]=true;
        //pos = pos.add(new Vector3(0,0.1,0));
    }
    if (key=='A'||key=='a') {
        key_input[1]=true;
    }
    if (key=='S'||key=='s') {
        key_input[2]=true;
       // pos = pos.add(new Vector3(0,-0.1,0));
    }
    if (key=='D'||key=='d') {
        key_input[3]=true;
    }
}

void keyReleased() {
    if (key=='W'||key=='w') {
        key_input[0]=false;
    }
    if (key=='A'||key=='a') {
        key_input[1]=false;
    }
    if (key=='S'||key=='s') {
        key_input[2]=false;
    }
    if (key=='D'||key=='d') {
        key_input[3]=false;
    }
}


Vector3 map(Vector3 v, float x0, float x1, float y0, float y1) {
    float x=map(v.x, x0, x1, y0, y1);
    float y=map(v.y, x0, x1, y0, y1);
    float z=map(v.z, x0, x1, y0, y1);
    return new Vector3(x, y, z);
}

void drawBuffer() {
    loadPixels();
    for (int i=0; i<pixels.length; i+=1) {
        pixels[i]=colorBuffer[i];
    }
    updatePixels();
}




void initZBuffer() {
    zBuffer=new float[width*height];
    colorBuffer=new int[width*height];    
    for (int i=0; i<zBuffer.length; i+=1) {
        zBuffer[i]=1.0/0.0;        
        colorBuffer[i]=0;
    }
}





void setSky() {
    for (int j=0; j<height; j+=1) {
        for (int i=0; i<width; i+=1) {
            int index=j*width+i;
            float t=map(j, 0, height, 1, 0);
            Vector3 c=new Vector3(1, 1, 1).mult(1-t).add(new Vector3(0.5, 0.7, 1).mult(t));
            colorBuffer[index]=color(c.x*255, c.y*255, c.z*255);
        }
    }
}
