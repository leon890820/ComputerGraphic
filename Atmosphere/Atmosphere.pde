import controlP5.*;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.Random;

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
static float GH_FAR = 1000.0f;
static float GH_MIN_CLIPPING=0.1f;
static int GH_FBO_SIZE = 2048;
static int GH_MAX_RECURSION = 4;

//Gameplay
static float GH_MOUSE_SENSITIVITY = 0.01f;
static float GH_MOUSE_SMOOTH = 0.5f;
static float GH_WALK_SPEED = 0.05f;
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

EarthMaterial earthMaterial;
MoonMaterial moonMaterial;
OceanMaterial oceanMaterial;
PhongMaterial phongMaterial;

PhongObject dragon;

Texture checkTexture;
Texture normalTexture1;
Texture normalTexture2;

Texture waveATexture;
Texture waveBTexture;

Icosahedron moon;
Earth earth;
Quad quad;


PhongObject bunny;

   
PJOGL pgl;
GL2ES2 gl;
GL3 gl3;
FBO main_texture_fbo;

PImage img;


float a = PI / 2;
float time = 0.0;


void setup() {
    size(900, 900, P3D);
    randomSeed(0);

    pgl = (PJOGL) beginPGL();  
    gl = pgl.gl.getGL2ES2();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();
    
    main_texture_fbo = new FBO(width,height,1);


    lightSetting();
    cameraSetting();
    setMaterial();
    initSetting();

}


void draw() {
    
    move();   
    main_texture_fbo.bindFrameBuffer();
    background(0);
    //moon.run();
    earth.run();
    
    gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);
    background(0);
    quad.run();
    main_light.setLightdirection(-200 * cos(a), -100, -200 * sin(a));
    //a+=0.01;
    time += 1.0 / frameRate;

    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}



public void initSetting() {
    setGameObject();
}

void setGameObject() {
    //dragon = new PhongObject("Meshes/Dragon_8K", phongMaterial1);
    //dragon.setScale(50, 50, 50);    
  
    
    //bunny = new PhongObject("Meshes/bunny",phongMaterial1);
    //bunny.setScale(100,100,100).setPosition(0,50,0);

    
    //NoiseSetting moonSetting = new NoiseSetting(1.8, 0.02 , 4, 2.0 , 0.7,new Vector3());
    //moon = new Icosahedron(moonMaterial,100 , 1000 , moonSetting);
    //moon.setScale(1,1,1).setPosition(5,0,0);
    
    NoiseSetting earthSetting = new NoiseSetting(2.0, 4.65 , 6 , 1.0 , 0.5, new Vector3());
    NoiseSetting earthRidgeSetting = new NoiseSetting(4.0, 8.7 , 5 , 1.5 , 0.5, new Vector3(), 2.18, 0.8, 0.09, 1.0);
    earth = new Earth(earthMaterial, 300, 0, earthSetting,earthRidgeSetting);
    earth.setScale(1,1,1).setPosition(0,0,0);
    
    quad = new Quad("Meshes/quad",oceanMaterial);

}

void setMaterial() {
    checkTexture = new Texture("Textures/Moon Noise.tif").setWrapMode(REPEAT);
    normalTexture1 = new Texture("Textures/Craters.tif").setWrapMode(REPEAT);
    normalTexture2 = new Texture("Textures/Rock3.tif").setWrapMode(REPEAT);
    waveATexture = new Texture("Textures/Wave A.png").setWrapMode(REPEAT);
    waveBTexture = new Texture("Textures/Wave B.png").setWrapMode(REPEAT);
    
    moonMaterial = new MoonMaterial("Shaders/Moon.frag", "Shaders/Moon.vert");
    moonMaterial.setAlbedo(1.0, 1.0, 1.0).setTexture(checkTexture).setNormalTexture1(normalTexture1).setNormalTexture2(normalTexture2).setrandomBiomeValues(-4.41, 0.0, -1.18, 5.65)
    .setPrimaryA(1.0, 1.0, 1.0).setSecondaryA(0.73, 0.73, 0.73).setPrimaryB(0.18, 0.18, 0.18).setSecondaryB(0.0, 0.0, 0.0).setNormalBias(1.0);
      
    earthMaterial = new EarthMaterial("Shaders/Earth.frag", "Shaders/Earth.vert");
    earthMaterial.setAlbedo(0.57/1.5, 0.46/1.5, 0.36/1.5).setMaxFlatHeight(0.5).setShoreLow(0.98,1.0,0.66).setShoreHigh(0.95,0.90,0.38)
                 .setFlatLowA(0.58,0.85,0.0).setFlatHighA(0.19,0.46,0.0).setFlatLowB(0.25,0.65,0.06).setFlatHighB(0.03,0.42,0.07)
                 .setSteepLow(0.52,0.49,0.18).setSteepHigh(0.14,0.06,0.0);
    
    oceanMaterial = new OceanMaterial("Shaders/Ocean.frag", "Shaders/Ocean.vert");
    oceanMaterial.setMainTexture(main_texture_fbo.tex[0]).setMainTexture2(main_texture_fbo.depthtex).setColA(0.382,0.9,0.865)
    .setColB(0.1,0.32,0.6).setdepthMultiplier(14.4).setalphaMultiplier(64.33).setSmoothness(0.92).setSpecularCol(0.96,1.0,0.88)
    .setWaveStrength(0.9).setWaveA(waveATexture).setWaveB(waveBTexture).setWaveScale(15.0).setWaveSpeed(0.02);
    
    phongMaterial = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial.setAlbedo(0.57/1.5, 0.46/1.5, 0.36/1.5);
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(0.0, 0.0, 5.0).setEular(-0.0, 0.0, 0.0);
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
