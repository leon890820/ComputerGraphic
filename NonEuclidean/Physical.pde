abstract class Physical extends Object{
  Vector3 gravity=new Vector3();
  Vector3 velocity=new Vector3();
  float bounce;
  float friction;
  float hight_friction;
  float drag;
  Vector3 prev_pos=new Vector3();
  ArrayList<Sphere> hit_spheres=new ArrayList<Sphere>();
  
  Physical(){
    reset();
  }
  @Override
  public void reset(){
    super.reset();
    velocity.setZero();
    gravity.set(0,GH_GRAVITY,0);
    bounce=0;
    friction=0;
    hight_friction=0;
    drag=0;
    prev_pos.setZero();
  }
  
  @Override
  public void update(){
    prev_pos=pos.copy();
    velocity=velocity.add(gravity.mult(p_scale*GH_DT));
    velocity=velocity.mult(1-drag);
    pos=pos.add(velocity.mult(GH_DT));
  }
  

  
  void onCollide(Object other,Vector3 push){
    pos=pos.add(push);
   
    if(push.magSq()<1e-8f*p_scale) return;
    
    float kinectic_friction=friction;
    if(hight_friction>0){
      float vel_ratio=velocity.norm()/(hight_friction*p_scale);
      kinectic_friction=min(1,friction*(vel_ratio+5)/(vel_ratio+1));
    }
    
  
    
    Vector3 push_proj=push.mult(Vector3.dot(velocity,push)/Vector3.dot(push,push));
    velocity=((velocity.sub(push_proj)).mult(1-kinectic_friction)).sub(push_proj.mult(bounce));
    
    
  }
  
  void setPosition(Vector3 _pos){
    pos=_pos.copy();
    prev_pos.copy();
  }
  
    
    
    
    
  
  @Override
  public Physical asPhysical(){
    return this;
  }
  

}
