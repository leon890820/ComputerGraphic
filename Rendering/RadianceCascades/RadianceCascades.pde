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
static float GH_NEAR_MAX = 1e-1f;
static float GH_FAR = 1000.0f;
static float GH_MIN_CLIPPING=0.1f;
static int GH_FBO_SIZE = 2048;
static int GH_MAX_RECURSION = 4;

//Gameplay
static float GH_MOUSE_SENSITIVITY = 0.01f;
static float GH_MOUSE_SMOOTH = 0.5f;
static float GH_WALK_SPEED = 0.01f;
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

FBO sdfFinalTarget;
ScreenMaterial screenMaterial;
Quad screen;


FBO[] sdfTargets;
CopySDFMaterial copySDFMaterial;
Quad copySDFScene;

FBO[] cascadeRealTargets;
CascadeMaterial cascadeMaterial;
Quad cascadeScene;

FBO[] cascadeMergeTargets;
MergeMaterial cascadeMergeMaterial;
Quad cascadeMergeScene;

FBO radianceFieldTarget;
RadianceFieldMaterial radianceFieldMaterial;
Quad radianceFieldScene;

FinalComposeMaterial finalComposeMaterial;
Quad finalComposeScene;

QuadMaterial quadMaterial;
Quad quadScene;
   
PJOGL pgl;
GL2ES2 gl;
GL3 gl3;


float a = -PI/4;
float time = 0.0;
float brushRidius = 20;
Vector3 brushColor = new Vector3(1,1,1);


int cascade0_Dims = 2;
float cascade0_Range = 1.0;
int sdfIndex = 0;
Vector3 currentPos;
Vector3 previousPos;

void setup() {
    size(1024, 1024, P3D);
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
    
    
    gl3.glDisable(gl.GL_BLEND);    
    main_light.setLightdirection(200 * cos(a), -200 ,200 * sin(a));
    
    sdfFinalTarget.bindFrameBuffer();
    screenMaterial.setBrushRadius(brushRidius).setBrushColour(brushColor.x, brushColor.y, brushColor.z).setBrushPos((float)mouseX / (float)width, 1.0 - (float)mouseY / (float)height,0)
                  .setSDFTexture(sdfTargets[(sdfIndex + 1) % 2].tex[0]);
    screen.run();
    
    for(int i = 0; i < cascadeRealTargets.length; i++){
        cascadeMaterial.setCascadeLevel(i).setSDFTexture(sdfFinalTarget.tex[0]);
        cascadeRealTargets[i].bindFrameBuffer();
        cascadeScene.run();
    }
    
    for(int i = cascadeRealTargets.length - 1; i >= 0; i--){
        cascadeMergeMaterial.setCurrentCascadeLevel(i).setCascadeRealTexture(cascadeRealTargets[i].tex[0]);
        if(i < cascadeRealTargets.length - 1) cascadeMergeMaterial.setNextCascadeMergedTexture(cascadeMergeTargets[i + 1].tex[0]);
        cascadeMergeTargets[i].bindFrameBuffer();
        cascadeMergeScene.run();
    }
    
    radianceFieldMaterial.setMergedCascade0Texture(cascadeMergeTargets[0].tex[0]);
    radianceFieldTarget.bindFrameBuffer();
    radianceFieldScene.run();
    
    gl3.glBindFramebuffer(gl3.GL_FRAMEBUFFER , 0);      
    background(0);
    finalComposeMaterial.setRadianceTexture(radianceFieldTarget.tex[0]).setSDFTexture(sdfFinalTarget.tex[0]);
    finalComposeScene.run();
    
    if(mousePressed) updateBrushSDF();
    
        
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);
    
    
    
}


public void mouseReleased(){
    currentPos = null;
    previousPos = null;

}

public void updateBrushSDF(){
    if(currentPos == null){
        currentPos = new Vector3(mouseX , mouseY , 0);
        previousPos = new Vector3(mouseX , mouseY , 0);
    }
    currentPos = new Vector3(mouseX , mouseY , 0);
    
    sdfTargets[sdfIndex].bindFrameBuffer();    
    //gl3.glDisable(gl.GL_BLEND);
    copySDFMaterial.setBrushRadius(brushRidius).setBrushColour(brushColor.x, brushColor.y, brushColor.z)
                   .setBrushPos1(currentPos.x / (float)width,  1.0 - currentPos.y / (float)height,0)
                   .setBrushPos2(previousPos.x / (float)width, 1.0 - previousPos.y / (float)height,0)
                   .setSDFSource(sdfTargets[1 - sdfIndex].tex[0]);
                   
    copySDFScene.run();    
    previousPos.set(currentPos.x,currentPos.y,currentPos.z);
    sdfIndex = (sdfIndex + 1) % 2;
}

public void initSetting() {
    setGameObject();
}

void setGameObject() {
    screen = new Quad(screenMaterial);
    copySDFScene = new Quad(copySDFMaterial); 
    cascadeScene = new Quad(cascadeMaterial);
    cascadeMergeScene = new Quad(cascadeMergeMaterial);
    radianceFieldScene = new Quad(radianceFieldMaterial);
    finalComposeScene = new Quad(finalComposeMaterial);
    
}

void setMaterial() {  
    
    sdfFinalTarget = new FBO(width,height,1 , gl3.GL_NEAREST);
    screenMaterial = new ScreenMaterial("Shaders/Screen.frag", "Shaders/Screen.vert");  
    
    
    float factor = 4.0;
    float diagonalLength = sqrt(width * width + height * height);
    int numCascadeLevels = ceil(log(diagonalLength / cascade0_Range) / log(factor)) - 1;
    for (int i = 0; true; ++i) {
        int cascadeLevel = i;
        float cascadeN_End_Pixels = (cascade0_Range * (1.0 - (pow(factor , (cascadeLevel + 1))))) / (1.0 - factor);
        if (cascadeN_End_Pixels > diagonalLength) {
            println("ACTUAL FUCKING LEVEL: " + i);
            numCascadeLevels = i + 1;
            break;
        }
    }
    
    cascadeRealTargets = new FBO[numCascadeLevels];
    for(int i = 0; i < cascadeRealTargets.length; i++){
        cascadeRealTargets[i] = new FBO(width, height, 1, gl3.GL_NEAREST);
    }    
    cascadeMaterial = new CascadeMaterial("Shaders/cascade.frag","Shaders/cascade.vert");
    cascadeMaterial.setCascade0_Dims(cascade0_Dims).setCascade0_Range(cascade0_Range);
    
    cascadeMergeTargets = new FBO[numCascadeLevels];
    for(int i = 0; i < cascadeMergeTargets.length; i++){
        cascadeMergeTargets[i] = new FBO(width, height ,1 , gl3.GL_NEAREST);
    }
    cascadeMergeMaterial = new MergeMaterial("Shaders/merge.frag","Shaders/merge.vert");
    cascadeMergeMaterial.setNumCascadeLevels(numCascadeLevels).setCascade0_Dims(cascade0_Dims).setCascade0_Range(cascade0_Range);
    
    radianceFieldTarget = new FBO(width / cascade0_Dims,height / cascade0_Dims,1 , gl3.GL_LINEAR);
    radianceFieldMaterial = new RadianceFieldMaterial("Shaders/radiance_field.frag","Shaders/radiance_field.vert");
    radianceFieldMaterial.setCascade0_Dims(cascade0_Dims).setCascade0_Range(cascade0_Range);
    
    sdfTargets = new FBO[2];
    sdfTargets[0] = new FBO(width, height , 1 , gl3.GL_NEAREST);
    gl3.glClearColor(0,0,0,1000);
    sdfTargets[0].bindFrameBuffer();
    sdfTargets[1] = new FBO(width, height , 1, gl3.GL_NEAREST);    
    sdfTargets[1].bindFrameBuffer();
    gl3.glClearColor(0,0,0,0);
    
    finalComposeMaterial = new FinalComposeMaterial("Shaders/finalCompose.frag","Shaders/finalCompose.vert");
    finalComposeMaterial.setSDFTexture(sdfTargets[0].tex[0]);
    
       
    copySDFMaterial = new CopySDFMaterial("Shaders/CopySDF.frag","Shaders/CopySDF.vert");
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(0.0, 1.0, 2.0).setEular(-0.0, 0.0, 0.0);
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
    
    if (key=='Z'||key=='z') {
        brushColor.set(1,1,1);
    }
    if (key=='X'||key=='x') {
        brushColor.set(0,0,0);
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
