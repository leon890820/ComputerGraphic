class Engine{
  ArrayList<Object> v_objects=new ArrayList<Object>();
  ArrayList<Scene> v_scenes=new ArrayList<Scene>();
  Camera light_cam;
  Scene curScene;
  
  Engine(){
    v_scenes.add(new Level1());
        
    loadScene(0);
    
  }
  float a = 0;
  
  void run(){
    update();
    main_cam.setPositionOrientation(new Vector3(0,0,0),0,0);
    main_cam.setSize(width,height,GH_MIN_CLIPPING,GH_FAR);   
    
    
    light_cam.setPositionOrientation(light.pos,light.light_dir);
    light_cam.setSize(width,height,GH_MIN_CLIPPING,GH_FAR);
    render();   
  }
  
  void update(){
    v_objects.forEach(Object::update);      
  }
  
  void render(){
    v_objects.forEach(Object::Pass1);
    v_objects.forEach(Object::Pass2);      
  }
  
  void loadScene(int i){
    v_objects.clear();    
    curScene=v_scenes.get(i);
    curScene.load(v_objects);
    
    light_cam = new Camera();
    light_cam.setPositionOrientation(light.pos,light.light_dir);
    light_cam.setSize(width,height,GH_MIN_CLIPPING,GH_FAR);
    
  }
  
}
