public class ShadowObject extends GameObject{
    
    
    public ShadowObject(String mesh){
        shape = loadShape(mesh);
    }
    
    public ShadowObject(String mesh,Material m){
        shape = loadShape(mesh);
        material = m;
    }
    
    

    
    @Override
    public void draw(){
        material.setGameobject(this);
        material.run();           
        shape(shape);
    }
    

}
