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
static Vector3 AMBIENT_LIGHT = new Vector3(0.3, 0.3, 0.3);

boolean[] key_input={false,false,false,false};


ShadowObject mona;
ShadowObject floor;

ShadowObject light;

Camera main_camera;
Light main_light;
ShadowMaterial shadowMaterial;
PhongMaterial phongMaterial1;
PhongMaterial phongMaterial2;

Texture mary_texture;
Texture floor_texture;

FBO depth_FBO;
float a = PI/4+0.2;


void setup() {
    background(0);
    size(800, 800, P3D);

    cameraSetting();
    lightSetting();
    initSetting();
}

public void initSetting() {
    mary_texture = new Texture("Textures/MC003_Kozakura_Mari.png");
    floor_texture = new Texture("Textures/Floor.png");
    //check_texture.setWrapMode(REPEAT).setSamplingMode(2);

    shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    phongMaterial1 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial1.setAlbedo(0.9, 0.9, 0.9).setTexture(floor_texture);
    phongMaterial2 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial2.setAlbedo(0.9, 0.9, 0.9).setTexture(mary_texture);

    mona = new ShadowObject("Meshes/Marry.obj", shadowMaterial);
    mona.setPos(0.0, -75.0, 0.0).setEular(0.0, 0.0, 0.0).setScale(50,50,50);

    floor = new ShadowObject("Meshes/ground.obj", shadowMaterial);
    floor.setPos(0.0, -75.0, 0.0).setScale(200, 1, 200);
    
    light = new ShadowObject("Meshes/cube.obj", phongMaterial1);

    depth_FBO = new FBO();
}

public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPos(0.0,50.0,200);
    main_camera.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
}

public void lightSetting() {
    main_light = new Light(new Vector3(200*cos(a), 200, 200*sin(a)), new Vector3(-1.0, -1.0, -1.0), new Vector3(0.8));
}

void draw() {

    background(0);
    //float dirY = (mouseY / float(height) - 0.5) * 2;
    //float dirX = (mouseX / float(width) - 0.5) * 2;
    lights();
    main_light.setPos(200*cos(a), 100 + 50*sin(a*2), 200*sin(a));
    main_light.setLightdirection(main_light.pos.mult(-1).unit_vector());
    a+=0.01;
    
    move();
    render();
    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}

void render() {
    mona.setMaterial(shadowMaterial);
    floor.setMaterial(shadowMaterial);


    mona.draw();
    floor.draw();

    depth_FBO.bindFrameBuffer();

    phongMaterial1.setDepthTexture(depth_FBO.tex);
    phongMaterial2.setDepthTexture(depth_FBO.tex);
    mona.setMaterial(phongMaterial2);
    floor.setMaterial(phongMaterial1);

    mona.draw();
    floor.draw();
}

void keyPressed() {
    if (key=='W'||key=='w') {
        key_input[0]=true;
    }
    if (key=='A'||key=='a') {
        key_input[1]=true;
    }
    if (key=='S'||key=='s') {
        key_input[2]=true;
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

void move() {
    if(mousePressed){
        if(mouseButton == RIGHT){
            float dx = (pmouseX - mouseX) * GH_MOUSE_SENSITIVITY;
            float dy = (pmouseY - mouseY) * GH_MOUSE_SENSITIVITY;
            main_camera.eular.set(main_camera.eular.x + dy,main_camera.eular.y + dx , 0.0);
        }
    }
    
    Vector3 forward = main_camera.localToWorld().mult(new Vector3(0,0,-1));
    Vector3 right = main_camera.localToWorld().mult(new Vector3(1,0,0));
    
    float wx = key_input[3] ? 1.0 * GH_WALK_SPEED : key_input[1] ? -1.0 * GH_WALK_SPEED : 0.0;
    float wz = key_input[0] ? 1.0 * GH_WALK_SPEED : key_input[2] ? -1.0 * GH_WALK_SPEED: 0.0;
    
    Vector3 mv = forward.mult(wz).add(right.mult(wx));
    main_camera.pos = main_camera.pos.add(mv);

    main_camera.update();
}
