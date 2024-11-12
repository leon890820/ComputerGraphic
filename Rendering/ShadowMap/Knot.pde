class Capsule extends ShadowMapObject{
  Capsule(){
    super("capsule.obj");    
  }
   
}

class Knot extends ShadowMapObject{
  Knot(){
    super("Knot.obj");    
  }
  
  
  void update(){
    setEular(eular.add(new Vector3(0,0.1,0)));
  }
}

class Quad extends ShadowMapObject{
  Quad(){
    super("quad.obj");
  }
  
  @Override
  public void update(){
    setPos(pos.add(new Vector3(0,-0.0,0)));
  }
  
}


class Gura extends ShadowMapObject{
  Gura(){
    super("mona.obj");
  }
  
  @Override
  public void update(){
    setEular(eular.add(new Vector3(0,0.1,0)));
  }
}
