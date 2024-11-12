class Engine {
    ArrayList<Object> v_objects=new ArrayList<Object>();
    ArrayList<Scene> v_scenes=new ArrayList<Scene>();
    Camera light_cam;
    Scene curScene;

    Engine() {
        v_scenes.add(new Level1());

        loadScene(0);
    }
    float a = 0;

    void run() {
        update();
        main_cam.setPositionOrientation(new Vector3(0, 0, 0), 0, 0);
        main_cam.setSize(width, height, GH_MIN_CLIPPING, GH_FAR);


        light_cam.setPositionOrientation(light.pos, light.light_dir);
        light_cam.setSize(width, height, GH_MIN_CLIPPING, GH_FAR);
        render();
    }

    void update() {
        v_objects.forEach(Object::update);
    }

    void render() {
        v_objects.forEach(Object::Draw);
    }

    void loadScene(int i) {
        v_objects.clear();
        curScene=v_scenes.get(i);
        curScene.load(v_objects);

        light_cam = new Camera();
        light_cam.setPositionOrientation(light.pos, light.light_dir);
        light_cam.setSize(width, height, GH_MIN_CLIPPING, GH_FAR);
    }
    
    public boolean intersection(Vector3 p,Vector3 dir){
      for(int i=0;i<v_objects.size();i+=1){
        Mesh mesh = v_objects.get(i).mesh;
        for(int j=0;j<mesh.triangles.size();i+=1){
          Triangle triangle = mesh.triangles.get(j);
          if(intersectionTriangle(p,dir,triangle.verts)){
            return true;
          }
        }
      }
      return false;
    }
}
