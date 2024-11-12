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
static float GH_FOV = 30.0f;
static float GH_NEAR_MIN = 1e-3f;
static float GH_NEAR_MAX = 1e-2f;
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
static float GH_GRAVITY = 0;//-9.8f;
static Vector3 AMBIENT_LIGHT = new Vector3(0.3, 0.3, 0.3);

boolean[] key_input={false, false, false, false};

Camera main_camera;
Camera cam1;
Camera cam2;
Camera cam3;
Player player;

Light main_light;
Level1 level1;

PJOGL pgl;
GL2ES2 gl;
GL3 gl3;

float a = -0.5;
float time = 0.0;



void setup() {
    size(900, 900, P3D);
    randomSeed(0);

    pgl = (PJOGL) beginPGL();  
    gl = pgl.gl.getGL2ES2();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();
    


    lightSetting();
    cameraSetting();
    initSetting();

}


void draw() {
    
    player.move();   

    background(0);
    level1.run();
        
    main_light.setLightdirection(200 * cos(a), -200 ,200 * sin(a) );
  
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
}



public void initSetting() {
    level1 = new Level1();
}




public void cameraSetting() {
    player = new Player();
    player.setPosition(0.0, 10.0, 20.0).setEular(-0.0, 0.0, 0.0);
    
    cam1 = new Camera();
    cam1.setPosition(0.0, 10.0, 20.0).setEular(-0.0, 0.0, 0.0);
    cam1.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
    
    cam2 = new Camera();
    cam2.setPosition(-12.0, 10.0 , 20.0).setEular(-0.0, 0.0, 0.0);
    cam2.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
    
    cam3 = new Camera();
    cam3.setPosition(12.0, 10.0 , 20.0).setEular(-0.0, 0.0, 0.0);
    cam3.setSize((float)width, (float)height, GH_NEAR_MAX, GH_FAR);
    
    //main_camera = cam2;
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
