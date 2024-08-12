abstract interface Scene {
    abstract void load(ArrayList<GObject> objs);
}

class Level1 implements Scene {

    void load(ArrayList<GObject> objs) {
        Ball ball1 = new Ball();
        ball1.setScale(new Vector3(0.05,0.05,0.05));
        ball1.setPos(new Vector3(-4,0,0));
        ball1.roughness = 0.1;
        objs.add(ball1);
                
        Ball ball2 = new Ball();
        ball2.setScale(new Vector3(0.05,0.05,0.05));
        ball2.setPos(new Vector3(-2,0,0));
        ball2.roughness = 0.3;
        objs.add(ball2);
                
        Ball ball3 = new Ball();
        ball3.setScale(new Vector3(0.05,0.05,0.05));
        ball3.setPos(new Vector3(0,0,0));
        ball3.roughness = 0.5;
        objs.add(ball3);
        
        Ball ball4 = new Ball();
        ball4.setScale(new Vector3(0.05,0.05,0.05));
        ball4.setPos(new Vector3(2,0,0));
        ball4.roughness = 0.7;
        objs.add(ball4);
        
        Ball ball5 = new Ball();
        ball5.setScale(new Vector3(0.05,0.05,0.05));
        ball5.setPos(new Vector3(4,0,0));
        ball5.roughness = 0.9;
        objs.add(ball5);
    }
}
