class Engine{
  ArrayList<Object> v_objects=new ArrayList<Object>();
  
  ArrayList<Scene> v_scenes=new ArrayList<Scene>();
  Player player;
  Scene curScene;
  
  Engine(){
    player=new Player();
    player.reset();
    v_scenes.add(new Level1());
    
    loadScene(0);
    
  }
  
  void run(){
    update();
     
    main_cam.worldView=player.worldToCam();
    main_cam.setSize(width,height,GH_MIN_CLIPPING,GH_FAR);
    
    render();
    
  }
  
  void update(){
   
    for(Object o:v_objects){
      o.update();
    }
    
    for(int i=0;i<v_objects.size();++i){
      Physical physical=v_objects.get(i).asPhysical();
      if(physical==null) continue;
      Matrix4 worldToLocal=physical.worldToLocal();
      
      for(int j=0;j<v_objects.size();++j){
        if(i==j) continue;
        Object obj=v_objects.get(j);
        if(obj.mesh==null)continue;
        
        for(int s=0;s<physical.hit_spheres.size();++s){
          Sphere sphere=physical.hit_spheres.get(s);
          Matrix4 worldToUnit=sphere.localToUnit().mult(worldToLocal);
          Matrix4 localToUnit=worldToUnit.mult(obj.localToWorld());
          Matrix4 unitToWorld=worldToUnit.Inverse();
          
          for(int c=0;c<obj.mesh.colliders.size();++c){
           
            Vector3 push=new Vector3();
            Collider collider=obj.mesh.colliders.get(c);
            if(collider.collide(localToUnit,push)){
              
              push=unitToWorld.MulDirection(push);              
              obj.onHit(physical,push);
              physical.onCollide(obj,push);
              
              worldToLocal=physical.worldToLocal();
              worldToUnit=sphere.localToUnit().mult(worldToLocal);
              localToUnit=worldToUnit.mult(obj.localToWorld());
              unitToWorld=worldToUnit.Inverse();
            
            }
            
            
          
          }
        
        }
        
      }
      
    }
    
    
    
    
  }
  
  void render(){
    for(Object o:v_objects){
      o.Draw();
    }
    
  
  }
  
  void loadScene(int i){
    v_objects.clear();
    
    player.reset();
    
    curScene=v_scenes.get(i);
    curScene.load(v_objects,player);
    
    v_objects.add(player);
  }
  



}
