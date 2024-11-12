class Sphere{
  Vector3 center;
  float radius;
  Sphere(float r){
    center=new Vector3(0);
    radius=r;
  }
  Sphere(Vector3 pos,float r){
    center=pos;
    radius=r;
  }
  
  Matrix4 unitToLocal(){
    return Matrix4.Trans(center).mult(Matrix4.Scale(radius));
  }
  
  Matrix4 localToUnit(){
    return Matrix4.Scale(1/radius).mult(Matrix4.Trans(center.mult(-1)));
  }

}
