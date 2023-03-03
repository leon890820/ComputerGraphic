abstract class Scene{
  abstract void load(ArrayList<Object> objs,Player player);

}

class Level1 extends Scene{
  
  void load(ArrayList<Object> objs,Player player){
      
      
        
      //SphereObj sphere=new SphereObj();
      
      //objs.add(sphere);
      //Quad quad=new Quad();      
      //objs.add(quad);
      
      Quad quad1=new Quad();
      quad1.eular=new Vector3(0,PI/2,0);
      quad1.pos=new Vector3(1,0,1);
      //objs.add(quad1);
      
      Quad quad2=new Quad();   
      quad2.eular=new Vector3(0,PI/2,0);
      quad2.pos=new Vector3(0,0,0);
      //objs.add(quad2);
      
      Quad quad3=new Quad();    
      quad1.eular=new Vector3(0,0,PI/2);
     //objs.add(quad3);
      
      Capsule capsule=new Capsule();
      capsule.pos=new Vector3(0,2,0);
      objs.add(capsule);
      
      
      
      player.setPosition(new Vector3(0,0,-2));
  
  }
}
