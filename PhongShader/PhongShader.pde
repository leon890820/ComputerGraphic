static boolean GH_START_FULLSCREEN = false;
static boolean GH_HIDE_MOUSE = true;
static boolean GH_USE_SKY = true;
static int GH_SCREEN_WIDTH = 1280;
static int GH_SCREEN_HEIGHT = 720;
static int GH_SCREEN_X = 50;
static int GH_SCREEN_Y = 50;
static float GH_FOV = 30.0f;
static float GH_NEAR_MIN = 1e-3f;
static float GH_NEAR_MAX = 1e-1f;
static float GH_FAR = 1000.0f;
static float GH_MIN_CLIPPING=0.1f;
static int GH_FBO_SIZE = 2048;
static int GH_MAX_RECURSION = 4;

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
static Vector3 AMBIENT_LIGHT = new Vector3(0.3,0.3,0.3);

PhongObject mona;
Camera main_camera;
Light main_light;

void setup(){
    size(800,800,P3D);
     
    cameraSetting();
    lightSetting();
    initSetting();
 
}

public void initSetting(){
    mona = new PhongObject("Meshes/mona.obj","Shaders/BlinnPhong.frag","Shaders/BlinnPhong.vert");
    mona.setPos(0.0, -75.0, 0.0).setEular(0.0, 0.0, 0.0).setColor(0.9, 0.9, 0.9);
}

public void cameraSetting(){
    main_camera = new Camera();
    main_camera.setPositionOrientation(new Vector3(0.0,0.0,200),new Vector3(0.0));
    main_camera.setSize((float)width,(float)height, GH_NEAR_MAX, GH_FAR);
}

public void lightSetting(){
    main_light = new Light(new Vector3(0.0),new Vector3(1.0,1.0,1.0), new Vector3(0.8));
}

void draw(){
    
    background(0);
    float dirY = (mouseY / float(height) - 0.5) * 2;
    float dirX = (mouseX / float(width) - 0.5) * 2;
    lights();   
    main_light.setLightColor(0.8,0.8,0.8).setLightdirection(dirX, -dirY,1.0);   
    mona.draw();
    
}
