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
ShadowObject gura;

Camera main_camera;
Light main_light;

ShadowMaterial shadowMaterial;
PhongMaterial phongMaterial1;
PhongMaterial phongMaterial2;
PhongMaterial phongMaterial3;

Texture mary_texture;
Texture floor_texture;
Texture gura_texture;

FBO depth_FBO;
float a = PI/4+0.2;


void setup() {
    background(0);
    size(900, 900, P3D);

    setMaterial();
    cameraSetting();
    lightSetting();
    initSetting();
    
}

public void initSetting() {
    
    setGameObject();
    depth_FBO = new FBO(width,height);
}

void setMaterial(){
    mary_texture = new Texture("Textures/MC003_Kozakura_Mari.png");
    floor_texture = new Texture("Textures/Floor.png");
    gura_texture = new Texture("Textures/Atlas_33922.png");
    
    shadowMaterial = new ShadowMaterial("Shaders/Shadow.frag", "Shaders/Shadow.vert");
    phongMaterial1 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial1.setAlbedo(0.9, 0.9, 0.9).setTexture(floor_texture);
    phongMaterial2 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial2.setAlbedo(0.9, 0.9, 0.9).setTexture(mary_texture);
    phongMaterial3 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial3.setAlbedo(0.9, 0.9, 0.9).setTexture(gura_texture);
}

void setGameObject(){
    
    //check_texture.setWrapMode(REPEAT).setSamplingMode(2);

    mona = new ShadowObject("Meshes/Marry.obj", shadowMaterial);
    mona.setPos(10.0, -75.0, 20.0).setEular(PI/3, PI/4, -PI/5).setScale(50,50,50);
    
    
    gura = new ShadowObject("Meshes/pekora.obj", shadowMaterial);
    gura.setPos(00.0, -75.0, 0.0).setEular(0.0, 0.0, 0.0).setScale(50,50,50);

    floor = new ShadowObject("Meshes/ground.obj", shadowMaterial);
    floor.setPos(0.0, -75.0, 0.0).setScale(400, 1, 400);


}

public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPos(0.0,50.0,200);
    main_camera.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
}

public void lightSetting() {
    main_light = new Light(new Vector3(100*cos(a), 200, 100*sin(a)), new Vector3(-1.0, -1.0, -1.0), new Vector3(0.8));
    main_light.setShape("Meshes/cube.obj").setMaterial(phongMaterial1).setScale(2,2,2);
    
}

void draw() {

    background(0);
    lights();
    main_light.setPos(-200*cos(a*3), 200 + 50*sin(a*2), -200*sin(a*5));
    main_light.setLightdirection(main_light.pos.mult(-1).unit_vector());
    a+=0.003;
    
    move();
    render();
    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}

void render() {
    mona.setMaterial(shadowMaterial);
    gura.setMaterial(shadowMaterial);
    floor.setMaterial(shadowMaterial);

    //mona.draw();
    gura.draw();
    floor.draw();

    depth_FBO.bindFrameBuffer();

    phongMaterial1.setDepthTexture(depth_FBO);
    phongMaterial2.setDepthTexture(depth_FBO);
    phongMaterial3.setDepthTexture(depth_FBO);
    mona.setMaterial(phongMaterial2);
    gura.setMaterial(phongMaterial3);
    floor.setMaterial(phongMaterial1);
    
    


    //mona.draw(); 
    gura.draw();
    floor.draw();
    main_light.draw();
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
