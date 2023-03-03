class Camera{
  Vector3 eye_position;
  Vector3 view_location;
  Vector3 up_vector;
  Camera(Vector3 ep,Vector3 vl){
    eye_position=ep;
    view_location=vl;
    up_vector=Vector3.add(vl,new Vector3(0,1,0));
  }
  Camera(){
    eye_position=new Vector3();
    view_location=new Vector3();
  
  }
  
  
  



}
