abstract interface Scene {
    abstract void load(ArrayList<GObject> objs);
}

class Level1 implements Scene {

    void load(ArrayList<GObject> objs) {
       Cube1 cube1 = new Cube1();
       //cube1.scale = new Vector3(0.03,0.03,0.03);
       cube1.eular = new Vector3(0,0,0);
       objs.add(cube1);
       
       Cube cube = new Cube();
       cube.pos = light.pos;
       cube.scale = new Vector3(0.3,0.3,0.3);
       objs.add(cube);
    }
}
