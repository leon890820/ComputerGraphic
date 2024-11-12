public class Light {
    public Vector3 pos;
    public Vector3 light_dir;
    public Vector3 light_color;

    public Light(Vector3 pos, Vector3 ld, Vector3 lc) {
        this.pos = pos;
        this.light_dir = ld;
        this.light_color = lc;
    }
    
    public Light setPos(Vector3 v){
        this.pos = v;
        return this;
        
    }
    public Light setPos(float x,float y,float z){
        this.pos.set(x,y,z);
        return this;
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
    
}
