import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL3ES3;
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
static float GH_WALK_SPEED = 0.03f;
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

FBO[] rayTracingTarget;
RayTracingMaterial rayTracingMaterial;
Quad rayTracingScene;
Texture whiteNoise;

QuadMaterial finaMaterial;
Quad finalScene;

PJOGL pgl;
GL3ES3 gl;
GL3 gl3;

SSBO ssbo_triangle;
SSBO ssbo_circle;

float a = -PI/4;
float time = 0.0;

int count = 0;

void setup() {
    size(900, 900, P3D);
    randomSeed(0);

    pgl = (PJOGL) beginPGL();
    gl = pgl.gl.getGL3ES3();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();

    lightSetting();
    cameraSetting();
    setMaterial();    
    initSetting();

    //println(gl3.GL_MAX_FRAGMENT_UNIFORM_COMPONENTS);
    //println(gl3.glGetString(gl3.GL_VERSION));
}

float[] data = new float[]{1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
    1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0,
    1.0, 0.0, 1.0, 0.0, 0.1, 1.0, 0.0, 0.0,
    1.0, 1.0, 1.0, 0.0, 0.5, 1.0, 1.0, 0.0};





void draw() {

    move();

    main_light.setLightdirection(200 * cos(a), -200, 200 * sin(a));

    rayTracingTarget[frameCount % 2].bindFrameBuffer();
    rayTracingMaterial.setCamPos(main_camera.transform.position).setLastFrame(rayTracingTarget[(frameCount + 1) % 2].tex[0]);
    rayTracingScene.run();

    gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, 0);
    background(0);
    finaMaterial.setFinalTexture(rayTracingTarget[frameCount % 2].tex[0]);



    finalScene.run();

    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);

    count++;
}






public void initSetting() {
    setScence(2);
    setGameObject();
}

void setGameObject() {
    rayTracingScene = new Quad(rayTracingMaterial);
    finalScene = new Quad(finaMaterial);
}

void setMaterial() {

    Texture earth = new Texture("Textures/earth.jpg");

    rayTracingTarget = new FBO[2];
    for (int i = 0; i < rayTracingTarget.length; i++) {
        rayTracingTarget[i] = new FBO(width, height, 1, gl3.GL_LINEAR);
        rayTracingTarget[i].bindFrameBuffer();
    }
    gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER, 0);
    rayTracingMaterial = new RayTracingMaterial("Shaders/RayTracing.frag", "Shaders/RayTracing.vert");
    rayTracingMaterial.setEarth(earth);

    finaMaterial = new QuadMaterial("Shaders/quad.frag", "Shaders/quad.vert");

    
}


void setScence(int i){
    if(i == 0){
        rayTracingMaterial.setDark(false);
        ssbo_circle = new SSBO(1, rayTracingMaterial, getSphereScenceData());
    }else if(i == 2){
        rayTracingMaterial.setDark(true);
        ssbo_triangle = new SSBO(0, rayTracingMaterial, getFinalScenceData());
        ssbo_circle = new SSBO(1, rayTracingMaterial, getFinalScenceData1());
    }

}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(5.0, 5.0, 5.0).setEular(-0.2, 0.5, 0.0);
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
            if (dy != 0 || dx != 0) count = 0;
        }
    }

    Vector3 forward = main_camera.localToWorld().mult(new Vector3(0, 0, -1));
    Vector3 right = main_camera.localToWorld().mult(new Vector3(1, 0, 0));

    float wx = key_input[3] ? 1.0 * GH_WALK_SPEED : key_input[1] ? -1.0 * GH_WALK_SPEED : 0.0;
    float wz = key_input[0] ? 1.0 * GH_WALK_SPEED : key_input[2] ? -1.0 * GH_WALK_SPEED: 0.0;
    if (wx != 0 || wz != 0) count = 0;

    Vector3 mv = forward.mult(wz).add(right.mult(wx));
    main_camera.transform.position = main_camera.transform.position.add(mv);

    main_camera.update();
}



public float[] getSphereScenceData(){
    FloatList data = new FloatList();
    int sphere_per_side = 5;
    for (int i = -sphere_per_side; i <= sphere_per_side; i++) {
        for (int j = -sphere_per_side; j <= sphere_per_side; j++) {
            float mr = random(1);
            if(mr < 0.2){
                float[] sd = getSphereData(new Vector3(i + random(0.6), 0.2, j + random(0.6)) , 0.2 , 0 , 
                                           new Vector3(random(1),random(1),random(1)), 0.0, 0.0);
                 data.append(sd);
            }else{
                float[] sd = getSphereData(new Vector3(i + random(0.6), 0.2, j + random(0.6)) , 0.2 , 1 , 
                                           new Vector3(random(1),random(1),random(1)), 0.0, 0.0);
                 data.append(sd);
            }
           
        }
    }
    
    float[] ground = getSphereData(new Vector3(0, -1000, 0) , 1000 , 0 , new Vector3(0.5), 0.0, 0.0);
    data.append(ground);
    return data.toArray();
}

public float[] getFinalScenceData1(){
    FloatList data = new FloatList();
    float[] lams = getSphereData(new Vector3(0.0,3.0,0.0) , 0.4 , 0 , 
                               new Vector3(0.7,0.3,0.1), 0.0, 0.0);
    float[] mats = getSphereData(new Vector3(2.0,3.0,2.0) , 0.4 , 2 , 
                               new Vector3(0.0), 0.0, 1.5);
    float[] mats1 = getSphereData(new Vector3(0.0,3.0,2.0) , 0.6 , 2 , 
                               new Vector3(0.0), 0.0, 1.8);
    data.append(lams);  
    data.append(mats); 
    data.append(mats1); 
    return data.toArray();
}


public float[] getFinalScenceData() {
    int boxes_per_side = 3;
    FloatList data = new FloatList();

    for (int i = -boxes_per_side; i <= boxes_per_side; i++) {
        for (int j = -boxes_per_side; j <= boxes_per_side; j++) {
            float y = random(1) * 0.5;
            float[] cd = getCubeData(new Vector3(i, 1 + y, j), new Vector3(1.0, 1 + y, 1.0));
            data.append(cd);
        }
    }
    
    Vector3[] lv1 = new Vector3[]{new Vector3(-2,7,-2) , new Vector3(2,7,-2), new Vector3(2,7,2)};
    Vector3[] lv2 = new Vector3[]{new Vector3(-2,7,-2) , new Vector3(2,7,2), new Vector3(-2,7,2)};
    
    float[] lt1 = getTriangleData(lv1 , 3 , new Vector3(3.0) , 0.0 , 0.0);
    float[] lt2 = getTriangleData(lv2 , 3 , new Vector3(3.0) , 0.0 , 0.0);
    data.append(lt1);
    data.append(lt2);
    
    return data.toArray();
}
