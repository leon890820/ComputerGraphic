class Particle{
    private float radius = 5;
    public Vector3 position;
    public Vector3 velocity;
    public Vector3 acceleration;
    
    public Particle(float x,float y){
        position = new Vector3(x,y,0);     
        init();
    }
    
    public Particle(float x,float y,float r){
        position = new Vector3(x,y,0);
        radius = r;
        init();
    }
    
    public void init(){
        velocity = new Vector3();
        acceleration = new Vector3();
    }
    
    public void update(){
        addForce();   
        //println(velocity.add(acceleration.mult(delta_time)));
        position = position.add(velocity.mult(delta_time));
        velocity = velocity.add(acceleration.mult(delta_time));  
        velocity = velocity.mult(dump);
        if(position.y>1){
            velocity = velocity.mult(-1);
            //position.y = 1.0;           
        }
         
    }
    
    public void addForce(){
        acceleration = acceleration.mult(0);
        acceleration = acceleration.add(gravity);
        
    }
    
    public void run(){
        update();
        show();
    }
    
    public void show(){
        noStroke();
        float x = map(position.x,0,1,0,width);
        float y = map(position.y,0,1,0,height);
        circle(x,y,radius);
    }
    
    

}
