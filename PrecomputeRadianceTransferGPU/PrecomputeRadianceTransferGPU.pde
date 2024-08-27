import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;


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
static float GH_MOUSE_SENSITIVITY = 0.005f;
static float GH_MOUSE_SMOOTH = 0.25f;
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

boolean[] key_input={false, false, false, false};

Camera main_camera;
Light main_light;


PhongMaterial lightMaterial1;
PhongMaterial phongMaterial1;
Skybox skyboxMaterial;
PRTMaterial prtMaterial1;
Quad skybox;
PRTObject pekora;

Texture mary_texture;
Texture floor_texture;
Texture pekora_texture;

Sampler sampler;

PJOGL pgl;
GL2ES2 gl;

float a = PI/4 + 0.2;
int shCof = 4;
int sample_number = 100;
float INV_PI = 1.0 / PI * 2;

void setup() {
    background(0);
    size(800, 800, P3D);
    
    pgl = (PJOGL) beginPGL();  
    gl = pgl.gl.getGL2ES2();
    
    sampler = new Sampler(sample_number,shCof);

    setMaterial();
    cameraSetting();
    lightSetting();
    initSetting();

}




void draw() {

    background(0);
    //lights();
    main_light.setPos(200*cos(a*3), 100 + 50*sin(a*2), 200*sin(a*5));
    main_light.setLightdirection(main_light.pos.mult(-1).unit_vector());
    a+=0.003;


    move();
    render();
    

    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

IntBuffer allocateDirectIntBuffer(int n) {
  return ByteBuffer.allocateDirect(n * Integer.BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
}

void render() {
    skybox.draw();
    main_light.draw();
    pekora.draw();
    
}

public void initSetting() {

    setGameObject();
}

void setGameObject() {
    skybox = new Quad("Meshes/quad.obj", skyboxMaterial);
    pekora = new PRTObject("Meshes/pekora.obj",prtMaterial1);
    pekora.setScale(50,50,50);
}

void setMaterial() {

    floor_texture = new Texture("Textures/Floor.png");
    lightMaterial1 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    lightMaterial1.setAlbedo(0.9, 0.9, 0.9).setTexture(floor_texture);

    skyboxMaterial = new Skybox("Shaders/skybox.frag", "Shaders/skybox.vert");
    skyboxMaterial.setSkycube("Textures/CornellBox");
    
    pekora_texture = new Texture("Textures/Atlas_33922.png");
    phongMaterial1 = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial1.setAlbedo(0.9, 0.9, 0.9);//.setTexture(pekora_texture);
    
    prtMaterial1 = new PRTMaterial("Shaders/preconputetransform.frag", "Shaders/preconputetransform.vert");

    skyboxMaterial.precomputeSphereHarmonicParameter(shCof);

    //saveCof(cof);
   
    
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPos(0.0, 20.0, 100);
    main_camera.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
}

public void lightSetting() {
    main_light = new Light(new Vector3(0, 0, 0), new Vector3(200 * cos(a), 50, 200 * sin(a)), new Vector3(0.8) , "Meshes/cube.obj",lightMaterial1);
    main_light.setScale(2, 2, 2);
}

void saveCof(Vector3[] cof) {
    String[] s = new String[cof.length];
    for (int i = 0; i < s.length; i++) {
        s[i] = cof[i].x + " " + cof[i].y + " " + cof[i].z;
    }
    saveStrings("church" +shCof+".txt", s);
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
    if (mousePressed) {
        if (mouseButton == RIGHT) {
            float dx = (pmouseX - mouseX) * GH_MOUSE_SENSITIVITY;
            float dy = (pmouseY - mouseY) * GH_MOUSE_SENSITIVITY;
            main_camera.eular.set(main_camera.eular.x + dy, main_camera.eular.y + dx, 0.0);
        }
    }

    Vector3 forward = main_camera.localToWorld().mult(new Vector3(0, 0, -1));
    Vector3 right = main_camera.localToWorld().mult(new Vector3(1, 0, 0));

    float wx = key_input[3] ? 1.0 * GH_WALK_SPEED : key_input[1] ? -1.0 * GH_WALK_SPEED : 0.0;
    float wz = key_input[0] ? 1.0 * GH_WALK_SPEED : key_input[2] ? -1.0 * GH_WALK_SPEED: 0.0;

    Vector3 mv = forward.mult(wz).add(right.mult(wx));
    main_camera.pos = main_camera.pos.add(mv);

    main_camera.update();
}
