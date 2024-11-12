class Player extends Physical{
  float cam_rx;
  float cam_ry;
  float bob_mag;
  float bob_phi;
  boolean on_ground;
  Vector3 dir=new Vector3();
  Player(){
    reset();
    hit_spheres.add(new Sphere(new Vector3(0,0,0),GH_PLAYER_RADIUS));
    hit_spheres.add(new Sphere(new Vector3(0,GH_PLAYER_RADIUS - GH_PLAYER_HEIGHT,0),GH_PLAYER_RADIUS));
  }
  
  @Override
  public void Draw(){
  
  }
  
  @Override
 public  void reset(){
    super.reset();
    cam_rx=0;
    cam_ry=0;
    bob_mag=0;
    bob_phi=0;
    friction=0.08;
    drag=0.002;
    on_ground=true;
    
  }
  @Override
  public void update(){
    
    float magT=prev_pos.sub(pos).norm()/(GH_DT*p_scale);
    if(!on_ground) magT=0;
    bob_mag=bob_mag*(1-GH_BOB_DAMP)+magT*GH_BOB_DAMP;
    if(bob_mag<GH_BOB_MIN){
      bob_phi=0;
    }else{
      bob_phi+=GH_BOB_FREQ*GH_DT;
      if(bob_phi>2*PI){
        bob_phi-=2*PI;
      }
    }
    
    super.update();
    
    float mouse_dx=mouseX-pmouseX;
    float mouse_dy=mouseY-pmouseY;
    look(-mouse_dx,-mouse_dy);
    float moveF=0;
    float moveL=0;
    if(key_input[0]) moveF+=1;
    if(key_input[2]) moveF-=1;
    if(key_input[1]) moveL+=1;
    if(key_input[3]) moveL-=1;
    move(moveF,moveL);
    on_ground=false;
    dir=new Vector3(cos(engine.player.cam_rx)*cos(engine.player.cam_ry),sin(engine.player.cam_rx),cos(engine.player.cam_rx)*sin(engine.player.cam_ry));
    velocity=velocity.mult(0.9);
  }
  @Override
  public void onCollide(Object other,Vector3 push){
    Vector3 new_push=push.copy();
    if(push.unit_vector().y>0.7f){
      new_push.x=0;
      new_push.z=0;
      on_ground=true;
    }
    
    float cur_friction=friction;
    if(!on_ground) friction=0;
    super.onCollide(other,new_push);
    friction=cur_friction;
    
  }
  
  void look(float mouseDx,float mouseDy){
    cam_rx += mouseDy * GH_MOUSE_SENSITIVITY;
  if (cam_rx > PI / 2+PI) {
    cam_rx = PI / 2+PI;
  } else if (cam_rx < -PI / 2+PI) {
    cam_rx = -PI / 2+PI;
  }

  //Adjust y-axis rotation
  cam_ry += mouseDx * GH_MOUSE_SENSITIVITY;
  if (cam_ry > PI) {
    cam_ry -= PI * 2;
  } else if (cam_ry < -PI) {
    cam_ry += PI * 2;
  }
  }
  void move(float moveF,float moveL){
    float mag=sqrt(moveF*moveF+moveL*moveL);
    if(mag>1){
      moveF/=mag;
      moveL/=mag;
    }
    
    
    Matrix4 camToWorld=localToWorld().mult(Matrix4.RotY(cam_ry));
    velocity=velocity.add(camToWorld.MulDirection(new Vector3(-moveL,0,-moveF).mult(GH_WALK_ACCEL*GH_DT)));
    float tempY=velocity.y;
    velocity.y=0;
    velocity.clipMag(p_scale*GH_WALK_SPEED);
    velocity.y=tempY;
  }
  
  Matrix4 worldToCam(){
    return Matrix4.RotX(-cam_rx).mult(Matrix4.RotY(-cam_ry)).mult(Matrix4.Trans(camOffset().mult(-1))).mult(worldToLocal());
  }
  
  Matrix4 camToWorld(){
    return localToWorld().mult(Matrix4.Trans(camOffset())).mult(Matrix4.RotY(cam_ry)).mult(Matrix4.RotX(cam_rx));
  }
  Vector3 camOffset(){
    if(bob_mag<GH_BOB_MIN) return Vector3.Zero();
    float theta=PI/2*sin(bob_phi);
    float y=bob_mag*GH_BOB_OFFS*(1-cos(theta));
    return new Vector3(0,y,0);
  }

  
  
}
