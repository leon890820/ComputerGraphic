public class Light extends GameObject{

    public Vector3 light_dir;
    public Vector3 light_color;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc,String mesh,Material m) {
        this.pos = pos;
        this.light_dir = ld;
        this.light_color = lc;
        this.setShape(mesh).setMaterial(m);
        
        init();
    }
    
    
    public Light setLightColor(Vector3 v){
        this.light_color = v;
        return this;
    }
    
    public Light setLightColor(float x,float y,float z){
        this.light_color.set(x,y,z);
        return this;
    }
    
    public Light setLightdirection(Vector3 v){
        this.light_dir = v;
        return this;
    }
    
    public Light setLightdirection(float x,float y,float z){
        this.light_dir.set(x,y,z);
        return this;
    }
    
    @Override
    public void draw(){
        material.setGameobject(this);
        material.shader.bind(); 
        
        material.run();   
        run();
        
        material.shader.unbind();

    }
    
}
