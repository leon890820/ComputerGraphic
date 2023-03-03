import peasy.*;
PeasyCam cam;
String[] teapot;
Editor editor;
int vs,ts;
Mesh mesh;
PVector[] verties;
int[] triangle;
int[] number;
void setup(){
  cam=new PeasyCam(this,100);
  editor=new Editor();
  size(600,600,P3D);
  background(0);
  teapot=loadStrings("teapot.asc");
  String[] vts=teapot[0].split(" ");
  vs=int(vts[0]);
  ts=int(vts[1]);
  verties=new PVector[vs];
  number=new int[ts];
  for(int i=0;i<vs;i+=1){
    String[] pv=teapot[i+1].split(" ");
    if(pv[0].equals("")){
      verties[i]=new PVector(float(pv[1]),float(pv[2]),float(pv[3]));  
      //println(pv[1],float(pv[2]),float(pv[3]));
    }else{
      verties[i]=new PVector(float(pv[0]),float(pv[1]),float(pv[2]));
      //println(pv[0],float(pv[1]),float(pv[2]));  
  }
    
  }
  int triangleIndex=0;
  int sum=0;
  for(int i=0;i<ts;i+=1){
    String[] tv=teapot[i+1+vs].split(" ");
    sum+=int(tv[0]);
  }
  triangle=new int[sum];
  for(int i=0;i<ts;i+=1){
    String[] tv=teapot[i+1+vs].split(" ");
    number[i]=int(tv[0]);
    for(int j=0;j<int(tv[0]);j+=1){
      triangle[triangleIndex+j]=int(tv[j+1])-1;
    }
    triangleIndex+=int(tv[0]);
    
  
  }
  
}

void draw(){
  background(0);
  mesh=new Mesh();
  mesh.verties=verties;
  mesh.triangles=triangle;
  mesh.number=number;
  mesh.show();

}
