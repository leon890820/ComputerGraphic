abstract class Object{
  Vector3 pos;
  Vector3 eular;
  Vector3 scale;
  float p_scale;
  Mesh mesh;
  Texture texture;
  
  
  Object(){
    pos=new Vector3(0);
    eular=new Vector3(0);
    scale=new Vector3(1);
    p_scale=1;
  }
  void reset(){
    pos.setZero();
    eular.setZero();
    scale.setOnes();
    p_scale=1;
  }
  
  void setPos(Vector3 v){
    pos = v;
  }
  
  void setEular(Vector3 v){
    eular = v;
  }
  void setScale(Vector3 v){
    scale = v;
  }
  
 
  abstract public void Draw();  
  public void Pass1(){};
  public void Pass2(){};
  public void update(){};
  void debugDraw(){}
 
 
 
  Matrix4 localToWorld(){
    return Matrix4.Trans(pos).mult(Matrix4.RotY(eular.y)).mult(Matrix4.RotX(eular.x)).mult(Matrix4.RotZ(eular.z)).mult(Matrix4.Scale(scale));     
  }
  Matrix4 worldToLocal(){
    return Matrix4.Scale(scale.mult(p_scale).inv()).mult(Matrix4.RotZ(-eular.z)).mult(Matrix4.RotX(-eular.x)).mult(Matrix4.RotY(-eular.y)).mult(Matrix4.Trans(pos.mult(-1)));
  }
  Vector3 forward(){
    return (Matrix4.RotZ(eular.z).mult(Matrix4.RotX(eular.y)).mult(Matrix4.RotY(eular.x)).zAxis()).mult(-1);
  }
  


}
