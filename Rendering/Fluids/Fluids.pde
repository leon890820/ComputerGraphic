import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;
import com.jogamp.opengl.GL3;


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

//Gameplay
static float GH_MOUSE_SENSITIVITY = 0.01f;
static float GH_MOUSE_SMOOTH = 0.5f;
static float GH_WALK_SPEED = 0.08f;
static float GH_WALK_ACCEL = 50.0f;
static float GH_BOB_FREQ = 8.0f;
static float GH_BOB_OFFS = 0.015f;
static float GH_BOB_DAMP = 0.08f;
static float GH_BOB_MIN = 0.1f;
static float GH_DT = 0.01f;
static int GH_MAX_STEPS = 30;
static float GH_PLAYER_HEIGHT = 1.5f;
static float GH_PLAYER_RADIUS = 0.2f;
static float GH_GRAVITY = -0.0f;
static Vector3 AMBIENT_LIGHT = new Vector3(0.3, 0.3, 0.3);

boolean[] key_input={false, false, false, false};

Camera main_camera;
Light main_light;

FBO fluidTarget;
Icosahedron[] fluids;
PhongMaterial phongMaterial;

FBO densityTarget;
Quad densityScene;
DensityMaterial densityMaterial;

Quad propertyScene;
PropertyMaterial propertyMaterial;

SSBO fluid_data;


PJOGL pgl;
GL2ES2 gl;
GL3 gl3;


int fluid_num = 16;
float a = -PI/4;
float time = 0.0;
float dt;
float damp = 0.95;
float kernelRadius = 0.5;
float pressureMutiplyer = 80.0;
float targetDensity = 10.0;

Vector3 boundSize = new Vector3(20, 10, 0);
Boundary boundary;

void setup() {
    size(900, 900, P3D);
    //randomSeed(0);

    pgl = (PJOGL) beginPGL();
    gl = pgl.gl.getGL2ES2();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();

    lightSetting();
    cameraSetting();
    setMaterial();
    initSetting();

    dt = 1.0/60.0;
}


void draw() {

    move();
    background(0);
    //gl3.glClearColor(0.0,0.0,0.0,0.0);
   // fluidTarget.bindFrameBuffer();
    main_light.setLightdirection(200 * cos(a), -200, 200 * sin(a) );
    for (Icosahedron fluid : fluids) {
        fluid.velosity = fluid.velosity.add(new Vector3(0,GH_GRAVITY,0).mult(dt));
        fluid.density = fluid.calculateDensity();
    }
    for (Icosahedron fluid : fluids) {
        fluid.force = fluid.calculatePressureForce();
    }
    for (Icosahedron fluid : fluids) {
        fluid.run();
    }
    
    
    boundary.debugRun();
    //gl3.glClearColor(0.0,0.0,0.0,1.0);
    
    //densityTarget.bindFrameBuffer();
    //densityMaterial.setCamPos(main_camera.transform.position);
    //densityScene.run();
    
    //gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);        
    //background(0);
    //propertyMaterial.setCamPos(main_camera.transform.position);
    //propertyScene.run();
    
    //fluid_data.updateData(getFluidData());

    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}

public float[] getFluidData(){
    FloatList data = new FloatList();
    
    for (Icosahedron fluid : fluids) {
        data.append(fluid.transform.position.x); data.append(fluid.transform.position.y);
        data.append(fluid.transform.position.z); data.append(0.0);
    }
        
    return data.toArray();
}

public void initSetting() {
    setGameObject();
}

void setGameObject() {
   
     
    fluids = new Icosahedron[(fluid_num * 2 + 1) * (fluid_num * 2 + 1)];
    int count = 0;
    for (int y = -fluid_num; y <= fluid_num; y++) {
        for (int x = -fluid_num; x <= fluid_num; x++) {
            fluids[count] = new Icosahedron(phongMaterial, 0.1, 5);
            fluids[count++].setPosition(x * 0.2,y * 0.2, 0);
        }
    }
    boundary = new Boundary(boundSize.mult(0.5), phongMaterial);
    
    fluid_data = new SSBO(0 , densityMaterial , getFluidData());
    densityScene = new Quad(densityMaterial);

    propertyScene = new Quad(propertyMaterial);
}

void setMaterial() {
    fluidTarget = new FBO(width,height,1,gl3.GL_LINEAR);

    phongMaterial = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial.setAlbedo(0.9, 0.9, 0.9);   
    
    densityTarget = new FBO(width,height,1,gl3.GL_LINEAR);
    densityMaterial = new DensityMaterial("Shaders/density.frag", "Shaders/density.vert");
    
    propertyMaterial = new PropertyMaterial("Shaders/quad.frag", "Shaders/quad.vert");
    propertyMaterial.setTexture(fluidTarget.tex[0]).setDensityTexture(densityTarget.tex[0]);
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(0.0, 0.0, 20.0).setEular(-0.0, 0.0, 0.0);
    main_camera.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
}

public void lightSetting() {
    main_light = new Light(new Vector3(0, 0, 0), new Vector3(-200 * cos(a), 500, -200 * sin(a)), new Vector3(0.8));
    main_light.setScale(2, 2, 2);
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
    if (key=='J'||key=='j') {
        kernelRadius += 0.1;
    }
    if (key=='K'||key=='k') {
        kernelRadius -= 0.1;
    }
    
    if (key=='U'||key=='u') {
        pressureMutiplyer += 5.0;
    }
    if (key=='I'||key=='i') {
        pressureMutiplyer -= 5.0;
    }
    
    if (key=='L'||key=='l') {
        GH_GRAVITY -= 5.0;
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
    if (mousePressed && false) {
        if (mouseButton == RIGHT) {
            float dx = (pmouseX - mouseX) * GH_MOUSE_SENSITIVITY;
            float dy = (pmouseY - mouseY) * GH_MOUSE_SENSITIVITY;
            main_camera.transform.eular.set(main_camera.transform.eular.x + dy, main_camera.transform.eular.y + dx, 0.0);
        }
    }

    Vector3 forward = main_camera.localToWorld().mult(new Vector3(0, 0, -1));
    Vector3 right = main_camera.localToWorld().mult(new Vector3(1, 0, 0));

    float wx = key_input[3] ? 1.0 * GH_WALK_SPEED : key_input[1] ? -1.0 * GH_WALK_SPEED : 0.0;
    float wz = key_input[0] ? 1.0 * GH_WALK_SPEED : key_input[2] ? -1.0 * GH_WALK_SPEED: 0.0;

    Vector3 mv = forward.mult(wz).add(right.mult(wx));
    main_camera.transform.position = main_camera.transform.position.add(mv);

    main_camera.update();
}
