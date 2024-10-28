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
static float GH_WALK_SPEED = 0.32f;
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


Texture blockTexture;
PhongMaterial phongMaterial;

   
PJOGL pgl;
GL2ES2 gl;
GL3 gl3;

Vector3[] dirs = new Vector3[]{new Vector3(1,0,0),new Vector3(-1,0,0),new Vector3(0,0,1),new Vector3(0,0,-1),new Vector3(0,1,0),new Vector3(0,-1,0)};


float a = 0.5;
float time = 0.0;

Tile[][][] tile;
Wave[][][] wave;

int size = 9;

float[] weight = new float[]{40.0 , 5.0 , 5.0 , 1.0 , 40.0 , 30.0};


void setup() {
    size(900, 900, P3D);
    randomSeed(11);
    pgl = (PJOGL) beginPGL();  
    gl = pgl.gl.getGL2ES2();
    gl3 = ((PJOGL)beginPGL()).gl.getGL3();

    lightSetting();
    cameraSetting();
    setMaterial();
    initSetting();


    
    //println(wave[2][0][0].state);
    //println(getNeiborDir(new Neighbor(TileState.Up , 3),3));
    
    
}


void draw() {
    
    move();   

    background(0);
    for(int y = 0; y < tile[0].length; y++) for(int z = 0; z < tile.length; z++) for(int x = 0; x < tile[0][0].length; x++){
        if(tile[z][y][x] == null) continue;
        tile[z][y][x].run();        
    }
    
    collapse();
    //println("------------");

    
    main_light.setLightdirection(200 * cos(a), -200 ,200 * sin(a) );    
    String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
    surface.setTitle(txt_fps);

    
}

int count = 0;
public void collapse(){
    resetWaveCollapse();
    
    // entropy
    ArrayList<Wave> w = new ArrayList<Wave>();
    float min_entropy = 100000;
    for(int y = 0; y < tile[0].length; y++) for(int z = 0; z < tile.length; z++) for(int x = 0; x < tile[0][0].length; x++){
        if(wave[z][y][x].done) continue;
        float entropy = wave[z][y][x].state.size();        
        if(entropy < min_entropy){
            min_entropy = entropy;
            w.clear();
            w.add(wave[z][y][x]);
        }else if(entropy == min_entropy){
            w.add(wave[z][y][x]);
        }
    }
    
    if(w.size() == 0) return;
    
    Wave sw = w.get((int)random(w.size()));   
    Neighbor n = sw.state.size() == 0? new Neighbor(TileState.Empty, 0) : randomChoseNeighborWithWeight(sw.state);
    Vector3 p = sw.position;

    tile[(int)p.z][(int)p.y][(int)p.x] = getTile(n.tile,n.rotation);
    tile[(int)p.z][(int)p.y][(int)p.x].setPosition(p.x,p.y,p.z);
    wave[(int)p.z][(int)p.y][(int)p.x].done = true;
    wave[(int)p.z][(int)p.y][(int)p.x].state.clear();
    wave[(int)p.z][(int)p.y][(int)p.x].state.add(n);
    propagation(p);
    count ++;
    //for(int y = 0; y < tile[0].length; y++) {
    //    for(int z = 0; z < tile.length; z++){
    //        for(int x = 0; x < tile[0][0].length; x++){
    //            print(wave[z][y][x].state.size() + " ");
    //        }
    //        println();
    //    }
    //    println();
    //}
    
}



void resetWaveCollapse(){
    for(int y = 0; y < tile[0].length; y++) for(int z = 0; z < tile.length; z++) for(int x = 0; x < tile[0][0].length; x++){
        wave[z][y][x].collapse = false;
    }

}

void deleteNotInNeighbor(ArrayList<Neighbor> state , Neighbor[] neighbor){
    if(state.size() <= 1) return;
    for(int j = state.size() - 1; j >=0 ; j--){
        boolean flag = false;
        Neighbor n = state.get(j);
        for(int i = 0; i < neighbor.length; i++){
            if(n.equals(neighbor[i])){
                flag = true;
                break;
            }
        }    
        if(!flag) state.remove(j);
    }
}

public void propagation(Vector3 p){
    ArrayList<Wave> queue = new ArrayList<Wave>();
    ArrayList<Wave> queue2 = new ArrayList<Wave>();
    queue.add(wave[(int)p.z][(int)p.y][(int)p.x]);

    while(true){    
        for(int i = 0; i < queue.size(); i++){
            Wave w = queue.get(i);    
            if(w.collapse) continue;
            w.collapse = true;
            for(int j = 0; j < 6; j++){
                Vector3 position = w.position.add(dirs[j]);
                if(outOfBoundary(position)) continue;
                Wave w2 = wave[(int)position.z][(int)position.y][(int)position.x];            
                if(w2.collapse || w2.done) continue;
                queue2.add(w2);                
                deleteNotInNeighbor(w2.state , getWaveNeighbor(w , j));
            }
        }
        if(queue2.size() == 0) return;
        queue.clear();
        queue.addAll(queue2);
        queue2.clear();
    }
    
    

}

public Neighbor[] getWaveNeighbor(Wave w , int r){
    Neighbor[] result = new Neighbor[0];
    for(int i = 0; i < w.state.size(); i++){
        result = unionNeighbor(result,getNeiborDir(w.state.get(i),r));
    }
    return result;    
}



public void initSetting() {
    setGameObject();
}

void setGameObject() {
    tile = new Tile[size][size][size];
    wave = new Wave[size][size][size];
    for(int y = 0; y < tile[0].length; y++) for(int z = 0; z < tile.length; z++) for(int x = 0; x < tile[0][0].length; x++){
        wave[z][y][x] = new Wave(x,y,z);
        if(z == 0 || x ==0 || y == 0 || z == size -1 || y == size - 1 || x == size -1){            
            wave[z][y][x].state.clear();
            for(int i = 0; i < 4; i++){
                wave[z][y][x].state.add(new Neighbor( TileState.Empty , i));
            }
            tile[z][y][x] = getTile(TileState.Empty,0);
            tile[z][y][x].setPosition(x,y,z);
        }        
    }
    
    for(int y = 0; y < tile[0].length; y++) for(int z = 0; z < tile.length; z++) for(int x = 0; x < tile[0][0].length; x++){
        if(z == 0 || x ==0 || y == 0 || z == size -1 || y == size - 1 || x == size -1){
            resetWaveCollapse();
            propagation(new Vector3(x,y,z));     
            wave[z][y][x].done = true;
        }
    }


    
    
}

void setMaterial() {  
    blockTexture = new Texture("Textures/Blocks.png");
    blockTexture.setSamplingMode(2);
       
    phongMaterial = new PhongMaterial("Shaders/BlinnPhong.frag", "Shaders/BlinnPhong.vert");
    phongMaterial.setAlbedo(0.0,0.0,0.0);
}


public void cameraSetting() {
    main_camera = new Camera();
    main_camera.setPosition(60.0, 60.0, 60.0).setEular(-0.67, 0.77 , 0.0);
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
