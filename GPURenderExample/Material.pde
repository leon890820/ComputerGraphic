public abstract class Material{
    PShader shader;
    GameObject gameobject;
    public Material(String frag){
         shader = loadShader(frag);
    }
    
    public Material(String frag,String vert){
         shader = loadShader(frag,vert);
    }
    
    public void setGameobject(GameObject g){
        gameobject = g;
    }
    

    
    abstract void run();

}


public class PhongMaterial extends Material{
    Vector3 albedo = new Vector3(0.0);
    Matrix4 light_MVP;
    Texture depth_texture;
    Texture texture;
    
    public PhongMaterial(String frag){
         super(frag);
    }
    public PhongMaterial(String frag,String vert){
         super(frag,vert);
    }
    
    public PhongMaterial setAlbedo(Vector3 v){
        albedo = v;
        return this;
    }
    
    public PhongMaterial setAlbedo(float x,float y,float z){
        albedo.set(x,y,z);
        return this;
    }
    
    public PhongMaterial setDepthTexture(Texture t){
        depth_texture = t;
        return this;
    }
    
    public PhongMaterial setTexture(Texture t){
        texture = t;
        return this;
    }
    
    public PhongMaterial setLightMVP(Matrix4 m){
        light_MVP = m;
        return this;
    }
    
    
     public void run(){
         shader(shader);
         shader.set("MVP",gameobject.MVP().transposed().toPMatrix());
                
         shader.set("modelMatrix", gameobject.localToWorld().transposed().toPMatrix());
         shader.set("light_dir",main_light.light_dir.x,main_light.light_dir.y,main_light.light_dir.z);
        
         shader.set("ambient_light",AMBIENT_LIGHT.x,AMBIENT_LIGHT.y,AMBIENT_LIGHT.z);
         shader.set("albedo", albedo.x, albedo.y, albedo.z);
         shader.set("light_color", main_light.light_color.x, main_light.light_color.y, main_light.light_color.z);
         shader.set("view_pos", main_camera.pos.x,main_camera.pos.y,main_camera.pos.z);    

        
         if(texture!=null)shader.set("tex",texture.img);
     }

}