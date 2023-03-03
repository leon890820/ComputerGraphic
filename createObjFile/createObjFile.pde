void setup(){
  createSphere();



}


void createSphere(){
  int grid=100;
  float r=1;
  Vector3[] verties=new Vector3[grid*(grid+1)];
  int[] triangles=new int[grid*(grid)*2*3];
  for(int i=0;i<=grid;i+=1){
    float theda=map(i,0,grid,0,PI);
    for(int j=0;j<grid;j+=1){
      float phi=map(j,0,grid,0,2*PI);
      int index=i*grid+j;
      verties[index]=new Vector3(r*sin(theda)*cos(phi),r*sin(theda)*sin(phi),r*cos(theda));
    }  
  }
  int count=0;
  for(int i=0;i<grid;i+=1){
    for(int j=0;j<grid;j+=1){
      triangles[count]=i*grid+(j%grid);
      triangles[count+1]=(i+1)*grid+(j%grid);
      triangles[count+2]=(i+1)*grid+((j+1)%grid);
      triangles[count+3]=i*grid+(j%grid);
      triangles[count+4]=(i+1)*grid+((j+1)%grid);
      triangles[count+5]=i*grid+((j+1)%grid);
      count+=6;
    }
  }
  
  
  String[] s=new String[verties.length+triangles.length/3+1];
  //s[0]=str(verties.length)+" "+str(triangles.length/3);
  for(int i=0;i<verties.length;i+=1){
    s[i]="v "+str(verties[i].x)+" "+str(verties[i].y)+" "+str(verties[i].z);
  }
  count=0;
  for(int j=verties.length;j<s.length-1;j+=1){
    s[j]="f"+" "+str(triangles[count]+1)+" "+str(triangles[count+1]+1)+" "+str(triangles[count+2]+1);
    count+=3;
  }
  saveStrings("sphere"+str(grid)+".obj",s);

}


static class Vector3{
  float x,y,z,h;
  float[] f=new float[4];
  Vector3(){
    x=0;
    y=0;
    x=0;
    h=1;
    init();
  }
  Vector3(float x,float y,float z){
    this.x=x;
    this.y=y;
    this.z=z;
    this.h=1;
    init();
  }
  Vector3(float x,float y,float z,float h){
    this.x=x;
    this.y=y;
    this.z=z;
    this.h=h;
    init();
  }
  Vector3(float[] f){
    this.x=f[0];
    this.y=f[1];
    this.z=f[2];
    this.h=f[3];
    this.f=f;
  }
  
  void init(){
    f[0]=this.x;
    f[1]=this.y;
    f[2]=this.z;
    f[3]=this.h;
  
  }
  
  public static Vector3 add(Vector3 v,Vector3 u){
    return new Vector3(v.x+u.x,v.y+u.y,v.z+u.z);
  }
  public static Vector3 sub(Vector3 v,Vector3 u){
    return new Vector3(v.x-u.x,v.y-u.y,v.z-u.z);
  }
  public static Vector3 mult(Vector3 v,float r){
    return new Vector3(v.x*r,v.y*r,v.z*r);
  }
  public static float dot(Vector3 v,Vector3 u){
    return v.x*u.x+v.y*u.y+v.z*u.z+v.h*u.h;
  }
  public static float dot3(Vector3 v,Vector3 u){
    return v.x*u.x+v.y*u.y+v.z*u.z;
  }
  public static Vector3 product(Vector3 v,Vector3 u){
    return new Vector3(v.x*u.x,v.y*u.y,v.z*u.z,v.h*u.h);
  }
  
   public static Vector3 cross(Vector3 a, Vector3 b) {
    Vector3 result=new Vector3();
    result.x=a.y*b.z-a.z*b.y;
    result.y=a.z*b.x-a.x*b.z;
    result.z=a.x*b.y-a.y*b.x;
    return result;
  }
  public void normalize() {
    float r=length();
    x/=r;
    y/=r;
    z/=r;
  }
  public void perspective(){
    this.x/=h;
    this.y/=h;
    this.z/=h;
    this.h=1;
  }
  public Vector3 norm() {
    float r=length();
    return new Vector3(x/r,y/r,z/r);
  }
  @Override
  public String toString(){
    return String.format("x : "+ x  +" y : " + y+" z : "+z+" h : "+h);
  }
  
  Vector3 copy(){  
    return new Vector3(x,y,z);
  }
  public float length_squared(){
    return x*x+y*y+z*z; 
  }
  float length(){
    return sqrt(this.length_squared());
  }
  
}
