Matrix EMPM_matrix;
Matrix transform_matrix;
Vector3 background_color;
Vector3 kala;
float[] dz;
int[] cz;
ArrayList<Light> lights;
Camera cam;
int type=0;
float a=0;

ArrayList<Mesh> meshes;
void settings() {
  size(1080, 1080);
  cam=new Camera(new Vector3(0, 0, 0), new Vector3(0, 0, 1));
  
}
void setup() {

  background(0);  
  //cam=new Camera();
  lights=new ArrayList<Light>();
  background_color=new Vector3(0.7*255, 0.8*255, 1*255);
  kala=new Vector3(0.8, 0.8, 0.8);
  
  initLight();

  dz=new float[width*height];
  cz=new int[width*height];
  initdzcz();
  meshes=new ArrayList<Mesh>();
  transform_matrix=identity_matrix();
  switch(type) {
  case 0:
    cam=new Camera(new Vector3(000, 150, 350), new Vector3(0, 100, 0));
    setGura();
    break;
  case 1:
    cam=new Camera(new Vector3(10, -100, 10), new Vector3(0, 0, 0));
    setDragon();
    break;
  case 2:
    cam=new Camera(new Vector3(4, 4, 4), new Vector3(0, 0, 0));
    setCube();
    break;
  case 3:
    cam=new Camera(new Vector3(8, 1, 1), new Vector3(0, 0, 0));
    setSphere(10);
    break;
  case 4:
    cam=new Camera(new Vector3(0, 1, -1), new Vector3(0, 5, 5));
    //EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 30);
    //EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 30));
    //println(PM(0.1, 1000, 30));
    //println("EMPM_matrix\n",EMPM_matrix);
    setFloor();
    break;
  }


  

  for (Mesh m : meshes) {
    //m.show();
    m.zBuffer();
  }

  loadPixels();
  for (int i=0; i<dz.length; i+=1) {
    if (dz[i]==1.0/0.0) cz[i]=color(background_color.x, background_color.y, background_color.z);
    pixels[i]=cz[i];
  }
  updatePixels();
  println();
  
  saveFrame("picture.png");
}
void initLight(){
  lights.clear();
  lights.add(new Light(new Vector3(0.6, 0.6, 0.6), new Vector3(100*cos(a), 5, 100*sin(a))));
  //lights.add(new Light(new Vector3(0.6, 0.6, 0.6), new Vector3(0, 2, 0)));
}

void addMeshObject(String s, Vector3 O, float Kd, float Ks, float N) {
  Vector3[] verties;
  int[] triangle;
  int vs, ts;
  String[] object=loadStrings(s);
  String[] vts=object[0].split(" ");
  vs=int(vts[0]);
  ts=int(vts[1]);

  verties=new Vector3[vs];
  

  for (int i=0; i<vs; i+=1) {
    String[] pv=object[i+1].split(" ");
    if (pv[0].equals("")) {
      verties[i]=new Vector3(float(pv[1]), float(pv[2]), float(pv[3]));
    } else {
      verties[i]=new Vector3(float(pv[0]), float(pv[1]), float(pv[2]));
    }
  }
  int triangleIndex=0;
  int sum=0;
  for (int i=0; i<ts; i+=1) {
    String[] tv=object[i+1+vs].split(" ");
    sum+=(int(tv[0])-2);
  }
  triangle=new int[sum*3];
  for (int i=0; i<ts; i+=1) {
    String[] tv=object[i+1+vs].split(" ");
    
    
    for(int k=0;k<int(tv[0])-2;k+=1){
      triangle[triangleIndex]=int(tv[1])-1;
      for (int j=0; j<2; j+=1) {
        triangle[triangleIndex+1+j]=int(tv[j+2+k])-1;
      }
      triangleIndex+=3;
    }
    
    
    
  }

  meshes.add(new Mesh(verties, triangle, null, null, new ShadeParameter(O, Kd, Ks, N),null,null,transform_matrix));
}


void addobjMeshObject(String s, Vector3 O, float Kd, float Ks, float N) {
  Vector3[] verties;
  int[] triangle;
  int[] number;
  int[] uv_triangle;
  int[] pc;
  int[] tc;
  String[] texture_name;
  Vector3[] uv;
  int vs, ts, vt;
  String[] object=loadStrings(s);
  String[] vts=object[0].split(" ");
  vs=int(vts[0]);
  ts=int(vts[1]);
  vt=int(vts[2]);
  pc=new int[int(vts[3])];
  tc=new int[int(vts[3])];
  texture_name=new String[int(vts[3])];
  verties=new Vector3[vs];
  uv=new Vector3[vt];
  for(int i=0;i<pc.length;i+=1){
    if(i==0) pc[i]=int(vts[4+i]);
    else pc[i]=int(vts[4+i])+pc[i-1];
    texture_name[i]=vts[7+i];
  }
  //texture_name[0]=vts[4];
  for (int i=0; i<vs; i+=1) {
    String[] pv=object[i+1].split(" ");
    if (pv[0].equals("v")) {
      verties[i]=new Vector3(float(pv[1]), float(pv[2]), float(pv[3]));
    } else {
      verties[i]=new Vector3(float(pv[1]), float(pv[2]), float(pv[3]));
    }
  }
  int triangleIndex=0;
  int sum=0;
  int c=0;
  
  for (int i=0; i<ts; i+=1) {
    String[] tv=object[i+1+vs].split(" ");
    sum+=int(tv.length-3);
    if(pc.length==0) continue;
    if(i==pc[c]-1){
      tc[c]=sum;
      c+=1;
    } 
  }

  number=new int[sum];
  triangle=new int[sum*3];
  uv_triangle=new int[sum*3];
  int count=0;
  for (int i=0; i<ts; i+=1) {

    String[] tv=object[i+1+vs].split(" ");
    
    for (int j=0; j<tv.length-3; j+=1) {
      String[] ttt=tv[1].split("/");
     
      triangle[triangleIndex+0]=int(ttt[0])-1;
      uv_triangle[triangleIndex+0]=int(ttt[1])-1;
      for (int k=0; k<2; k+=1) {
        String[] tt=tv[2+j+k].split("/");
       
        triangle[triangleIndex+k+1]=int(tt[0])-1;
        uv_triangle[triangleIndex+k+1]=int(tt[1])-1;
      }
      number[count]=3;
      count+=1;
      triangleIndex+=3;
    }
    //println(tv);

    
  }
 
  

  for (int i=0; i<uv.length; i+=1) {
    String[] pv=object[i+1+vs+ts].split(" ");
    if (pv[0].equals("vt")) {
      uv[i]=new Vector3(float(pv[1]), float(pv[2]), float(pv[3]));
      
      //println(pv[1],float(pv[2]),float(pv[3]));
    } else {
      uv[i]=new Vector3(float(pv[0]), float(pv[1]), float(pv[2]));
      //println(pv[0],float(pv[1]),float(pv[2]));
    }
  }
  
  meshes.add(new Mesh(verties, triangle, uv, uv_triangle,new ShadeParameter(O, Kd, Ks, N) ,tc,texture_name,transform_matrix));
}
void setCube(){
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 0);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 20));
  
  
  //transform_matrix=rotation_z(a);
  addobjMeshObject("cubetest.txt",new Vector3(0.9, 0.5, 0.5), 0.7, 0.3, 5);
  
  
}

void setFloor(){
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 30);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 30));
   
  //transform_matrix=rotation_z(a);
  addobjMeshObject("ground.obj",new Vector3(0.9, 0.9, 0.9), 0.7, 0.3, 5);
  
  
}

void setSphere(int a){
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 0);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 20));
   
  //transform_matrix=rotation_z(a);
  addMeshObject("sphere"+str(a)+".asc",new Vector3(0.9, 0.9, 0.5), 0.7, 0.3, 5);
  
  
}

void setGura() {
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 0);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 20));
  
  addobjMeshObject("gura.txt", new Vector3(0.9, 0.9, 0.9), 0.7, 0.3, 100);
  
}

void setDragon() {  
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 0);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 20));
  
  addobjMeshObject("dragon.txt", new Vector3(0.3, 0.7, 0.9), 0.7, 0.8, 10);
}


void setScence() {
  EMPM_matrix=EM(cam.eye_position, cam.view_location, cam.up_vector, 0);
  EMPM_matrix=Matrix.mult(EMPM_matrix, PM(0.1, 1000, 20));

  transform_matrix=scaling_matrix(new Vector3(0.7, 0.7, 0.7));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(1.7, 1.3, -0.5)));
  addMeshObject("glass.asc", new Vector3(0.6, 1, 1), 0.7, 0.3, 50);
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-1, 0, -0.5)));
  addMeshObject("glass.asc", new Vector3(0.6, 1, 1), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(6, 0.1, 6));
  addMeshObject("cube.asc", new Vector3(0.4, 0.2, 0), 0.7, 0.3, 4);
  transform_matrix=Matrix.mult(transform_matrix, scaling_matrix(new Vector3(0.5, 15, 0.5)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(0, -1, 0)));
  addMeshObject("cube.asc", new Vector3(0.4, 0.2, 0), 0.7, 0.3, 4);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.4, 0.4, 0.4));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-20, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-1.2, 0, 0)));
  addMeshObject("teapot.asc", new Vector3(0.9, 0.1, 0.1), 0.7, 0.3, 30);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.3, 1, 0.3));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-1.5, 1.15, -1.5)));
  addMeshObject("drop.asc", new Vector3(1, 0.6, 0.2), 0.7, 0.3, 100);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.15, 2.3, 0.15));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-1.5, 0, -1.5)));
  addMeshObject("cube.asc", new Vector3(0.95, 0.95, 0.95), 0.7, 0.3, 10);
  reset();

  transform_matrix=scaling_matrix(new Vector3(1, 2, 2.5));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(180, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(0, 0, -4)));
  addMeshObject("bench.asc", new Vector3(0.5, 0.3, 0.1), 0.7, 0.3, 4);
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-90, 0, 360, 0, 2*PI)));
  addMeshObject("bench.asc", new Vector3(0.5, 0.3, 0.1), 0.7, 0.3, 4);
  reset();

  transform_matrix=scaling_matrix(new Vector3(2, 1, 2));
  transform_matrix=Matrix.mult(transform_matrix, rotation_z(map(25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, rotation_x(map(270, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-2, 3.5, -7)));
  addMeshObject("Grid4x4.asc", new Vector3(0.6, 1, 1), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(4, 0.3, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-2, 5.5, -7)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(4, 0.3, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-2, 3.5, -7)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(4, 0.3, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-2, 1.5, -7)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.3, 4, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(0.05, 3.5, -7.2)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.3, 4, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-2, 3.5, -7)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();

  transform_matrix=scaling_matrix(new Vector3(0.3, 4, 0.1));
  transform_matrix=Matrix.mult(transform_matrix, rotation_y(map(-25, 0, 360, 0, 2*PI)));
  transform_matrix=Matrix.mult(transform_matrix, translate_matrix(new Vector3(-3.6, 3.5, -6.1)));
  addMeshObject("cube.asc", new Vector3(0.6, 0, 0), 0.7, 0.3, 50);
  reset();


  //cam=new Camera(new Vector3(10, 3, 10),new Vector3(0, 0, 0));



  
  //light.location=Matrix.mult(light.location, EMPM_matrix);
}



void maxArray(int[] i) {
}

void initdzcz() {
  for (int i=0; i<dz.length; i+=1) {
    dz[i]=1.0/0.0;
    cz[i]=color(0);
  }
}

void init() {
}

void reset() {
  transform_matrix=identity_matrix();
}

Matrix EM(Vector3 el, Vector3 COI, Vector3 tv, float theda) {
  theda=map(theda, 0, 360, 0, 2*PI);
  
  
  Matrix transform_matrix;
  Vector3 vz=Vector3.sub(COI, el);
  Vector3 vt=Vector3.sub(tv, el);
  Vector3 v3=vz.copy().norm();
  Vector3 v1=Vector3.cross(vt, vz).norm();
  Vector3 v2=Vector3.cross(v3, v1).norm();
  

  transform_matrix=Matrix.mult(translate_matrix(Vector3.mult(el, -1)), GRM(v1, v2, v3));
  float[][] mr={{-1, 0, 0, 0}, {0, -1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  Matrix mirror=new Matrix(mr);
  Matrix tilt=rotation_x(theda);  
  transform_matrix=Matrix.mult(transform_matrix, mirror);
  transform_matrix=Matrix.mult(transform_matrix, tilt);
  return transform_matrix;
}

Matrix GRM(Vector3 v1, Vector3 v2, Vector3 v3) {
  float[][] ff={{v1.x, v2.x, v3.x, 0}, {v1.y, v2.y, v3.y, 0}, {v1.z, v2.z, v3.z, 0}, {0, 0, 0, 1}};
  return new Matrix(ff);
}

Matrix PM(float H, float y, float theda) {
  theda=map(theda, 0, 360, 0, 2*PI);
  float[][] ff={{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, y/(y-H)*tan(theda), tan(theda)}, {0, 0, H*y/(H-y)*tan(theda), 0}};
  return new Matrix(ff);
}

Matrix identity_matrix() {
  float[][] ff={{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  return new Matrix(ff);
}



void draw() {
  background(200);
  //lights.clear();
  //lights.add(new Light(new Vector3(0.6, 0.6, 0.6), new Vector3(cos(a)*5, sin(a)*5, 0)));
  //println(meshes.size());
  a+=0.1;
  //println(EMPM_matrix);
  initdzcz();
  //initLight();
  transform_matrix=rotation_y(a);
  //transform_matrix=Matrix.mult(rotation_y(a*0.5),transform_matrix);
  //transform_matrix=Matrix.mult(rotation_z(-a*0.4),transform_matrix);
  for(Mesh m:meshes){
    
    m.transform_matrix=transform_matrix.copy();
    m.reload();
    m.zBuffer();
  }
  
  
  
  loadPixels();
  for (int i=0; i<dz.length; i+=1) {
    if (dz[i]==1.0/0.0) cz[i]=color(background_color.x, background_color.y, background_color.z);
    pixels[i]=cz[i];
  }
  updatePixels();
  
  String txt_fps = String.format(getClass().getName()+ " [frame %d]   [fps %6.2f]", frameCount, frameRate);
  surface.setTitle(txt_fps);
  
  
  //text(str(mouseX)+" "+str(mouseY), mouseX, mouseY);
  float speed=10;
  if (keyPressed) {
    if (key=='d'|| key=='D') {
      cam.eye_position.x+=0.1*speed;
    }
    if (key=='w'|| key=='W') {
      cam.eye_position.y-=0.1*speed;
    }
    if (key=='a'|| key=='A') {
      cam.eye_position.x-=0.1*speed;
    }
    if (key=='s'|| key=='S') {
      cam.eye_position.y+=0.1*speed;
    }
    
  }
}


void mouseDragged() {
  float px=mouseX-pmouseX;
  float py=mouseY-pmouseY;
}



Matrix translate_matrix(Vector3 p) {
  float[][] fs={{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {p.x, p.y, p.z, 1}};
  return new Matrix(fs);
}

Matrix scaling_matrix(Vector3 p) {
  float[][] fs={{p.x, 0, 0, 0}, {0, p.y, 0, 0}, {0, 0, p.z, 0}, {0, 0, 0, 1}};
  return new Matrix(fs);
}

Matrix rotation_z(float a) {
  float[][] fs={{cos(a), sin(a), 0, 0}, {-sin(a), cos(a), 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  return new Matrix(fs);
}
Matrix rotation_x(float a) {
  float[][] fs={{1, 0, 0, 0}, {0, cos(a), sin(a), 0}, {0, -sin(a), cos(a), 0}, {0, 0, 0, 1}};
  return new Matrix(fs);
}
Matrix rotation_y(float a) {
  float[][] fs={{cos(a), 0, sin(a), 0}, {0, 1, 0, 0}, {-sin(a), 0, cos(a), 0}, {0, 0, 0, 1}};
  return new Matrix(fs);
}

void line(Vector3 p1, Vector3 p2) {
  line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
}
void line(Vector3 p1) {
  line(0, 0, 0, p1.x, p1.y, p1.z);
}
void drawPoint(Vector3 p) {
  //pushMatrix();
  //translate(p.x,p.y,p.z);
  //vertex(p.x,p.y,p.z);

  //popMatrix();
}


void axis() {
  pushMatrix();
  stroke(255);
  line(0, 0, 0, 1000);
  line(0, 0, 1000, 0);
  rotateY(PI/2);
  line(0, 0, -1000, 0);
  popMatrix();
}


boolean pnpoly(float x, float y, Vector3[] vertexes) {
  boolean c=false;

  for (int i=0, j=vertexes.length-1; i<vertexes.length; j=i++) {
    if (((vertexes[i].y>y)!=(vertexes[j].y>y))&&(x<(vertexes[j].x-vertexes[i].x)*(y-vertexes[i].y)/(vertexes[j].y-vertexes[i].y)+vertexes[i].x)) {
      c=!c;
    }
  }
  return c;
}
