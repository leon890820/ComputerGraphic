import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import java.util.LinkedHashMap;

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
static float GH_FOV = 30.0f;
static float GH_NEAR_MIN = 1e-3f;
static float GH_NEAR_MAX = 1e-1f;
static float GH_FAR = 10000.0f;
static float GH_MIN_CLIPPING=0.1f;
static int GH_FBO_SIZE = 2048;
static int GH_MAX_RECURSION = 4;

//Gameplay
static float GH_MOUSE_SENSITIVITY = 0.005f;
static float GH_MOUSE_SMOOTH = 0.5f;
static float GH_WALK_SPEED = 1.0f;
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

GBufferMaterial gBufferMaterial;
RSMBufferMaterial rsmBufferMaterial;
PhongObject sponza;

PJOGL pgl;
GL2ES2 gl;
GL3 gl3;

QuadMaterial quadMaterial;
Quad quad;

FBO GBuffer;
FBO RSMBuffer;

float a = -PI/4;
float time = 0.0;

void setup() {
    size(900, 900, P3D);
    randomSeed(0);

    pgl = (PJOGL) beginPGL();  
    gl = pgl.gl.getGL2ES2();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();

    lightSetting();
    cameraSetting();
    setMaterial();
    initSetting();
}


void draw() {
    
    move();   
    
    GBuffer.bindFrameBuffer();
    sponza.run();
    GBuffer.unbindFrameBuffer(width,height);

    background(0);
    quad.run();
    
    main_light.setLightdirection(200 * cos(a), -100 ,200 * sin(a) );    


    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}



public void initSetting() {
    setGameObject();
}

void setGameObject() {
    sponza = new PhongObject("../../Model/sponza/Scale300Sponza", gBufferMaterial);  
    quad = new Quad(quadMaterial);
}

void setMaterial() {  
    GBuffer = new FBO(width, height, 3, gl3.GL_LINEAR);
    RSMBuffer = new FBO(width, height, 3, gl3.GL_LINEAR);
    
    gBufferMaterial = new GBufferMaterial("Shaders/GBuffer.frag", "Shaders/GBuffer.vert");
    rsmBufferMaterial = new RSMBufferMaterial("Shaders/RSMBuffer.frag", "Shaders/RSMBuffer.vert");

    
    quadMaterial = new QuadMaterial("Shaders/quad.frag", "Shaders/quad.vert");
    quadMaterial.setTexture(GBuffer.tex[0]);
    
   
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(0.0, -500, 800.0).setEular(-0.0, 0.0, 0.0);
    main_camera.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
    //main_camera.ortho(-1000,1000,-1000,1000,0.1,1000);
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
    if (mousePressed && mouseButton == RIGHT) {
        float dx = (pmouseX - mouseX) * GH_MOUSE_SENSITIVITY;
        float dy = (pmouseY - mouseY) * GH_MOUSE_SENSITIVITY;

        Vector3 rot = main_camera.getEular();
        main_camera.setEular(rot.x + dy, rot.y + dx, 0.0);
    }

    Matrix4 camMat = main_camera.localToWorld();
    Vector3 forward = camMat.transformDirection(new Vector3(0, 0, -1));
    Vector3 right   = camMat.transformDirection(new Vector3(1, 0, 0));

    float wx = key_input[3] ? 1.0f * GH_WALK_SPEED : key_input[1] ? -1.0f * GH_WALK_SPEED : 0.0f;
    float wz = key_input[0] ? 1.0f * GH_WALK_SPEED : key_input[2] ? -1.0f * GH_WALK_SPEED : 0.0f;

    Vector3 mv = forward.mult(wz).add(right.mult(wx));
    Vector3 pos = main_camera.getPosition().add(mv);

    main_camera.setPosition(pos);
    main_camera.update();
}
