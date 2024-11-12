abstract interface Scene{
  abstract void load(ArrayList<Object> objs);

}

class Level1 implements Scene{
  
  void load(ArrayList<Object> objs){      
      Capsule cap = new Capsule(); 
      cap.setPos(new Vector3(2,2.5,0));
      //objs.add(cap);
      
      Knot knot = new Knot();
      knot.setScale(new Vector3(0.1,0.1,0.1));
      knot.setEular(new Vector3(PI/2,0,0));
      
      Gura gura = new Gura();
      gura.setScale(new Vector3(0.03,0.03,0.03));
      gura.setEular(new Vector3(0,0,PI));
      gura.setPos(new Vector3(0,2.6,0));
      
      Quad quad = new Quad();
      quad.setEular(new Vector3(PI/2,0,0));
      quad.setPos(new Vector3(0,2.6,0));
      quad.setScale(new Vector3(4,4,1));      
      objs.add(gura);
      objs.add(quad);
  }
}
